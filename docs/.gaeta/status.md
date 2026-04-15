# Status

## Current phase

Phase 0 -> Phase 1 handoff

## Objective

Build gaeta as an OpenCode-safe wrapper with a gaeta-native workflow control plane, methodology-enforced agents, and approval-gated self-improvement.

## Current state

- The existing wrapper already supports bubblewrap sandboxing.
- Landlock via `landrun` is optional defense-in-depth.
- Wrapper entrypoint is now `./gaeta` (repo-local `./scoder` retired).
- Config precedence now uses key-level merge for `opencode.json`/`tui.json` (gaeta overrides OpenCode defaults when both exist).
- `gaeta tasks` now delegates to `mdt` with default `docs/.gaeta` + `checklist.md` wiring and a built-in fallback mode when `mdt` is unavailable.
- Runtime metadata is now written under `./.gaeta/` (`phase`, `command.json`, `session.log`, `approval.log`).
- Generated projection artifacts are now emitted under `./.gaeta/projection/` (`opencode.json`, `tui.json`, `projection.json`).
- Directory projection now covers `agents/`, `commands/`, `modes/`, and `plugins/` using mirror strategy with gaeta-over-opencode precedence.
- `gaeta doctor` now performs self-inspection for dependencies, config sources, projection artifacts, workflow files, and an in-sandbox launch check.
- `gaeta doctor --json` now emits machine-readable output for repeatable validation and TDD automation.
- `make lint` and `make test` now exist; test flow prefers `bats` and falls back to shell script validation for doctor JSON and config inheritance, with shellharden checks on hardened test scripts.
- `make lint`/`make test` now provide colored, explicit status markers for check outcomes.
- Interactive sessions now default to TTY compatibility mode (better resize/redraw behavior), with strict session isolation opt-in via `--strict-tty`.
- `gaeta resume` (`gaeta r`) now launches a resumed gaeta session using OpenCode `--agent plan` plus a read-only handoff `--prompt`, with `--show` for dry-run visibility.
- Operator resume prompt is recorded in `PROJECT.md` under `## Resume Prompt` for clean handoff into new gaeta sessions.
- Root `opencode.json` permissions were relaxed to an `allow` baseline with explicit destructive denies to avoid non-persistent ask prompts in sandboxed sessions.
- Repo docs were previously split/inconsistent; canonical workflow location is now `docs/.gaeta/`.
- Legacy root/reference files were archived under `docs/references/` to reduce root noise.

## In progress

- Define commit-sized implementation slices with human checkpoints.
- Define checklist/status sync behavior for gaeta workflow files.
- Add methodology-enforced agent instructions per phase.

## Blockers

- Need to define the first approval-gated Darwin/Godel proposal format.
- Full sandbox runtime validation is limited in this environment due namespace limits (`bwrap` ENOSPC), so wrapper behavior validation is currently partial.

## Next step

Implement checklist/status sync behavior for gaeta workflow files, then add methodology-enforced agent instructions per phase.

## Decisions

- gaeta is a wrapper, not a fork.
- `~/.config/gaeta/` is canonical and uses OpenCode-compatible config naming (`opencode.json`, `tui.json`).
- Legacy `gaeta.json`/`scoder.json` config fallbacks are removed to keep config behavior explicit and clean.
- Config merge semantics are recursive key-level overlay: OpenCode base + gaeta override for JSON/YAML structured config.
- Runtime projection semantics now generate concrete config artifacts in repo-local `.gaeta/projection/` and bind those into sandbox config paths.
- Directory projection semantics are now fixed to mirror mode (no direct symlink): merge OpenCode base + gaeta overrides, with structured file key-level merge for JSON/YAML.
- Self-inspection command naming is `gaeta doctor` only (no inspect alias).
- Doctor output modes are now dual: human-readable default and JSON via `--json`.
- Doctor JSON and human outputs now share the same check collection source and differ only in rendering.
- TTY session policy is now explicit and observable (`compat`/`strict`) in doctor output and `.gaeta/command.json`.
- Session handoff prompt is now executable via `gaeta resume` with default plan agent (and inspectable via `gaeta resume --show`) to support clean migration from legacy scoder usage.
- Plan agent remains read-only (`edit: deny`) while bash policy now favors explicit allow/deny (no interactive ask dependency in sandbox flow).
- `docs/.gaeta/` is the canonical repository workflow control plane.
- Markdown checklists are the workflow task system.
- Self-updating behavior is approval-gated only.
- `mdt` is the preferred external checklist operator; gaeta must provide graceful fallback when unavailable.
- The `mdt` decision and fallback requirement are now documented in top-level gaeta docs.
- `sem` is the preferred semantic diff dependency; gaeta should fall back to `git diff` if unavailable.
