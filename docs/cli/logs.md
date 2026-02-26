---
summary: "CLI reference for `dryads-ai logs` (tail gateway logs via RPC)"
read_when:
  - You need to tail Gateway logs remotely (without SSH)
  - You want JSON log lines for tooling
title: "logs"
---

# `dryads-ai logs`

Tail Gateway file logs over RPC (works in remote mode).

Related:

- Logging overview: [Logging](/logging)

## Examples

```bash
dryads-ai logs
dryads-ai logs --follow
dryads-ai logs --json
dryads-ai logs --limit 500
dryads-ai logs --local-time
dryads-ai logs --follow --local-time
```

Use `--local-time` to render timestamps in your local timezone.
