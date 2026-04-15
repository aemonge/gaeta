# PROJECT

## Snapshot

- Name: gaeta
- Direction: OpenCode-safe wrapper with phase-driven, methodology-enforced agent workflow.
- Current phase: Phase 0 -> Phase 1 handoff.
- Current sprint: workflow sync + methodology enforcement integration.
- Diagnostics: `gaeta doctor` (human) and `gaeta doctor --json` (machine-readable) available for self-inspection, with `make lint`/`make test` entrypoints.
- Terminal UX: interactive runs default to compatibility redraw mode; strict TTY isolation is opt-in via `--strict-tty`.
- Session continuity: `gaeta resume` (`gaeta r`) launches OpenCode with `--agent plan` and the documented resume prompt; use `--show` to preview command/prompt.
- Runtime permissions: root `opencode.json` now uses a sensible ask-first policy with explicit destructive denies.

## Next Step

Implement checklist/status sync behavior for gaeta workflow files, then add methodology-enforced agent instructions per phase.

## Resume Prompt

Use this prompt in a new gaeta session to continue exactly from current state:

`Read AGENTS.md and docs/.gaeta/{phases,status,checklist,backlog} plus PROJECT.md and GAETA.md. Provide a concise read-only handoff: current phase, next step, top pending sprint items, and blockers. Do not modify files yet; propose the exact first implementation slice and validation commands.`

## Blockers

- Approval-gated evolution proposal format is not frozen.

## Canonical Workflow Files

- `docs/.gaeta/phases.md`
- `docs/.gaeta/status.md`
- `docs/.gaeta/checklist.md`
- `docs/.gaeta/backlog.md`
- `docs/.gaeta/human_test.md`
