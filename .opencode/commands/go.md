---
description: Start the next slice with rotated kickoff role
agent: plan
---
Resolve gaeta launcher in this order:
1. `./gaeta` when present in current project root.
2. `gaeta` from PATH.

If neither launcher exists, stop and report: `gaeta not found` (recommended fix: run `make build` in gaeta repo and ensure `gaeta` is in PATH).

Run `<gaeta-launcher> go --show --format user .`.

If output indicates project is not initialized, run `<gaeta-launcher> init .` first, then rerun `<gaeta-launcher> go --show --format user .`.

Reply with the command output as the kickoff bundle.
