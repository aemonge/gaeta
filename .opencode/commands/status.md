---
description: Show gaeta workflow status snapshot
agent: plan
---
Resolve gaeta launcher in this order:
1. `./gaeta` when present in current project root.
2. `gaeta` from PATH.
3. `~/.config/gaeta/bin/gaeta` as per-user fallback launcher.

If no launcher exists, stop and report: `gaeta not found` (recommended fix: run `make build` in gaeta repo to install `~/.config/gaeta/bin/gaeta` and/or add it to PATH).

Run `<gaeta-launcher> status .`.

If output indicates project is not initialized, run `<gaeta-launcher> init .` first.

Then reply with the same concise status snapshot fields:
- current phase,
- next step,
- top pending sprint items,
- blockers.
