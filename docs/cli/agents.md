---
summary: "CLI reference for `dryads-ai agents` (list/add/delete/set identity)"
read_when:
  - You want multiple isolated agents (workspaces + routing + auth)
title: "agents"
---

# `dryads-ai agents`

Manage isolated agents (workspaces + auth + routing).

Related:

- Multi-agent routing: [Multi-Agent Routing](/concepts/multi-agent)
- Agent workspace: [Agent workspace](/concepts/agent-workspace)

## Examples

```bash
dryads-ai agents list
dryads-ai agents add work --workspace ~/.dryads-ai/workspace-work
dryads-ai agents set-identity --workspace ~/.dryads-ai/workspace --from-identity
dryads-ai agents set-identity --agent main --avatar avatars/dryads-ai.png
dryads-ai agents delete work
```

## Identity files

Each agent workspace can include an `IDENTITY.md` at the workspace root:

- Example path: `~/.dryads-ai/workspace/IDENTITY.md`
- `set-identity --from-identity` reads from the workspace root (or an explicit `--identity-file`)

Avatar paths resolve relative to the workspace root.

## Set identity

`set-identity` writes fields into `agents.list[].identity`:

- `name`
- `theme`
- `emoji`
- `avatar` (workspace-relative path, http(s) URL, or data URI)

Load from `IDENTITY.md`:

```bash
dryads-ai agents set-identity --workspace ~/.dryads-ai/workspace --from-identity
```

Override fields explicitly:

```bash
dryads-ai agents set-identity --agent main --name "Dryads AI" --emoji "🦞" --avatar avatars/dryads-ai.png
```

Config sample:

```json5
{
  agents: {
    list: [
      {
        id: "main",
        identity: {
          name: "Dryads AI",
          theme: "space lobster",
          emoji: "🦞",
          avatar: "avatars/dryads-ai.png",
        },
      },
    ],
  },
}
```
