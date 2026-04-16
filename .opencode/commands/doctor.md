---
description: Run gaeta doctor and summarize actionable findings
agent: qa
---
This is the QA diagnostics command.

Resolve gaeta launcher in this order:
1. `./gaeta` when present in current project root.
2. `gaeta` from PATH.

Run `<gaeta-launcher> doctor --json .`.

Then summarize only actionable outcomes:
- failures,
- warnings,
- likely root cause,
- exact next remediation command per issue.

If all checks are clean, reply with a short all-clear message.
