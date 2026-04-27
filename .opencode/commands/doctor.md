---
description: Run gaeta doctor diagnostics from TUI
agent: review
---
Resolve gaeta launcher in this order:
1. `gaeta` from PATH.
2. `./gaeta` when present in current project root.
3. `~/.config/gaeta/bin/gaeta` as per-user fallback launcher.

If no launcher exists, stop and report: `gaeta not found`.

Run:

1. `<gaeta-launcher> doctor --strict .`
2. `<gaeta-launcher> profile sync --dry-run .`

Summarize fail/warn findings without printing secret values, and include exact next command suggestions, preferring:
- `gaeta profile sync --dry-run .`
- `gaeta profile sync --install .`
- `gaeta doctor --strict .`
