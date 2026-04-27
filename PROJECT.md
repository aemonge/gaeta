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
- Dedicated threat modeling is now documented in `docs/threat-model.md`.
- Doctor test fixtures are now centralized under `tests/fixtures/`.
- Migration guidance from legacy `docs/.opencode` paths is documented in `docs/migration-docs-opencode.md`.
- `make lint` now runs shellharden in-band for both test scripts and the `gaeta` wrapper.
- Runtime launch-path coverage now includes shellharden-refactored branches for `--not-paranoid` and missing-`landrun` `--require-landlock` behavior.
- `gaeta pause` snapshot now includes `/go` cycle context (`selected role` and `next role in cycle`).
- Command/agent prompt templates now explicitly handle bubblewrap host-path visibility limits and require host-side verification commands when needed.
- Slash-command launcher resolution now includes `~/.config/gaeta/bin/gaeta` fallback, and `make build` installs the launcher there.
- Review prompts now require medium/high-risk follow-up writeback into checklist/backlog before session end.
- Build defaults keep `todowrite`, `python -q`, and `pytest` enabled, with strictness handled through project-local overrides.
- Permission hardening now keeps `plan` non-mutating (`todowrite` denied) and scopes build-agent bash allows to explicit test/build commands while avoiding overlapping wildcard families.
- `gaeta backup` remains supported and is not deprecated.
- Proposal guidance is now native-first for approve/reject (`/approve` / `/reject`) with explicit `gaeta proposal` fallback commands.
- OpenCode TUI agent-selection UX review is documented in `docs/tui-agent-ux-review.md`.
- `GAETA.md` now includes an operator-facing role/command matrix.
- Legacy `gaeta proposal` subcommands remain supported until `/evolve` parity, then should be removed immediately (no deprecation window).
- `README.md` now includes a public-friendly quickstart, audience fit, status caveats, and a short operator flow for new users.
- MCP expansion policy now prefers a low-risk baseline (`context7`, `playwright`, `postgres`), keeps Semgrep optional, and excludes direct Perplexity API integration.
- OpenCode Monitor compatibility now documents local-only policy: set `OPENCODE_SERVER_HOST=127.0.0.1` and enable OpenCode HTTP with `server.hostname: "localhost"` (or `OPENCODE_HTTP_ENABLED=true`).
- gaeta vNext direction is now TUI-first: CLI is airlock/launcher (`gaeta`, `init`, `doctor`, `profile`, `serve`, `upgrade`) and most workflow actions happen via OpenCode slash commands.
- Profile system now supports `minimal`, `recommended` (default), and `experimental` metadata under `.gaeta/profile.json`.
- `gaeta init` now accepts `--profile` and scaffolds `.mcp.json.example` plus `.gaeta/artifacts/index.html`.
- `gaeta profile` now supports profile inspection/list/set operations.
- `gaeta profile` now supports `sync` (`--dry-run`, `--install`) with curated plugin-state reporting.
- Profile runtime state now projects into `.gaeta/profile.lock.json` plus OpenCode-visible `.opencode/gaeta.generated.json` and `.opencode/gaeta-profile.md`.
- `gaeta serve` now supports local artifact lifecycle (`start`, `status`, `stop`) with metadata in `.gaeta/server.json`.
- `gaeta doctor` now supports `--strict` and adds safety checks for ignore policy, tracked `.mcp.json`, secret-pattern scanning, profile consistency, direnv gating, and artifact safety.
- `gaeta status` now surfaces cockpit-visible profile/plugin/artifact/sem state and next suggested command guidance.
- Added TUI command templates: `/brainstorm`, `/plan`, `/build`, `/doctor`, `/serve`, `/design`, `/handoff`.
- Added docs: `docs/opencode-integration.md`, `docs/opencode-profiles.md`, `docs/opencode-plugins.md`, `docs/artifacts.md`.

## Next Step

Implement `gaeta upgrade` as a backup/diff-safe profile template re-projection flow.

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
