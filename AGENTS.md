# AGENTS.md

## Purpose

This repository is built with a documentation-first gaeta workflow.

The agent must treat `./docs/.gaeta/` as required operational context, not optional notes.

## Required files

Before planning, editing, or running meaningful commands, read:
- `./docs/.gaeta/phases.md`
- `./docs/.gaeta/status.md`
- `./docs/.gaeta/checklist.md`
- `./docs/.gaeta/backlog.md`

For quick orientation, also read:
- `./PROJECT.md`
- `./GAETA.md`

## Behavioral rules

- Always align work to the current phase in `status.md`.
- Always update `checklist.md` when a task advances or completes.
- Always update `status.md` after meaningful changes.
- If a new task appears during execution, add it to `checklist.md` or `backlog.md` before ending the session.
- Never mark a task done unless the code, docs, and validation state all match.
- If blocked, write the blocker explicitly in `status.md`.
- If you make a design choice, append it to `status.md` or the decision log.
- If repository state and docs disagree, update the docs first or explain the mismatch.

## Checklist format

Use plain Markdown checkboxes only:
- `- [ ]` not started
- `- [x]` done

No nested task managers.
No external task DB as the source of truth.

## Session protocol

At session start:
1. Read required files.
2. Restate current phase and active checklist items.
3. Choose the smallest next slice of work.

During session:
1. Keep changes aligned to the active phase.
2. Update checklist entries when status changes.

At session end:
1. Update `status.md`.
2. Update `checklist.md`.
3. Add newly discovered work to `backlog.md`.
4. Leave the next step explicit.
