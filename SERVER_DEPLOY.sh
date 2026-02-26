#!/usr/bin/env bash
#
# Dryads AI — Full Server Deploy Script
# ======================================
# Copy-paste this ENTIRE script into your SSH session on 147.182.236.61
#
# What it does:
#   1. Moves /opt/dmms-bot → /opt/dryads-bot (if old name exists)
#   2. Pulls latest code from GitHub (with the rebrand)
#   3. Rebuilds the project
#   4. Copies server-setup configs into place
#   5. Runs the full production hardening setup
#
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✗]${NC} $*" >&2; }

echo ""
echo "================================================"
echo "  Dryads AI — Full Server Deploy"
echo "================================================"
echo ""

# ──────────────────────────────────────────
# Phase 1: Rename directory if needed
# ──────────────────────────────────────────
if [ -d /opt/dmms-bot ] && [ ! -d /opt/dryads-bot ]; then
  warn "Renaming /opt/dmms-bot → /opt/dryads-bot"

  # Stop existing PM2 processes first
  pm2 stop all 2>/dev/null || true
  pm2 delete all 2>/dev/null || true

  mv /opt/dmms-bot /opt/dryads-bot
  log "Directory renamed"
elif [ -d /opt/dryads-bot ]; then
  log "Directory /opt/dryads-bot already exists"
elif [ -d /opt/dmms-bot ]; then
  warn "Both /opt/dmms-bot and /opt/dryads-bot exist — using /opt/dryads-bot"
else
  err "No app directory found! Clone the repo first:"
  err "  git clone https://github.com/DMMSAI/dmms-ai.git /opt/dryads-bot"
  exit 1
fi

APP_DIR="/opt/dryads-bot"
cd "$APP_DIR"

# ──────────────────────────────────────────
# Phase 2: Pull latest code
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Phase 2: Pulling latest code${NC}"
git fetch origin main
git reset --hard origin/main
log "Code updated to latest"

# ──────────────────────────────────────────
# Phase 3: Install dependencies & build
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Phase 3: Install & Build${NC}"
npm ci --omit=dev 2>&1 | tail -5
log "Dependencies installed"

if grep -q '"build"' package.json 2>/dev/null; then
  npm run build 2>&1 | tail -10
  log "Build complete"
fi

# ──────────────────────────────────────────
# Phase 4: Create required directories
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Phase 4: Setup directories${NC}"
mkdir -p "$APP_DIR/logs" "$APP_DIR/scripts" "$APP_DIR/backups"
log "Created logs/, scripts/, backups/"

# ──────────────────────────────────────────
# Phase 5: Run the production setup script
# ──────────────────────────────────────────
echo -e "\n${YELLOW}Phase 5: Production hardening${NC}"
if [ -d "$APP_DIR/server-setup" ]; then
  bash "$APP_DIR/server-setup/setup-server.sh"
else
  err "server-setup/ directory not found in the repo!"
  exit 1
fi

echo ""
echo "================================================"
echo "  Deploy complete!"
echo "================================================"
echo ""
echo "Verify:"
echo "  curl https://test.dryads.ai/api/health"
echo "  pm2 status"
echo "  ufw status"
echo ""
