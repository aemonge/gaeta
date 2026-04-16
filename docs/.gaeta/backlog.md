# Backlog

- [ ] Add sample `~/.config/gaeta/opencode.json` and generated `opencode.json` projection pair.
- [ ] Add projection safety matrix for symlink vs mirror decisions.
- [ ] Add Linux/macOS portability notes.
- [ ] Add threat model document.
- [ ] Add fixture repository layout.
- [ ] Add migration note for projects using `docs/.opencode`.
- [ ] Expand shellharden compliance from test scripts to the main `gaeta` wrapper.
- [ ] Extend `gaeta handoff` snapshot detail (without adding pause/end-of-day alias commands).
- [ ] Evaluate whether deferred slash commands should be added as `/status` (phase snapshot) and `/snapshot` (hard-save) after backup command implementation lands.
- [ ] Investigate slow startup path for `gaeta` and add profiling-based optimization plan.
- [ ] Review OpenCode TUI agent-selection UX and document improvements for gaeta operator flow.
- [ ] Integrate proposal approval/rejection with OpenCode native approve/reject flow semantics.
- [ ] Create a full TUI demo script (with video) that explicitly switches through `discovery`, `orchestrator`, `plan`, `build`, `reviewer`, `qa`, and `evolution`.
- [ ] Fix slash-command launcher robustness when `gaeta` is not available in PATH from non-gaeta projects (`/handoff` currently fails with `gaeta: command not found` in some sessions).
- [ ] Evaluate whether `build` should default-allow `todowrite`, `python -q`, and `pytest` in all environments; keep an escape hatch for stricter repos.
- [ ] Re-evaluate whether backup snapshot should be deprecated now that init-first onboarding and handoff continuity are in place.
