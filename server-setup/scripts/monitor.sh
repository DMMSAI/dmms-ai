#!/usr/bin/env bash
set -euo pipefail

HEALTH_URL="http://127.0.0.1:3001/api/health"
LOG_FILE="/opt/dryads-bot/logs/monitor.log"
MAX_RETRIES=3

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"; }

# Check if PM2 processes are online
for PROC in dryads-bot dryads-web; do
  STATUS=$(pm2 jlist 2>/dev/null | node -e "
    const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
    const p = d.find(x => x.name === '$PROC');
    console.log(p ? p.pm2_env.status : 'missing');
  " 2>/dev/null || echo "error")

  if [ "$STATUS" != "online" ]; then
    log "WARN: $PROC status=$STATUS — restarting"
    pm2 restart "$PROC" 2>/dev/null || pm2 start /opt/dryads-bot/ecosystem.config.cjs --only "$PROC" 2>/dev/null
    sleep 3
  fi
done

# Hit health endpoint
HEALTHY=false
for i in $(seq 1 $MAX_RETRIES); do
  HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$HEALTH_URL" 2>/dev/null || echo "000")
  if [ "$HTTP_CODE" = "200" ]; then
    HEALTHY=true
    break
  fi
  sleep 2
done

if [ "$HEALTHY" = "false" ]; then
  log "ALERT: Health check failed after $MAX_RETRIES retries (last=$HTTP_CODE) — restarting all"
  pm2 restart ecosystem.config.cjs 2>/dev/null
fi
