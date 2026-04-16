# PROJECT

## Snapshot

- Name: gaeta
- Direction: OpenCode-safe wrapper with phase-driven, methodology-enforced agent workflow.
- Current phase: Phase 0 -> Phase 1 handoff.
- Current sprint: init-first project onboarding and workflow guards.
- Diagnostics: `gaeta doctor` (human) and `gaeta doctor --json` (machine-readable) available for self-inspection, with `make lint`/`make test` entrypoints.
- Install bundle: `make build` installs `opencode.json` plus `.opencode/commands/*.md` and `.opencode/agents/*.md` templates into `~/.config/gaeta`.
- Terminal UX: interactive runs default to compatibility redraw mode; strict TTY isolation is opt-in via `--strict-tty`.
- Session continuity: `gaeta resume` (`gaeta r`) launches OpenCode with `--agent orchestrator` and the documented resume prompt; use `--show` to preview command/prompt.
- Default launch behavior: bare `gaeta` now injects `--agent discovery` when no agent is explicitly provided.
- Resume priority: when available, `gaeta resume` now prefers `docs/.gaeta/handoff.md` narrative context before `PROJECT.md`/`status.md` fallback.
- Runtime permissions: root `opencode.json` now uses an allow baseline for `read`/`edit`/`external_directory` plus explicit destructive bash denies.
- Handoff operator surface: use OpenCode `/handoff` as the single canonical handoff command (no aliases).
- Review/operator slash commands now include `/review`, `/qa`, `/propose`, `/approve`, `/reject`, and `/resume` (with `/check` and `/doctor` compatibility aliases).
- Proposal workflow is now explicit via `gaeta proposal create|list|approve|reject` with artifacts under `docs/.gaeta/proposals/`.
- OpenCode agent roster is now gaeta-native and core-only: `discovery`, `orchestrator`, `plan`, `build`, `reviewer`, `qa`, `evolution`.

## Next Step

Add backup snapshot command/script for hard saves.

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
