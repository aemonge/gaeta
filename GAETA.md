# GAETA

gaeta means Guided Assistant Engineered Taskflow Agent.

gaeta is an OpenCode-safe wrapper that adds:
- sandbox and projection control,
- phase-driven execution,
- methodology enforcement,
- documentation-first project memory,
- approval-gated self-updating behavior.

## Task Operations

- Canonical task truth: `docs/.gaeta/checklist.md`.
- Preferred external operator: `mdt`.
- Required behavior: graceful fallback when `mdt` is not installed.
- Internal planning helpers do not replace Markdown source-of-truth files.

## Review Operations

- Preferred semantic diff operator: `sem`.
- If `sem` is unavailable, use standard `git diff` as fallback.

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

## Operator Slash Commands

- Session resume: `/resume`.
- Session snapshot: `/status`.
- Session checkpoint: `/pause`.
- Implementation review and validation: `/review`.
- Agent/workflow evolution: `/evolve`.

## Agent Roles

- gaeta-native roles: `plan`, `build`, `review`.
- `plan`: think, refine, design, and slice with goals + acceptance criteria.
- `build`: implement approved slices.
- `review`: inspect diffs, validate behavior, and provide manual showcase steps.
- Bare `gaeta` defaults to `--agent plan` when no agent is provided.
- `gaeta resume` defaults to `--agent plan`.

## Source of Truth

- Canonical workflow control plane: `docs/.gaeta/*`.
- `PROJECT.md` is a dashboard, not a second source of truth.
