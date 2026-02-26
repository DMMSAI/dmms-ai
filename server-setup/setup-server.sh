#!/usr/bin/env bash
#
# Dryads AI — Production Server Setup
# Run as root on 147.182.236.61
#
# Usage: bash setup-server.sh
#
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✗]${NC} $*"; }

APP_DIR="/opt/dryads-bot"
SETUP_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "========================================"
echo "  Dryads AI — Production Server Setup"
echo "========================================"
echo ""

# ──────────────────────────────────────────
# Step 1: Swap Memory (2GB)
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 1: Swap Memory${NC}"
if swapon --show | grep -q '/swapfile'; then
  log "Swap already active, skipping"
else
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  if ! grep -q '/swapfile' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
  fi
  sysctl vm.swappiness=10
  if ! grep -q 'vm.swappiness' /etc/sysctl.conf; then
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
  fi
  log "2GB swap created, swappiness=10"
fi

# ──────────────────────────────────────────
# Step 2: UFW Firewall
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 2: UFW Firewall${NC}"
if ufw status | grep -q "Status: active"; then
  log "UFW already active, skipping"
else
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow 22/tcp comment 'SSH'
  ufw allow 80/tcp comment 'HTTP'
  ufw allow 443/tcp comment 'HTTPS'
  echo "y" | ufw enable
  log "UFW enabled — ports 22, 80, 443 open"
fi

# ──────────────────────────────────────────
# Step 3: Fail2ban
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 3: Fail2ban${NC}"
if ! command -v fail2ban-client &>/dev/null; then
  apt-get update -qq && apt-get install -y -qq fail2ban
fi
cp "$SETUP_DIR/jail.local" /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl restart fail2ban
log "Fail2ban installed — 3 retries, 1hr ban"

# ──────────────────────────────────────────
# Step 4: Create directories
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 4: Directory structure${NC}"
mkdir -p "$APP_DIR/logs" "$APP_DIR/scripts" "$APP_DIR/backups"
log "Created logs/, scripts/, backups/"

# ──────────────────────────────────────────
# Step 5: PM2 Ecosystem Config
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 5: PM2 Ecosystem Config${NC}"
cp "$SETUP_DIR/ecosystem.config.cjs" "$APP_DIR/ecosystem.config.cjs"

# Stop existing ad-hoc processes
pm2 delete all 2>/dev/null || true

# Start with ecosystem file
cd "$APP_DIR"
pm2 start ecosystem.config.cjs
pm2 save
log "PM2 ecosystem config active"

# ──────────────────────────────────────────
# Step 6: Log Rotation
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 6: Log Rotation${NC}"
pm2 install pm2-logrotate 2>/dev/null || true
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
pm2 set pm2-logrotate:compress true
pm2 set pm2-logrotate:workerInterval 30
pm2 set pm2-logrotate:rotateInterval '0 0 * * *'

cp "$SETUP_DIR/logrotate-dryads" /etc/logrotate.d/dryads
log "PM2 log-rotate: 10MB/7 files. System logrotate for scripts."

# ──────────────────────────────────────────
# Step 7: Deploy Script
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 7: Deploy Script${NC}"
cp "$SETUP_DIR/deploy.sh" "$APP_DIR/deploy.sh"
chmod +x "$APP_DIR/deploy.sh"
log "Deploy script at $APP_DIR/deploy.sh"

# ──────────────────────────────────────────
# Step 8: Nginx Hardening
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 8: Nginx Hardening${NC}"

# Check if SSL certs exist, generate self-signed if not
if [ ! -f /etc/ssl/certs/dryads-selfsigned.crt ]; then
  warn "Generating self-signed SSL cert (Cloudflare terminates real SSL)"
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout /etc/ssl/private/dryads-selfsigned.key \
    -out /etc/ssl/certs/dryads-selfsigned.crt \
    -subj "/CN=test.dryads.ai" 2>/dev/null
fi

cp "$SETUP_DIR/nginx-dryads" /etc/nginx/sites-available/dryads

# Enable site if not already
if [ ! -L /etc/nginx/sites-enabled/dryads ]; then
  ln -sf /etc/nginx/sites-available/dryads /etc/nginx/sites-enabled/dryads
fi

# Remove default site and old dmms config if present
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-enabled/dmms

# Test and reload
nginx -t 2>&1
systemctl reload nginx
log "Nginx hardened with security headers, rate limiting, gzip"

# ──────────────────────────────────────────
# Step 9: Database Backups
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 9: Database Backups${NC}"
if ! command -v pg_dump &>/dev/null; then
  apt-get update -qq && apt-get install -y -qq postgresql-client
fi
cp "$SETUP_DIR/scripts/backup-db.sh" "$APP_DIR/scripts/backup-db.sh"
chmod +x "$APP_DIR/scripts/backup-db.sh"

# Add cron job (daily at 3 AM)
CRON_BACKUP="0 3 * * * /opt/dryads-bot/scripts/backup-db.sh >> /opt/dryads-bot/logs/backup.log 2>&1"
(crontab -l 2>/dev/null | grep -v 'backup-db.sh'; echo "$CRON_BACKUP") | crontab -
log "Database backup: daily at 3 AM, 7-day retention"

# ──────────────────────────────────────────
# Step 10: Monitor Script
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 10: Monitor Script${NC}"
cp "$SETUP_DIR/scripts/monitor.sh" "$APP_DIR/scripts/monitor.sh"
chmod +x "$APP_DIR/scripts/monitor.sh"

# Add cron job (every 2 minutes)
CRON_MONITOR="*/2 * * * * /opt/dryads-bot/scripts/monitor.sh 2>&1"
(crontab -l 2>/dev/null | grep -v 'monitor.sh'; echo "$CRON_MONITOR") | crontab -
log "Monitor: every 2 minutes, auto-restart on failure"

# ──────────────────────────────────────────
# Step 11: Webhook Auto-Deploy (optional)
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Step 11: Webhook Auto-Deploy${NC}"
cp "$SETUP_DIR/scripts/webhook-deploy.mjs" "$APP_DIR/scripts/webhook-deploy.mjs"

# Add webhook to PM2 ecosystem if not already there
if ! grep -q 'dryads-webhook' "$APP_DIR/ecosystem.config.cjs"; then
  warn "To enable webhook auto-deploy:"
  warn "  1. Add GITHUB_WEBHOOK_SECRET to .env"
  warn "  2. Add webhook process to ecosystem.config.cjs"
  warn "  3. Configure GitHub webhook to https://test.dryads.ai/webhook/deploy"
fi
log "Webhook script ready at $APP_DIR/scripts/webhook-deploy.mjs"

# ──────────────────────────────────────────
# Verification
# ──────────────────────────────────────────
echo ""
echo "========================================"
echo "  Verification"
echo "========================================"
echo ""

echo -n "Swap:      " && free -h | awk '/^Swap:/ {print $2}'
echo -n "UFW:       " && ufw status | head -1
echo -n "Fail2ban:  " && (fail2ban-client status sshd 2>/dev/null | grep "Currently banned" || echo "running")
echo -n "PM2:       " && pm2 jlist 2>/dev/null | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));console.log(d.map(p=>p.name+':'+p.pm2_env.status).join(', '))" 2>/dev/null || echo "check manually"
echo -n "Health:    " && (curl -s http://127.0.0.1:3001/api/health | head -c 100 || echo "not responding yet")
echo -n "Nginx:     " && (nginx -t 2>&1 | tail -1)
echo -n "Cron jobs: " && (crontab -l 2>/dev/null | grep -c 'dryads-bot' || echo "0") && echo " dryads-bot entries"

echo ""
log "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Push health endpoint code changes to git"
echo "  2. Run: /opt/dryads-bot/deploy.sh"
echo "  3. Verify: curl https://test.dryads.ai/api/health"
echo "  4. (Optional) Set up GITHUB_WEBHOOK_SECRET for auto-deploy"
echo ""
