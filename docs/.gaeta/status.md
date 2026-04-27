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
- Permission model now uses a minimal global bash deny set (interpreter escape + system/destructive commands) and removes brittle raw metacharacter denies.
- Agent permissions now use explicit allowlists with fallback `ask` for unknown commands; known workflow commands are allow/deny only.
- `build` agent now denies `git*` to keep commit/push operations human-driven.
- Agent roster is now hard-cut to `plan`, `build`, and `review`.
- Slash command surface is now `/resume`, `/status`, `/pause`, `/review`, and `/evolve`.
- `gaeta pause` now replaces `gaeta handoff` and writes `docs/.gaeta/pause.md` for resume continuity.
- `gaeta resume` now uses `docs/.gaeta/pause.md` context only (no legacy `docs/.gaeta/handoff.md` fallback).
- Added `make legacy-clean` to remove legacy command/agent templates from `~/.config/gaeta`; `make build` now runs it before installing current templates.
- Fixed doctor sandbox probe argument forwarding so non-OpenCode binaries (for example `-b /bin/bash` in the nested doctor check) no longer receive injected `--agent`, removing `/bin/bash: --agent: invalid option` noise.
- Normalized `tests/doctor.bats` with shellharden-compatible quoting/expansions so `make lint` no longer fails at the shellharden gate.
- Added `gaeta status` plus OpenCode `/status` command to report current phase, next step, top pending sprint items, and blockers from `docs/.gaeta/*`.
- Extended `make legacy-clean` to remove stale legacy agent templates (`architect.md`, `implementer.md`, `handoff-writer.md`) from `~/.config/gaeta/agents`.
- Added a deferred backlog item to make command/agent prompt templates bubblewrap-aware about host-home path isolation.
- Added `gaeta backup` command to create hard-save backups under `docs/.gaeta/backups/backup-<UTC>/`.
- Backup manifest now documents included workflow files plus explicit runtime exclusions (`.gaeta/session.log`, `.gaeta/approval.log`, `.gaeta/command.json`, `.gaeta/projection/`).
- Updated `/review` command contract so successful reviews proactively include a Conventional Commit suggestion.
- Improved `gaeta backup` UX output with human-readable stderr guidance while keeping stdout as the absolute backup directory path for scripting.
- Added config projection examples in both `docs/config-sample.md` and `docs/architecture.md`, with test assertions to keep both references in sync.
- Added a projection safety matrix to `docs/architecture.md` and locked gaeta projection policy to mirror-only for deterministic sandbox-safe binds.
- Added rotating `gaeta go` kickoff flow and wired `/go` (`agent: plan`) to rotate `plan -> build -> review` per invocation.
- Updated `gaeta go` with output formats (`user`/`agent`), commit-aware reset to `plan` on git HEAD changes, and cycle-state self-healing with runtime logs.
- Added Linux/macOS portability notes in `docs/architecture.md` with per-platform capability guidance, verification commands, and known sandbox constraints.
- Added dedicated `docs/threat-model.md` as the detailed security source of truth, and reduced `docs/architecture.md` threat content to a high-level pointer.
- Added reusable test fixture repository layout under `tests/fixtures/` and updated doctor test harnesses to copy fixtures instead of inline heredocs.
- Added `docs/migration-docs-opencode.md` documenting migration from legacy `docs/.opencode/` template paths to canonical repo-root `.opencode/`.
- Completed wrapper shellharden compliance for `gaeta`; `make lint` now reports `shellharden` success for both test scripts and the wrapper.
- Added runtime test coverage for shellharden-refactored launch branches: `--not-paranoid` bubblewrap path and `--require-landlock` failure when `landrun` is unavailable.
- Extended `gaeta pause` snapshots to include `/go` cycle state (`selected role`, `next role`, and cycle-state note) and added tests for the new snapshot fields.
- Updated command/agent prompt templates to explicitly account for bubblewrap host-path visibility limits and require host-side verification commands when direct verification is not possible.
- Improved slash-command launcher robustness by adding `~/.config/gaeta/bin/gaeta` fallback guidance in command templates and installing the launcher there via `make build`.
- Enforced review workflow writeback policy so medium/high-risk follow-ups must be recorded in checklist/backlog, with prompt and test coverage updates.
- Confirmed build-agent defaults keep `todowrite`, `python -q`, and `pytest` enabled, with guidance to tighten permissions via project-local `opencode.json` overrides when needed.
- Re-evaluated backup deprecation and kept `gaeta backup` supported as an explicit hard-save continuity guardrail.
- Updated `/evolve` guidance to prefer native OpenCode approve/reject semantics first, with explicit `gaeta proposal` fallback commands.
- Added `docs/tui-agent-ux-review.md` with a ranked UX assessment for role-selection/operator flow and a smallest next implementation slice.
- Added an operator-facing role/command matrix in `GAETA.md` and linked policy language to the TUI UX review outcomes.
- Refreshed `README.md` for external sharing with a quickstart, audience fit, project status/caveats, and a short operator flow.
- Added an MCP expansion policy in `GAETA.md` with a low-risk baseline (`context7`, `playwright`, `postgres`), Semgrep as optional, and no Perplexity API integration.
- Tightened permission policy in `opencode.json`: `plan` now denies `todowrite`, build-agent bash allows are scoped to explicit test/build commands, and overlapping wildcard families are avoided.
- Added a docs-only Fence wishlist direction: keep current Linux-first `bwrap` + optional `landrun` backend as default, and revisit Fence only when macOS support becomes an active priority with explicit parity/rollback gates.
- Added `docs/fence-wishlist.md` as a dedicated one-page reference for Fence revisit triggers, decision gates, and explicit out-of-scope boundaries.
- Added explicit policy language in `GAETA.md` that `docs/.gaeta/` is intentionally committed in git for cross-machine workflow continuity.
- Tightened reviewer policy so `/review` must always provide `Suggested commit:` when overall assessment is "looks good" with none/low-risk findings only, and added matching guard assertions.
- Added OpenCode Monitor local-only operator guidance: keep `OPENCODE_SERVER_HOST=127.0.0.1` and enable OpenCode HTTP server mode via `server.hostname=localhost` (or `OPENCODE_HTTP_ENABLED=true` fallback).
- `gaeta doctor` now includes an `opencode monitor local-only` projection check that warns when HTTP server mode is not detected or when non-local monitor host advertisement is configured.
- Added projection + sandbox bind support for singular OpenCode plugin path (`~/.config/opencode/plugin/` -> `.gaeta/projection/plugin/` -> `/home/gaeta/.config/opencode/plugin`) so `opencode-monitor` plugin discovery works under gaeta.
- Normalized slash-command launcher precedence to `gaeta` (PATH) -> `./gaeta` -> `~/.config/gaeta/bin/gaeta` across command templates for better cross-project behavior.
- Updated `/pause` command template fallback behavior to continue with direct `docs/.gaeta/pause.md` updates when no launcher can be resolved, instead of hard-stop reporting.
- Captured a new backlog follow-up for project-level persistence of interactive allow/reject permission choices so prompt decisions are not lost across sessions/projects.
- Updated `.opencode/agents/plan.md` to support operator-mediated Perplexity deep-search requests via a fixed `Perplexity Request` output contract and a copy-paste prompt template.
- Reframed gaeta as a TUI-first OpenCode distro: primary CLI surface is now `gaeta`, `init`, `doctor`, `profile`, `serve`, and `upgrade` (legacy workflow commands remain supported as compatibility paths).
- Added profile metadata workflow under `.gaeta/profile.json` with supported profiles `minimal`, `recommended` (default), and `experimental`.
- Extended `gaeta init` to support `--profile` and scaffold `.mcp.json.example`, `.gaeta/profile.json`, `.gaeta/artifacts/index.html`, and safe `.gitignore` defaults.
- Added `gaeta profile` subcommands (`show`, `list`, `set`) for profile inspection/switching.
- Added `gaeta serve` lifecycle (`start`, `status`, `stop`) with localhost defaults, random free port, `.gaeta/server.json` metadata, and repo-root serving guardrail.
- Hardened `gaeta doctor` with `--strict` and safety checks for active profile detection, `.mcp.json` tracking, ignore-policy entries, token-pattern scans (without value disclosure), direnv gating, and artifact-root safety.
- Added TUI command pack entries: `/brainstorm`, `/plan`, `/build`, `/doctor`, `/serve`, `/design`, `/handoff`.
- Added docs: `docs/opencode-integration.md`, `docs/opencode-profiles.md`, `docs/opencode-plugins.md`, and `docs/artifacts.md`.
- Expanded fixtures/tests for init profile defaults, profile command behavior, serve lifecycle, strict-doctor behavior, and new command-pack coverage.
- Added `gaeta profile sync` with `--dry-run` and `--install` modes under the existing `gaeta profile` surface.
- Added profile runtime lock and projection artifacts: `.gaeta/profile.lock.json`, `.opencode/gaeta.generated.json`, and `.opencode/gaeta-profile.md`.
- Added curated profile plugin-state computation (expected/configured/missing/blocked/optional) with hard-blocked plugin enforcement.
- Updated `gaeta status` to report cockpit-visible profile/plugin/artifact/sem state and suggest next commands.
- Updated `gaeta doctor` to check profile sync freshness, lockfile/plugin mismatch state, and generated profile-context staleness.
- Updated slash command bodies (`/status`, `/doctor`, `/plan`, `/review`, `/handoff`) to surface profile sync and sem context in TUI workflows.
- Added test coverage for `gaeta profile sync` dry-run/apply behavior, profile lock/context generation, profile boundary expectations, and richer command template semantics.
- Updated `gaeta init` behavior to run `gaeta profile sync --install` by default so freshly initialized projects immediately project profile runtime context and lock state.
- Added `gaeta init --no-install` as an explicit opt-out for non-install bootstrap flows.
- Added curated plugin registry at `packs/opencode/plugins.json` with explicit install typing (`opencode-plugin`, `executable`, `manual`) and hard-blocked plugin list.
- `gaeta profile sync --install` now merges verified curated npm plugin specs into project `opencode.json` (`plugin` array) and preserves existing entries such as `opencode-monitor`.
- Added `gaeta profile sync --no-notify` to skip optional notify projection; default behavior auto-projects notify for recommended/experimental profiles.
- Profile lock schema now records plugin ids/specs in a projection-oriented format (`expected_ids`, `configured_specs`, `manual_ids`, `missing_ids`, `optional_skipped_ids`, `blocked_detected_specs`).
- Doctor profile-sync check now warns explicitly when recommended profile is not fully projected and suggests `gaeta profile sync --dry-run` and `gaeta profile sync --install`.
- Extended tests to validate dry-run no-write behavior, real `opencode.json` plugin projection/merge, notify opt-out, and profile boundary expectations.
- `gaeta doctor` is now strict-by-default and supports `--no-strict` when warning-tolerant checks are required.
- Profile sync now emits suggested `npm install -g ...` commands for manual/executable pending plugins, and doctor surfaces those suggestions in profile-sync warnings.
- Profile sync guidance no longer emits guessed `npm install -g <plugin-id>` commands for unresolved manual plugins; unresolved items are now explicitly flagged as unverified package-name gaps.
- Doctor profile-sync warning now includes both verified install suggestions and an `unresolved` segment for manual plugins without verified package names.
- Promoted `opencode-ignore` to verified `opencode-plugin` projection (`opencode-ignore`) in curated registry so sync/install now writes it into `opencode.json` plugin specs.
- Kept `envsitter-guard` and `opencode-agents` in manual/unresolved state with explicit notes; `opencode-agents` is documented as non-`plugin[]` package semantics.
- Updated test assertions to require `opencode-ignore` projection in recommended profile and to remove it from manual/missing plugin expectations.

## In progress

- None.

## Blockers

- Full sandbox runtime validation is limited in this environment due namespace limits (`bwrap` ENOSPC), so wrapper behavior validation is currently partial.

## Next step

Add deterministic/pinned OCX-backed installer execution to `gaeta profile sync --install` once installer command contracts are verified.

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
- Session resume prompt is executable via `gaeta resume` with default `plan` agent (inspectable via `gaeta resume --show`).
- `docs/.gaeta/` is the canonical repository workflow control plane.
- Markdown checklists are the workflow task system.
- Self-updating behavior is approval-gated only.
- `mdt` is the preferred external checklist operator; gaeta must provide graceful fallback when unavailable.
- The `mdt` decision and fallback requirement are now documented in top-level gaeta docs.
- `sem` is the preferred semantic diff dependency; gaeta should fall back to `git diff` if unavailable.
- Handoff updates are implemented as an explicit wrapper command (`gaeta handoff`) plus a per-project OpenCode slash-command template (`.opencode/commands/handoff.md`).
- Updated root permission baseline to avoid build-agent deadlocks caused by overly narrow `external_directory`/`edit` patterns.
- Keep `/pause` as the canonical pause/checkpoint slash command.
- Approval-gated evolution remains file-first via `gaeta proposal` artifacts, exposed through `/evolve` UX.
- Operator slash commands are now: `/resume`, `/status`, `/pause`, `/review`, `/evolve`.
- Agent roster is minimal: `plan`, `build`, `review`.
- Bare `gaeta` sessions default to `plan` unless an explicit `--agent` is passed.
- `gaeta resume` defaults to `plan`.
- `plan` and `build` are now intentional core profiles: `plan` for architecture/planning and `build` for implementation.
- `discovery`, `orchestrator`, and `plan` explicitly allow `git status *` to avoid flag-based permission denials in resume-driven sessions.
- `reviewer` now prioritizes progress over hard blocks by using bash fallback `ask` for unknown review commands.
- `qa` now explicitly allows `gaeta` command execution to support diagnostics in non-default command paths.
- Permission policy strategy is now: minimal shared `deny`, explicit per-agent `allow`, fallback `ask` only for unknown commands.
- Build agent intentionally denies `git*` to enforce human-in-the-loop repository state changes.
- Hard-save feature naming is now `backup` (not `snapshot`) for command/help/test consistency.
- Backup output/manifest wording must stay project-relative and must not assume direct host-home visibility under bubblewrap.
- Successful `/review` runs should include a single `Suggested commit:` Conventional Commit line when no blocking issues are found.
- Config projection behavior is now documented twice by design: quick reference in `docs/config-sample.md` and architecture pointer in `docs/architecture.md`.
- Projection policy is now explicitly mirror-only for config and directory artifacts; symlink projection is intentionally not used.
- Operator slash command surface now includes `/go`, backed by a rotating `plan -> build -> review` kickoff cycle.
- `/go` default user output intentionally omits validation command lists; `--format agent` keeps validation commands visible for agent execution.
- Portability policy is now explicit: Linux-first sandbox guarantees, macOS partial sandbox validation with documented fallback expectations.
- Threat-model details now live in `docs/threat-model.md`; `docs/architecture.md` keeps only high-level security context.
- Doctor test setup now uses repository fixtures in `tests/fixtures/` to reduce duplication across `tests/doctor.bats` and `scripts/test-doctor.sh`.
- Command/agent templates are canonical under repo-root `.opencode/`; `docs/.opencode/` is legacy and should be migrated using `docs/migration-docs-opencode.md`.
- Shellharden lint policy now includes the main `gaeta` wrapper in `make lint` as a strict in-band check.
- Reviewer-agent medium/high risk findings must be recorded in `docs/.gaeta/checklist.md` or `docs/.gaeta/backlog.md` before the session ends.
- Pause snapshots include `/go` cycle-state context for better handoff continuity without adding new alias commands.
- Prompt templates now require explicit host-side verification guidance whenever sandbox visibility limits direct inspection of host-home paths.
- Slash-command launcher resolution order is now `./gaeta` -> `gaeta` from PATH -> `~/.config/gaeta/bin/gaeta` fallback for non-gaeta projects.
- Startup profiling remains intentionally deferred by operator request; prioritize policy and workflow reliability slices first.
- Build-agent practical defaults (`todowrite`, `python -q`, `pytest`) remain enabled by default; strictness is achieved through project-level permission overrides.
- `gaeta backup` remains supported and is not deprecated at this stage.
- Proposal approval guidance is now native-first (`/approve` / `/reject`) with `gaeta proposal` fallback for environments without native command support.
- Legacy `gaeta proposal` subcommands stay supported until `/evolve` UX parity is demonstrated, then they should be removed immediately (no deprecation window).
- Startup profiling and TUI demo script/video items are deferred and not planned for the current cycle.
- MCP expansion policy is low-risk first: baseline servers are `context7`, `playwright`, and `postgres`; Semgrep is optional; Perplexity API is not integrated in gaeta.
- Permission policy keeps global fallback permissive by operator choice, while agent-level rules prioritize explicit allowlists and avoid overlapping wildcard families.
- Fence backend exploration is deferred by default; treat it as a future portability option (primarily macOS-driven) rather than a near-term Linux backend replacement.
- `docs/.gaeta/` is intentionally committed and versioned in git as shared project workflow state, not local-only runtime cache.
- `/review` commit suggestion policy is now explicit: if assessment is "looks good" and findings are none/low-risk only, always include one Conventional Commit `Suggested commit:` line.
- OpenCode Monitor compatibility policy is local-only by default: `OPENCODE_SERVER_HOST=127.0.0.1` plus HTTP server enablement via `server.hostname=localhost` in projected OpenCode config (or `OPENCODE_HTTP_ENABLED=true` as fallback).
- Keep both OpenCode plugin directory conventions projected for compatibility: `plugins/` (existing) and `plugin/` (required by `@actualyze/opencode-monitor` install scripts).
- Slash-command launcher policy is now PATH-first (`gaeta`) to avoid project-local path coupling in cross-project sessions.
- `/pause` is intentionally resilient when launcher resolution fails: continue with manual pause-document update flow and include setup guidance.
- Plan-agent external research policy is now explicit: when web context is needed, emit a structured operator-facing `Perplexity Request`; treat returned findings as advisory (not source of truth).
- gaeta vNext command policy is now explicit: keep CLI small and TUI-first, with legacy workflow subcommands supported as compatibility escape hatches.
- Profile metadata canonical location is `.gaeta/profile.json`; default profile is `recommended`.
- `gaeta serve` defaults are local-safe by policy: root `.gaeta/artifacts`, bind `127.0.0.1`, dynamic free port, and server metadata in `.gaeta/server.json`.
- Doctor strict-mode policy is explicit: `gaeta doctor --strict` fails on warnings/failures and must never print secret values.
- Profile runtime state policy now includes lock/projection artifacts as first-class operator signals: `.gaeta/profile.lock.json` and `.opencode/gaeta-profile.*`.
- `gaeta profile sync` default behavior is non-destructive runtime synchronization (no arbitrary plugin install); explicit `--install` emits curated install guidance only.
- `gaeta init` now defaults to install-sync behavior to reduce post-init manual steps and make profile state immediately visible inside OpenCode.
- Verified plugin projection policy now separates exact known npm specs (auto-project) from unresolved plugin package names (manual), and never fakes manual installs as successful.
- Strict diagnostics policy now defaults to fail-on-warning for `gaeta doctor`; operators can opt out explicitly with `--no-strict`.
- Manual plugin install guidance policy now forbids guessed package-name install commands in diagnostics output.
- Curated plugin registry promotion policy is evidence-driven: move entries from manual to `opencode-plugin` only when package spec is authoritative.
