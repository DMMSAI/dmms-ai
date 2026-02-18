---
summary: "Install DMMS AI declaratively with Nix"
read_when:
  - You want reproducible, rollback-able installs
  - You're already using Nix/NixOS/Home Manager
  - You want everything pinned and managed declaratively
title: "Nix"
---

# Nix Installation

The recommended way to run DMMS AI with Nix is via **[nix-dmms-ai](https://github.com/dmms-ai/nix-dmms-ai)** — a batteries-included Home Manager module.

## Quick Start

Paste this to your AI agent (Claude, Cursor, etc.):

```text
I want to set up nix-dmms-ai on my Mac.
Repository: github:dmms-ai/nix-dmms-ai

What I need you to do:
1. Check if Determinate Nix is installed (if not, install it)
2. Create a local flake at ~/code/dmms-ai-local using templates/agent-first/flake.nix
3. Help me create a Telegram bot (@BotFather) and get my chat ID (@userinfobot)
4. Set up secrets (bot token, Anthropic key) - plain files at ~/.secrets/ is fine
5. Fill in the template placeholders and run home-manager switch
6. Verify: launchd running, bot responds to messages

Reference the nix-dmms-ai README for module options.
```

> **📦 Full guide: [github.com/dmms-ai/nix-dmms-ai](https://github.com/dmms-ai/nix-dmms-ai)**
>
> The nix-dmms-ai repo is the source of truth for Nix installation. This page is just a quick overview.

## What you get

- Gateway + macOS app + tools (whisper, spotify, cameras) — all pinned
- Launchd service that survives reboots
- Plugin system with declarative config
- Instant rollback: `home-manager switch --rollback`

---

## Nix Mode Runtime Behavior

When `DMMS_AI_NIX_MODE=1` is set (automatic with nix-dmms-ai):

DMMS AI supports a **Nix mode** that makes configuration deterministic and disables auto-install flows.
Enable it by exporting:

```bash
DMMS_AI_NIX_MODE=1
```

On macOS, the GUI app does not automatically inherit shell env vars. You can
also enable Nix mode via defaults:

```bash
defaults write bot.molt.mac dmms-ai.nixMode -bool true
```

### Config + state paths

DMMS AI reads JSON5 config from `DMMS_AI_CONFIG_PATH` and stores mutable data in `DMMS_AI_STATE_DIR`.
When needed, you can also set `DMMS_AI_HOME` to control the base home directory used for internal path resolution.

- `DMMS_AI_HOME` (default precedence: `HOME` / `USERPROFILE` / `os.homedir()`)
- `DMMS_AI_STATE_DIR` (default: `~/.dmms-ai`)
- `DMMS_AI_CONFIG_PATH` (default: `$DMMS_AI_STATE_DIR/dmms-ai.json`)

When running under Nix, set these explicitly to Nix-managed locations so runtime state and config
stay out of the immutable store.

### Runtime behavior in Nix mode

- Auto-install and self-mutation flows are disabled
- Missing dependencies surface Nix-specific remediation messages
- UI surfaces a read-only Nix mode banner when present

## Packaging note (macOS)

The macOS packaging flow expects a stable Info.plist template at:

```
apps/macos/Sources/DMMS AI/Resources/Info.plist
```

[`scripts/package-mac-app.sh`](https://github.com/dmms-ai/dmms-ai/blob/main/scripts/package-mac-app.sh) copies this template into the app bundle and patches dynamic fields
(bundle ID, version/build, Git SHA, Sparkle keys). This keeps the plist deterministic for SwiftPM
packaging and Nix builds (which do not rely on a full Xcode toolchain).

## Related

- [nix-dmms-ai](https://github.com/dmms-ai/nix-dmms-ai) — full setup guide
- [Wizard](/start/wizard) — non-Nix CLI setup
- [Docker](/install/docker) — containerized setup
