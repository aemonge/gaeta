# Workflow Guide

## Overview

`forge` operates through a **five-phase development cycle** with explicit human approval
gates between phases. This guide details each phase, its artifacts, and how feedback
flows between phases.

## The Five Phases

```
Discovery → [Gate] → **(Inventory - OPTIONAL)** → [Gate] → Plan → [Gate] → Build → [Gate] → Presentation → [Gate] → Suggestions
```

**Note on Inventory phase:**

Inventory is an **optional phase** that runs before Plan when working with existing codebases:
- **Run Inventory when**: Extending existing code, refactoring, or unfamiliar codebase
- **Skip Inventory when**: Greenfield projects, isolated new features, or patterns are already known

See [Inventory Phase](./inventory.md) for detailed guidance.

**Key characteristics**:

- Each phase has clear inputs, outputs, and responsibilities
- Human gates prevent autonomous progression
- Feedback flows forward (inform next phase) and backward (iterate previous phase)
- All phases contribute to evolution engine

## Phase 1: Discovery

### Purpose

Understand **WHAT** to build and **WHY** it matters.

### Who

- **Product Agent**: Asks questions, synthesizes understanding
- **Human**: Provides domain knowledge, constraints, priorities

### Process Flow

```
Human: "I need OAuth authentication for my app"
    ↓
Product Agent:
    ├─ Asks clarifying questions:
    │  ├─ Which OAuth providers? (Google, GitHub, custom?)
    │  ├─ User stories? (sign up, sign in, profile access?)
    │  ├─ Constraints? (existing auth system, compliance requirements?)
    │  ├─ Success criteria? (how do we know it works?)
    │  └─ Timeline? (urgency, dependencies on other work?)
    │
    └─ Generates artifacts
    ↓
Artifacts Created:
    ├─ project_overview.md [REQUIRED]
    └─ user_stories.yaml [OPTIONAL]
    ↓
Human Review Gate:
    ├─ [✓] Approve → Proceed to Plan
    ├─ [✗] Reject with feedback → Document Gate → Agent regenerates
    ├─ [🔧] Approve with changes → Document Gate → Agent applies changes, then proceed
    └─ [?] Questions → Document Gate → Agent clarifies

### Gate States and Documentation

When forge pauses for human input or hits a blocker, it creates a **Gate Document** in `docs/plans/{session}/gates/gate-{timestamp}.md`. This ensures every decision and pause reason is tracked and auditable.
```

### Artifacts

**project_overview.md** [REQUIRED]

```markdown
# Project: OAuth Authentication

## Vision

Add OAuth 2.0 authentication to allow users to sign in with Google and GitHub accounts.

## Goals

1. Users can sign in with Google OAuth
2. Users can sign in with GitHub OAuth
3. User profile data synced on successful auth
4. Existing session management integrates seamlessly

## Non-Goals

- Custom OAuth provider support (future work)
- Multi-factor authentication (separate project)
- Social features beyond authentication

## Success Criteria

- OAuth flow completes successfully for both providers
- User can access protected resources after auth
- Session persists across browser sessions
- Error states handled gracefully (denied permissions, network errors)

## Constraints

- Must use existing User model (no schema changes)
- Must work with current session management (Redis-backed)
- GDPR compliance required (data minimization)

## Risks

- OAuth provider downtime affects our login
- Token refresh logic can be complex
- Security vulnerabilities in implementation
```

**user_stories.yaml** [OPTIONAL]

```yaml
user_stories:
  - id: US1
    title: Sign in with Google
    as_a: new user
    i_want_to: sign in using my Google account
    so_that: I don't need to create a new password
    acceptance_criteria:
      - OAuth redirect to Google works
      - User grants permissions
      - Profile data (name, email) saved
      - User redirected back to app with valid session

  - id: US2
    title: Sign in with GitHub
    as_a: developer user
    i_want_to: sign in using my GitHub account
    so_that: I can use my existing developer identity
    acceptance_criteria:
      - OAuth redirect to GitHub works
      - User grants permissions
      - Profile data (username, email) saved
      - User redirected back to app with valid session

  - id: US3
    title: Handle OAuth errors
    as_a: user
    i_want_to: see clear error messages if OAuth fails
    so_that: I understand what went wrong
    acceptance_criteria:
      - Network errors shown with retry option
      - Permission denial shown with explanation
      - Invalid state/CSRF errors handled securely
```

### Typical Duration

- **Simple feature**: 15-30 minutes
- **Complex feature**: 1-2 hours
- **Large project**: Half day (includes multiple discovery sessions)

### Feedback Loops

**Forward (to Plan)**:

- Goals inform architecture decisions
- Constraints shape implementation approach
- Success criteria become validation rules

**Backward (iterate Discovery)**:

- Human rejects: "Non-goals should include custom providers"
- Agent regenerates with updated scope

**Lateral (to Evolution)**:

- Discovery patterns learned (common questions, typical constraints)
- Question effectiveness tracked (did it elicit useful info?)

### Common Escalations

**Ambiguity**:

```
Product Agent: "Goal 2 mentions 'seamlessly integrate' but doesn't specify:
- Should existing users be able to link OAuth accounts?
- Should OAuth-only users have passwords?
- How to handle email conflicts between OAuth and existing accounts?

Please clarify."
```

**Scope creep detected**:

```
Product Agent: "The goals list 5 OAuth providers, 3 admin features, and 2
analytics dashboards. This appears to be multiple projects.

Recommendation: Split into:
- Project A: OAuth (2 providers)
- Project B: Admin features
- Project C: Analytics

Proceed with split or keep as one large project?"
```

## Phase 2: Plan

### Purpose

Define **HOW** to build and **HOW** to validate success.

### Who

- **Architect Agent**: Designs architecture, breaks down tasks
- **Human**: Reviews approach, approves dependencies, confirms methodology

### Process Flow

```
Input: Approved project_overview.md (+ user_stories.yaml if exists)
    ↓
Architect Agent:
    ├─ (Optional) Generate inventory.yaml if modifying existing code
    │  └─ Analyzes affected modules, patterns, dependencies
    │
    ├─ Designs architecture
    │  ├─ Module structure
    │  ├─ Data flow
    │  ├─ Integration points
    │  └─ Risk mitigation
    │
    ├─ Chooses methodology per feature
    │  ├─ TDD for critical logic
    │  ├─ Inventory-Driven for existing code mods
    │  ├─ Traditional for simple changes
    │  └─ Documents rationale
    │
    ├─ Identifies dependencies
    │  └─ Lists what human must install
    │
    └─ Breaks down into tasks
       └─ Ordered by dependencies + methodology
    ↓
Artifacts Created:
    ├─ plan.md [REQUIRED]
    ├─ tasks.yaml [REQUIRED]
    ├─ methodology.yaml or inline in plan.md [OPTIONAL]
    ├─ features.yaml [OPTIONAL]
    └─ inventory.yaml [OPTIONAL - if analyzing existing code]
    ↓
Human Review Gate:
    ├─ Reviews architecture decisions
    ├─ Checks dependency list
    ├─ Confirms methodology choices
    ├─ Decides:
    │  ├─ [✓] Approve → Install dependencies → Proceed to Build
    │  ├─ [✗] Reject with feedback → Agent revises plan
    │  └─ [🔧] Approve with changes → Agent applies → Proceed
    │
    └─ If approved: Human installs dependencies
       └─ Example: cargo add oauth2@4.4
```

### Artifacts

**plan.md** [REQUIRED]

````markdown
# Implementation Plan: OAuth Authentication

## Architecture Overview

### New Modules

- `src/auth/oauth/mod.rs` - OAuth core traits and types
- `src/auth/oauth/google.rs` - Google OAuth provider
- `src/auth/oauth/github.rs` - GitHub OAuth provider
- `src/auth/oauth/callback.rs` - Callback handler

### Modified Modules

- `src/auth/mod.rs` - Add OAuth integration
- `src/routes/auth.rs` - Add OAuth routes
- `src/models/user.rs` - Add OAuth fields (provider, provider_id)

### Data Flow

1. User clicks "Sign in with Google"
2. Redirect to Google OAuth with state token (CSRF protection)
3. Google redirects to callback URL with auth code
4. Exchange code for access token
5. Fetch user profile from Google API
6. Create or update User record
7. Create session and redirect to app

## Design Decisions

**Decision 1: Trait-based provider abstraction**

- Rationale: Allows future providers without duplicating flow logic
- Trade-off: Slight complexity increase, but worth it for extensibility

**Decision 2: Store provider + provider_id, not full profile**

- Rationale: Data minimization (GDPR), reduce storage
- Trade-off: Can't display provider avatar without refetch

**Decision 3: Use existing session system**

- Rationale: Reuse Redis session management
- Trade-off: None, constraint satisfied

## Dependencies Required

**Human must install before Build phase:**

1. `oauth2 = "4.4"`
   - Purpose: OAuth 2.0 client implementation
   - Installation: `cargo add oauth2@4.4`

2. `reqwest = { version = "0.11", features = ["json"] }`
   - Purpose: HTTP client for API calls
   - Installation: `cargo add reqwest --features json`

**Note**: After installing, commit separately:

```bash
git commit -m "chore: add OAuth dependencies (oauth2, reqwest)"
```

## Methodology

- **Tasks T1-T5 (OAuth core)**: TDD
  - Rationale: Critical authentication logic, security-sensitive

- **Tasks T6-T7 (Route integration)**: Inventory-Driven
  - Rationale: Modifying existing routes, must respect patterns

- **Tasks T8-T9 (UI buttons)**: Traditional
  - Rationale: Simple UI changes, straightforward

## Risk Mitigation

**Risk 1: OAuth provider downtime**

- Mitigation: Graceful error handling, fallback to password auth
- Validation: Test with provider unreachable

**Risk 2: Token refresh complexity**

- Mitigation: Use oauth2 crate's built-in refresh logic
- Validation: Integration test for expired tokens

**Risk 3: CSRF attacks**

- Mitigation: State parameter with secure random token
- Validation: Security test attempts CSRF

## Integration Points

- User model: Add fields (migration needed? No - using JSON column)
- Session system: No changes (stores user_id as before)
- Routes: Add `/auth/oauth/{provider}` and `/auth/oauth/callback`

## Timeline Estimate

- Task breakdown: 9 tasks
- Estimated time: 4-6 hours (Build phase)
- High confidence: Architecture is straightforward
````

**tasks.yaml** [REQUIRED]

```yaml
tasks:
  # TDD approach for OAuth core (T1-T5)
  - id: T1
    phase: red
    title: Write failing tests for OAuth trait
    description: |
      Define OAuthProvider trait and write tests that expect:
      - auth_url() returns correct redirect URL
      - exchange_code() fetches access token
      - get_user_profile() returns user data
    methodology: tdd
    estimated_duration: 30m

  - id: T2
    phase: green
    title: Implement OAuthProvider trait
    description: Minimal implementation to pass T1 tests
    methodology: tdd
    dependencies: [T1]
    estimated_duration: 45m

  - id: T3
    phase: red
    title: Write failing tests for Google provider
    description: Tests for Google-specific OAuth flow
    methodology: tdd
    dependencies: [T2]
    estimated_duration: 30m

  - id: T4
    phase: green
    title: Implement Google OAuth provider
    description: GoogleOAuthProvider implementing OAuthProvider trait
    methodology: tdd
    dependencies: [T3]
    estimated_duration: 1h

  - id: T5
    phase: refactor
    title: Refactor OAuth core for GitHub reuse
    description: Extract common logic, ensure GitHub can reuse
    methodology: tdd
    dependencies: [T4]
    estimated_duration: 30m

  # Inventory-driven for integration (T6-T7)
  - id: T6
    phase: analysis
    title: Generate inventory for routes module
    description: Analyze src/routes/ to understand patterns
    methodology: inventory_driven
    dependencies: [T5]
    estimated_duration: 15m

  - id: T7
    phase: implementation
    title: Add OAuth routes following existing patterns
    description: |
      Add routes:
      - GET /auth/oauth/google
      - GET /auth/oauth/github
      - GET /auth/oauth/callback
      Match existing route structure from inventory
    methodology: inventory_driven
    dependencies: [T6]
    estimated_duration: 1h

  # Traditional for simple UI (T8-T9)
  - id: T8
    title: Add OAuth sign-in buttons to login page
    description: |
      Add buttons:
      - "Sign in with Google"
      - "Sign in with GitHub"
      Link to OAuth routes
    methodology: traditional
    dependencies: [T7]
    estimated_duration: 30m

  - id: T9
    title: Add tests for UI buttons
    description: Basic rendering and link tests
    methodology: traditional
    dependencies: [T8]
    estimated_duration: 30m

validation:
  automated:
    - check: all_tests_pass
      command: cargo test

    - check: oauth_flow_integration
      command: cargo test --test oauth_integration

    - check: security_checks
      command: cargo clippy -- -D warnings

  manual:
    - check: google_oauth_flow
      steps:
        - Click "Sign in with Google"
        - Grant permissions
        - Verify redirect back with session

    - check: github_oauth_flow
      steps:
        - Click "Sign in with GitHub"
        - Grant permissions
        - Verify redirect back with session
```

**methodology.yaml** [OPTIONAL - can be inline in plan.md]

```yaml
methodology:
  tasks:
    T1-T5:
      approach: tdd
      rationale: "Critical auth logic, test-first essential"

    T6-T7:
      approach: inventory_driven
      rationale: "Modifying existing routes, respect patterns"

    T8-T9:
      approach: traditional
      rationale: "Simple UI, straightforward implementation"
```

**inventory.yaml** [OPTIONAL - only if analyzing existing code]

```yaml
# Generated by Architect Agent analyzing src/routes/

inventory:
  module: src/routes/

  patterns_detected:
    - pattern: route_handler_signature
      example: "pub async fn handler(State(app): State<AppState>, Json(req): Json<RequestType>) -> Result<Json<ResponseType>>"
      rationale: "All handlers use axum extractors consistently"

    - pattern: error_handling
      example: ".map_err(|e| AppError::from(e))"
      rationale: "Errors converted to AppError for consistent responses"

    - pattern: validation
      example: "req.validate()?;"
      rationale: "All requests validated before processing"

  dependencies:
    - module: src/models/user.rs
      used_types: [User, UserId]

    - module: src/auth/session.rs
      used_functions: [create_session]

  architecture_notes:
    - "Routes organized by feature (/auth, /api, /admin)"
    - "Each route file has tests in tests/ matching structure"
    - "State management via axum State extractor"

  recommendation:
    "Add OAuth routes to src/routes/auth.rs (existing file).
     Follow established patterns for extractors, error handling, and validation.
     Add tests to tests/routes/auth_test.rs."
```

### Typical Duration

- **Simple feature**: 30 minutes - 1 hour
- **Complex feature**: 2-4 hours
- **Large project**: Half day to full day

### Feedback Loops

**Forward (to Build)**:

- Architecture guides implementation
- Tasks define work order
- Validation rules become automated checks
- Dependency list ensures Build can proceed

**Backward (iterate Plan)**:

- Human: "This architecture introduces too much complexity"
- Agent revises with simpler approach

**Backward (to Discovery)**:

- Human: "This plan assumes features not in scope"
- Return to Discovery to clarify scope

**Lateral (to Evolution)**:

- Planning patterns learned (effective architectures, task granularity)
- Dependency prediction accuracy tracked

### Common Escalations

**Missing information**:

```
Architect Agent: "Cannot design OAuth integration without knowing:
- Does User model have OAuth fields already?
- What is current authentication mechanism?
- Are there existing OAuth dependencies?

Recommend: Enable inventory-driven mode to analyze existing code.
Proceed? [y/n]"
```

**Dependency conflicts**:

```
Architect Agent: "Task T5 requires refactoring src/auth/mod.rs, but
inventory shows high complexity (800 LOC, 15 functions).

Options:
1. Proceed with refactor (risky, may introduce bugs)
2. Create separate module (safer, slight duplication)
3. Return to Discovery to split into smaller project

Recommendation: Option 2 (safer)
Your decision?"
```

## Phase 3: Build

### Purpose

Implement features according to plan with **continuous human collaboration** and
validation.

### Who

- **Dev Agent**: Implements tasks from tasks.yaml
- **QA Agent**: Validates each task against success criteria
- **Human**: Reviews each step, runs custom validations, commits manually

### Philosophy

**Build phase is collaborative, not autonomous.**

Unlike other AI coding tools that run to completion, forge **requires human
participation at each step**:

- You review changes after each task (or small batch)
- You run your own validation commands
- You install dependencies when needed
- You commit manually (forge NEVER executes or writes git commands)
- You maintain full control over git history. System suggests, but never touches Git.

**Why**: You are the director. Each commit is a decision point.

### Process Flow

````
Input: Approved plan.md + tasks.yaml (+ initial dependencies installed by human)
    ↓
For each task in tasks.yaml (ordered):
    ├─ Dev Agent reads task + methodology
    │
    ├─ If methodology == TDD:
    │  ├─ RED: Write failing test
    │  ├─ Verify test fails (else error)
    │  ├─ GREEN: Implement minimal code
    │  ├─ Verify test passes
    │  └─ REFACTOR: Improve code, tests still pass
    │
    ├─ If methodology == Inventory-Driven:
    │  ├─ Read inventory.yaml
    │  ├─ Follow patterns detected
    │  ├─ Implement respecting boundaries
    │  └─ Verify no new refactor signals
    │
    ├─ If methodology == Traditional:
    │  ├─ Implement feature
    │  └─ Write tests after
    │
    ├─ Dev Agent marks task complete
    │  ├─ Logs: files modified, decisions made, issues encountered
    │  └─ Updates progress.yaml
    │
    ├─ QA Agent validates task
    │  ├─ Runs automated checks (tests, lint, build)
    │  ├─ Verifies methodology followed (if TDD, tests were first)
    │  ├─ Checks validation rules from tasks.yaml
    │  └─ Result: PASS or FAIL
    │
    ├─ If PASS: Continue to checkpoint
    └─ If FAIL: Dev Agent retries (max 3 attempts) or escalates
    ↓
After EACH task (or small batch, configurable):
    ┌─────────────────────────────────────────────────────┐
    │         HUMAN STEP-BY-STEP CHECKPOINT               │
    └─────────────────────────────────────────────────────┘

    forge pauses and presents:

    ┌─────────────────────────────────────────────────────┐
    │ Task T2 Complete: Implement OAuthProvider trait     │
    │                                                     │
    │ Changes:                                            │
    │   M src/auth/oauth/mod.rs (+127 lines)              │
    │   A src/auth/oauth/types.rs (+45 lines)             │
    │                                                     │
    │ Validation: ✓ All tests pass (cargo test)           │
    │                                                     │
    │ Suggested commit message:                           │
    │   feat(auth): implement OAuth provider trait        │
    │                                                     │
    │ What would you like to do?                          │
    │                                                     │
    │ [r] Review code (opens diff in $EDITOR)             │
    │ [t] Run custom tests (enter command)                │
    │ [m] Run make command (e.g., make test, make lint)   │
    │ [i] Install dependency (if needed)                  │
    │ [✗] Reject and revise (provide feedback)            │
    │ [✓] Approve (continue to next task)                 │
    │ [s] Show suggested commit message in terminal       │
    │ [q] Quit (save session, resume later)               │
    │                                                     │
    │ Note: Commit manually when ready:                   │
    │   $ git add .                                       │
    │   $ git commit -m "feat(auth): implement trait"     │
    └─────────────────────────────────────────────────────┘

    Human chooses action:

    ├─ [r] Review code
    │  ├─ Opens git diff in $EDITOR (nvim, vim, etc.)
    │  ├─ Human reviews changes
    │  └─ Returns to checkpoint menu
    │
    ├─ [t] Run custom tests
    │  ├─ Prompt: "Enter command: "
    │  ├─ Human types: cargo test --features oauth
    │  ├─ forge runs in sandbox, shows output
    │  └─ Returns to checkpoint menu
    │
    ├─ [m] Run make command
    │  ├─ Prompt: "Enter make target: "
    │  ├─ Human types: make test (or make lint, make coverage, etc.)
    │  ├─ forge runs: make test
    │  ├─ Shows output
    │  └─ Returns to checkpoint menu
    │
    ├─ [i] Install dependency
    │  ├─ Prompt: "Enter install command: "
    │  ├─ Human types: cargo add serde --features derive
    │  ├─ forge shows: "Exit forge and run this command in your terminal"
    │  ├─ forge pauses, saves state
    │  ├─ Human runs command outside forge
    │  ├─ Human resumes: forge resume
    │  └─ forge detects changes, continues
    │
    ├─ [✗] Reject and revise
    │  ├─ Prompt: "Feedback: "
    │  ├─ Human types feedback: "Use builder pattern instead"
    │  ├─ Dev Agent revises based on feedback
    │  ├─ QA Agent re-validates
    │  └─ Returns to checkpoint menu with revised changes
    │
    ├─ [✓] Approve
    │  ├─ forge logs approval
    │  ├─ forge continues to next task
    │  └─ Human commits manually when ready (outside forge)
    │
    ├─ [s] Show suggested commit message
    │  ├─ Prints to terminal:
    │  │  ```
    │  │  feat(auth): implement OAuth provider trait
    │  │
    │  │  Defined OAuthProvider trait with async methods for:
    │  │  - auth_url() - Generate OAuth redirect URL
    │  │  - exchange_code() - Exchange auth code for token
    │  │  - get_user_profile() - Fetch user profile data
    │  │
    │  │  Added OAuthConfig struct for provider configuration.
    │  │  ```
    │  └─ Returns to checkpoint menu
    │
    └─ [q] Quit and save
       ├─ forge saves session state:
       │  ├─ Current task progress
       │  ├─ Uncommitted changes
       │  └─ Agent conversation history
       ├─ Human can commit manually: git commit ...
       ├─ Resume later: forge resume <session_id>
       └─ Useful for: breaks, context switching, emergencies
    ↓
After batch of tasks (or explicit checkpoint):
    forge shows summary:

    ┌─────────────────────────────────────────────────────┐
    │         BATCH SUMMARY: Tasks T1-T5 Complete         │
    │                                                     │
    │ Tasks completed: 5                                  │
    │ Files modified: 8                                   │
    │ Tests added: 12                                     │
    │                                                     │
    │ All automated checks: PASS                          │
    │                                                     │
    │ Suggested batch commit message:                     │
    │   feat(auth): implement OAuth core (T1-T5)          │
    │                                                     │
    │ Continue to next batch? [y/n]                       │
    │ Or return to a previous task? [task_id]             │
    │                                                     │
    │ Commit manually when ready:                         │
    │   $ git add .                                       │
    │   $ git commit -m "..."                             │
    └─────────────────────────────────────────────────────┘
    ↓
When all tasks complete:
    Build phase done → Proceed to Presentation
````

### Checkpoint Frequency (Configurable)

**Default**: After each task

**Options**:

```
# In forge config or per-project
checkpoint_mode: per_task          # Stop after each task (default)
checkpoint_mode: per_feature       # Stop after logical feature complete
checkpoint_mode: batch             # Stop every N tasks (e.g., every 3)
checkpoint_mode: manual            # Only when human presses Ctrl+C
```

**Recommendation**: Start with `per_task`, adjust based on project complexity.

### Interactive Commands Available at Checkpoints

| Command | Description         | Example                                   |
| ------- | ------------------- | ----------------------------------------- |
| **r**   | Review code         | Opens diff in $EDITOR                     |
| **t**   | Run custom test     | `cargo test --lib oauth`                  |
| **m**   | Run make target     | `make test`, `make lint`, `make coverage` |
| **i**   | Install dependency  | Exit forge, run `cargo add oauth2@4.4`    |
| **✗**   | Reject & revise     | Provide feedback, agent retries           |
| **✓**   | Approve             | Continue to next task                     |
| **s**   | Show commit message | Display suggested message to copy         |
| **q**   | Quit & save         | Save session, resume later                |

### Extended Review Diff (Planned)

The Review code step is planned to support an **extended diff tool** that goes
beyond a raw patch and summarizes structural changes using tree-sitter AST
analysis, with `syndiff` as the core diff engine.

**Baseline summary (promised):**

- Functions/methods added, removed, changed
- Types added, removed, changed (class/struct/enum/trait/interface)
- Modules/namespaces added, removed, changed
- Fields/properties added, removed, changed
- Top-level constants added, removed, changed

**Best-effort/optional (heuristic):**

- Local variables added/removed/changed
- Imports/uses and visibility changes
- Signature changes (params/return types)
- Inheritance/implements/trait bounds
- Decorators/annotations/macros

**Output shape (proposed):**

- Summary counts + named lists (per file and overall)
- Optional unified diff output (via `syndiff`)
- Confidence tagging per category when heuristics are used

**Planned CLI usage:**

```
# Summary only (default)
forge diff --summary

# Summary + unified diff output
forge diff --summary --patch

# Scope to a path or file
forge diff --summary src/lib.rs

# Compare two paths directly
forge diff --summary --from path/a --to path/b
```

**Review code integration (planned):**

- `r` (Review code) will show the extended summary first
- Optional prompt to open the full diff in `$EDITOR`

### Why Step-by-Step Checkpoints

**Human controls ALL git operations**:

- forge NEVER executes git commands
- forge can SUGGEST commit messages
- forge can SHOW diffs
- Human executes: `git add`, `git commit`, `git push`

**Clean git history**:

- Each task = one commit (your decision)
- Or batch multiple tasks into one commit
- Easy to bisect bugs
- Clear progression visible in git log

**Full control**:

- Review each change before committing
- Run your own validation commands
- Install dependencies as needed (not in advance)

**Flexibility**:

- Can batch tasks if desired (approve multiple, commit once)
- Can reject and iterate individual tasks
- Can pause and resume anytime

**Real-world workflow**:

- Matches how experienced developers work
- Director-level decisions at each step
- Not "wait 4 hours then review 847 lines"

### Example: Interactive Build Session

```
$ forge build

Task T1: Write failing tests for OAuth trait
→ Dev Agent writes tests
→ QA Agent validates: Tests fail ✓

┌───────────────────────────────────────────────────────────┐
│ Task T1 Complete                                          │
│ A tests/auth/oauth_test.rs (+85 lines)                    │
│ Validation: ✓ Tests fail as expected (TDD RED)            │
│                                                           │
│ Suggested commit message:                                 │
│   test(auth): add OAuth provider trait tests              │
│                                                           │
│ [r] Review  [t] Test  [m] Make  [✓] Approve  [s] Show msg │
└───────────────────────────────────────────────────────────┘

You: r ↵

# Opens in nvim, you review tests
# Looks good, exit editor

You: s ↵

Suggested commit message:
───────────────────────────────────────────────────────
test(auth): add OAuth provider trait tests (TDD RED)

Added failing tests for OAuthProvider trait:
- test_oauth_provider_auth_url()
- test_oauth_provider_exchange_code()
- test_oauth_provider_get_user_profile()

Tests fail as expected (TDD RED phase).
───────────────────────────────────────────────────────

Press Enter to continue... ↵

You: ✓ ↵

Approved. Continue to Task T2.

You switch to your terminal and commit:
$ git add tests/auth/oauth_test.rs
$ git commit -m "test(auth): add OAuth provider trait tests (TDD RED)"
[feature/oauth a3f2b5c] test(auth): add OAuth provider trait tests (TDD RED)

───────────────────────────────────────────────────────

Task T2: Implement OAuthProvider trait
→ Dev Agent implements trait
→ QA Agent validates: Tests pass ✓

┌───────────────────────────────────────────────────────────┐
│ Task T2 Complete                                          │
│ A src/auth/oauth/mod.rs (+127 lines)                      │
│ A src/auth/oauth/types.rs (+45 lines)                     │
│ Validation: ✓ All tests pass (TDD GREEN)                  │
│                                                           │
│ Suggested commit message:                                 │
│   feat(auth): implement OAuth provider trait              │
│                                                           │
│ [r] Review  [t] Test  [m] Make  [✓] Approve  [s] Show msg │
└───────────────────────────────────────────────────────────┘

You: m ↵
Enter make target: test ↵

Running: make test
  cargo test --lib
  running 12 tests
  test result: ok. 12 passed; 0 failed

Press Enter to continue... ↵

You: ✓ ↵

Approved. Continue to Task T3.

You commit manually:
$ git add src/auth/
$ git commit -m "feat(auth): implement OAuth provider trait (TDD GREEN)"
[feature/oauth b7e9c1a] feat(auth): implement OAuth provider trait (TDD GREEN)

───────────────────────────────────────────────────────

Task T3: Write failing tests for Google provider
→ Dev Agent writes tests
→ QA Agent validates: Tests fail ✓

┌───────────────────────────────────────────────────────────┐
│ Task T3 Complete                                          │
│ M tests/auth/oauth_test.rs (+62 lines)                    │
│ Validation: ✓ Tests fail as expected (TDD RED)            │
│                                                           │
│ Suggested commit message:                                 │
│   test(auth): add Google OAuth provider tests             │
│                                                           │
│ [r] Review  [t] Test  [m] Make  [✓] Approve  [s] Show msg │
└───────────────────────────────────────────────────────────┘

You: t ↵
Enter command: cargo test google ↵

Running: cargo test google
  running 3 tests
  test test_google_auth_url_format ... FAILED
  test test_google_token_exchange ... FAILED
  test test_google_user_profile_parsing ... FAILED

Good - tests failing as expected (TDD RED phase)

Press Enter to continue... ↵

You: ✓ ↵

Approved. Continue to Task T4.

You commit:
$ git add tests/
$ git commit -m "test(auth): add Google OAuth provider tests (TDD RED)"
[feature/oauth c2d4e8f] test(auth): add Google OAuth provider tests (TDD RED)

───────────────────────────────────────────────────────

Task T4: Implement Google OAuth provider
→ Dev Agent implements GoogleOAuthProvider
→ QA Agent validates: Tests pass ✓

┌───────────────────────────────────────────────────────────┐
│ Task T4 Complete                                          │
│ A src/auth/oauth/google.rs (+189 lines)                   │
│ Validation: ✓ All tests pass (TDD GREEN)                  │
│                                                           │
│ Suggested commit message:                                 │
│   feat(auth): implement Google OAuth provider             │
│                                                           │
│ [r] Review  [t] Test  [m] Make  [✓] Approve  [s] Show msg │
└───────────────────────────────────────────────────────────┘

You: r ↵

# Reviews implementation in nvim
# Notices potential issue with error handling

You: ✗ ↵
Feedback: Error handling for network failures should be more specific.
Add custom error types for timeout vs connection refused. ↵

→ Dev Agent revises error handling
→ Adds src/auth/oauth/error.rs with custom error types
→ QA Agent re-validates: Tests pass ✓

┌───────────────────────────────────────────────────────────┐
│ Task T4 Revised                                           │
│ M src/auth/oauth/google.rs                                │
│ A src/auth/oauth/error.rs (+34 lines)                     │
│ Validation: ✓ All tests pass                              │
│                                                           │
│ Suggested commit message:                                 │
│   feat(auth): implement Google OAuth with errors          │
│                                                           │
│ [r] Review  [t] Test  [m] Make  [✓] Approve  [s] Show msg │
└───────────────────────────────────────────────────────────┘

You: ✓ ↵

Approved. Continue to Task T5.

You commit:
$ git add src/auth/oauth/
$ git commit -m "feat(auth): implement Google OAuth provider with detailed errors"
[feature/oauth d5f1a3b] feat(auth): implement Google OAuth provider with detailed errors

───────────────────────────────────────────────────────

Task T5: Refactor OAuth core
→ Dev Agent refactors common logic
→ QA Agent validates: Tests still pass ✓

┌───────────────────────────────────────────────────────────┐
│ Task T5 Complete                                          │
│ M src/auth/oauth/mod.rs                                   │
│ M src/auth/oauth/google.rs                                │
│ Validation: ✓ All tests pass (TDD REFACTOR)               │
│                                                           │
│ Suggested commit message:                                 │
│   refactor(auth): extract common OAuth logic              │
│                                                           │
│ [r] Review  [t] Test  [m] Make  [✓] Approve  [s] Show msg │
└───────────────────────────────────────────────────────────┘

You: m ↵
Enter make target: lint ↵

Running: make lint
  cargo clippy --all-targets
  Checking oauth...
  warning: unused variable `state`
  --> src/auth/oauth/google.rs:45:9

Fix warnings before continuing? [y/n] y ↵

→ Dev Agent fixes clippy warnings
→ QA Agent re-validates

You: ✓ ↵

Approved. Continue to next batch.

You commit:
$ git add src/auth/
$ git commit -m "refactor(auth): extract common OAuth logic"
[feature/oauth e8a2b7d] refactor(auth): extract common OAuth logic

───────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────┐
│         BATCH SUMMARY: OAuth Core Complete          │
│                                                     │
│ Tasks completed: T1-T5                              │
│ Commits made by you: 5 commits                      │
│ All tests passing                                   │
│                                                     │
│ You can now push:                                   │
│   $ git push origin feature/oauth-authentication    │
│                                                     │
│ Continue to next batch (T6-T9)? [y/n]               │
└─────────────────────────────────────────────────────┘

You: y ↵
└─────────────────────────────────────────────────────┘

You: m ↵
Enter make target: lint ↵

Running: make lint
  cargo clippy --all-targets
  Checking oauth...
  warning: unused variable `state`
  --> src/auth/oauth/google.rs:45:9

Fix warnings before continuing? [y/n] y ↵

→ Dev Agent fixes clippy warnings
→ QA Agent re-validates

You: ✓ ↵

Approved. Continue to next batch.

You commit:
$ git add src/auth/
$ git commit -m "refactor(auth): extract common OAuth logic"
[feature/oauth e8a2b7d] refactor(auth): extract common OAuth logic

───────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────┐
│         BATCH SUMMARY: OAuth Core Complete          │
│                                                     │
│ Tasks completed: T1-T5                              │
│ Commits made by you: 5 commits                      │
│ All tests passing                                   │
│                                                     │
│ You can now push:                                   │
│   $ git push origin feature/oauth-authentication    │
│                                                     │
│ Continue to next batch (T6-T9)? [y/n]               │
└─────────────────────────────────────────────────────┘

You: y ↵

You manually push when ready:
$ git push origin feature/oauth-authentication
To github.com:yourorg/yourrepo.git
 * [new branch]      feature/oauth-authentication -> feature/oauth-authentication

───────────────────────────────────────────────────────

# Build continues with T6-T9...
```

### Artifacts

**Code changes** [REQUIRED]

- Modified source files (you commit them manually)
- New test files
- Updated documentation

**Git history** [RESULT OF YOUR MANUAL COMMITS]

```
$ git log --oneline

e8a2b7d refactor(auth): extract common OAuth logic
d5f1a3b feat(auth): implement Google OAuth provider with detailed errors
c2d4e8f test(auth): add Google OAuth provider tests (TDD RED)
b7e9c1a feat(auth): implement OAuth provider trait (TDD GREEN)
a3f2b5c test(auth): add OAuth provider trait tests (TDD RED)
```

**build_log.md** [REQUIRED]

```markdown
# Build Log: OAuth Authentication

## Interactive Session

### Task T1: Write failing tests for OAuth trait (RED phase)

- Started: 2026-02-02 10:15:00
- Duration: 28 minutes
- Methodology: TDD (RED)

Files created:

- `tests/auth/oauth_test.rs`

Tests written:

- `test_oauth_provider_auth_url()`
- `test_oauth_provider_exchange_code()`
- `test_oauth_provider_get_user_profile()`

Validation: Tests fail as expected ✓

**Human checkpoint**:

- Action: Reviewed code (r)
- Action: Showed commit message (s)
- Action: Approved (✓)
- Human committed manually: a3f2b5c

### Task T2: Implement OAuthProvider trait (GREEN phase)

- Started: 2026-02-02 10:43:00
- Duration: 42 minutes
- Methodology: TDD (GREEN)

Files created:

- `src/auth/oauth/mod.rs`
- `src/auth/oauth/types.rs`

Implementation:

- Defined `OAuthProvider` trait with required methods
- Added `OAuthConfig` struct for provider configuration
- Implemented basic types (AuthUrl, AccessToken, UserProfile)

Validation: All tests pass ✓

**Human checkpoint**:

- Action: Ran make test (m)
- Result: All 12 tests passed
- Action: Approved (✓)
- Human committed manually: b7e9c1a

### Task T3: Write failing tests for Google provider (RED phase)

- Started: 2026-02-02 11:25:00
- Duration: 25 minutes
- Methodology: TDD (RED)

Files modified:

- `tests/auth/oauth_test.rs`

Tests written:

- `test_google_auth_url_format()`
- `test_google_token_exchange()`
- `test_google_user_profile_parsing()`

Validation: Tests fail as expected ✓

**Human checkpoint**:

- Action: Ran custom test: cargo test google (t)
- Result: 3 tests failed as expected (TDD RED)
- Action: Approved (✓)
- Human committed manually: c2d4e8f

### Task T4: Implement Google OAuth provider (GREEN phase)

- Started: 2026-02-02 11:50:00
- Duration: 58 minutes (includes revision)
- Methodology: TDD (GREEN)

Files created:

- `src/auth/oauth/google.rs`
- `src/auth/oauth/error.rs` (added after human feedback)

Implementation:

- `GoogleOAuthProvider` implements `OAuthProvider`
- Handles Google-specific OAuth 2.0 flow
- Parses Google user info response

Validation: All tests pass ✓

**Human checkpoint**:

- Action: Reviewed code (r)
- Feedback: Requested more specific error handling (✗)
- Revision: Added custom error types for network failures
- QA re-validated: Tests pass ✓
- Action: Approved (✓)
- Human committed manually: d5f1a3b

### Task T5: Refactor OAuth core (REFACTOR phase)

- Started: 2026-02-02 12:48:00
- Duration: 32 minutes (includes clippy fixes)
- Methodology: TDD (REFACTOR)

Files modified:

- `src/auth/oauth/mod.rs`
- `src/auth/oauth/google.rs`

Refactoring:

- Extracted `exchange_code_impl()` common logic
- Created `UserProfileBuilder` for consistent profile construction
- Improved error types (`OAuthError` enum)

Validation: All tests still pass ✓

**Human checkpoint**:

- Action: Ran make lint (m)
- Result: 1 warning found (unused variable)
- Action: Agent fixed warnings
- QA re-validated: Clean ✓
- Action: Approved (✓)
- Human committed manually: e8a2b7d

---

**Batch Summary: OAuth Core Complete**

- Tasks: T1-T5 complete
- Human commits: 5 commits
- Human action: Pushed to remote manually
- Time: 2026-02-02 13:00:00

---

### Task T6: Generate inventory for routes module

- Started: 2026-02-02 13:05:00
- Duration: 12 minutes
- Methodology: Inventory-Driven (ANALYSIS)

Files analyzed:

- `src/routes/auth.rs` (existing)
- `src/routes/mod.rs`
- `tests/routes/auth_test.rs`

inventory.yaml generated (see artifacts)

Patterns detected:

- Consistent use of axum State extractor
- Error handling via AppError conversion
- Request validation before processing

**Human checkpoint**:

- Action: Approved without commit (✓)
- Rationale: Inventory is intermediate artifact
- Continued to next task

### Task T7: Add OAuth routes following patterns

- Started: 2026-02-02 13:17:00
- Duration: 55 minutes
- Methodology: Inventory-Driven (IMPLEMENTATION)

Files modified:

- `src/routes/auth.rs`

Routes added:

- `GET /auth/oauth/google` → initiates Google OAuth
- `GET /auth/oauth/github` → initiates GitHub OAuth
- `GET /auth/oauth/callback` → handles OAuth callback

Implementation notes:

- Followed existing handler signature pattern from inventory
- Used same error handling approach
- Matched validation pattern

Validation:

- All existing tests pass ✓
- New integration tests pass ✓
- No new refactor signals detected ✓

**Human checkpoint**:

- Action: Ran make test (m)
- Result: All 45 route tests passed
- Action: Approved (✓)
- Human committed manually: f3b8d2a

---

**Batch Summary: Route Integration Complete**

- Tasks: T6-T7 complete
- Human commits: 1 commit (T6 was intermediate)
- Time: 2026-02-02 14:15:00

---

### Task T8: Add OAuth sign-in buttons

- Started: 2026-02-02 14:20:00
- Duration: 25 minutes
- Methodology: Traditional

Files modified:

- `templates/login.html`

Changes:

- Added "Sign in with Google" button
- Added "Sign in with GitHub" button
- Styled to match existing button design

**Human checkpoint**:

- Action: Reviewed code (r)
- Action: Manual validation (opened in browser)
- Result: Buttons look good
- Action: Approved (✓)
- Human committed manually: a9c5e3f

### Task T9: Add tests for UI buttons

- Started: 2026-02-02 14:45:00
- Duration: 20 minutes
- Methodology: Traditional

Files created:

- `tests/ui/login_test.rs`

Tests written:

- `test_login_page_has_google_button()`
- `test_login_page_has_github_button()`
- `test_oauth_buttons_link_correctly()`

Validation: All tests pass ✓

**Human checkpoint**:

- Action: Ran make coverage (m)
- Result: UI coverage 78% (acceptable for templates)
- Action: Approved (✓)
- Human committed manually: b2f7d9a

---

**Final Summary: Build Complete** Total duration: 4 hours 30 minutes Human commits: 7
commits Files modified: 8 files Lines added: 847 Lines deleted: 24 Tests written: 23
test functions

All automated checks PASS:

- cargo test: 145/145 tests passed
- cargo clippy: No warnings
- cargo build: Success

Human actions during build:

- Reviewed code: 3 times
- Ran make test: 2 times
- Ran custom tests: 1 time
- Ran make lint: 1 time
- Rejected and revised: 1 time (Task T4)
- Approved tasks: 9 times
- Manual commits: 7 commits
- Manual push: 1 time

Ready for Presentation phase.
```

**progress.yaml** [OPTIONAL]

```yaml
progress:
  total_tasks: 9
  completed_tasks: 9
  status: complete

  human_commits:
    - commit: a3f2b5c
      task: T1
      message: "test(auth): add OAuth provider trait tests (TDD RED)"

    - commit: b7e9c1a
      task: T2
      message: "feat(auth): implement OAuth provider trait (TDD GREEN)"

    - commit: c2d4e8f
      task: T3
      message: "test(auth): add Google OAuth provider tests (TDD RED)"

    - commit: d5f1a3b
      task: T4
      message: "feat(auth): implement Google OAuth provider with detailed errors"

    - commit: e8a2b7d
      task: T5
      message: "refactor(auth): extract common OAuth logic"

    - commit: f3b8d2a
      task: T7
      message: "feat(routes): add OAuth routes following existing patterns"
      note: "T6 was intermediate (inventory), not committed separately"

    - commit: a9c5e3f
      task: T8
      message: "feat(ui): add OAuth sign-in buttons to login page"

    - commit: b2f7d9a
      task: T9
      message: "test(ui): add tests for OAuth sign-in buttons"

  human_interactions:
    - task: T1
      actions: [review, show_message, approve]
      human_committed: true

    - task: T2
      actions: [make_test, approve]
      human_committed: true

    - task: T3
      actions: [custom_test, approve]
      human_committed: true

    - task: T4
      actions: [review, reject_revise, approve]
      human_committed: true
      revisions: 1

    - task: T5
      actions: [make_lint, fix_applied, approve]
      human_committed: true

    - task: T6
      actions: [approve]
      human_committed: false
      note: "Intermediate artifact"

    - task: T7
      actions: [make_test, approve]
      human_committed: true

    - task: T8
      actions: [review, manual_validation, approve]
      human_committed: true

    - task: T9
      actions: [make_coverage, approve]
      human_committed: true

  git_operations:
    note: "All git operations (add, commit, push) performed manually by human"
    total_commits: 7
    pushed: true
    push_performed_by: human
    push_time: "2026-02-02T13:00:00Z"
```

### Typical Duration

- **Simple feature**: 1-3 hours (+ interactive time ~30 min)
- **Complex feature**: 4-8 hours (+ interactive time ~1-2 hours)
- **Large project**: Multiple days (regular checkpoints throughout)

**Note**: Interactive checkpoints add time but provide control and quality.

### Benefits of Interactive Build

**Human controls ALL git operations**:

- forge NEVER executes git commands
- forge suggests commit messages
- forge shows diffs
- Human commits: `git add`, `git commit`, `git push`

**Clean git history**:

- Atomic commits per task (or batched as you prefer)
- Easy to bisect bugs
- Reviewable progression
- All in your name with your PGP signature

**Continuous validation**:

- Run custom tests/analysis between tasks
- Catch issues early
- Fix before proceeding

**Full control**:

- Review each change before committing
- Adjust as needed (reject/revise)
- Pause and resume anytime

**Dependency management**:

- Install dependencies exactly when needed
- Not all in advance (may not need some if requirements change)
- Commit dependency changes separately (you control)

**Real-world workflow**:

- Matches experienced developer habits
- Director-level decisions, not passive observer
- Builds trust in AI through transparency

### Feedback Loops

**Forward (to Presentation)**:

- Build log with human interactions provides rich data
- Your git history shows evolution
- Issues encountered inform retrospective

**Backward (iterate Build)**:

- At any checkpoint: Reject and revise current task
- Can return to previous task if needed
- Git history allows easy rollback (you control)

**Backward (to Plan)**:

- If multiple tasks reveal architectural issue
- Human can quit, return to Plan phase
- Resume Build after plan revised

**Backward (to Discovery)**:

- If implementation reveals requirements misunderstood
- Return to Discovery to clarify
- Rare but possible

**Lateral (to Evolution)**:

- Interactive patterns learned (when humans reject, what they validate)
- Commit message quality improves
- Checkpoint frequency optimized per project type

### Common Escalations

**Dependency missing (interactive resolution)**:

```
Dev Agent: "Task T4 requires `oauth2` crate, but compilation fails.

From plan.md, this dependency should have been installed.

┌─────────────────────────────────────────────────────┐
│ Dependency Required                                 │
│                                                     │
│ Package: oauth2 = "4.4"                             │
│ Command: cargo add oauth2@4.4                       │
│                                                     │
│ [i] Instructions   [q] Quit (install manually)      │
└─────────────────────────────────────────────────────┘

You: i ↵

forge shows:
───────────────────────────────────────────────────────
To install this dependency:

1. Exit forge (or open another terminal)
2. Run: cargo add oauth2@4.4
3. Review changes to Cargo.toml and Cargo.lock
4. Commit separately:
   git commit -am "chore: add oauth2 dependency"
5. Resume forge: forge resume

Or press 'q' to quit forge now and install manually.
───────────────────────────────────────────────────────

You: q ↵

forge saves session and exits.

You install dependency:
$ cargo add oauth2@4.4
  Adding oauth2 v4.4.0 to dependencies

$ git add Cargo.toml Cargo.lock
$ git commit -m "chore: add oauth2 dependency"
[feature/oauth x7y3z8a] chore: add oauth2 dependency

You resume:
$ forge resume
Resuming session... Task T4 will continue.
```

**Ambiguity in task**:

```
Dev Agent: "Task T7 says 'add routes following patterns' but inventory
shows two different patterns:
1. Handlers in separate functions (8 examples)
2. Inline closures (3 examples)

┌─────────────────────────────────────────────────────┐
│ Clarification Needed                                │
│                                                     │
│ Which pattern should I follow for OAuth routes?     │
│                                                     │
│ [1] Separate functions (recommended, more testable) │
│ [2] Inline closures (matches 3 examples)            │
│ [f] Provide custom guidance                         │
└─────────────────────────────────────────────────────┘

You: 1 ↵

Dev Agent: "Using separate functions pattern. Continuing..."
```

**Test failure (interactive debugging)**:

```
QA Agent: "Task T5 validation FAILED.

Issue: Integration test 'oauth_flow_end_to_end' failing.

┌─────────────────────────────────────────────────────┐
│ Validation Failed                                   │
│                                                     │
│ Test: oauth_flow_end_to_end                         │
│ Error: state token mismatch                         │
│                                                     │
│ [r] Retry (Dev Agent will attempt fix)              │
│ [d] Show detailed error output                      │
│ [t] Run specific test manually                      │
│ [✗] Reject (provide guidance)                       │
└─────────────────────────────────────────────────────┘

You: d ↵

# Shows full error output

You: ✗ ↵
Feedback: State token encoding issue. Use base64url encoding, not base64. ↵

Dev Agent: Applying feedback...
QA Agent: Re-validating...
QA Agent: ✓ All tests pass

Continue? [y/n] y ↵
```

**Quality check before approving**:

```
┌─────────────────────────────────────────────────────┐
│ Task T7 Complete                                    │
│ M src/routes/auth.rs (+145 lines)                   │
│ Validation: ✓ All tests pass                        │
│                                                     │
│ Suggested commit message:                           │
│   feat(routes): add OAuth routes                    │
│                                                     │
│ [r] Review  [m] Make  [✓] Approve  [s] Show msg     │
└─────────────────────────────────────────────────────┘

You: m ↵
Enter make target: lint ↵

Running: make lint
  cargo clippy --all-targets
  warning: missing documentation for public function
  --> src/routes/auth.rs:67:1

Add docs before continuing? [y/n] y ↵

Dev Agent: Adding documentation comments...
QA Agent: Re-validating...

You: ✓ ↵

Approved. You commit manually:
$ git add src/routes/auth.rs
$ git commit -m "feat(routes): add OAuth routes with documentation"
[feature/oauth f3b8d2a] feat(routes): add OAuth routes with documentation
```

## Phase 4: Presentation

### Purpose

Analyze completed work, generate metrics, provide retrospective insights.

### Who

- **Analysis Agent**: Computes metrics, generates retrospective
- **Human**: Reviews analysis, provides feedback for evolution

### Process Flow

```
Input: Completed Build phase artifacts
    ├─ build_log.md
    ├─ progress.yaml
    ├─ Code changes (git diff)
    └─ All validation results
    ↓
Analysis Agent:
    ├─ Parses build log
    ├─ Computes metrics:
    │  ├─ Time per phase, per task
    │  ├─ Files modified (additions, deletions)
    │  ├─ Test metrics (count, coverage, pass rate)
    │  ├─ Validation results (automated, manual)
    │  ├─ Retry/escalation counts
    │  └─ Methodology effectiveness
    │
    ├─ Generates timeline
    ├─ Identifies bottlenecks
    ├─ Analyzes what worked / didn't work
    └─ Proposes improvements
    ↓
Artifacts Created:
    ├─ retrospective.md [REQUIRED]
    └─ improvement_suggestions.yaml [OPTIONAL]
    ↓
Human Review:
    ├─ Reads retrospective
    ├─ Provides feedback:
    │  ├─ Accuracy rating (did analysis capture reality?)
    │  ├─ Satisfaction rating (happy with process?)
    │  ├─ Specific feedback (what could improve?)
    │  └─ Notes for evolution engine
    └─ Approves → Proceed to Suggestions
```

### Artifacts

**retrospective.md** [REQUIRED]

```markdown
# Retrospective: OAuth Authentication

## Summary

**Project**: OAuth Authentication **Duration**: 4 hours 30 minutes (Discovery to Build
complete) **Outcome**: ✓ Success - All features implemented and validated

## Timeline
```

09:00 - Discovery Phase (30 minutes) ├─ Product Agent clarified requirements ├─
Generated project_overview.md └─ Human approved

09:30 - Plan Phase (45 minutes) ├─ Architect Agent designed architecture ├─ Chose TDD
for core, Inventory-Driven for integration ├─ Listed dependencies (oauth2, reqwest) └─
Human approved + installed dependencies

10:15 - Build Phase (4 hours 30 minutes) ├─ Tasks T1-T5: TDD (OAuth core) - 2h 45m │ └─
Checkpoint 1: Approved ├─ Tasks T6-T7: Inventory-Driven (routes) - 1h 7m │ └─ Checkpoint
2: Approved └─ Tasks T8-T9: Traditional (UI) - 45m └─ Checkpoint 3: Approved

15:00 - Presentation Phase (15 minutes - this document)

```
## Metrics

### Time Breakdown

| Phase        | Duration  | % of Total |
|--------------|-----------|------------|
| Discovery    | 30m       | 8%         |
| Plan         | 45m       | 13%        |
| Build        | 4h 30m    | 75%        |
| Presentation | 15m       | 4%         |
| **Total**    | **6h 0m** | **100%**   |

### Code Changes

- Files modified: 8 files
- Lines added: 847
- Lines deleted: 24
- Net change: +823 lines

### Test Metrics

- Tests written: 23 test functions
- Test coverage: 94% (oauth module)
- All tests passing: ✓ (145/145)

### Validation

- Automated checks: 100% pass rate
- Manual validations: 2 performed, both passed
- Retries: 1 (Task T4, resolved quickly)
- Escalations: 0

### Methodology Effectiveness

**TDD (Tasks T1-T5)**:
- Time: 2h 45m (estimated: 2h 30m)
- Overhead: +10% time
- Benefits: Caught 1 bug in RED phase (incorrect scope param)
- Verdict: ✓ Worth it for critical auth logic

**Inventory-Driven (Tasks T6-T7)**:
- Time: 1h 7m (estimated: 1h 15m)
- Savings: -10% time (analysis saved implementation time)
- Benefits: No refactor signals introduced, patterns respected
- Verdict: ✓ Essential for modifying existing code

**Traditional (Tasks T8-T9)**:
- Time: 45m (estimated: 1h)
- Savings: -25% time
- Trade-off: Lower test coverage for UI (acceptable for simple changes)
- Verdict: ✓ Appropriate for straightforward features

## What Went Well

✅ **TDD caught bugs early**: Task T4 had incorrect scope parameter, caught in RED phase before implementation

✅ **Inventory-Driven prevented issues**: Following route patterns ensured consistency, no integration surprises

✅ **Clear task breakdown**: Tasks were right-sized (20-60 minutes each), easy to checkpoint

✅ **Dependency planning worked**: All deps installed in Plan, no Build blockers

✅ **Human checkpoints efficient**: 3 checkpoints at natural boundaries, quick reviews (~5 min each)

## What Didn't Work

⚠️ **TDD overhead for simple functions**: Some helper functions didn't need test-first (e.g., format_auth_url)

⚠️ **Inventory analysis could be cached**: Analyzed same routes module twice (Plan + Build T6)

⚠️ **UI tests were minimal**: Traditional approach led to lower coverage for templates (63%)

## Bottlenecks Identified

**Build phase dominated time** (75%):
- Not a problem per se (implementation is the work)
- But: TDD RED-GREEN-REFACTOR added cycles

**Potential optimization**:
- For low-risk code, skip TDD overhead
- Use TDD only for security-critical paths

## Recommendations

**For similar projects**:
1. Use TDD for auth/security logic (worth the time)
2. Use Inventory-Driven for any route modifications
3. Cache inventory analysis (don't regenerate per task)
4. Consider increasing UI test coverage even with Traditional

**For forge evolution**:
1. Detect low-risk functions and suggest skipping TDD
2. Cache inventory between Plan and Build phases
3. Add "coverage goals" per methodology (e.g., Traditional still needs 80%)

## Human Feedback Request

Please provide ratings (1-5):
- **Accuracy**: Did this analysis capture what happened?
- **Satisfaction**: Happy with the process?
- **Pace**: Was this too slow, too fast, or just right?

Any specific feedback for improvement?
```

**improvement_suggestions.yaml** [OPTIONAL]

```yaml
improvements:
  - category: methodology
    suggestion: "Cache inventory analysis between phases"
    rationale: "Routes inventory generated in Plan (optional), then again in Build T6. Wasteful."
    impact: "Save ~10-15 minutes on similar projects"
    difficulty: low

  - category: validation
    suggestion: "Add coverage goals per methodology"
    rationale: "Traditional approach led to 63% coverage for UI (acceptable but lower than desired)"
    impact: "Ensure quality floor regardless of methodology"
    difficulty: medium

  - category: task_planning
    suggestion: "Detect low-risk code, suggest skipping TDD"
    rationale: "Helper functions like format_auth_url don't need test-first"
    impact: "Reduce TDD overhead by ~15% on similar projects"
    difficulty: high

  - category: checkpoints
    suggestion: "Current checkpoint frequency is good"
    rationale: "3 checkpoints at feature boundaries worked well, reviews were quick"
    impact: "No change needed"
    difficulty: n/a
```

### Typical Duration

- **Any project**: 10-20 minutes (analysis is fast)

### Feedback Loops

**Forward (to Suggestions)**:

- Metrics inform commit message (e.g., "Added 847 lines, 23 tests")
- Timeline helps estimate deployment duration

**Forward (to Evolution)**:

- Retrospective insights feed evolution engine
- Human feedback guides improvement priorities
- Methodology effectiveness informs future defaults

**Backward (to Build)**:

- If retrospective reveals serious issue: "This implementation has security flaw"
- Return to Build to fix

**Backward (to Plan)**:

- If retrospective reveals architectural mistake: "This design causes X problem"
- Rare but possible: Return to Plan to redesign

### Common Escalations

(Rare - Presentation is mostly automated analysis)

**Metrics computation error**:

```
Analysis Agent: "Cannot compute test coverage - tarpaulin not installed.

Install tarpaulin for detailed coverage metrics:
  cargo install cargo-tarpaulin

Or proceed with basic metrics only? [y/n]"
```

## Phase 5: Suggestions

### Purpose

Propose commit message and deployment steps based on completed work.

### Who

- **Suggestions Agent**: Analyzes changes, proposes commit and deployment
- **Human**: Reviews proposals, executes (or modifies first)

### Process Flow

```
Input: All phase artifacts
    ├─ project_overview.md (what was built)
    ├─ plan.md (how it was built)
    ├─ Code changes (git diff)
    ├─ build_log.md (implementation details)
    └─ retrospective.md (metrics)
    ↓
Suggestions Agent:
    ├─ Analyzes all changes
    ├─ Determines commit type (feat, fix, refactor, etc.)
    ├─ Generates conventional commit message
    ├─ Creates deployment plan (if needed)
    ├─ Creates rollback plan (if risky)
    └─ Checks for missed dependencies
    ↓
Artifacts Created:
    ├─ commit_message.txt [REQUIRED]
    ├─ deployment_plan.md [OPTIONAL]
    ├─ rollback_plan.md [OPTIONAL]
    └─ dependency_changes.yaml [OPTIONAL - if any missed]
    ↓
Human Decision:
    ├─ [Accept] Use commit message as-is, execute deployment plan
    ├─ [Modify] Edit commit message or plan, then execute
    ├─ [Discard] Write own commit message and plan
    └─ [Iterate] Go back to previous phase for changes
    ↓
Human Executes (outside forge):
    ├─ git commit -F commit_message.txt (or manual)
    ├─ git push
    └─ Follow deployment plan steps
```

### Artifacts

**commit_message.txt** [REQUIRED]

```
feat(auth): add OAuth authentication for Google and GitHub

Implemented OAuth 2.0 authentication flow supporting Google and GitHub
providers with comprehensive test coverage and security validation.

Features:
- Google OAuth provider with full OAuth 2.0 flow
- GitHub OAuth provider with full OAuth 2.0 flow
- Trait-based provider abstraction for extensibility
- CSRF protection via state token validation
- Integration with existing session management

Technical details:
- Followed TDD for OAuth core logic (src/auth/oauth/)
- Used inventory-driven approach for route integration
- Traditional approach for UI components
- Added 23 test functions (94% coverage for oauth module)
- No refactor signals introduced
- All automated checks passing (cargo test, clippy)

Changes:
- Files modified: 8 files
- Lines added: 847
- Lines deleted: 24
- Net: +823 lines

Dependencies added (committed separately):
- oauth2 = "4.4"
- reqwest = "0.11" (with json feature)

Breaking changes: None

Co-authored-by: forge-dev-agent <forge@local>

Closes #42
```

**deployment_plan.md** [OPTIONAL]

```markdown
# Deployment Plan: OAuth Authentication

## Prerequisites

- [ ] Dependencies already installed and committed:
```

git log --oneline -1 | grep "chore: add OAuth dependencies"

```
- [ ] All tests passing locally:
```

cargo test

## Summary: Interactive Build Philosophy

forge's Build phase is **not autonomous execution**. It's **collaborative
implementation**:

- **You review each step** (or approve batches if you prefer)
- **You run custom validations** (make targets, custom tests, analysis tools)
- **You install dependencies when needed** (just-in-time, not all upfront)
- **You commit manually** (forge NEVER touches git)
- **You maintain full control** (review, reject, revise at any point)
- **You create clean git history** (atomic commits, reviewable progression)

**Result**: AI handles implementation details, you handle architecture and quality
decisions.

**You are the director. Build phase is your orchestra following your baton.** 🎼

# Expected: 145/145 tests pass

```
- [ ] Linting clean:
```

cargo clippy

# Expected: No warnings

````
## Environment Variables Required

Add to production environment:

```bash
# Google OAuth
GOOGLE_OAUTH_CLIENT_ID=your_google_client_id
GOOGLE_OAUTH_CLIENT_SECRET=your_google_client_secret
GOOGLE_OAUTH_REDIRECT_URL=https://yourdomain.com/auth/oauth/callback

# GitHub OAuth
GITHUB_OAUTH_CLIENT_ID=your_github_client_id
GITHUB_OAUTH_CLIENT_SECRET=your_github_client_secret
GITHUB_OAUTH_REDIRECT_URL=https://yourdomain.com/auth/oauth/callback
````

## Deployment Steps

### 1. Commit Changes

```bash
# Review changes one last time
git diff

# Commit using generated message
git commit -F commit_message.txt

# Or edit message first
git commit -e -F commit_message.txt
```

### 2. Push to Repository

```bash
git push origin feature/oauth-authentication
```

### 3. Create Pull Request

- Title: "feat(auth): add OAuth authentication for Google and GitHub"
- Description: Copy from commit message body
- Reviewers: @security-team (auth changes require security review)
- Labels: `enhancement`, `security`

### 4. CI/CD Pipeline (Automated)

Monitor CI/CD:

- Build verification
- Full test suite
- Security scanning
- Coverage report
- Staging deployment (auto)

### 5. Staging Verification

Manual tests in staging:

- [ ] Navigate to `/login`
- [ ] Click "Sign in with Google"
  - [ ] Redirects to Google
  - [ ] Grant permissions
  - [ ] Redirects back with valid session
  - [ ] User profile visible
- [ ] Log out
- [ ] Click "Sign in with GitHub"
  - [ ] Redirects to GitHub
  - [ ] Grant permissions
  - [ ] Redirects back with valid session
  - [ ] User profile visible
- [ ] Check logs for errors (should be none)

### 6. Production Deployment

After PR approval:

```bash
git checkout main
git pull origin main
# CI/CD auto-deploys to production
```

Monitor:

- Error rates in dashboard
- Auth endpoint latency (target: < 500ms)
- OAuth provider status
- User sign-in success rate

### 7. Post-Deployment Verification

First 15 minutes critical:

- [ ] Smoke test: Sign in with Google (production)
- [ ] Smoke test: Sign in with GitHub (production)
- [ ] Check error logs (filter by /auth/oauth/)
- [ ] Verify metrics dashboard shows healthy auth rate
- [ ] Monitor user feedback channels

## Timeline Estimate

- Commit & PR: 5 minutes
- CI/CD to staging: 10 minutes
- Staging verification: 15 minutes
- PR review: 1-4 hours (depends on reviewer availability)
- Production deployment: 5 minutes (after approval)
- Post-deployment monitoring: 30 minutes

**Total active time**: ~1 hour **Total elapsed time**: 2-5 hours (including PR review
wait)

## Success Criteria

- [ ] OAuth flows working for both providers
- [ ] Error rate < 0.1% for auth endpoints
- [ ] Response time < 500ms (p95)
- [ ] No security alerts
- [ ] User feedback positive

## Notes

- OAuth providers have rate limits - monitor for 429 errors
- State tokens expire after 10 minutes - users must complete flow promptly
- If provider is down, fallback to password auth still works

````
**rollback_plan.md** [OPTIONAL]

```markdown
# Rollback Plan: OAuth Authentication

## When to Rollback

Trigger rollback if:
- OAuth flows failing > 5% of attempts
- Response time > 1000ms (2x target)
- Security vulnerability discovered
- Critical bug affecting users
- OAuth provider outage cascading to our system

## Quick Rollback (< 5 minutes)

### Option 1: Revert Deployment

```bash
# Revert to previous deployment
kubectl rollout undo deployment/auth-service

# Or via CI/CD dashboard: click "Rollback" button
````

### Option 2: Revert Commit

```bash
# Revert the feature commit
git revert HEAD
git push origin main

# CI/CD will auto-deploy reverted version
```

## Database Rollback

No database migrations in this change - **skip this step**.

## Configuration Rollback

If OAuth environment variables cause issues:

```bash
# In production environment, remove OAuth vars
unset GOOGLE_OAUTH_CLIENT_ID
unset GOOGLE_OAUTH_CLIENT_SECRET
unset GITHUB_OAUTH_CLIENT_ID
unset GITHUB_OAUTH_CLIENT_SECRET

# Restart service to apply
kubectl rollout restart deployment/auth-service
```

System will continue working - OAuth buttons won't appear if vars missing.

## Communication

If rolling back:

1. **Internal team**: Post in #incidents channel
   ```
   🚨 Rolling back OAuth feature due to [reason].
   Timeline: [X] minutes to complete.
   Impact: OAuth sign-in unavailable, password auth still works.
   ```

2. **Users** (if customer-facing):
   - Status page update: "OAuth sign-in temporarily unavailable"
   - Estimated resolution time
   - Workaround: Use password authentication

3. **Post-mortem**: Schedule within 24 hours to analyze what went wrong

## Post-Rollback Actions

- [ ] Investigate root cause
- [ ] Fix issue in feature branch
- [ ] Add tests to prevent recurrence
- [ ] Re-verify in staging
- [ ] Re-deploy when ready

## Rollback Testing

Test rollback procedure in staging before production deployment:

```bash
# In staging
1. Deploy OAuth feature
2. Verify it works
3. Execute rollback
4. Verify system still functional
5. Note rollback duration
```

Expected rollback time: < 5 minutes

````
**dependency_changes.yaml** [OPTIONAL - only if dependencies missed]

```yaml
# Only generated if Build phase used dependencies not in Plan

dependency_changes:
  - action: added
    package: async-trait
    version: "0.1"
    reason: "Used for async OAuthProvider trait (Task T2)"
    installation_command: "cargo add async-trait@0.1"
    human_action_required: true
    note: "This dependency was not in plan.md. Please review and install if approved."

recommendation:
  "This dependency was added during implementation but not planned.

   Options:
   1. Approve and install now (update Plan for record-keeping)
   2. Refactor to avoid dependency (return to Build phase)

   Recommendation: Option 1 (async-trait is lightweight and necessary)"
````

### Typical Duration

- **Generation**: 5-10 minutes (automated)
- **Human review**: 5-15 minutes
- **Execution**: 5 minutes (commit + push) + deployment time (varies)

### Feedback Loops

**Forward (to next project)**:

- Commit message quality improves with learning
- Deployment plan templates refined based on what works
- Evolution engine learns effective deployment strategies

**Backward (to Build)**:

- Human: "This commit message doesn't capture breaking change"
- Agent: "You're right, there's a breaking change in User model fields"
- Return to Build to address, or update commit message

**Backward (to any phase)**:

- Human: "Actually, I want to change this before committing"
- Can return to any previous phase

### Common Escalations

**Unclear breaking changes**:

```
Suggestions Agent: "Detected potential breaking change:
- User model now requires `oauth_provider` field
- Existing User records will have NULL

Is this breaking? Should migration be added?
Or is NULL acceptable (password-only users)?

Please clarify for commit message."
```

**Deployment complexity**:

```
Suggestions Agent: "This change requires:
- 4 environment variables
- Database migration (optional)
- OAuth app registration with Google/GitHub
- DNS changes (callback URL)

Deployment plan would be complex (>20 steps).

Recommendation: Deploy in stages:
1. This PR: Code only (feature flag OFF)
2. Separate task: Infrastructure setup
3. Separate task: Enable feature flag

Proceed with staged approach? [y/n]"
```

## Feedback Flow Across Phases

### Forward Feedback (Inform Next Phase)

```
Discovery
   ↓ (goals, constraints, success criteria)
Plan
   ↓ (architecture, tasks, validation rules)
Build
   ↓ (implementation, issues encountered, metrics)
Presentation
   ↓ (retrospective insights, recommendations)
Suggestions
   ↓ (commit message, deployment approach)
Evolution (learns from complete cycle)
```

### Backward Feedback (Iterate Previous Phase)

Can return to any previous phase if issues discovered:

**Common backward paths**:

1. **Suggestions → Build**: "Need to change implementation before committing"
2. **Build → Plan**: "This task breakdown doesn't work"
3. **Plan → Discovery**: "We misunderstood requirements"
4. **Presentation → Build**: "Retrospective revealed serious bug"

**Rare backward paths**:

5. **Suggestions → Discovery**: "This whole feature is wrong direction" (rare, but
   possible)

### Lateral Feedback (Inform Evolution)

Every phase contributes to evolution engine:

- **Discovery**: Question effectiveness, common patterns
- **Plan**: Architecture decisions that worked/failed, task estimation accuracy
- **Build**: Implementation patterns, methodology effectiveness
- **Presentation**: Metrics, bottlenecks, what worked
- **Suggestions**: Commit message quality, deployment success rate

Evolution engine aggregates across projects to improve.

## Multi-Project Workflow

When running multiple projects in parallel, phases interleave:

```
Timeline:
09:00 - Project A: Discovery
09:30 - Project B: Discovery (while A in Plan)
10:00 - Project A: Plan complete, install deps
10:15 - Project A: Build starts
10:15 - Project B: Plan complete, install deps
10:30 - Project C: Discovery starts (while A, B building)
10:30 - Project B: Build starts
11:00 - Project A: Checkpoint 1 (approve, continue)
11:15 - Project C: Plan complete
11:30 - Project B: Checkpoint 1 (approve, continue)
12:00 - Project C: Build starts (A, B, C all building)

Result: 3 projects progressing in parallel
```

See [Multi-Project Orchestration](multi-project-orchestration.md) for details.

## Next Steps

- Read [Agents Guide](agents.md) to understand agent specialization
- Read [Multi-Project Orchestration](multi-project-orchestration.md) for parallel workflows
- Read [Security Model](security.md) for sandbox details

## Artifact Organization

### Session Directory Structure

forge organizes each project/feature as a **session** within `docs/plans/`:

```
docs/plans/{session-name}/
├── session.json          # Current phase and state (git ignored)
├── discovery.md          # Discovery phase summary
├── plan.md               # Master plan (Plan phase)
├── tasks.md              # Task breakdown (Plan phase)
├── methodology.md        # Approach decisions (Plan phase)
├── testing-strategy.md   # Testing approach (Plan phase)
├── retrospective.md      # Analysis (Presentation phase)
├── commit_message.txt    # Suggested message (Suggestions phase)
├── next_steps.md         # Next actions (Suggestions phase)
└── implementation/       # Detailed milestone plans
    └── milestone-*.md
```

### Session Naming

Sessions are named: `{type}-{description}`

Examples:
- `forge-self-development` - Building forge itself
- `feature-oauth` - Adding OAuth authentication
- `bugfix-issue-123` - Fixing specific bug
- `refactor-agents` - Refactoring agent system

### Multiple Sessions

Multiple sessions can exist simultaneously, each representing independent work (features, bugfixes, refactors). The active session is tracked in `.forge/session.json`.

### Persistent Data vs. Ephemeral Data

- **Ephemeral Data** (`.forge/`): Runtime state, active session pointer, and raw execution logs. This directory is git-ignored.
- **Persistent Data** (`docs/plans/`): Plans, tasks, methodologies, and retrospectives. These are committed to git as part of the project's documentation and history.
