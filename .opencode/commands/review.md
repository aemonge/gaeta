---
description: Inspect, validate, and describe manual verification
agent: review
---
Resolve gaeta launcher in this order:
1. `./gaeta` when present in current project root.
2. `gaeta` from PATH.
3. `~/.config/gaeta/bin/gaeta` as per-user fallback launcher.

If no launcher exists, continue review checks without gaeta invocation and include a note.

Run these checks in order:

1. `git status`
2. `git diff`
3. `git diff --staged`
4. If `sem` is available, run `sem`; otherwise skip with a short note.

Then reply with a concise review bundle:
- changed files,
- highest-risk diffs,
- validation results or gaps,
- recommended human checks before commit,
- a short manual showcase describing how a human can run and verify the feature.

Sandbox visibility rule:
- If sandbox/bubblewrap visibility prevents direct verification (for example host-home paths such as `~/.config/*`), do not claim direct verification.
- Explicitly state the limitation and provide host-side verification commands a human can run.

If checks pass without blocking issues, proactively add:
- `Suggested commit:` with one Conventional Commit message (`feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`) aligned to the reviewed changes.
