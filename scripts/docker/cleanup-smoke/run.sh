#!/usr/bin/env bash
set -euo pipefail

cd /repo

export DMMS_AI_STATE_DIR="/tmp/dmms-ai-test"
export DMMS_AI_CONFIG_PATH="${DMMS_AI_STATE_DIR}/dmms-ai.json"

echo "==> Build"
pnpm build

echo "==> Seed state"
mkdir -p "${DMMS_AI_STATE_DIR}/credentials"
mkdir -p "${DMMS_AI_STATE_DIR}/agents/main/sessions"
echo '{}' >"${DMMS_AI_CONFIG_PATH}"
echo 'creds' >"${DMMS_AI_STATE_DIR}/credentials/marker.txt"
echo 'session' >"${DMMS_AI_STATE_DIR}/agents/main/sessions/sessions.json"

echo "==> Reset (config+creds+sessions)"
pnpm dmms-ai reset --scope config+creds+sessions --yes --non-interactive

test ! -f "${DMMS_AI_CONFIG_PATH}"
test ! -d "${DMMS_AI_STATE_DIR}/credentials"
test ! -d "${DMMS_AI_STATE_DIR}/agents/main/sessions"

echo "==> Recreate minimal config"
mkdir -p "${DMMS_AI_STATE_DIR}/credentials"
echo '{}' >"${DMMS_AI_CONFIG_PATH}"

echo "==> Uninstall (state only)"
pnpm dmms-ai uninstall --state --yes --non-interactive

test ! -d "${DMMS_AI_STATE_DIR}"

echo "OK"
