---
summary: "CLI reference for `dmms-ai agents` (list/add/delete/set identity)"
read_when:
  - You want multiple isolated agents (workspaces + routing + auth)
title: "agents"
---

# `dmms-ai agents`

Manage isolated agents (workspaces + auth + routing).

Related:

- Multi-agent routing: [Multi-Agent Routing](/concepts/multi-agent)
- Agent workspace: [Agent workspace](/concepts/agent-workspace)

## Examples

```bash
dmms-ai agents list
dmms-ai agents add work --workspace ~/.dmms-ai/workspace-work
dmms-ai agents set-identity --workspace ~/.dmms-ai/workspace --from-identity
dmms-ai agents set-identity --agent main --avatar avatars/dmms-ai.png
dmms-ai agents delete work
```

## Identity files

Each agent workspace can include an `IDENTITY.md` at the workspace root:

- Example path: `~/.dmms-ai/workspace/IDENTITY.md`
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
dmms-ai agents set-identity --workspace ~/.dmms-ai/workspace --from-identity
```

Override fields explicitly:

```bash
dmms-ai agents set-identity --agent main --name "DMMS AI" --emoji "🦞" --avatar avatars/dmms-ai.png
```

Config sample:

```json5
{
  agents: {
    list: [
      {
        id: "main",
        identity: {
          name: "DMMS AI",
          theme: "space lobster",
          emoji: "🦞",
          avatar: "avatars/dmms-ai.png",
        },
      },
    ],
  },
}
```
