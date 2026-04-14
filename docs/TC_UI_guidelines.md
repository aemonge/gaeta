# TC UI Guidelines

This document captures the current UI direction for Forge CLI/TUI work, including design choices, iteration workflow, and implementation status.

## Current Direction

- Primary frame: control-room style (not lazygit/lazysql style).
- Density: calm and concise.
- Tone: sober base with playful accents.
- Inputs: keyboard-first, Vim-friendly behavior expected.

## `forge test-uis` Presets

- `1` UI 1 Legacy (pcenter-style zebra)
- `2` UI 2 (Status+) — stronger semantic status colors
- `3` UI 3 (Meta+) — stronger key:value hierarchy
- `4` UI 4 (Progress+) — alternate progress rendering
- `5` UI 5 (Status Map) — review full status palette (`done/wip/todo/blocked/error/stale`)
- `6` UI 6 (Meta Map) — review metadata hierarchy emphasis
- `7` UI 7 (Breakpoints) — review width behavior at 100/120/160
- `8` UI 1 Baseline (default; winner)

## Baseline + Iteration Contract

- Keep `forge test-uis 8` as the active base for current iteration.
- Promote iteration into baseline only after explicit approval.
- Decision update: UI 8 is approved as current baseline.

## Rich Mode Behavior

UI mode resolution for `test-uis`:

- Default behavior: rich mode on TTY output.
- Fallback: plain mode on non-TTY output.
- Override via `FORGE_UI`:
  - rich: `yes`, `rich`, `tui`
  - plain: `no`, `plain`, `text`

Examples:

```bash
forge test-uis
FORGE_UI=yes forge test-uis
FORGE_UI=plain forge test-uis
```

## Table Rendering Rules (Inspired by `pcenter`)

- Use width-fit behavior based on terminal width.
- Use priority-based shrink/grow across columns.
- Keep column alignment stable and readable.
- Clip long cells with ellipsis (`...`).
- Keep strong separators for scanability.

## Visual Rules

- Header and separators may use semantic color (when rich mode enabled).
- Color should carry information, not decoration.
- Progress indicator should be clean, compact, and informative.
- Preserve ASCII-safe output in plain mode.

## Implementation Status

- Rich CLI previews are implemented and tested.
- `forge test-uis` defaults to UI 8 baseline.
- Shared UI primitives are extracted in `src/ui.rs`.
- `forge discover` recap now uses shared UI rendering primitives.
- Ratatui migration is planned for iteration lane after lock/dependency environment is writable.
- Existing work remains valid and testable in plain/rich text mode.

## Validation Workflow

For each UI iteration:

1. Run `forge test-uis` (active base)
2. Compare readability, alignment, spacing, and progress clarity
3. Approve/reject iteration in chat before promotion

## Final Decisions To Lock

- [x] Semantic status map for all states (`done`, `wip`, `todo`, `blocked`, `error`, `stale`)
- [x] Progress bar final style (glyphs, labels, thresholds)
- [x] Metadata hierarchy (`key:value` emphasis levels)
- [x] Width breakpoints and clipping behavior (80/100/120/160 cols)
- [x] Plain/no-color accessibility behavior (`FORGE_UI=plain`, `NO_COLOR=1`)

Locked baseline decision: `forge test-uis 8` (`UI 1 (Baseline)`).

Locked metadata hierarchy:

- key: bold color accent
- value: readable neutral tone
- `catalog` and `host` always rendered as explicit key:value lines

Locked width policy:

- baseline table behavior targets 120-col operator view
- graceful clipping at narrower widths (100-col)
- expanded context at wider widths (160-col)

Locked accessibility behavior:

- rich mode preserves text labels (no color-only meaning)
- plain mode remains readable with the same content hierarchy
- status semantics remain explicit in literal words (`done`, `wip`, `todo`, `blocked`, `error`, `stale`)

Locked status color map (chosen from `forge test-uis 5`):

- `done` / `active/running`: green
- `wip` / `active/wip`: yellow
- `todo`: blue
- `blocked`: red
- `error`: red
- `stale` / `todo/stale`: gray

Decision presets to use:

- Status map: `forge test-uis 5`
- Metadata hierarchy: `forge test-uis 6`
- Width breakpoints: `forge test-uis 7`
- Accessibility wording in rich mode: `forge test-uis 8`

Recommended project checks after changes:

```bash
cargo fmt
cargo test --test e2e_tests
make lint test
```
