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
- `make build` now installs a lean config bundle to `~/.config/gaeta` (`opencode.json`, all `.opencode/commands/*.md` templates, and all `.opencode/agents/*.md` role prompts, plus optional `tui.json` when present).
- `README.md` now expands the gaeta acronym as "Guided Assistant Engineered Taskflow Agent" for clearer project naming context.
- `make lint`/`make test` now provide colored, explicit status markers for check outcomes.
- Interactive sessions now default to TTY compatibility mode (better resize/redraw behavior), with strict session isolation opt-in via `--strict-tty`.
- `gaeta resume` (`gaeta r`) now launches a resumed gaeta session using OpenCode `--agent orchestrator` plus a read-only handoff `--prompt`, with `--show` for dry-run visibility.
- Operator resume prompt is recorded in `PROJECT.md` under `## Resume Prompt` for clean handoff into new gaeta sessions.
- Root `opencode.json` permissions now use an explicit allow baseline for `read`, `edit`, and `external_directory` to prevent permission deadlocks in build workflows; destructive bash denies remain in place.
- Repo docs were previously split/inconsistent; canonical workflow location is now `docs/.gaeta/`.
- Legacy root/reference files were archived under `docs/references/` to reduce root noise.
- `gaeta tasks sync` now uses an explicit built-in sync path so status updates work even when `mdt` is installed.
- `gaeta handoff` now syncs `docs/.gaeta/status.md`, writes `docs/.gaeta/handoff.md`, updates `PROJECT.md` `## Next Step`, and appends a runtime handoff log entry.
- Per-project OpenCode `/handoff` is now available via `.opencode/commands/handoff.md`.
- `/handoff` is now the single canonical handoff interface (no aliases), with richer narrative capture sections in `docs/.gaeta/handoff.md`.
- `/handoff` slash-command now runs with `agent: orchestrator` (core agent roster only).
- `gaeta resume` now prefers `docs/.gaeta/handoff.md` context (project update, conversation summary, attempts/outcomes, decisions, frozen items) before falling back to `PROJECT.md`/`status.md`.
- Added `gaeta proposal` subcommands (`create`, `list`, `approve`, `reject`) to support explicit approval-gated proposal artifacts under `docs/.gaeta/proposals/`.
- Added OpenCode slash-command pack entries: `/review`, `/qa`, `/propose`, `/approve`, `/reject`, `/resume` plus compatibility aliases `/check` and `/doctor`.
- Added core gaeta OpenCode agent profiles in `opencode.json`: `discovery`, `orchestrator`, `plan`, `build`, `reviewer`, `qa`, and `evolution`.
- Removed command-only agent profiles so each agent has a workflow role beyond a single slash command.
- Bare `gaeta` launches now default to `--agent discovery` when no `--agent` is provided.
- Added per-project `.opencode/agents/*.md` role prompts for all gaeta-native agents.
- Config merge now supports tombstones (`null`) for structured files, allowing gaeta overlays to remove inherited keys (used to prevent legacy `plan`/`build` agent leakage from base OpenCode config).
- Added `docs/.gaeta/human_test_agents.md` with a sample ping-pong project checklist to manually validate all gaeta-native agents and slash commands.
- Validation now covers proposal lifecycle and slash-command/agent bindings in both `tests/doctor.bats` and `scripts/test-doctor.sh`.
- `gaeta doctor` human output is now quiet by default (summary + warn/fail lines) and uses colored status labels.
- `gaeta doctor --verbose` now emits the full section-by-section check table.
- Doctor now includes a projected-config check that validates core agent profile presence and warns on deprecated command-only profiles.
- Fixed resume/orchestrator permission gap by allowing `git status *` flags for `discovery`, `orchestrator`, and `plan` profiles.
- Reduced reviewer permission denials by setting reviewer bash fallback to `ask` (instead of hard deny).
- Expanded qa/build practical command permissions (`gaeta *`, `python -q`, `pytest`, `make lint`, `make test`; build `todowrite` now allowed).
- Added `gaeta init` command to scaffold `PROJECT.md`, `GAETA.md`, and `docs/.gaeta/{phases,status,checklist,backlog}.md`.
- Added initialization guard to fail fast with `gaeta init` guidance when workflow files are missing (`launch`, `resume`, `handoff`, `tasks`, `proposal`).
- `gaeta doctor` now reports workflow init state and checks `PROJECT.md`/`GAETA.md` presence.

## In progress

- Fix slash-command launcher robustness when `gaeta` is not available in PATH for non-gaeta projects.
- Re-evaluate backup snapshot scope now that init-first onboarding is implemented.

## Blockers

- Full sandbox runtime validation is limited in this environment due namespace limits (`bwrap` ENOSPC), so wrapper behavior validation is currently partial.

## Next step

Add slash-command launcher fallback/auto-discovery so `/handoff` and related commands work reliably outside the gaeta repo.

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
- Session handoff prompt is executable via `gaeta resume` with default `orchestrator` agent (inspectable via `gaeta resume --show`).
- `docs/.gaeta/` is the canonical repository workflow control plane.
- Markdown checklists are the workflow task system.
- Self-updating behavior is approval-gated only.
- `mdt` is the preferred external checklist operator; gaeta must provide graceful fallback when unavailable.
- The `mdt` decision and fallback requirement are now documented in top-level gaeta docs.
- `sem` is the preferred semantic diff dependency; gaeta should fall back to `git diff` if unavailable.
- Handoff updates are implemented as an explicit wrapper command (`gaeta handoff`) plus a per-project OpenCode slash-command template (`.opencode/commands/handoff.md`).
- Updated root permission baseline to avoid build-agent deadlocks caused by overly narrow `external_directory`/`edit` patterns.
- Keep `/handoff` as the only handoff slash command (no alias commands).
- `/handoff` executes under `orchestrator` policy to avoid command-only agent sprawl.
- Approval-gated evolution flow is file-first and explicit: proposals are created and state-transitioned via `gaeta proposal` (`pending` -> `approved` or `rejected`) under `docs/.gaeta/proposals/`.
- New operator slash commands are split by intent: review (`/review`, `/qa`, with `/check` and `/doctor` aliases), governance (`/propose`, `/approve`, `/reject`), and context (`/resume`).
- Agent roster is core-only: `discovery`, `orchestrator`, `plan`, `build`, `reviewer`, `qa`, `evolution`.
- Bare `gaeta` sessions default to `discovery` unless an explicit `--agent` is passed.
- `gaeta resume` defaults to `orchestrator` for role-based continuation.
- `plan` and `build` are now intentional core profiles: `plan` for architecture/planning and `build` for implementation.
- `discovery`, `orchestrator`, and `plan` explicitly allow `git status *` to avoid flag-based permission denials in resume-driven sessions.
- `reviewer` now prioritizes progress over hard blocks by using bash fallback `ask` for unknown review commands.
- `qa` now explicitly allows `gaeta` command execution to support diagnostics in non-default command paths.
