#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${DMMS_AI_IMAGE:-${CLAWDBOT_IMAGE:-dmms-ai:local}}"
CONFIG_DIR="${DMMS_AI_CONFIG_DIR:-${CLAWDBOT_CONFIG_DIR:-$HOME/.dmms-ai}}"
WORKSPACE_DIR="${DMMS_AI_WORKSPACE_DIR:-${CLAWDBOT_WORKSPACE_DIR:-$HOME/.dmms-ai/workspace}}"
PROFILE_FILE="${DMMS_AI_PROFILE_FILE:-${CLAWDBOT_PROFILE_FILE:-$HOME/.profile}}"

PROFILE_MOUNT=()
if [[ -f "$PROFILE_FILE" ]]; then
  PROFILE_MOUNT=(-v "$PROFILE_FILE":/home/node/.profile:ro)
fi

echo "==> Build image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" -f "$ROOT_DIR/Dockerfile" "$ROOT_DIR"

echo "==> Run live model tests (profile keys)"
docker run --rm -t \
  --entrypoint bash \
  -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  -e HOME=/home/node \
  -e NODE_OPTIONS=--disable-warning=ExperimentalWarning \
  -e DMMS_AI_LIVE_TEST=1 \
  -e DMMS_AI_LIVE_MODELS="${DMMS_AI_LIVE_MODELS:-${CLAWDBOT_LIVE_MODELS:-all}}" \
  -e DMMS_AI_LIVE_PROVIDERS="${DMMS_AI_LIVE_PROVIDERS:-${CLAWDBOT_LIVE_PROVIDERS:-}}" \
  -e DMMS_AI_LIVE_MODEL_TIMEOUT_MS="${DMMS_AI_LIVE_MODEL_TIMEOUT_MS:-${CLAWDBOT_LIVE_MODEL_TIMEOUT_MS:-}}" \
  -e DMMS_AI_LIVE_REQUIRE_PROFILE_KEYS="${DMMS_AI_LIVE_REQUIRE_PROFILE_KEYS:-${CLAWDBOT_LIVE_REQUIRE_PROFILE_KEYS:-}}" \
  -v "$CONFIG_DIR":/home/node/.dmms-ai \
  -v "$WORKSPACE_DIR":/home/node/.dmms-ai/workspace \
  "${PROFILE_MOUNT[@]}" \
  "$IMAGE_NAME" \
  -lc "set -euo pipefail; [ -f \"$HOME/.profile\" ] && source \"$HOME/.profile\" || true; cd /app && pnpm test:live"
