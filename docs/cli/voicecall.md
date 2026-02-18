---
summary: "CLI reference for `dmms-ai voicecall` (voice-call plugin command surface)"
read_when:
  - You use the voice-call plugin and want the CLI entry points
  - You want quick examples for `voicecall call|continue|status|tail|expose`
title: "voicecall"
---

# `dmms-ai voicecall`

`voicecall` is a plugin-provided command. It only appears if the voice-call plugin is installed and enabled.

Primary doc:

- Voice-call plugin: [Voice Call](/plugins/voice-call)

## Common commands

```bash
dmms-ai voicecall status --call-id <id>
dmms-ai voicecall call --to "+15555550123" --message "Hello" --mode notify
dmms-ai voicecall continue --call-id <id> --message "Any questions?"
dmms-ai voicecall end --call-id <id>
```

## Exposing webhooks (Tailscale)

```bash
dmms-ai voicecall expose --mode serve
dmms-ai voicecall expose --mode funnel
dmms-ai voicecall unexpose
```

Security note: only expose the webhook endpoint to networks you trust. Prefer Tailscale Serve over Funnel when possible.
