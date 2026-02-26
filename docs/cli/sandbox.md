---
title: Sandbox CLI
summary: "Manage sandbox containers and inspect effective sandbox policy"
read_when: "You are managing sandbox containers or debugging sandbox/tool-policy behavior."
status: active
---

# Sandbox CLI

Manage Docker-based sandbox containers for isolated agent execution.

## Overview

Dryads AI can run agents in isolated Docker containers for security. The `sandbox` commands help you manage these containers, especially after updates or configuration changes.

## Commands

### `dryads-ai sandbox explain`

Inspect the **effective** sandbox mode/scope/workspace access, sandbox tool policy, and elevated gates (with fix-it config key paths).

```bash
dryads-ai sandbox explain
dryads-ai sandbox explain --session agent:main:main
dryads-ai sandbox explain --agent work
dryads-ai sandbox explain --json
```

### `dryads-ai sandbox list`

List all sandbox containers with their status and configuration.

```bash
dryads-ai sandbox list
dryads-ai sandbox list --browser  # List only browser containers
dryads-ai sandbox list --json     # JSON output
```

**Output includes:**

- Container name and status (running/stopped)
- Docker image and whether it matches config
- Age (time since creation)
- Idle time (time since last use)
- Associated session/agent

### `dryads-ai sandbox recreate`

Remove sandbox containers to force recreation with updated images/config.

```bash
dryads-ai sandbox recreate --all                # Recreate all containers
dryads-ai sandbox recreate --session main       # Specific session
dryads-ai sandbox recreate --agent mybot        # Specific agent
dryads-ai sandbox recreate --browser            # Only browser containers
dryads-ai sandbox recreate --all --force        # Skip confirmation
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
docker pull dryads-ai-sandbox:latest
docker tag dryads-ai-sandbox:latest dryads-ai-sandbox:bookworm-slim

# Update config to use new image
# Edit config: agents.defaults.sandbox.docker.image (or agents.list[].sandbox.docker.image)

# Recreate containers
dryads-ai sandbox recreate --all
```

### After changing sandbox configuration

```bash
# Edit config: agents.defaults.sandbox.* (or agents.list[].sandbox.*)

# Recreate to apply new config
dryads-ai sandbox recreate --all
```

### After changing setupCommand

```bash
dryads-ai sandbox recreate --all
# or just one agent:
dryads-ai sandbox recreate --agent family
```

### For a specific agent only

```bash
# Update only one agent's containers
dryads-ai sandbox recreate --agent alfred
```

## Why is this needed?

**Problem:** When you update sandbox Docker images or configuration:

- Existing containers continue running with old settings
- Containers are only pruned after 24h of inactivity
- Regularly-used agents keep old containers running indefinitely

**Solution:** Use `dryads-ai sandbox recreate` to force removal of old containers. They'll be recreated automatically with current settings when next needed.

Tip: prefer `dryads-ai sandbox recreate` over manual `docker rm`. It uses the
Gateway’s container naming and avoids mismatches when scope/session keys change.

## Configuration

Sandbox settings live in `~/.dryads-ai/dryads-ai.json` under `agents.defaults.sandbox` (per-agent overrides go in `agents.list[].sandbox`):

```jsonc
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "all", // off, non-main, all
        "scope": "agent", // session, agent, shared
        "docker": {
          "image": "dryads-ai-sandbox:bookworm-slim",
          "containerPrefix": "dryads-ai-sbx-",
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
