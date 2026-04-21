# OpenCode TUI Agent-Selection UX Review

## Scope

This review focuses on operator flow for selecting and switching gaeta roles in
interactive sessions (`plan`, `build`, `review`) through slash commands and
wrapper commands.

## Current operator flow

- Entry defaults to `plan` (`gaeta` and `gaeta resume`).
- `/go` rotates role context `plan -> build -> review` and reports selected/next role.
- `/status` and `/pause` provide state snapshots and continuity checkpoints.
- `/review` provides risk review + validation framing.
- `/evolve` drives proposal authoring and approval workflow.

## Friction points

1. Role-selection intent is mostly implicit in `/go` output and can be missed in
   long chat sessions.
2. Operators do not have a compact, single-page command map for role-switch
   intent vs command choice.
3. Proposal approval flow has two paths (native slash semantics and
   `gaeta proposal ...`) that need explicit preference ordering.
4. Recovery guidance when the operator loses context mid-session is spread
   across `/status`, `/pause`, and `/resume` docs.

## Improvement candidates (ranked)

## High impact, low effort

- Add a concise role/command matrix to operator docs.
- Add explicit native-first approve/reject guidance (keep fallback commands).
- Add one-line "if lost, run this" recovery sequence in operator docs.

## Medium impact, low effort

- Standardize command help snippets to include expected role outcome.
- Add one example transcript for `plan -> build -> review` kickoff and handoff.

## Higher effort

- Add explicit runtime command for role preview/switch (future behavior change).
- Add richer TUI surfacing of current role in long-running sessions.

## Decision: legacy `gaeta proposal` subcommands

- Keep legacy `gaeta proposal create|list|approve|reject` subcommands for now.
- Native OpenCode semantics (`/approve` and `/reject`) remain the preferred UX
  path in command templates.
- Revisit removal only after `/evolve` UX reaches parity for:
  - proposal creation,
  - proposal listing/discovery,
  - approve/reject with reason,
  - clear operator error recovery guidance.

## Smallest next implementation slice

- Add an operator-facing role/command matrix to `GAETA.md` and reference this
  review doc.
- Keep runtime behavior unchanged.
