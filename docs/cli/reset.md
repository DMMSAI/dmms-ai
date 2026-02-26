---
summary: "CLI reference for `dryads-ai reset` (reset local state/config)"
read_when:
  - You want to wipe local state while keeping the CLI installed
  - You want a dry-run of what would be removed
title: "reset"
---

# `dryads-ai reset`

Reset local config/state (keeps the CLI installed).

```bash
dryads-ai reset
dryads-ai reset --dry-run
dryads-ai reset --scope config+creds+sessions --yes --non-interactive
```
