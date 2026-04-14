# Status

## Current phase

Phase 0 -> Phase 1 handoff

## Objective

Build gaeta as an OpenCode-safe wrapper with a gaeta-native workflow control plane, methodology-enforced agents, and approval-gated self-improvement.

## Current state

- The existing wrapper already supports bubblewrap sandboxing.
- Landlock via `landrun` is optional defense-in-depth.
- Wrapper entrypoint is now `./gaeta` (repo-local `./scoder` retired).
- Config precedence now prefers `~/.config/gaeta/gaeta.json`, with fallback to `~/.config/scoder/scoder.json` and then OpenCode default config.
- Runtime metadata is now written under `./.gaeta/` (`phase`, `command.json`, `session.log`, `approval.log`).
- Repo docs were previously split/inconsistent; canonical workflow location is now `docs/.gaeta/`.

## In progress

- Implement generated `opencode.json` projection from `gaeta.json`.
- Implement directory projection for agents/commands/modes/plugins.
- Define commit-sized implementation slices with human checkpoints.

## Blockers

- Need to decide exact projection semantics for directories vs config files.
- Need to verify which OpenCode customization directories are safest to symlink directly.
- Need to define the first approval-gated Darwin/Godel proposal format.
- Full sandbox runtime validation is limited in this environment due namespace limits (`bwrap` ENOSPC), so wrapper behavior validation is currently partial.

## Next step

Implement minimal projection output (`gaeta.json` -> generated `opencode.json`) and write `projection.json` metadata.

## Decisions

- gaeta is a wrapper, not a fork.
- `~/.config/gaeta/` is canonical (with migration compatibility from scoder during transition).
- `docs/.gaeta/` is the canonical repository workflow control plane.
- Markdown checklists are the workflow task system.
- Self-updating behavior is approval-gated only.
