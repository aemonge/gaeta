# Backlog

- [x] Add sample `~/.config/gaeta/opencode.json` and generated `opencode.json` projection pair.
- [x] Add projection safety matrix for symlink vs mirror decisions.
- [x] Add Linux/macOS portability notes.
- [x] Make `/go` keep validation commands visible to agents but hidden from user-facing chat output.
- [x] Add threat model document.
- [x] Add fixture repository layout.
- [ ] Add migration note for projects using `docs/.opencode`.
- [ ] Expand shellharden compliance from test scripts to the main `gaeta` wrapper.
- [ ] Extend `gaeta pause` snapshot detail (without adding extra alias commands).
- [ ] Investigate slow startup path for `gaeta` and add profiling-based optimization plan.
- [ ] Review OpenCode TUI agent-selection UX and document improvements for gaeta operator flow.
- [ ] Integrate proposal approval/rejection with OpenCode native approve/reject flow semantics.
- [ ] Create a full TUI demo script (with video) for `plan -> build -> review` with `/resume`, `/pause`, and `/evolve`.
- [ ] Fix slash-command launcher robustness when `gaeta` is not available in PATH from non-gaeta projects (`/pause` currently fails with `gaeta: command not found` in some sessions).
- [ ] Update gaeta command/agent prompt templates to explicitly account for bubblewrap isolation (no direct access to host home paths) and prefer reporting host-side verification steps when needed.
- [ ] Evaluate whether `build` should default-allow `todowrite`, `python -q`, and `pytest` in all environments; keep an escape hatch for stricter repos.
- [ ] Re-evaluate whether backup command should be deprecated now that init-first onboarding and handoff continuity are in place.
- [ ] Decide whether to remove legacy `gaeta proposal` subcommands once `/evolve` command UX is finalized.
