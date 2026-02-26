---
summary: "Uninstall Dryads AI completely (CLI, service, state, workspace)"
read_when:
  - You want to remove Dryads AI from a machine
  - The gateway service is still running after uninstall
title: "Uninstall"
---

# Uninstall

Two paths:

- **Easy path** if `dryads-ai` is still installed.
- **Manual service removal** if the CLI is gone but the service is still running.

## Easy path (CLI still installed)

Recommended: use the built-in uninstaller:

```bash
dryads-ai uninstall
```

Non-interactive (automation / npx):

```bash
dryads-ai uninstall --all --yes --non-interactive
npx -y dryads-ai uninstall --all --yes --non-interactive
```

Manual steps (same result):

1. Stop the gateway service:

```bash
dryads-ai gateway stop
```

2. Uninstall the gateway service (launchd/systemd/schtasks):

```bash
dryads-ai gateway uninstall
```

3. Delete state + config:

```bash
rm -rf "${DRYADS_AI_STATE_DIR:-$HOME/.dryads-ai}"
```

If you set `DRYADS_AI_CONFIG_PATH` to a custom location outside the state dir, delete that file too.

4. Delete your workspace (optional, removes agent files):

```bash
rm -rf ~/.dryads-ai/workspace
```

5. Remove the CLI install (pick the one you used):

```bash
npm rm -g dryads-ai
pnpm remove -g dryads-ai
bun remove -g dryads-ai
```

6. If you installed the macOS app:

```bash
rm -rf /Applications/DryadsAi.app
```

Notes:

- If you used profiles (`--profile` / `DRYADS_AI_PROFILE`), repeat step 3 for each state dir (defaults are `~/.dryads-ai-<profile>`).
- In remote mode, the state dir lives on the **gateway host**, so run steps 1-4 there too.

## Manual service removal (CLI not installed)

Use this if the gateway service keeps running but `dryads-ai` is missing.

### macOS (launchd)

Default label is `bot.molt.gateway` (or `bot.molt.<profile>`; legacy `com.dryads-ai.*` may still exist):

```bash
launchctl bootout gui/$UID/bot.molt.gateway
rm -f ~/Library/LaunchAgents/bot.molt.gateway.plist
```

If you used a profile, replace the label and plist name with `bot.molt.<profile>`. Remove any legacy `com.dryads-ai.*` plists if present.

### Linux (systemd user unit)

Default unit name is `dryads-ai-gateway.service` (or `dryads-ai-gateway-<profile>.service`):

```bash
systemctl --user disable --now dryads-ai-gateway.service
rm -f ~/.config/systemd/user/dryads-ai-gateway.service
systemctl --user daemon-reload
```

### Windows (Scheduled Task)

Default task name is `Dryads AI Gateway` (or `Dryads AI Gateway (<profile>)`).
The task script lives under your state dir.

```powershell
schtasks /Delete /F /TN "Dryads AI Gateway"
Remove-Item -Force "$env:USERPROFILE\.dryads-ai\gateway.cmd"
```

If you used a profile, delete the matching task name and `~\.dryads-ai-<profile>\gateway.cmd`.

## Normal install vs source checkout

### Normal install (install.sh / npm / pnpm / bun)

If you used `https://dryads-ai.com/install.sh` or `install.ps1`, the CLI was installed with `npm install -g dryads-ai@latest`.
Remove it with `npm rm -g dryads-ai` (or `pnpm remove -g` / `bun remove -g` if you installed that way).

### Source checkout (git clone)

If you run from a repo checkout (`git clone` + `dryads-ai ...` / `bun run dryads-ai ...`):

1. Uninstall the gateway service **before** deleting the repo (use the easy path above or manual service removal).
2. Delete the repo directory.
3. Remove state + workspace as shown above.
