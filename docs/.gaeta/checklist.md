# Checklist

## Current Sprint

- [x] Add `./gaeta` executable and switch wrapper identity from scoder to gaeta.
- [x] Retire repo-local `./scoder` entrypoint.
- [x] Add `gaeta`-namespace config resolution with OpenCode-compatible naming (`opencode.json`, `tui.json`).
- [x] Add key-level config merge behavior (`gaeta` overrides `opencode` for JSON/YAML config files).
- [x] Add `.gaeta/` runtime metadata (`phase`, `command.json`, `session.log`, `approval.log`).
- [x] Implement generated `opencode.json` projection from gaeta-managed config.
- [x] Implement projection for `agents/`, `commands/`, `modes/`, and `plugins/`.
- [x] Add `gaeta doctor` self-inspection command for config/projection/workflow health.
- [x] Add `gaeta doctor --json` machine-readable output for validation/TDD workflows.
- [x] Add `make lint` and `make test` entrypoints (doctor JSON + config inheritance validation).
- [x] Add `make build` config install target for `~/.config/gaeta` (`opencode.json` + `commands/handoff.md`).
- [x] Improve `make lint`/`make test` UX with colored status output and explicit check markers.
- [x] Add interactive TTY compatibility mode by default with strict opt-in (`--strict-tty`).
- [x] Add `gaeta resume` / `gaeta r` helper to continue from documented phase/context.
- [x] Set resume launcher defaults to OpenCode `--agent plan` and refine handoff prompt quality.
- [x] Make `/handoff` the single canonical handoff interface and make `gaeta resume` prefer `docs/.gaeta/handoff.md` context.
- [x] Relax root `opencode.json` permission profile to reduce over-restrictive plan/build failures while keeping destructive command denies.
- [ ] Add methodology-enforced agent instructions per phase.
- [x] Add checklist/status sync behavior for gaeta workflow files.
- [x] Add `gaeta handoff` command plus project `/handoff` prompt template.
- [x] Add `gaeta tasks` command flow using `mdt` with graceful fallback.
- [ ] Add approval-gated self-update proposal flow.
- [ ] Add backup snapshot command/script for hard saves.

## Current

- [x] Freeze gaeta as the project name and direction.
- [x] Set `docs/.gaeta/` as the canonical workflow control plane.
- [x] Add top-level dashboard and operator entry docs (`PROJECT.md`, `GAETA.md`).
- [x] Align README and AGENTS behavior to `docs/.gaeta/*`.
- [x] Write `docs/.gaeta/human_test.md` for stage-one validation.

## Done

- [x] Establish wrapper-over-OpenCode direction (not a fork).
- [x] Establish Markdown checkbox files as the task system.
- [x] Archive legacy root/reference material under `docs/references/` and add ignore rules for local runtime artifacts.
- [x] Document `mdt` as preferred task operator with graceful fallback requirement.
- [x] Document `sem` as preferred semantic diff dependency with fallback to `git diff`.
