# PROJECT

## Snapshot

- Name: gaeta
- Direction: OpenCode-safe wrapper with phase-driven, methodology-enforced agent workflow.
- Current phase: Phase 0 -> Phase 1 handoff.
- Current sprint: workflow sync + methodology enforcement integration.
- Diagnostics: `gaeta doctor` (human) and `gaeta doctor --json` (machine-readable) available for self-inspection, with `make lint`/`make test` entrypoints.
- Terminal UX: interactive runs default to compatibility redraw mode; strict TTY isolation is opt-in via `--strict-tty`.

## Next Step

Implement checklist/status sync behavior for gaeta workflow files, then add methodology-enforced agent instructions per phase.

## Blockers

- Approval-gated evolution proposal format is not frozen.

## Canonical Workflow Files

- `docs/.gaeta/phases.md`
- `docs/.gaeta/status.md`
- `docs/.gaeta/checklist.md`
- `docs/.gaeta/backlog.md`
- `docs/.gaeta/human_test.md`
