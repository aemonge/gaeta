---
description: Evolve agents and workflow with explicit proposal
agent: plan
---
Resolve gaeta launcher in this order:
1. `./gaeta` when present in current project root.
2. `gaeta` from PATH.

If neither launcher exists, stop and report: `gaeta not found` (recommended fix: run `make build` in gaeta repo and ensure `gaeta` is in PATH).

Run `<gaeta-launcher> proposal create . "Evolve agents and workflow"`.

Open the generated proposal under `docs/.gaeta/proposals/` and replace placeholders with concise, session-accurate content:
- Summary
- Scope
- Validation

Then reply with:
- proposal path,
- one-line summary,
- exact changes requested,
- validation commands,
- explicit recommendation to run `gaeta proposal approve . latest` or `gaeta proposal reject . latest "<reason>"`.
