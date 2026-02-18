---
summary: "CLI reference for `dmms-ai config` (get/set/unset config values)"
read_when:
  - You want to read or edit config non-interactively
title: "config"
---

# `dmms-ai config`

Config helpers: get/set/unset values by path. Run without a subcommand to open
the configure wizard (same as `dmms-ai configure`).

## Examples

```bash
dmms-ai config get browser.executablePath
dmms-ai config set browser.executablePath "/usr/bin/google-chrome"
dmms-ai config set agents.defaults.heartbeat.every "2h"
dmms-ai config set agents.list[0].tools.exec.node "node-id-or-name"
dmms-ai config unset tools.web.search.apiKey
```

## Paths

Paths use dot or bracket notation:

```bash
dmms-ai config get agents.defaults.workspace
dmms-ai config get agents.list[0].id
```

Use the agent list index to target a specific agent:

```bash
dmms-ai config get agents.list
dmms-ai config set agents.list[1].tools.exec.node "node-id-or-name"
```

## Values

Values are parsed as JSON5 when possible; otherwise they are treated as strings.
Use `--json` to require JSON5 parsing.

```bash
dmms-ai config set agents.defaults.heartbeat.every "0m"
dmms-ai config set gateway.port 19001 --json
dmms-ai config set channels.whatsapp.groups '["*"]' --json
```

Restart the gateway after edits.
