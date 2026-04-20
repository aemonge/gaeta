---
description: Show gaeta workflow status snapshot
agent: plan
---
Resolve gaeta launcher in this order:
1. `./gaeta` when present in current project root.
2. `gaeta` from PATH.

If neither launcher exists, stop and report: `gaeta not found` (recommended fix: run `make build` in gaeta repo and ensure `gaeta` is in PATH).

Run `<gaeta-launcher> status .`.

If output indicates project is not initialized, run `<gaeta-launcher> init .` first.

Then reply with the same concise status snapshot fields:
- current phase,
- next step,
- top pending sprint items,
- blockers.
