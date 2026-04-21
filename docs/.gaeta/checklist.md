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
- [x] Add `make build` config install target for `~/.config/gaeta` (`opencode.json` + command templates).
- [x] Improve `make lint`/`make test` UX with colored status output and explicit check markers.
- [x] Document the GAETA acronym expansion in `README.md`.
- [x] Add interactive TTY compatibility mode by default with strict opt-in (`--strict-tty`).
- [x] Add `gaeta resume` / `gaeta r` helper to continue from documented phase/context.
- [x] Set resume launcher defaults to OpenCode `--agent orchestrator` and refine handoff prompt quality.
- [x] Make `/handoff` the single canonical handoff interface and make `gaeta resume` prefer `docs/.gaeta/handoff.md` context.
- [x] Relax root `opencode.json` permission profile to reduce over-restrictive agent failures while keeping destructive command denies.
- [x] Add methodology-enforced agent instructions per phase.
- [x] Add checklist/status sync behavior for gaeta workflow files.
- [x] Add `gaeta handoff` command plus project `/handoff` prompt template.
- [x] Add `gaeta tasks` command flow using `mdt` with graceful fallback.
- [x] Add approval-gated self-update proposal flow.
- [x] Add backup command/script for hard saves.
- [x] Make `/review` proactively suggest a Conventional Commit message when checks pass.
- [x] Improve `gaeta backup` UX messaging while keeping stdout script-safe.
- [x] Add sample `~/.config/gaeta/opencode.json` and generated `opencode.json` projection pair.
- [x] Add projection safety matrix for symlink vs mirror decisions.
- [x] Add Linux/macOS portability notes.
- [x] Add threat model document.
- [x] Add fixture repository layout.
- [x] Add migration note for projects using `docs/.opencode`.
- [x] Expand shellharden compliance from test scripts to the main `gaeta` wrapper.
- [x] Add runtime branch coverage for shellharden-refactored launch paths (`--not-paranoid`, missing `landrun` with `--require-landlock`).
- [x] Extend `gaeta pause` snapshot detail to include `/go` cycle state.
- [x] Update command/agent prompt templates with bubblewrap host-visibility guidance and host-side verification fallback wording.
- [ ] Investigate slow startup path for `gaeta` and add a profiling-based optimization plan.
- [x] Add rotating `/go` kickoff flow (`plan -> build -> review`) for the next implementation slice.
- [x] Make `/go` reset to `plan` after git HEAD changes and hide validation commands in user format.
- [x] Add OpenCode slash-command pack: `/check`, `/doctor`, `/propose`, `/approve`, `/reject`, `/resume`.
- [x] Add additional OpenCode agent profiles beyond `plan`/`build` for orchestration and review flows.
- [x] Reuse `plan` and `build` as core agent roles (`plan`=architecture, `build`=implementation).
- [x] Remove command-only agent profiles so each agent has non-slash workflow responsibility.
- [x] Split review workflows into distinct commands: `/review` (reviewer) and `/qa` (qa), with `/check` and `/doctor` compatibility aliases.
- [x] Add Stage 2 human test checklist for validating gaeta-native agents and slash commands on a sample project.
- [x] Make `gaeta doctor` quiet by default with colorful status summary and issue-only output.
- [x] Add `gaeta doctor --verbose` for full section-by-section output.
- [x] Add doctor check for projected legacy `plan`/`build` profile leakage.
- [x] Fix `/resume` permission issue by allowing `git status *` for discovery/orchestrator/plan agent profiles.
- [x] Reduce reviewer permission dead-ends by switching reviewer bash fallback from deny to ask.
- [x] Expand qa/build permissions for practical validation commands (`gaeta *`, `python -q`, `pytest`, `make lint`, `make test`, `todowrite` for build).
- [x] Add `gaeta init` command to scaffold required workflow files in new projects.
- [x] Add initialization guard so `launch`, `resume`, `handoff`, `tasks`, and `proposal` fail fast when project workflow files are missing.
- [x] Replace brittle metacharacter bash denies with minimal interpreter/system global deny rules in `opencode.json`.
- [x] Convert agent profiles to explicit allowlists with fallback `ask` for unknown commands (no planned per-command asks).
- [x] Enforce human-in-the-loop git flow by denying `git*` in `build` agent profile.
- [x] Hard-cut agent roster to `plan`, `build`, and `review`.
- [x] Set operator slash commands to `/resume`, `/status`, `/pause`, `/review`, and `/evolve`.
- [x] Rename workflow checkpoint command from `gaeta handoff` to `gaeta pause` and emit `docs/.gaeta/pause.md` snapshots.
- [x] Update resume context preference to `docs/.gaeta/pause.md`.
- [x] Remove legacy `handoff.md` resume fallback and keep pause-only session continuity.
- [x] Add `make legacy-clean` to remove legacy command/agent templates from `~/.config/gaeta`.
- [x] Fix `gaeta doctor` sandbox probe so custom `-b /bin/bash` checks do not get default `--agent` injection.
- [x] Normalize `tests/doctor.bats` shell style so `shellharden --check` passes in `make lint`.
- [x] Add `gaeta status` and `/status` to show phase, next step, pending sprint items, and blockers.
- [x] Extend `make legacy-clean` to remove stale legacy role prompts (`architect`, `implementer`, `handoff-writer`) from `~/.config/gaeta/agents`.

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
