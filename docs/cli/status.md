---
summary: "CLI reference for `dryads-ai status` (diagnostics, probes, usage snapshots)"
read_when:
  - You want a quick diagnosis of channel health + recent session recipients
  - You want a pasteable “all” status for debugging
title: "status"
---

# `dryads-ai status`

Diagnostics for channels + sessions.

```bash
dryads-ai status
dryads-ai status --all
dryads-ai status --deep
dryads-ai status --usage
```

Notes:

- `--deep` runs live probes (WhatsApp Web + Telegram + Discord + Google Chat + Slack + Signal).
- Output includes per-agent session stores when multiple agents are configured.
- Overview includes Gateway + node host service install/runtime status when available.
- Overview includes update channel + git SHA (for source checkouts).
- Update info surfaces in the Overview; if an update is available, status prints a hint to run `dryads-ai update` (see [Updating](/install/updating)).
