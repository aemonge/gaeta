# Plan Phase

## Overview

Plan is the **architectural design** phase where the Architect Agent turns the approved
Discovery output into a concrete implementation strategy. It defines *how* to build what
Discovery clarified.

**Input**: `project_overview.md` (from Discovery)\
**Output**: `plan.md` + `tasks.yaml` (+ optional `inventory.yaml` if used)

## Purpose

Bridge requirements → implementation without writing code.

- Identify architecture and boundaries.
- Choose methodologies (TDD, inventory-driven, traditional).
- Decompose work into small, verifiable tasks.
- Minimize surprises during Build.

## Responsibilities

### Architect Agent

- Reads `project_overview.md` thoroughly.
- (Optionally) reads `inventory.yaml` when working on existing code.
- Proposes architecture and approach.
- Breaks work into tasks with clear acceptance criteria.
- Flags dependencies and risks.
- Produces `plan.md` + `tasks.yaml`.

### Human

- Reviews architecture.
- Adjusts scope, constraints, and priorities.
- Approves or requests revisions.
- Confirms methodology (TDD vs inventory-driven vs traditional).
- Confirms dependency strategy (what to install, when).

## Process Flow

```
Input: project_overview.md
    ↓
Architect Agent: Analyze context
    ├─ Identify domains, modules, boundaries
    ├─ Check for existing code (inventory if available)
    ├─ Select methodology per area (TDD, Inventory, Traditional)
    └─ Draft high-level architecture
    ↓
Architect Agent: Propose implementation strategy
    ├─ Data structures, interfaces, modules
    ├─ Flow diagrams (described in text / pseudo)
    ├─ Dependencies (crates/libs/tools)
    └─ Risks / trade-offs
    ↓
Architect Agent: Generate artifacts
    ├─ plan.md (narrative design)
    └─ tasks.yaml (ordered, small tasks with validations)
    ↓
Human: Review
    ├─ Approve → Build phase
    ├─ Revise → Provide constraints/feedback, regenerate
    └─ Reject → Possibly return to Discovery / Inventory
```

## plan.md Structure

A typical `plan.md` produced by the Architect Agent:

```markdown
# Plan: OAuth Authentication

## 1. Architecture Overview

### 1.1 High-Level Design

We will introduce an `OAuthProvider` trait to abstract provider-specific logic (Google,
GitHub). Each provider will implement this trait, and a central `OAuthService` will
orchestrate the flow.

Key components:

- `OAuthProvider` trait
- Provider implementations: `GoogleOAuthProvider`, `GitHubOAuthProvider`
- `OAuthService` for high-level flow
- Auth routes for redirect and callback
- JWT-based session generation

### 1.2 Modules

- `src/auth/oauth/`
  - `mod.rs` (trait + service)
  - `google.rs` (Google implementation)
  - `github.rs` (GitHub implementation)
  - `types.rs` (DTOs, config types)
  - `error.rs` (error types)

- `src/routes/auth.rs`
  - OAuth routes (init + callback)

- `templates/login.html`
  - OAuth buttons

### 1.3 Methodology

- Core logic (trait + providers): **TDD** (test-first).
- Integration with existing routes: **Inventory-Driven** (respect patterns from current
  `routes` module).
- UI changes: **Traditional** (HTML, then tests).

## 2. Data Structures & Interfaces

### 2.1 OAuthProvider Trait

Methods:

- `auth_url(state) -> Url`
- `exchange_code(code) -> AccessToken`
- `get_user_profile(token) -> UserProfile`

### 2.2 Types

- `OAuthConfig` (client_id, client_secret, redirect_uri, scopes)
- `AccessToken` (token, expires_at)
- `UserProfile` (email, name, avatar_url, provider)

### 2.3 Error Handling

- `OAuthError` enum (InvalidState, ProviderError, NetworkError, ...)

## 3. Flow

### 3.1 Login Flow (Happy Path)

1. User clicks "Sign in with Google/GitHub".
2. Frontend calls `/auth/oauth/{provider}`.
3. Backend generates state token, stores it (e.g., in cookie), returns redirect.
4. User authenticates with provider.
5. Provider redirects to `/auth/oauth/callback` with `code` and `state`.
6. Backend validates `state`.
7. Backend exchanges `code` for access token.
8. Backend fetches user profile.
9. Backend creates/updates user record.
10. Backend issues JWT and sets cookie / returns token.

### 3.2 Error/Edge Cases

- State mismatch → abort, log, show error.
- Network failures → retry once, then fail.
- Provider down → user-friendly error + password fallback (if available).

## 4. Dependencies

Crates:

- `oauth2 = "4.4"` (if not present)
- `jsonwebtoken = "8"` (reuse if present)
- `reqwest = "0.11"` (if not present)

Installation:

- Prior to Build: add `oauth2` and `reqwest`.
- JWT assumed present; if not, add as chore task.

## 5. Risks & Trade-offs

- Dependency on external OAuth APIs (availability).
- Handling partial failures (token issued but DB down).
- Security sensitivity (state, redirect URIs).

## 6. Task Breakdown

See `tasks.yaml` for detailed steps.
```

## tasks.yaml Structure

`tasks.yaml` is the **contract** for the Build phase: small, ordered, verifiable units
of work.

### Core Fields

- `id`: Short task id (`T1`, `T2`, …).
- `title`: One-line description.
- `description`: What to do (brief).
- `methodology`: `tdd` | `inventory` | `traditional`.
- `depends_on`: Optional list of task IDs.
- `validation`: Commands/checks to run.
- `files_hint`: Expected files to touch (for Build agent guidance).
- `notes`: Additional constraints.

### Example tasks.yaml (excerpt)

```yaml
tasks:
  - id: T1
    title: "Write failing tests for OAuthProvider trait"
    description: >
      Define test cases for auth_url, exchange_code, and get_user_profile
      covering both success and error scenarios.
    methodology: tdd
    depends_on: []
    validation:
      - "cargo test oauth_provider -- --nocapture"
    files_hint:
      - "tests/auth/oauth_provider_test.rs"

  - id: T2
    title: "Implement OAuthProvider trait and core types"
    description: >
      Implement OAuthProvider trait and minimal types to satisfy tests from T1.
    methodology: tdd
    depends_on: ["T1"]
    validation:
      - "cargo test oauth_provider -- --nocapture"
    files_hint:
      - "src/auth/oauth/mod.rs"
      - "src/auth/oauth/types.rs"

  - id: T3
    title: "Write failing tests for GoogleOAuthProvider"
    description: >
      Add tests for Google-specific OAuth flow, using test client IDs.
    methodology: tdd
    depends_on: ["T2"]
    validation:
      - "cargo test google_oauth -- --nocapture"
    files_hint:
      - "tests/auth/google_oauth_test.rs"

  - id: T4
    title: "Implement GoogleOAuthProvider"
    description: >
      Implement GoogleOAuthProvider using oauth2 crate, passing tests from T3.
    methodology: tdd
    depends_on: ["T3"]
    validation:
      - "cargo test google_oauth -- --nocapture"
    files_hint:
      - "src/auth/oauth/google.rs"
      - "src/auth/oauth/error.rs"

  - id: T5
    title: "Refactor OAuth core (extract common logic)"
    description: >
      Extract shared logic between providers, keeping tests green.
    methodology: tdd
    depends_on: ["T2", "T4"]
    validation:
      - "cargo test"
      - "cargo clippy --all-targets -- -D warnings"
    files_hint:
      - "src/auth/oauth/mod.rs"
      - "src/auth/oauth/google.rs"

  - id: T6
    title: "Inventory routes module"
    description: >
      Analyze existing auth routes and generate inventory.yaml with patterns.
    methodology: inventory
    depends_on: []
    validation:
      - "cat inventory.yaml | grep routes/auth"
    files_hint:
      - "src/routes/"
      - "inventory.yaml"

  - id: T7
    title: "Add OAuth routes following existing patterns"
    description: >
      Add /auth/oauth/{provider} and callback routes consistent with inventory.
    methodology: inventory
    depends_on: ["T5", "T6"]
    validation:
      - "cargo test routes::auth"
    files_hint:
      - "src/routes/auth.rs"

  - id: T8
    title: "Add OAuth buttons to login template"
    description: >
      Add Google/GitHub sign-in buttons and wire them to OAuth routes.
    methodology: traditional
    depends_on: ["T7"]
    validation:
      - "cargo test ui::login"
    files_hint:
      - "templates/login.html"

  - id: T9
    title: "Add UI tests for OAuth buttons"
    description: >
      Ensure OAuth buttons exist and link to correct routes.
    methodology: traditional
    depends_on: ["T8"]
    validation:
      - "cargo test ui::oauth_buttons"
    files_hint:
      - "tests/ui/login_oauth_test.rs"
```

## Methodology Selection

The Architect Agent tags each task with a methodology:

- **TDD**
  - New business logic.
  - Non-trivial flows and error handling.
  - Needs confidence and regression safety.

- **Inventory-Driven**
  - Working inside existing code with established patterns.
  - Goal: follow the *inventory* instead of inventing new shapes.
  - Particularly for routes, handlers, services that already exist.

- **Traditional**
  - UI/layout tweaks, simple glue code.
  - Low risk, high visibility.
  - Often faster to iterate then cover with tests.

This tells the Dev/QA agents *how* to behave during Build.

## Human Review Loop

### What You Review in plan.md

- Architecture shape (modules, traits, boundaries).
- Risk/trade-off reasoning.
- Dependency choices (crates, versions, non-code tools).
- Mapping between requirements and tasks.

### What You Review in tasks.yaml

- Task granularity (small enough, not trivial).
- Order/dependencies (no obvious deadlocks).
- Validation commands (use your real build/test stack).
- Methodology tags (TDD vs inventory vs traditional).

### Typical Adjustments

- Tighten scope: remove or defer tasks.
- Change methodology for parts (e.g., insist on TDD for something critical).
- Change dependencies (prefer different crate or in-house solution).
- Reprioritize tasks (move risk earlier).

## Plan Phase Variants

### Greenfield Project

- No inventory.
- `plan.md` focuses on architecture from scratch.
- `tasks.yaml` starts at T1 with test-first or bootstrapping tasks.

### Refactor / Existing System

- Plan may depend heavily on `inventory.yaml`.
- Tasks include “stabilize tests” and “protect behavior” before refactor.
- Architecture changes described in terms of existing modules.

### Bug Fix / Hotfix

- Smaller `plan.md` (focused on the bug’s area).
- Very short `tasks.yaml` (2–5 tasks).
- Emphasis on reproducer test + fix + regression coverage.

## Duration

- Small feature / bugfix: 15–30 minutes.
- Medium feature: 30–60 minutes.
- Large/architectural: 1–2 hours (often with inventory).

## Phase Exit Criteria

Plan phase is **complete** when:

- `project_overview.md` is stable (no blocking open questions).
- `plan.md` explains architecture and flow in a way you’d accept from a senior engineer.
- `tasks.yaml` covers the work end-to-end with clear validation.
- You explicitly approve.

After approval, Build starts using these artifacts as the blueprint.
