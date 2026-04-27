---
description: Inspect, validate, and describe manual verification
agent: review
---
Resolve gaeta launcher in this order:
1. `gaeta` from PATH.
2. `./gaeta` when present in current project root.
3. `~/.config/gaeta/bin/gaeta` as per-user fallback launcher.

If no launcher exists, continue review checks without gaeta invocation and include a note.

Run these checks in order:

1. `git status`
2. `git diff`
3. `git diff --staged`
4. If `sem` is available, run `sem`; otherwise skip with a short note.

When `sem` is available, include changed-symbol observations (or state explicitly if no symbol-level signal is available).

Then reply with a concise review bundle:
- changed files,
- highest-risk diffs,
- validation results or gaps,
- recommended human checks before commit,
- a short manual showcase describing how a human can run and verify the feature.

Workflow writeback rule:
- If you identify a medium/high-risk follow-up item, you must add it to `docs/.gaeta/checklist.md` or `docs/.gaeta/backlog.md` before ending the session.
- If you cannot edit files in the current runtime, explicitly report the exact follow-up item text and target file so the operator can apply it immediately.

Sandbox visibility rule:
- If sandbox/bubblewrap visibility prevents direct verification (for example host-home paths such as `~/.config/*`), do not claim direct verification.
- Explicitly state the limitation and provide host-side verification commands a human can run.

If the overall assessment is "looks good" with no medium/high-risk findings (none or only low-risk/nit findings), proactively add:
- `Suggested commit:` with one Conventional Commit message (`feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`) aligned to the reviewed changes.
