---
summary: "CLI reference for `dmms-ai devices` (device pairing + token rotation/revocation)"
read_when:
  - You are approving device pairing requests
  - You need to rotate or revoke device tokens
title: "devices"
---

# `dmms-ai devices`

Manage device pairing requests and device-scoped tokens.

## Commands

### `dmms-ai devices list`

List pending pairing requests and paired devices.

```
dmms-ai devices list
dmms-ai devices list --json
```

### `dmms-ai devices approve [requestId] [--latest]`

Approve a pending device pairing request. If `requestId` is omitted, DMMS AI
automatically approves the most recent pending request.

```
dmms-ai devices approve
dmms-ai devices approve <requestId>
dmms-ai devices approve --latest
```

### `dmms-ai devices reject <requestId>`

Reject a pending device pairing request.

```
dmms-ai devices reject <requestId>
```

### `dmms-ai devices rotate --device <id> --role <role> [--scope <scope...>]`

Rotate a device token for a specific role (optionally updating scopes).

```
dmms-ai devices rotate --device <deviceId> --role operator --scope operator.read --scope operator.write
```

### `dmms-ai devices revoke --device <id> --role <role>`

Revoke a device token for a specific role.

```
dmms-ai devices revoke --device <deviceId> --role node
```

## Common options

- `--url <url>`: Gateway WebSocket URL (defaults to `gateway.remote.url` when configured).
- `--token <token>`: Gateway token (if required).
- `--password <password>`: Gateway password (password auth).
- `--timeout <ms>`: RPC timeout.
- `--json`: JSON output (recommended for scripting).

Note: when you set `--url`, the CLI does not fall back to config or environment credentials.
Pass `--token` or `--password` explicitly. Missing explicit credentials is an error.

## Notes

- Token rotation returns a new token (sensitive). Treat it like a secret.
- These commands require `operator.pairing` (or `operator.admin`) scope.
