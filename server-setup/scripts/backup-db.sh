#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/opt/dryads-bot/backups"
RETENTION_DAYS=7
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_FILE="$BACKUP_DIR/dryads_${TIMESTAMP}.sql.gz"

# Load DATABASE_URL from .env
if [ -f /opt/dryads-bot/.env ]; then
  DATABASE_URL=$(grep '^DATABASE_URL=' /opt/dryads-bot/.env | cut -d'=' -f2- | tr -d '"' | tr -d "'")
fi

if [ -z "${DATABASE_URL:-}" ]; then
  echo "[$(date)] ERROR: DATABASE_URL not set" >&2
  exit 1
fi

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting backup -> $BACKUP_FILE"
pg_dump "$DATABASE_URL" | gzip > "$BACKUP_FILE"

FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "[$(date)] Backup complete: $BACKUP_FILE ($FILE_SIZE)"

# Prune old backups
DELETED=$(find "$BACKUP_DIR" -name "dryads_*.sql.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)
if [ "$DELETED" -gt 0 ]; then
  echo "[$(date)] Pruned $DELETED old backup(s)"
fi
