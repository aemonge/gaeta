# Extended Diff Tool Requirements (Planned)

This document defines the planned extended diff tool for forge. The goal is to
provide high-signal review summaries that go beyond raw patches by using
tree-sitter AST analysis, while retaining a traditional diff view via `syndiff`.

Status: **Planned** (documentation only; no implementation yet).

## Goals

- Provide a compact, structured summary of code changes for review checkpoints.
- Reduce manual scanning by surfacing changed symbols and structural deltas.
- Keep raw diffs available for exact line-level inspection.
- Support multiple languages via tree-sitter with clear confidence signaling.

## Non-goals

- Perfect semantic change detection across all languages.
- Full rename tracking across unrelated files (best-effort only).
- Exact behavior or runtime impact analysis.

## Inputs

Primary sources:

- `git diff` (default for repository comparisons)
- Explicit file/dir pairs (`--from`/`--to`) for direct comparisons

Optional filters:

- Path scoping (files, folders)
- Ignore patterns (generated files, vendor, build artifacts)
- Language selection override

## Outputs

### Baseline Summary (Promised)

- Functions/methods added, removed, changed
- Types added, removed, changed (class/struct/enum/trait/interface)
- Modules/namespaces added, removed, changed
- Fields/properties added, removed, changed
- Top-level constants added, removed, changed

### Best-effort/Optional (Heuristic)

- Local variables added/removed/changed
- Imports/uses and visibility changes
- Signature changes (params/return types)
- Inheritance/implements/trait bounds
- Decorators/annotations/macros

### Raw Diff Output (Optional)

- Unified diff output rendered by `syndiff`
- Emitted after the summary when `--patch` is set

### Confidence Signaling

- Each category can include a confidence label: `high`, `medium`, `low`
- Any heuristic category defaults to `low` unless language-specific rules raise it

## CLI Usage (Planned)

```
# Summary only (default)
forge diff --summary

# Summary + unified diff output
forge diff --summary --patch

# Scope to a path or file
forge diff --summary src/lib.rs

# Compare two paths directly
forge diff --summary --from path/a --to path/b
```

## Review Code Integration (Planned)

At review checkpoints:

- `r` (Review code) shows the extended summary first
- User can optionally open the full diff in `$EDITOR`

## Analysis Pipeline (Conceptual)

1. Collect changes (git diff or file pairs)
2. Determine language per file (extension or tree-sitter detection)
3. Parse AST via tree-sitter
4. Extract symbols and structural elements
5. Compare before/after symbol sets
6. Classify changes into categories
7. Render summary + optional raw diff

## Change Classification Rules

Baseline rules (promised):

- Added: symbol exists only in `after`
- Removed: symbol exists only in `before`
- Changed: symbol exists in both with signature/body delta

Optional/heuristic rules:

- Renames inferred by high similarity + same location or signature
- Local variables tracked only within a function scope
- Import/use changes derived from AST node list diff

## Language Support (Initial Targets)

Initial languages should favor high-fidelity AST extraction:

- Rust
- Python

This is extensible to any tree-sitter grammar, but categories may vary by
language. Each language declares supported categories and confidence levels.

## Edge Cases and Constraints

- Files that fail to parse fall back to raw diff only
- Binary or non-text files are excluded from AST summary
- Very large diffs may skip low-confidence categories to reduce noise
- Generated files should be ignored by default (configurable)

## Output Shape (Proposed)

Example summary layout (plain text):

```
Summary
- Files changed: 3
- Functions: +2 / -1 / ~3
- Types: +1 / -0 / ~1
- Modules: +0 / -0 / ~1
- Fields: +4 / -0 / ~2
- Constants: +1 / -0 / ~0

Details
- Functions added: parse_config, load_state
- Functions changed: run, handle_review
- Types changed: ForgeConfig
- Modules changed: providers

Optional (low confidence)
- Local variables changed: 12
- Imports changed: 3
```

## Configuration (Planned)

- Enable/disable optional categories
- Ignore paths and file patterns
- Set maximum summary size
- Choose output format (plain text, JSON)

## Acceptance Criteria

- Summary appears before diff during review
- Output is deterministic for a given diff
- Heuristic categories are clearly labeled
- Falls back gracefully on parse failures

## Test Strategy (Planned)

- Golden tests for summary output per language
- Unit tests for symbol extraction per grammar
- Regression tests for rename/heuristic logic
