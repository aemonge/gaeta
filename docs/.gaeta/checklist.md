# Checklist

## Current Sprint

- [x] Add `./gaeta` executable and switch wrapper identity from scoder to gaeta.
- [x] Retire repo-local `./scoder` entrypoint.
- [x] Add `gaeta`-first config resolution with OpenCode compatibility fallback.
- [x] Add `.gaeta/` runtime metadata (`phase`, `command.json`, `session.log`, `approval.log`).
- [ ] Implement generated `opencode.json` projection from `gaeta.json`.
- [ ] Implement projection for `agents/`, `commands/`, `modes/`, and `plugins/`.
- [ ] Add methodology-enforced agent instructions per phase.
- [ ] Add checklist/status sync behavior for gaeta workflow files.
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
