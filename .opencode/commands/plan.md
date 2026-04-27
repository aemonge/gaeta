---
description: Convert approach into executable plan
agent: plan
---
Build an execution plan for the approved approach.

Sem/AST context:
- if `sem` is available, include a concise sem-based outline/diff context in the plan.
- if `sem` is unavailable, say so explicitly and continue with file/diff reasoning.

Output must include:
- ordered steps,
- likely touched files/modules,
- test strategy,
- rollback strategy,
- acceptance criteria.

Do not edit files in this step.
