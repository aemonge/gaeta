---
description: Show gaeta workflow status snapshot
agent: plan
---
Resolve gaeta launcher in this order:
1. `gaeta` from PATH.
2. `./gaeta` when present in current project root.
3. `~/.config/gaeta/bin/gaeta` as per-user fallback launcher.

If no launcher exists, stop and report: `gaeta not found` (recommended fix: run `make build` in gaeta repo to install `~/.config/gaeta/bin/gaeta` and/or add it to PATH).

Run these commands in order:

1. `<gaeta-launcher> profile sync --dry-run .`
2. `<gaeta-launcher> serve status .`
3. `<gaeta-launcher> status .`

If output indicates project is not initialized, run `<gaeta-launcher> init .` first.

Then reply with a Gaeta cockpit snapshot including:
- gaeta profile,
- current phase,
- sandbox status,
- direnv mode,
- artifact server status and URL,
- sem status/freshness,
- expected profile plugins,
- configured plugin specs,
- missing curated plugins,
- last handoff/status file,
- next suggested command.
