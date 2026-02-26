---
summary: "CLI reference for `dryads-ai health` (gateway health endpoint via RPC)"
read_when:
  - You want to quickly check the running Gateway’s health
title: "health"
---

# `dryads-ai health`

Fetch health from the running Gateway.

```bash
dryads-ai health
dryads-ai health --json
dryads-ai health --verbose
```

Notes:

- `--verbose` runs live probes and prints per-account timings when multiple accounts are configured.
- Output includes per-agent session stores when multiple agents are configured.
