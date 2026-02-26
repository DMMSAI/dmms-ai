---
summary: "CLI reference for `dryads-ai config` (get/set/unset config values)"
read_when:
  - You want to read or edit config non-interactively
title: "config"
---

# `dryads-ai config`

Config helpers: get/set/unset values by path. Run without a subcommand to open
the configure wizard (same as `dryads-ai configure`).

## Examples

```bash
dryads-ai config get browser.executablePath
dryads-ai config set browser.executablePath "/usr/bin/google-chrome"
dryads-ai config set agents.defaults.heartbeat.every "2h"
dryads-ai config set agents.list[0].tools.exec.node "node-id-or-name"
dryads-ai config unset tools.web.search.apiKey
```

## Paths

Paths use dot or bracket notation:

```bash
dryads-ai config get agents.defaults.workspace
dryads-ai config get agents.list[0].id
```

Use the agent list index to target a specific agent:

```bash
dryads-ai config get agents.list
dryads-ai config set agents.list[1].tools.exec.node "node-id-or-name"
```

## Values

Values are parsed as JSON5 when possible; otherwise they are treated as strings.
Use `--json` to require JSON5 parsing.

```bash
dryads-ai config set agents.defaults.heartbeat.every "0m"
dryads-ai config set gateway.port 19001 --json
dryads-ai config set channels.whatsapp.groups '["*"]' --json
```

Restart the gateway after edits.
