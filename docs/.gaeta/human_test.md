# Stage 1 Human Test

## Purpose

Validate that gaeta can run as an OpenCode-safe wrapper while keeping workflow docs and phase discipline in sync.

## Scope

This stage validates:
- docs control plane availability,
- wrapper entrypoint behavior,
- metadata creation,
- checklist/status discipline,
- methodology-aware phase behavior.

## Preconditions

- Repository contains `PROJECT.md` and `GAETA.md`.
- Repository contains `docs/.gaeta/phases.md`, `docs/.gaeta/status.md`, `docs/.gaeta/checklist.md`, and `docs/.gaeta/backlog.md`.
- `./gaeta` executable exists and is runnable.

## Test Steps

1. Open `PROJECT.md` and confirm it links to canonical workflow files.
2. Open `GAETA.md` and confirm the operator rules are clear.
3. Run `./gaeta --help` and confirm naming and defaults use gaeta identity.
4. Run a dry session in a test repo and verify `.gaeta/` metadata files are created.
5. Confirm active phase in `docs/.gaeta/status.md` matches checklist focus.
6. Complete one small task and verify `docs/.gaeta/checklist.md` is updated.
7. Add one newly discovered task and verify it is written to `checklist.md` or `backlog.md`.
8. Add one blocker and verify it is written explicitly in `docs/.gaeta/status.md`.
9. Confirm `docs/.gaeta/status.md` has a concrete next step at session end.

## Expected Evidence

- Updated checkbox state in `docs/.gaeta/checklist.md`.
- Updated narrative state in `docs/.gaeta/status.md`.
- New task recorded in `docs/.gaeta/checklist.md` or `docs/.gaeta/backlog.md`.
- Runtime metadata present under `./.gaeta/`.

## Fail Conditions

- A task is completed without checklist/status updates.
- A blocker appears but is not recorded in status.
- Methodology requirement is ignored for a phase task.
- Workflow files are duplicated as independent sources of truth.
