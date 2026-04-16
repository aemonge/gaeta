---
description: Run QA validation checks and summarize evidence
agent: qa
---
Resolve gaeta launcher in this order:
1. `./gaeta` when present in current project root.
2. `gaeta` from PATH.

If neither launcher exists, skip gaeta diagnostics with a note and continue with project validation commands.

Run these checks in order:

1. `<gaeta-launcher> doctor --json .`
2. If available, run project validation commands in this order: `make lint`, then `make test`.

If gaeta reports the project is uninitialized, run `<gaeta-launcher> init .` before diagnostics.

Then reply with a concise QA report:
- overall pass/fail,
- failing checks and root cause,
- exact remediation commands,
- evidence lines for all passed checks.
