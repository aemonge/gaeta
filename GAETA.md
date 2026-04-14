# GAETA

gaeta means Guided Assistant Engineered Taskflow Agent.

gaeta is an OpenCode-safe wrapper that adds:
- sandbox and projection control,
- phase-driven execution,
- methodology enforcement,
- documentation-first project memory,
- approval-gated self-updating behavior.

## Operator Rules

Before meaningful work:
- read `docs/.gaeta/phases.md`,
- read `docs/.gaeta/status.md`,
- read `docs/.gaeta/checklist.md`,
- read `docs/.gaeta/backlog.md`.

During work:
- align with active phase,
- update checklist when task state changes,
- update status after meaningful changes,
- record new work in checklist or backlog,
- record blockers explicitly in status,
- follow defined methodology in every phase/task instruction.

At session end:
- leave next step explicit in status,
- ensure checklist reflects reality,
- ensure backlog captures deferred work.

## Source of Truth

- Canonical workflow control plane: `docs/.gaeta/*`.
- `PROJECT.md` is a dashboard, not a second source of truth.
