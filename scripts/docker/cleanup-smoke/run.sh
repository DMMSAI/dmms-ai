#!/usr/bin/env bash
set -euo pipefail

cd /repo

export DRYADS_AI_STATE_DIR="/tmp/dryads-ai-test"
export DRYADS_AI_CONFIG_PATH="${DRYADS_AI_STATE_DIR}/dryads-ai.json"

echo "==> Build"
pnpm build

echo "==> Seed state"
mkdir -p "${DRYADS_AI_STATE_DIR}/credentials"
mkdir -p "${DRYADS_AI_STATE_DIR}/agents/main/sessions"
echo '{}' >"${DRYADS_AI_CONFIG_PATH}"
echo 'creds' >"${DRYADS_AI_STATE_DIR}/credentials/marker.txt"
echo 'session' >"${DRYADS_AI_STATE_DIR}/agents/main/sessions/sessions.json"

echo "==> Reset (config+creds+sessions)"
pnpm dryads-ai reset --scope config+creds+sessions --yes --non-interactive

test ! -f "${DRYADS_AI_CONFIG_PATH}"
test ! -d "${DRYADS_AI_STATE_DIR}/credentials"
test ! -d "${DRYADS_AI_STATE_DIR}/agents/main/sessions"

echo "==> Recreate minimal config"
mkdir -p "${DRYADS_AI_STATE_DIR}/credentials"
echo '{}' >"${DRYADS_AI_CONFIG_PATH}"

echo "==> Uninstall (state only)"
pnpm dryads-ai uninstall --state --yes --non-interactive

test ! -d "${DRYADS_AI_STATE_DIR}"

echo "OK"
