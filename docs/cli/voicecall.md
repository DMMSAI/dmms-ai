---
summary: "CLI reference for `dryads-ai voicecall` (voice-call plugin command surface)"
read_when:
  - You use the voice-call plugin and want the CLI entry points
  - You want quick examples for `voicecall call|continue|status|tail|expose`
title: "voicecall"
---

# `dryads-ai voicecall`

`voicecall` is a plugin-provided command. It only appears if the voice-call plugin is installed and enabled.

Primary doc:

- Voice-call plugin: [Voice Call](/plugins/voice-call)

## Common commands

```bash
dryads-ai voicecall status --call-id <id>
dryads-ai voicecall call --to "+15555550123" --message "Hello" --mode notify
dryads-ai voicecall continue --call-id <id> --message "Any questions?"
dryads-ai voicecall end --call-id <id>
```

## Exposing webhooks (Tailscale)

```bash
dryads-ai voicecall expose --mode serve
dryads-ai voicecall expose --mode funnel
dryads-ai voicecall unexpose
```

Security note: only expose the webhook endpoint to networks you trust. Prefer Tailscale Serve over Funnel when possible.
