#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
#  DMMS AI Installer
#  One-line install: curl -fsSL https://raw.githubusercontent.com/DMMSAI/dmms-ai/main/install.sh | bash
# ──────────────────────────────────────────────────────────────

REPO_URL="https://github.com/DMMSAI/dmms-ai.git"
INSTALL_DIR="${DMMS_AI_DIR:-$HOME/dmms-ai}"
MIN_NODE_VERSION=22
GATEWAY_PORT="${DMMS_AI_GATEWAY_PORT:-18789}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_banner() {
  echo ""
  echo -e "${CYAN}${BOLD}"
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║                                          ║"
  echo "  ║            DMMS AI Installer              ║"
  echo "  ║     Every Messenger is AI Now.            ║"
  echo "  ║                                          ║"
  echo "  ╚══════════════════════════════════════════╝"
  echo -e "${NC}"
}

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

detect_os() {
  case "$(uname -s)" in
    Linux*)  OS="linux" ;;
    Darwin*) OS="macos" ;;
    *)       error "Unsupported OS: $(uname -s). DMMS AI supports Linux and macOS." ;;
  esac

  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64)  ARCH="x64" ;;
    aarch64) ARCH="arm64" ;;
    arm64)   ARCH="arm64" ;;
    *)       error "Unsupported architecture: $ARCH" ;;
  esac

  info "Detected: ${OS} (${ARCH})"
}

command_exists() {
  command -v "$1" &>/dev/null
}

get_node_path() {
  which node 2>/dev/null || echo "/usr/bin/node"
}

install_node() {
  if command_exists node; then
    NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VER" -ge "$MIN_NODE_VERSION" ]; then
      success "Node.js $(node -v) is installed"
      return
    else
      warn "Node.js $(node -v) is too old (need >= ${MIN_NODE_VERSION})"
    fi
  else
    warn "Node.js not found"
  fi

  info "Installing Node.js ${MIN_NODE_VERSION}..."

  if [ "$OS" = "macos" ]; then
    if command_exists brew; then
      brew install node@${MIN_NODE_VERSION}
      brew link --overwrite node@${MIN_NODE_VERSION} 2>/dev/null || true
    else
      info "Installing Homebrew first..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
      brew install node@${MIN_NODE_VERSION}
      brew link --overwrite node@${MIN_NODE_VERSION} 2>/dev/null || true
    fi
  elif [ "$OS" = "linux" ]; then
    if command_exists apt-get; then
      info "Using NodeSource for Debian/Ubuntu..."
      curl -fsSL https://deb.nodesource.com/setup_${MIN_NODE_VERSION}.x | sudo -E bash -
      sudo apt-get install -y nodejs
    elif command_exists dnf; then
      curl -fsSL https://rpm.nodesource.com/setup_${MIN_NODE_VERSION}.x | sudo -E bash -
      sudo dnf install -y nodejs
    elif command_exists yum; then
      curl -fsSL https://rpm.nodesource.com/setup_${MIN_NODE_VERSION}.x | sudo -E bash -
      sudo yum install -y nodejs
    else
      error "No supported package manager found (apt, dnf, yum). Please install Node.js >= ${MIN_NODE_VERSION} manually."
    fi
  fi

  if ! command_exists node; then
    error "Node.js installation failed. Please install Node.js >= ${MIN_NODE_VERSION} manually."
  fi
  success "Node.js $(node -v) installed"
}

install_git() {
  if command_exists git; then
    success "Git $(git --version | cut -d' ' -f3) is installed"
    return
  fi

  info "Installing Git..."
  if [ "$OS" = "macos" ]; then
    brew install git
  elif [ "$OS" = "linux" ]; then
    if command_exists apt-get; then
      sudo apt-get update && sudo apt-get install -y git
    elif command_exists dnf; then
      sudo dnf install -y git
    elif command_exists yum; then
      sudo yum install -y git
    fi
  fi

  command_exists git || error "Git installation failed. Please install Git manually."
  success "Git installed"
}

install_pnpm() {
  if command_exists pnpm; then
    success "pnpm $(pnpm -v) is installed"
    return
  fi

  info "Installing pnpm..."
  if command_exists corepack; then
    corepack enable
    corepack prepare pnpm@latest --activate 2>/dev/null || npm install -g pnpm
  else
    npm install -g pnpm
  fi

  command_exists pnpm || error "pnpm installation failed."
  success "pnpm $(pnpm -v) installed"
}

clone_repo() {
  if [ -d "$INSTALL_DIR/.git" ]; then
    info "Existing installation found at ${INSTALL_DIR}, updating..."
    cd "$INSTALL_DIR"
    git pull origin main
  else
    info "Cloning DMMS AI to ${INSTALL_DIR}..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
  fi
  success "Source code ready at ${INSTALL_DIR}"
}

build_project() {
  cd "$INSTALL_DIR"

  info "Installing dependencies..."
  pnpm install --frozen-lockfile 2>/dev/null || pnpm install
  success "Dependencies installed"

  info "Building DMMS AI..."
  pnpm build
  success "Core built"

  info "Building UI..."
  pnpm ui:build
  success "UI built"
}

setup_cli() {
  LOCAL_BIN="$HOME/.local/bin"
  mkdir -p "$LOCAL_BIN"

  # Create CLI wrapper
  cat > "$LOCAL_BIN/dmms-ai" << WRAPPER
#!/usr/bin/env bash
exec $(get_node_path) "${INSTALL_DIR}/dmms-ai.mjs" "\$@"
WRAPPER
  chmod +x "$LOCAL_BIN/dmms-ai"

  # Add to PATH in all shell config files that exist
  for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$rc_file" ]; then
      if ! grep -q 'DMMS AI' "$rc_file" 2>/dev/null; then
        echo '' >> "$rc_file"
        echo '# DMMS AI' >> "$rc_file"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc_file"
      fi
    fi
  done

  # Also create .bashrc if it doesn't exist (some servers only have .profile)
  if [ ! -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ]; then
    echo '# DMMS AI' > "$HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  fi

  export PATH="$LOCAL_BIN:$PATH"
  success "CLI installed at ${LOCAL_BIN}/dmms-ai"
}

setup_systemd_service() {
  if [ "$OS" != "linux" ]; then
    return
  fi

  if ! command_exists systemctl; then
    warn "systemd not found, skipping service setup"
    return
  fi

  info "Setting up systemd service..."

  NODE_BIN="$(get_node_path)"
  CURRENT_USER="$(whoami)"

  sudo tee /etc/systemd/system/dmms-ai.service > /dev/null << EOF
[Unit]
Description=DMMS AI Gateway
After=network.target

[Service]
Type=simple
User=${CURRENT_USER}
WorkingDirectory=${INSTALL_DIR}
ExecStart=${NODE_BIN} ${INSTALL_DIR}/dmms-ai.mjs gateway --allow-unconfigured
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production
Environment=DMMS_AI_GATEWAY_HOST=0.0.0.0
Environment=DMMS_AI_GATEWAY_PORT=${GATEWAY_PORT}
Environment=PATH=${HOME}/.local/bin:/usr/local/bin:/usr/bin:/bin

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  success "Systemd service created"
}

start_service() {
  if [ "$OS" != "linux" ]; then
    return
  fi

  if ! command_exists systemctl; then
    return
  fi

  info "Starting DMMS AI service..."

  # Stop any existing instance
  sudo systemctl stop dmms-ai 2>/dev/null || true

  # Start and enable
  sudo systemctl start dmms-ai
  sudo systemctl enable dmms-ai 2>/dev/null

  # Verify it's running
  sleep 2
  if sudo systemctl is-active --quiet dmms-ai; then
    success "DMMS AI service is running"
  else
    warn "Service may have failed to start. Check: sudo journalctl -u dmms-ai -n 20"
  fi
}

open_firewall() {
  if [ "$OS" != "linux" ]; then
    return
  fi

  # UFW (Ubuntu/Debian)
  if command_exists ufw; then
    if sudo ufw status 2>/dev/null | grep -q "active"; then
      sudo ufw allow ${GATEWAY_PORT}/tcp 2>/dev/null && success "Firewall: port ${GATEWAY_PORT} opened (ufw)" || true
    fi
  fi

  # firewalld (CentOS/RHEL/Fedora)
  if command_exists firewall-cmd; then
    sudo firewall-cmd --permanent --add-port=${GATEWAY_PORT}/tcp 2>/dev/null && \
    sudo firewall-cmd --reload 2>/dev/null && \
    success "Firewall: port ${GATEWAY_PORT} opened (firewalld)" || true
  fi
}

get_external_ip() {
  curl -s --max-time 5 ifconfig.me 2>/dev/null || \
  curl -s --max-time 5 icanhazip.com 2>/dev/null || \
  curl -s --max-time 5 api.ipify.org 2>/dev/null || \
  echo "YOUR_SERVER_IP"
}

print_done() {
  EXTERNAL_IP="$(get_external_ip)"

  echo ""
  echo -e "${GREEN}${BOLD}"
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║                                          ║"
  echo "  ║      DMMS AI installed successfully!      ║"
  echo "  ║                                          ║"
  echo "  ╚══════════════════════════════════════════╝"
  echo -e "${NC}"
  echo ""
  echo -e "  ${GREEN}${BOLD}DMMS AI is now running!${NC}"
  echo ""
  echo -e "  ${BOLD}Open in your browser:${NC}"
  echo ""
  echo -e "    ${CYAN}http://${EXTERNAL_IP}:${GATEWAY_PORT}${NC}"
  echo ""
  echo -e "  ${BOLD}Service commands:${NC}"
  echo ""
  echo -e "    ${CYAN}sudo systemctl status dmms-ai${NC}      Check status"
  echo -e "    ${CYAN}sudo systemctl restart dmms-ai${NC}     Restart"
  echo -e "    ${CYAN}sudo systemctl stop dmms-ai${NC}        Stop"
  echo -e "    ${CYAN}sudo journalctl -u dmms-ai -f${NC}      View logs"
  echo ""
  echo -e "  ${BOLD}Config:${NC}  ~/.dmms-ai/dmms-ai.json"
  echo -e "  ${BOLD}Install:${NC} ${INSTALL_DIR}"
  echo ""
  echo -e "  ${YELLOW}NOTE: If using Google Cloud, AWS, or Azure, make sure port ${GATEWAY_PORT}${NC}"
  echo -e "  ${YELLOW}is open in your cloud provider's firewall/security group settings.${NC}"
  echo ""
}

# ── Main ──────────────────────────────────────────────────────

main() {
  print_banner
  detect_os
  install_node
  install_git
  install_pnpm
  clone_repo
  build_project
  setup_cli
  setup_systemd_service
  open_firewall
  start_service
  print_done
}

main "$@"
