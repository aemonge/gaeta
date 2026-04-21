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
- Start the next rotated slice (`plan -> build -> review`): `/go`.
- Implementation review and validation: `/review`.
- Agent/workflow evolution: `/evolve`.

## Operator Role Matrix

| Intent | Preferred command | Agent | Expected outcome |
| --- | --- | --- | --- |
| Resume a session | `/resume` | `plan` | Continue from documented pause/context |
| Quick project snapshot | `/status` | `plan` | Phase, next step, pending items, blockers |
| Checkpoint current work | `/pause` | `build` | Updated pause snapshot and synced status |
| Start next implementation slice | `/go` | `plan` (rotating) | Rotated kickoff bundle (`plan -> build -> review`) |
| Validate and assess risk | `/review` | `review` | Findings, validation status, manual checks |
| Propose workflow changes | `/evolve` | `plan` | Proposal artifact + approval/reject guidance |
| Lost-context recovery | `/status` -> `/pause` -> `/resume` | mixed | Re-anchor state, checkpoint, then resume |

## Agent Roles

- gaeta-native roles: `plan`, `build`, `review`.
- `plan`: think, refine, design, and slice with goals + acceptance criteria.
- `build`: implement approved slices.
- `review`: inspect diffs, validate behavior, and provide manual showcase steps.
- Bare `gaeta` defaults to `--agent plan` when no agent is provided.
- `gaeta resume` defaults to `--agent plan`.

## Build Permission Policy

- Default build-agent behavior keeps practical validation commands enabled: `todowrite`, `python -q`, and `pytest`.
- For stricter repositories, use a project-local override in `opencode.json` to tighten `build` permissions instead of changing global defaults.
- Keep stricter overrides explicit and versioned per project.
- Strict-repo override example: set `agent.build.permission.todowrite` to `deny` and tighten `agent.build.permission.bash` entries for `python -q` / `pytest` in the project-local `opencode.json`.

## Backup Policy

- `gaeta backup` remains supported (not deprecated) as a hard-save guardrail for workflow continuity.
- Revisit deprecation only after equivalent safety and recovery guarantees are proven across init/pause/resume flows.
- Defer deprecation unless there is a validated replacement that preserves the same recoverability guarantees for workflow files and operator checkpoints.

## Proposal Lifecycle Policy

- Native approve/reject semantics are preferred in operator flow (`/approve`, `/reject`).
- `gaeta proposal create|list|approve|reject` remains supported as explicit fallback.
- Legacy `gaeta proposal` subcommands are removed only when `/evolve` reaches parity for create, list/discovery, approve/reject with reason, and recovery guidance.
- Once parity is validated, remove legacy subcommands immediately (no deprecation window).

## Source of Truth

- Canonical workflow control plane: `docs/.gaeta/*`.
- Template path migration guide: `docs/migration-docs-opencode.md`.
- `PROJECT.md` is a dashboard, not a second source of truth.
