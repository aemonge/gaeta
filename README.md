# gaeta: OpenCode-safe wrapper

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-support-yellow?logo=buy-me-a-coffee)](https://www.buymeacoffee.com/aemonge)

This document pack is for building **gaeta** as an OpenCode-safe wrapper with
phase-driven, methodology-enforced workflow control.

The target model is:

- `~/.config/gaeta/` is the source of truth.
- `gaeta` projects its configuration into the paths OpenCode already understands,
  primarily `~/.config/opencode/`.
- The wrapper preserves OpenCode compatibility instead of forking its internals.
- Sandbox, policy, modes, agents, commands, plugins, and workflow conventions live under
  the gaeta namespace.

The goal is not "replace OpenCode". The goal is "compose a stricter, more opinionated
operator layer around OpenCode".

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
