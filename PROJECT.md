# PROJECT

## Snapshot

- Name: gaeta
- Direction: OpenCode-safe wrapper with phase-driven, methodology-enforced agent workflow.
- Current phase: Phase 0 -> Phase 1 handoff.
- Current sprint: init-first project onboarding and workflow guards.
- Diagnostics: `gaeta doctor` (human) and `gaeta doctor --json` (machine-readable) available for self-inspection, with `make lint`/`make test` entrypoints.
- Install bundle: `make build` installs `opencode.json` plus `.opencode/commands/*.md` and `.opencode/agents/*.md` templates into `~/.config/gaeta`.
- Terminal UX: interactive runs default to compatibility redraw mode; strict TTY isolation is opt-in via `--strict-tty`.
- Session continuity: `gaeta resume` (`gaeta r`) launches OpenCode with `--agent plan` and the documented resume prompt; use `--show` to preview command/prompt.
- Default launch behavior: bare `gaeta` now injects `--agent plan` when no agent is explicitly provided.
- Resume priority: `gaeta resume` now reads `docs/.gaeta/pause.md` context first, then `PROJECT.md`/`status.md` fallback (no legacy handoff fallback).
- Runtime permissions: root `opencode.json` now uses an allow baseline for `read`/`edit`/`external_directory` plus explicit destructive bash denies.
- Pause operator surface: use OpenCode `/pause` as the canonical session checkpoint command.
- Operator slash commands are now: `/resume`, `/status`, `/pause`, `/go`, `/review`, `/evolve`.
- `/go` now rotates kickoff role across `plan -> build -> review` for each invocation.
- `/go` defaults to user-friendly output; use `gaeta go --show --format agent` for validation-command visibility in agent workflows.
- Proposal workflow remains available via `gaeta proposal create|list|approve|reject` with artifacts under `docs/.gaeta/proposals/`.
- OpenCode agent roster is now minimal and role-aligned: `plan`, `build`, `review`.
- Hard-save backups are now available via `gaeta backup [PROJECT_DIR]` under `docs/.gaeta/backups/` with a manifest documenting explicit runtime exclusions.
- Config projection examples are documented in both `docs/config-sample.md` and `docs/architecture.md`.
- Projection safety policy is now documented as `mirror-only` in `docs/architecture.md`.
- Linux/macOS portability notes are documented in `docs/architecture.md`.

## Next Step

Add threat model document.

## Resume Prompt

Use this prompt in a new gaeta session to continue exactly from current state:

`Read AGENTS.md and docs/.gaeta/{phases,status,checklist,backlog} plus PROJECT.md and GAETA.md. Provide a concise read-only handoff: current phase, next step, top pending sprint items, and blockers. Do not modify files yet; propose the exact first implementation slice and validation commands.`

## Blockers

- Full sandbox runtime validation is limited in this environment due namespace limits (`bwrap` ENOSPC).

## Canonical Workflow Files

- `docs/.gaeta/phases.md`
- `docs/.gaeta/status.md`
- `docs/.gaeta/checklist.md`
- `docs/.gaeta/backlog.md`
- `docs/.gaeta/human_test.md`
- `docs/.gaeta/human_test_agents.md`
