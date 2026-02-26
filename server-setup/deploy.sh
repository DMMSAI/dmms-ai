#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/dryads-bot"
LOG_FILE="$APP_DIR/logs/deploy.log"
HEALTH_URL="http://127.0.0.1:3001/api/health"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "=== Deploy started ==="

cd "$APP_DIR"

# Pull latest changes
BEFORE=$(git rev-parse HEAD)
git pull --ff-only 2>&1 | tee -a "$LOG_FILE"
AFTER=$(git rev-parse HEAD)

if [ "$BEFORE" = "$AFTER" ]; then
  log "Already up to date ($BEFORE). Skipping build."
  exit 0
fi

log "Updated $BEFORE -> $AFTER"

# Install dependencies
log "Installing dependencies..."
npm ci --omit=dev 2>&1 | tail -5 | tee -a "$LOG_FILE"

# Build if there's a build script
if grep -q '"build"' package.json 2>/dev/null; then
  log "Building..."
  npm run build 2>&1 | tail -10 | tee -a "$LOG_FILE"
fi

# Restart processes
log "Restarting PM2 processes..."
pm2 restart ecosystem.config.cjs 2>&1 | tee -a "$LOG_FILE"

# Wait for startup
sleep 5

# Health check with retries
RETRIES=3
for i in $(seq 1 $RETRIES); do
  HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' "$HEALTH_URL" 2>/dev/null || echo "000")
  if [ "$HTTP_CODE" = "200" ]; then
    log "Health check passed (attempt $i)"
    break
  fi
  log "Health check failed with $HTTP_CODE (attempt $i/$RETRIES)"
  if [ "$i" -eq "$RETRIES" ]; then
    log "WARNING: Health check failed after $RETRIES attempts!"
    exit 1
  fi
  sleep 3
done

log "=== Deploy completed ==="
