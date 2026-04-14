---
project:
  name: forge
  version: 0.1.0
  phase: implementation
---

# forge Development Tasks

## Current Checkpoint (2026-03-18)

- Milestone 1: complete
- Milestone 2: complete
- Milestone 3: complete
- Next task: `T4.2 - Write discovery.md`

### Discovery TUI Vim Wave Checkpoint (DONE)

- Discovery TUI now uses hybrid-blue by default and keeps in-app editing (external `nvim` path removed).
- Mode signaling improved: visible `INSERT/NORMAL/VISUAL/VISUAL-LINE` states with vim-like cursor behavior.
- Core vim movement/operators expanded in TUI editor:
  - movement: `h/j/k/l`, `w/W`, `e/E`, `b/B`, `ge/gE`, `0`, `^`, `$`, `gg`, `G`
  - operators: `dd`, `dw/db/de/d0/d$`, `diw/daw`, `cw/ce/ciw/caw`, `cc`, `x`, `s/S`, `C/D`
  - visual: `v`, `V`, `o/O`, `d/x`, `y`, `>`, `<`, `~`, `U`, `u`
  - edit helpers: `r`, `R`, `J`, `gJ`, `o`, `O`, `yy`, `p`, `P`, `.`, `u`, `Ctrl-R`
- Search loop added in TUI editor: `/`, `?`, `Enter`, `n`, `N`.
- New TUI-focused unit tests were added for key vim behaviors (`gg`, `diw/ciw/daw`, undo/redo, `.`, search repeat, `gJ`, visual yank).
- Regression status: `make test` and strict clippy are green after the vim wave.

### Discovery TUI Vim Parity Extension Checkpoint (DONE)

- Added ex-style command mode in TUI: `:w`, `:q`, `:q!`, `:wq`, `:x`, and `:%s/old/new/g`.
- Added marks and registers support:
  - marks: `m<char>`, `` `<char>``, `' <char>`
  - registers: `"<char>` prefix for yank/delete/paste flows.
- Added find-family motions: `f/t/F/T` with `;` and `,` repeat.
- Added count prefixes for key motions/operators (examples: `3j`, `5x`, `2dd`, `5G`, `5gg`).
- Added word-under-cursor search shortcuts: `*` and `#`.
- Tab workflow aligned to vim-style preference: `Ctrl-N/Ctrl-P` and `gt/gT` (Tab/Shift-Tab removed).
- Expanded TUI test coverage for command mode, counts, marks/registers, search, and tab switching (`Ctrl-N/Ctrl-P`).
- Current outcome: discovery editor ergonomics are "more than enough" for this phase; focus shifts back to core forge workflow tasks.

### Runtime Integration Checkpoint (DONE)

- `forge provider openai-pro login` now supports browser OAuth flow (`/oauth/authorize` + localhost callback) and headless fallback.
- `forge doctor ping-provider` validated successful completion ping (`HTTP 200`) with OpenAI Pro flow.
- `forge doctor` now reports fully healthy environment after provider login.
- Global provider mode is now stable: `~/.config/forge/config.jsonc` + `~/.config/forge/openai-pro-session.json` are used across workspaces.
- Bootstrap workspace configs from `forge init` now correctly defer to global provider config (no accidental fallback to API-key path).
- Sandbox behavior hardened: Landlock permission-denied fallback to Bubblewrap is covered by integration test.

### End-of-Day Note

- Checkpoint complete for discovery TUI vim parity extension.
- Next implementation task is `T4.2 - Write discovery.md`.

### UI Decision Checkpoint (2026-03-16)

- `forge test-uis` baseline is now locked to **UI 4**.
- UI 4 is the selected control-room default (table readability + alternate progress style + section-like notes).
- Shared rendering primitives were extracted to `src/ui.rs`.
- `forge discover` recap output now uses shared UI rendering primitives.
- Remaining UI decision locks are tracked in `docs/TC_UI_guidelines.md` (`Final Decisions To Lock`).

### Sandbox Migration Testing Policy (Mandatory)

Landlock crate adoption is deferred until stronger tests are in place.

- **Manual testing (human/director)** is required at each migration step.
- **Automated testing (agent)** is required at each migration step:
  - unit tests for sandbox policy/allowlist construction
  - integration tests for real allow/deny filesystem behavior
  - e2e tests for wrapper routing and fallback behavior
- **No default switch** to crate-based enforcement until manual + automated checks are both green.

### Sandbox Migration Execution Checklist (Landlock Crate)

Use this staged checklist before any default switch to Rust `landlock` crate enforcement.

#### Phase 0 - Baseline freeze (current behavior)
- [ ] Confirm current `landrun -> bwrap` behavior remains green in CI/local.
- [ ] Freeze baseline expectations in docs and tests before crate integration.

#### Phase 1 - Test harness first (no behavior change)
- [ ] Add unit tests for sandbox policy/allowlist derivation.
- [ ] Add integration tests that verify allowed writes succeed.
- [ ] Add integration tests that verify forbidden writes are blocked.
- [ ] Add e2e tests for wrapper routing (passive vs active commands).

#### Phase 2 - Crate integration behind guard (default OFF)
- [ ] Add `landlock` crate integration behind feature flag/internal guard.
- [ ] Keep existing wrapper and `bwrap` fallback unchanged.
- [ ] Add tests for crate path initialization success/failure handling.

#### Phase 3 - Controlled enablement
- [ ] Enable crate path in controlled mode while preserving fallback behavior.
- [ ] Add regression tests for fallback on unsupported kernel/permission failures.
- [ ] Verify doctor/status messaging accurately reports effective sandbox path.

#### Phase 4 - Default switch gate
- [ ] Manual validation by director (required at this phase):
  - [ ] `forge build`, `forge sync`, and `forge task add` run in real workspace.
  - [ ] Allowed paths are writable (`workspace`, `.forge/logs`, `.dstask`).
  - [ ] Forbidden write attempts outside allowed scope are denied.
- [ ] Automated validation by agent (required at this phase):
  - [ ] Unit + integration + e2e suites pass.
  - [ ] Existing security/wrapper regressions remain green.
- [ ] Only then: approve default switch to crate-based enforcement.

### How to Verify Runtime Status

Run these commands from inside a forge-initialized workspace:

```bash
forge status
forge doctor
forge doctor ping-provider
forge task list
```

Notes:
- `forge doctor` checks environment and completion readiness (including billing/credits).
- `forge doctor ping-provider` provides detailed provider error output for troubleshooting.

## Milestone 1: Build Infrastructure 🏗️
*(All tasks completed and verified)*

---

## Milestone 2: Native Provider Integration (MVP) 🎯

### T2.1 - Provider config schema
**Status**: completed  
**Methodology**: TDD  
**Estimated**: 60 min  
**Dependencies**: T1.6

Define `.forge/config.toml` schema for provider integration and validate required fields.

**Validation:**
- [x] Config loads from workspace
- [x] Missing required fields returns error

---

### T2.2 - OpenAI-compatible provider client
**Status**: completed  
**Methodology**: TDD  
**Estimated**: 90 min  
**Dependencies**: T2.1

Implement a provider client that can call OpenAI-compatible endpoints.

**Validation:**
- [x] Requires API key or env var
- [x] Builds request payload correctly

---

### T2.3 - Build command integration
**Status**: completed  
**Methodology**: TDD  
**Estimated**: 60 min  
**Dependencies**: T2.2

Route `forge build` through the provider layer and log responses.

**Validation:**
- [x] `forge build` reads provider config
- [x] Build output logged to `.forge/logs`

---

### T2.4 - Provider regression tests
**Status**: completed  
**Methodology**: TDD  
**Estimated**: 60 min  
**Dependencies**: T2.3

Add unit tests for config parsing and provider validation.

**Validation:**
- [x] Tests pass for config loading scenarios
- [x] Missing API key is handled cleanly

---

## Milestone 3: Task Synchronization (dstask Integration) 🔄

### T3.1 - native dstask backend
**Status**: completed  
**Methodology**: traditional  
**Estimated**: 90 min  
**Dependencies**: T1.5

Implement `DstaskBackend` using UUID-named YAML files in `~/.dstask` or local `.dstask`.

**Validation:**
- [x] `forge task add` creates valid YAML
- [x] `forge task list` filters by project
- [x] Tasks are automatically committed to Git

---

### T3.2 - Workspace-local tasks
**Status**: completed  
**Methodology**: traditional  
**Estimated**: 45 min  
**Dependencies**: T3.1

Prioritize `.dstask` folder within the project workspace for isolation.

**Validation:**
- [x] `forge init` bootstraps local `.dstask`
- [x] `forge doctor` identifies local vs global repository

---

### T3.3 - Secure Wrapper Routing
**Status**: completed  
**Methodology**: traditional  
**Estimated**: 60 min  
**Dependencies**: T2.6, T3.1

Update wrapper to allow passive commands (help/doctor) to run directly while sandboxing active ones.

**Validation:**
- [x] `forge help` works without landrun
- [x] `forge build` triggers Landlock/Bubblewrap fallback

---

### T3.4 - Regression Guards (Frozen Fixes)
**Status**: completed  
**Methodology**: TDD  
**Estimated**: 60 min  
**Dependencies**: T3.3

Add unit and E2E tests to ensure accessibility and integration stability.

**Validation:**
- [x] Unit tests for security environment checks
- [x] Unit tests for dstask path discovery
- [x] E2E tests for passive command accessibility

---

## Milestone 4: Discovery Phase Implementation 🔍

### T4.1 - Hardcoded questions
**Status**: completed  
**Methodology**: TDD  
**Estimated**: 60 min  
**Dependencies**: T1.6

Implement `forge discover` with 3-5 hardcoded questions about the feature.

**Validation:**
- [x] `forge discover` prompts 5 hardcoded discovery questions
- [x] Empty answers trigger reprompt
- [x] Discovery recap is printed at completion

---

### T4.2 - Write discovery.md
**Status**: pending  
**Methodology**: TDD  
**Estimated**: 45 min  
**Dependencies**: T4.1

Save answers to `docs/plans/{session}/discovery.md`.

---

## Milestone 7.1: 🎉 SELF-BUILDING MILESTONE 🔄

### T7.1.1 - Use forge to build a new feature
**Status**: pending  
**Methodology**: dogfooding  
**Estimated**: 120 min  
**Dependencies**: M7

Successfully use the developed forge tool to implement Milestone 8 tasks.

---

*(Additional tasks for M4-M15 to be detailed as project progresses)*
