---
summary: "CLI reference for `dmms-ai reset` (reset local state/config)"
read_when:
  - You want to wipe local state while keeping the CLI installed
  - You want a dry-run of what would be removed
title: "reset"
---

# `dmms-ai reset`

Reset local config/state (keeps the CLI installed).

```bash
dmms-ai reset
dmms-ai reset --dry-run
dmms-ai reset --scope config+creds+sessions --yes --non-interactive
```
