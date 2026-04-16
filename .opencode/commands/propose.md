---
description: Draft an approval-gated self-update proposal
agent: evolution
---
Resolve gaeta launcher in this order:
1. `./gaeta` when present in current project root.
2. `gaeta` from PATH.

Create a proposal skeleton with:

1. `<gaeta-launcher> proposal create . "Build a terminal todo list MVP"`
2. Open the generated file under `docs/.gaeta/proposals/`.
3. Replace all `Pending capture via /propose.` bullets with concise, session-accurate content.

Required sections to fill:
- `## Summary`
- `## Scope`
- `## Validation`

Then reply with:
- proposal path,
- one-line summary,
- scope bullets,
- validation commands,
- approval request (`/approve` or `/reject`).
