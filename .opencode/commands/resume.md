---
description: Show gaeta resume context and launch preview
agent: plan
---
Resolve gaeta launcher in this order:
1. `gaeta` from PATH.
2. `./gaeta` when present in current project root.
3. `~/.config/gaeta/bin/gaeta` as per-user fallback launcher.

If no launcher exists, stop and report: `gaeta not found` (recommended fix: run `make build` in gaeta repo to install `~/.config/gaeta/bin/gaeta` and/or add it to PATH).

Run `<gaeta-launcher> resume --show .`.

If output indicates project is not initialized, run `<gaeta-launcher> init .` first.

Then provide a concise resume handoff containing:
- current phase,
- next step,
- top pending sprint items,
- blockers,
- exact first implementation slice,
- validation commands.
