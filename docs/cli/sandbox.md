---
title: Sandbox CLI
summary: "Manage sandbox containers and inspect effective sandbox policy"
read_when: "You are managing sandbox containers or debugging sandbox/tool-policy behavior."
status: active
---

# Sandbox CLI

Manage Docker-based sandbox containers for isolated agent execution.

## Overview

DMMS AI can run agents in isolated Docker containers for security. The `sandbox` commands help you manage these containers, especially after updates or configuration changes.

## Commands

### `dmms-ai sandbox explain`

Inspect the **effective** sandbox mode/scope/workspace access, sandbox tool policy, and elevated gates (with fix-it config key paths).

```bash
dmms-ai sandbox explain
dmms-ai sandbox explain --session agent:main:main
dmms-ai sandbox explain --agent work
dmms-ai sandbox explain --json
```

### `dmms-ai sandbox list`

List all sandbox containers with their status and configuration.

```bash
dmms-ai sandbox list
dmms-ai sandbox list --browser  # List only browser containers
dmms-ai sandbox list --json     # JSON output
```

**Output includes:**

- Container name and status (running/stopped)
- Docker image and whether it matches config
- Age (time since creation)
- Idle time (time since last use)
- Associated session/agent

### `dmms-ai sandbox recreate`

Remove sandbox containers to force recreation with updated images/config.

```bash
dmms-ai sandbox recreate --all                # Recreate all containers
dmms-ai sandbox recreate --session main       # Specific session
dmms-ai sandbox recreate --agent mybot        # Specific agent
dmms-ai sandbox recreate --browser            # Only browser containers
dmms-ai sandbox recreate --all --force        # Skip confirmation
```

**Options:**

- `--all`: Recreate all sandbox containers
- `--session <key>`: Recreate container for specific session
- `--agent <id>`: Recreate containers for specific agent
- `--browser`: Only recreate browser containers
- `--force`: Skip confirmation prompt

**Important:** Containers are automatically recreated when the agent is next used.

## Use Cases

### After updating Docker images

```bash
# Pull new image
docker pull dmms-ai-sandbox:latest
docker tag dmms-ai-sandbox:latest dmms-ai-sandbox:bookworm-slim

# Update config to use new image
# Edit config: agents.defaults.sandbox.docker.image (or agents.list[].sandbox.docker.image)

# Recreate containers
dmms-ai sandbox recreate --all
```

### After changing sandbox configuration

```bash
# Edit config: agents.defaults.sandbox.* (or agents.list[].sandbox.*)

# Recreate to apply new config
dmms-ai sandbox recreate --all
```

### After changing setupCommand

```bash
dmms-ai sandbox recreate --all
# or just one agent:
dmms-ai sandbox recreate --agent family
```

### For a specific agent only

```bash
# Update only one agent's containers
dmms-ai sandbox recreate --agent alfred
```

## Why is this needed?

**Problem:** When you update sandbox Docker images or configuration:

- Existing containers continue running with old settings
- Containers are only pruned after 24h of inactivity
- Regularly-used agents keep old containers running indefinitely

**Solution:** Use `dmms-ai sandbox recreate` to force removal of old containers. They'll be recreated automatically with current settings when next needed.

Tip: prefer `dmms-ai sandbox recreate` over manual `docker rm`. It uses the
Gateway’s container naming and avoids mismatches when scope/session keys change.

## Configuration

Sandbox settings live in `~/.dmms-ai/dmms-ai.json` under `agents.defaults.sandbox` (per-agent overrides go in `agents.list[].sandbox`):

```jsonc
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "all", // off, non-main, all
        "scope": "agent", // session, agent, shared
        "docker": {
          "image": "dmms-ai-sandbox:bookworm-slim",
          "containerPrefix": "dmms-ai-sbx-",
          // ... more Docker options
        },
        "prune": {
          "idleHours": 24, // Auto-prune after 24h idle
          "maxAgeDays": 7, // Auto-prune after 7 days
        },
      },
    },
  },
}
```

## See Also

- [Sandbox Documentation](/gateway/sandboxing)
- [Agent Configuration](/concepts/agent-workspace)
- [Doctor Command](/gateway/doctor) - Check sandbox setup
