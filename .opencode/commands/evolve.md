---
description: Evolve agents and workflow with explicit proposal
agent: plan
---
Resolve gaeta launcher in this order:
1. `gaeta` from PATH.
2. `./gaeta` when present in current project root.
3. `~/.config/gaeta/bin/gaeta` as per-user fallback launcher.

If no launcher exists, stop and report: `gaeta not found` (recommended fix: run `make build` in gaeta repo to install `~/.config/gaeta/bin/gaeta` and/or add it to PATH).

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
- explicit recommendation to approve/reject using native OpenCode semantics first (`/approve` / `/reject`) when available in the current environment,
- explicit fallback commands: `gaeta proposal approve . latest` or `gaeta proposal reject . latest "<reason>"`.
