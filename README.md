# gaeta: OpenCode-safe wrapper

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-support-yellow?logo=buy-me-a-coffee)](https://www.buymeacoffee.com/aemonge)

This document pack is for building **gaeta** as an OpenCode-safe wrapper with
phase-driven, methodology-enforced workflow control.

`gaeta` means **Guided Assistant Engineered Taskflow Agent**.

The target model is:

- `~/.config/gaeta/` is the source of truth.
- `gaeta` projects its configuration into the paths OpenCode already understands,
  primarily `~/.config/opencode/`.
- The wrapper preserves OpenCode compatibility instead of forking its internals.
- Sandbox, policy, modes, agents, commands, plugins, and workflow conventions live under
  the gaeta namespace.
- CLI is intentionally small (`gaeta`, `init`, `doctor`, `profile`, `serve`, `upgrade`).
- Most workflow actions run inside OpenCode TUI slash commands.

The goal is not "replace OpenCode". The goal is "compose a stricter, more opinionated
operator layer around OpenCode".

## Quickstart

```bash
make build
./gaeta doctor .
./gaeta init --profile recommended .
./gaeta profile .
./gaeta serve .
./gaeta go --show --format user .
```

If you use OpenCode slash commands, start with:

- `/resume` to restore context,
- `/go` to start the next rotated slice,
- `/pause` to checkpoint state.

## Who gaeta is for

- Teams that want OpenCode compatibility with stricter workflow discipline.
- Operators who prefer documentation-first state (`docs/.gaeta/*`) and explicit gates.
- Repositories that need reproducible role/command policy without forking OpenCode.

Not for:

- Projects that want fully implicit/autonomous agent mutation without documented checkpoints.
- Workflows that do not want repo-local task/state files.

## Project status

- Stable preview for sharing and collaborative feedback.
- Linux-first sandbox guarantees; macOS support is functional with reduced sandbox parity.
- Known environment caveat: nested namespace limits can cause `bwrap` ENOSPC in constrained environments.
- UX findings and next UX iteration priorities are documented in `docs/tui-agent-ux-review.md`.

## 30-second flow

```text
1) ./gaeta doctor .
2) ./gaeta init .
3) /go
4) Implement smallest approved slice
5) /review
6) /pause
```

## OpenCode Monitor (local-only)

If you use `@actualyze/opencode-monitor`, keep gaeta/OpenCode in local-only mode while still enabling HTTP attach/browser support:

```bash
export OPENCODE_SERVER_HOST=127.0.0.1
```

Enable OpenCode HTTP server mode in config (gaeta-compatible projection source is `~/.config/gaeta/opencode.json`):

```json
{
  "server": {
    "hostname": "localhost"
  }
}
```

Upstream monitor docs may reference `~/.config/opencode/config.json`; in gaeta workflows prefer `~/.config/gaeta/opencode.json` (or `~/.config/opencode/opencode.json`) so projection and doctor checks stay consistent.

- Why `localhost`: OpenCode starts HTTP only when hostname differs from `127.0.0.1`; `localhost` still binds loopback.
- Fallback: `OPENCODE_HTTP_ENABLED=true opencode`
- Verify at startup: `HTTP server listening on http://localhost:<port>`
- If missing, OpenCode Monitor attach/browser actions report `Server Unavailable`.
- Ensure plugin is installed at `~/.config/opencode/plugin/opencode-monitor.js` (`oc-mon --install-plugin`); gaeta now projects this path into sandbox sessions.

## Task tooling

- Canonical task state lives in `docs/.gaeta/checklist.md`.
- Preferred external task operator is `mdt` (Markdown todo CLI).
- gaeta must provide graceful fallback behavior when `mdt` is unavailable.
- Internal agent planning can use background task helpers, but repository truth remains
  Markdown files under `docs/.gaeta/`.

## Diff tooling

- Preferred semantic diff tool is `sem` for clearer review of meaningful changes.
- Reference: `https://ataraxy-labs.github.io/sem/`.
- gaeta should use `sem` when available and gracefully fall back to standard `git diff`
  when it is not installed.

## Deliverables in this pack

- `docs/architecture.md` — system design, boundaries, config mapping, runtime model.
- `docs/opencode-integration.md` — TUI-first boundary and authority model.
- `docs/opencode-profiles.md` — minimal/recommended/experimental profile behavior.
- `docs/opencode-plugins.md` — curated plugin table and security impact.
- `docs/artifacts.md` — artifact layout and `gaeta serve` lifecycle.
- `docs/implementation-plan.md` — phased build plan.
- `docs/decisions.md` — ADR-style decision log.
- `docs/.gaeta/checklist.md` — Markdown checkbox workflow for task tracking.
- `docs/.gaeta/phases.md` — phase definitions and exit criteria.
- `docs/.gaeta/status.md` — living project status file.
- `docs/.gaeta/backlog.md` — queued work.
- `AGENTS.md` — behavioral rules for OpenCode/gaeta to keep docs updated.

## Design principles

- Reuse OpenCode primitives before inventing gaeta-specific ones.
- Keep the wrapper thin; keep policy explicit.
- Prefer compatibility shims over patches to upstream internals.
- Separate sandbox concerns from workflow concerns.
- Separate config source-of-truth from config projection.
- Make phase/state/checklist updates mandatory by convention.
- Treat documentation as an executable control surface for vibe-coding.

## What this assumes from current wrapper lineage

The current wrapper already proves the core direction:

- Bubblewrap sandboxing is the primary isolation layer.
- Landlock via `landrun` is optional defense-in-depth.
- `~/.config/gaeta/opencode.json` and `~/.config/gaeta/tui.json` should merge over
  equivalent files in `~/.config/opencode/` with gaeta key-level precedence.
- `agents/`, `commands/`, `modes/`, and `plugins/` should be projected in mirror mode
  with gaeta precedence over OpenCode defaults.
- Metadata already exists conceptually via phase/session/approval logs.
- The wrapper already binds a synthetic home and overlays OpenCode config into
  sandbox-visible paths.

This documentation turns that into a fuller product plan.
