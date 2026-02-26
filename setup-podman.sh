#!/usr/bin/env bash
# One-time host setup for rootless Dryads AI in Podman: creates the dryads-ai
# user, builds the image, loads it into that user's Podman store, and installs
# the launch script. Run from repo root with sudo capability.
#
# Usage: ./setup-podman.sh [--quadlet|--container]
#   --quadlet   Install systemd Quadlet so the container runs as a user service
#   --container Only install user + image + launch script; you start the container manually (default)
#   Or set DRYADS_AI_PODMAN_QUADLET=1 (or 0) to choose without a flag.
#
# After this, start the gateway manually:
#   ./scripts/run-dryads-ai-podman.sh launch
#   ./scripts/run-dryads-ai-podman.sh launch setup   # onboarding wizard
# Or as the dryads-ai user: sudo -u dryads-ai /home/dryads-ai/run-dryads-ai-podman.sh
# If you used --quadlet, you can also: sudo systemctl --machine dryads-ai@ --user start dryads-ai.service
set -euo pipefail

DRYADS_AI_USER="${DRYADS_AI_PODMAN_USER:-dryads-ai}"
REPO_PATH="${DRYADS_AI_REPO_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
RUN_SCRIPT_SRC="$REPO_PATH/scripts/run-dryads-ai-podman.sh"
QUADLET_TEMPLATE="$REPO_PATH/scripts/podman/dryads-ai.container.in"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

is_root() { [[ "$(id -u)" -eq 0 ]]; }

run_root() {
  if is_root; then
    "$@"
  else
    sudo "$@"
  fi
}

run_as_user() {
  local user="$1"
  shift
  if command -v sudo >/dev/null 2>&1; then
    sudo -u "$user" "$@"
  elif is_root && command -v runuser >/dev/null 2>&1; then
    runuser -u "$user" -- "$@"
  else
    echo "Need sudo (or root+runuser) to run commands as $user." >&2
    exit 1
  fi
}

run_as_dryads-ai() {
  # Avoid root writes into $DRYADS_AI_HOME (symlink/hardlink/TOCTOU footguns).
  # Anything under the target user's home should be created/modified as that user.
  run_as_user "$DRYADS_AI_USER" env HOME="$DRYADS_AI_HOME" "$@"
}

# Quadlet: opt-in via --quadlet or DRYADS_AI_PODMAN_QUADLET=1
INSTALL_QUADLET=false
for arg in "$@"; do
  case "$arg" in
    --quadlet)   INSTALL_QUADLET=true ;;
    --container) INSTALL_QUADLET=false ;;
  esac
done
if [[ -n "${DRYADS_AI_PODMAN_QUADLET:-}" ]]; then
  case "${DRYADS_AI_PODMAN_QUADLET,,}" in
    1|yes|true)  INSTALL_QUADLET=true ;;
    0|no|false) INSTALL_QUADLET=false ;;
  esac
fi

require_cmd podman
if ! is_root; then
  require_cmd sudo
fi
if [[ ! -f "$REPO_PATH/Dockerfile" ]]; then
  echo "Dockerfile not found at $REPO_PATH. Set DRYADS_AI_REPO_PATH to the repo root." >&2
  exit 1
fi
if [[ ! -f "$RUN_SCRIPT_SRC" ]]; then
  echo "Launch script not found at $RUN_SCRIPT_SRC." >&2
  exit 1
fi

generate_token_hex_32() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 32
    return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import secrets
print(secrets.token_hex(32))
PY
    return 0
  fi
  if command -v od >/dev/null 2>&1; then
    # 32 random bytes -> 64 lowercase hex chars
    od -An -N32 -tx1 /dev/urandom | tr -d " \n"
    return 0
  fi
  echo "Missing dependency: need openssl or python3 (or od) to generate DRYADS_AI_GATEWAY_TOKEN." >&2
  exit 1
}

user_exists() {
  local user="$1"
  if command -v getent >/dev/null 2>&1; then
    getent passwd "$user" >/dev/null 2>&1 && return 0
  fi
  id -u "$user" >/dev/null 2>&1
}

resolve_user_home() {
  local user="$1"
  local home=""
  if command -v getent >/dev/null 2>&1; then
    home="$(getent passwd "$user" 2>/dev/null | cut -d: -f6 || true)"
  fi
  if [[ -z "$home" && -f /etc/passwd ]]; then
    home="$(awk -F: -v u="$user" '$1==u {print $6}' /etc/passwd 2>/dev/null || true)"
  fi
  if [[ -z "$home" ]]; then
    home="/home/$user"
  fi
  printf '%s' "$home"
}

resolve_nologin_shell() {
  for cand in /usr/sbin/nologin /sbin/nologin /usr/bin/nologin /bin/false; do
    if [[ -x "$cand" ]]; then
      printf '%s' "$cand"
      return 0
    fi
  done
  printf '%s' "/usr/sbin/nologin"
}

# Create dryads-ai user (non-login, with home) if missing
if ! user_exists "$DRYADS_AI_USER"; then
  NOLOGIN_SHELL="$(resolve_nologin_shell)"
  echo "Creating user $DRYADS_AI_USER ($NOLOGIN_SHELL, with home)..."
  if command -v useradd >/dev/null 2>&1; then
    run_root useradd -m -s "$NOLOGIN_SHELL" "$DRYADS_AI_USER"
  elif command -v adduser >/dev/null 2>&1; then
    # Debian/Ubuntu: adduser supports --disabled-password/--gecos. Busybox adduser differs.
    run_root adduser --disabled-password --gecos "" --shell "$NOLOGIN_SHELL" "$DRYADS_AI_USER"
  else
    echo "Neither useradd nor adduser found, cannot create user $DRYADS_AI_USER." >&2
    exit 1
  fi
else
  echo "User $DRYADS_AI_USER already exists."
fi

DRYADS_AI_HOME="$(resolve_user_home "$DRYADS_AI_USER")"
DRYADS_AI_UID="$(id -u "$DRYADS_AI_USER" 2>/dev/null || true)"
DRYADS_AI_CONFIG="$DRYADS_AI_HOME/.dryads-ai"
LAUNCH_SCRIPT_DST="$DRYADS_AI_HOME/run-dryads-ai-podman.sh"

# Prefer systemd user services (Quadlet) for production. Enable lingering early so rootless Podman can run
# without an interactive login.
if command -v loginctl &>/dev/null; then
  run_root loginctl enable-linger "$DRYADS_AI_USER" 2>/dev/null || true
fi
if [[ -n "${DRYADS_AI_UID:-}" && -d /run/user ]] && command -v systemctl &>/dev/null; then
  run_root systemctl start "user@${DRYADS_AI_UID}.service" 2>/dev/null || true
fi

# Rootless Podman needs subuid/subgid for the run user
if ! grep -q "^${DRYADS_AI_USER}:" /etc/subuid 2>/dev/null; then
  echo "Warning: $DRYADS_AI_USER has no subuid range. Rootless Podman may fail." >&2
  echo "  Add a line to /etc/subuid and /etc/subgid, e.g.: $DRYADS_AI_USER:100000:65536" >&2
fi

echo "Creating $DRYADS_AI_CONFIG and workspace..."
run_as_dryads-ai mkdir -p "$DRYADS_AI_CONFIG/workspace"
run_as_dryads-ai chmod 700 "$DRYADS_AI_CONFIG" "$DRYADS_AI_CONFIG/workspace" 2>/dev/null || true

ENV_FILE="$DRYADS_AI_CONFIG/.env"
if run_as_dryads-ai test -f "$ENV_FILE"; then
  if ! run_as_dryads-ai grep -q '^DRYADS_AI_GATEWAY_TOKEN=' "$ENV_FILE" 2>/dev/null; then
    TOKEN="$(generate_token_hex_32)"
    printf 'DRYADS_AI_GATEWAY_TOKEN=%s\n' "$TOKEN" | run_as_dryads-ai tee -a "$ENV_FILE" >/dev/null
    echo "Added DRYADS_AI_GATEWAY_TOKEN to $ENV_FILE."
  fi
  run_as_dryads-ai chmod 600 "$ENV_FILE" 2>/dev/null || true
else
  TOKEN="$(generate_token_hex_32)"
  printf 'DRYADS_AI_GATEWAY_TOKEN=%s\n' "$TOKEN" | run_as_dryads-ai tee "$ENV_FILE" >/dev/null
  run_as_dryads-ai chmod 600 "$ENV_FILE" 2>/dev/null || true
  echo "Created $ENV_FILE with new token."
fi

# The gateway refuses to start unless gateway.mode=local is set in config.
# Make first-run non-interactive; users can run the wizard later to configure channels/providers.
DRYADS_AI_JSON="$DRYADS_AI_CONFIG/dryads-ai.json"
if ! run_as_dryads-ai test -f "$DRYADS_AI_JSON"; then
  printf '%s\n' '{ gateway: { mode: "local" } }' | run_as_dryads-ai tee "$DRYADS_AI_JSON" >/dev/null
  run_as_dryads-ai chmod 600 "$DRYADS_AI_JSON" 2>/dev/null || true
  echo "Created $DRYADS_AI_JSON (minimal gateway.mode=local)."
fi

echo "Building image from $REPO_PATH..."
podman build -t dryads-ai:local -f "$REPO_PATH/Dockerfile" "$REPO_PATH"

echo "Loading image into $DRYADS_AI_USER's Podman store..."
TMP_IMAGE="$(mktemp -p /tmp dryads-ai-image.XXXXXX.tar)"
trap 'rm -f "$TMP_IMAGE"' EXIT
podman save dryads-ai:local -o "$TMP_IMAGE"
chmod 644 "$TMP_IMAGE"
(cd /tmp && run_as_user "$DRYADS_AI_USER" env HOME="$DRYADS_AI_HOME" podman load -i "$TMP_IMAGE")
rm -f "$TMP_IMAGE"
trap - EXIT

echo "Copying launch script to $LAUNCH_SCRIPT_DST..."
run_root cat "$RUN_SCRIPT_SRC" | run_as_dryads-ai tee "$LAUNCH_SCRIPT_DST" >/dev/null
run_as_dryads-ai chmod 755 "$LAUNCH_SCRIPT_DST"

# Optionally install systemd quadlet for dryads-ai user (rootless Podman + systemd)
QUADLET_DIR="$DRYADS_AI_HOME/.config/containers/systemd"
if [[ "$INSTALL_QUADLET" == true && -f "$QUADLET_TEMPLATE" ]]; then
  echo "Installing systemd quadlet for $DRYADS_AI_USER..."
  run_as_dryads-ai mkdir -p "$QUADLET_DIR"
  DRYADS_AI_HOME_SED="$(printf '%s' "$DRYADS_AI_HOME" | sed -e 's/[\\/&|]/\\\\&/g')"
  sed "s|{{DRYADS_AI_HOME}}|$DRYADS_AI_HOME_SED|g" "$QUADLET_TEMPLATE" | run_as_dryads-ai tee "$QUADLET_DIR/dryads-ai.container" >/dev/null
  run_as_dryads-ai chmod 700 "$DRYADS_AI_HOME/.config" "$DRYADS_AI_HOME/.config/containers" "$QUADLET_DIR" 2>/dev/null || true
  run_as_dryads-ai chmod 600 "$QUADLET_DIR/dryads-ai.container" 2>/dev/null || true
  if command -v systemctl &>/dev/null; then
    run_root systemctl --machine "${DRYADS_AI_USER}@" --user daemon-reload 2>/dev/null || true
    run_root systemctl --machine "${DRYADS_AI_USER}@" --user enable dryads-ai.service 2>/dev/null || true
    run_root systemctl --machine "${DRYADS_AI_USER}@" --user start dryads-ai.service 2>/dev/null || true
  fi
fi

echo ""
echo "Setup complete. Start the gateway:"
echo "  $RUN_SCRIPT_SRC launch"
echo "  $RUN_SCRIPT_SRC launch setup   # onboarding wizard"
echo "Or as $DRYADS_AI_USER (e.g. from cron):"
echo "  sudo -u $DRYADS_AI_USER $LAUNCH_SCRIPT_DST"
echo "  sudo -u $DRYADS_AI_USER $LAUNCH_SCRIPT_DST setup"
if [[ "$INSTALL_QUADLET" == true ]]; then
  echo "Or use systemd (quadlet):"
  echo "  sudo systemctl --machine ${DRYADS_AI_USER}@ --user start dryads-ai.service"
  echo "  sudo systemctl --machine ${DRYADS_AI_USER}@ --user status dryads-ai.service"
else
  echo "To install systemd quadlet later: $0 --quadlet"
fi
