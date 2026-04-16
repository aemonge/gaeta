---
description: Run review diff checks for human verification
agent: reviewer
---
This is a compatibility alias for `/review`.

Resolve gaeta launcher in this order:
1. `./gaeta` when present in current project root.
2. `gaeta` from PATH.

Run these checks in order:

1. `git status`
2. `git diff`
3. `git diff --staged`
4. If `sem` is available, run `sem`; otherwise skip with a short note.

Then reply with a concise review bundle:
- changed files,
- highest-risk diffs,
- validation gaps,
- recommended human checks before commit.
