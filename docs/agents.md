# Agent System

## Overview

forge uses specialized **AI agents** that collaborate to move projects through phases.
Each agent has a distinct role, expertise domain, and interaction style—mimicking how a
high-functioning engineering team operates.

**Philosophy**: Multiple focused specialists > Single generalist

## Agent Architecture

### Core Agents (Phase-Specific)

| Agent                  | Phase        | Role                  | Expertise                                               |
| ---------------------- | ------------ | --------------------- | ------------------------------------------------------- |
| **Product Agent**      | Discovery    | Requirements engineer | Clarification, edge cases, scope definition             |
| **Inventory Agent**    | Inventory    | Code archaeologist    | Pattern detection, refactor signals                     |
| **Architect Agent**    | Plan         | System designer       | Architecture, methodology selection, task decomposition |
| **Dev Agent**          | Build        | Implementation        | Code generation, TDD, following patterns                |
| **QA Agent**           | Build        | Quality assurance     | Validation, testing, methodology compliance             |
| **Presentation Agent** | Presentation | Data analyst          | Metrics, retrospectives, insights                       |
| **Suggestions Agent**  | Suggestions  | Technical writer      | Commit messages, PR descriptions, next steps            |

### Subagent System

Agents can spawn **specialized subagents** programmatically to handle focused tasks.
These are not conversational entities invoked via @mentions—they're internal helpers
that agents call as needed.

**Examples**:

- Dev Agent spawns **Test Generator** subagent to write test boilerplate
- Dev Agent spawns **Refactor Engine** subagent to extract methods or apply patterns
- Architect Agent spawns **Security Analyzer** subagent during plan generation
- QA Agent spawns **Coverage Analyzer** subagent to calculate test metrics

**Characteristics**:

- **Non-conversational**: Subagents are function-like (input → output)
- **Transparent**: Logged in build_log.md or plan.md (you see what was invoked)
- **Specialized**: Each handles one narrow task (test generation, pattern detection,
  etc.)
- **Ephemeral**: Spawned for specific task, returns control to parent agent

### Supporting Systems

- **Evolution System**: Background Darwin Gödel Machine learning system (cross-project analysis)
- **Orchestrator**: Phase transitions, agent coordination
- **Sandbox**: Isolated execution environment using Bubblewrap + Landlock

## Agent Collaboration Model

### Handoff Pattern

Agents work sequentially through phases:

```
Discovery: Product Agent
    ↓ (handoff: project_overview.md)
Inventory: Inventory Agent (optional)
    ↓ (handoff: inventory.yaml)
Plan: Architect Agent
    ↓ (handoff: plan.md + tasks.yaml)
Build: Dev Agent + QA Agent (parallel)
    ↓ (handoff: code + build_log.md)
Presentation: Presentation Agent
    ↓ (handoff: retrospective.md)
Suggestions: Suggestions Agent
    ↓ (handoff: commit_message.txt)
```

**Clean boundaries**: Each agent consumes artifacts from previous phase, produces
artifacts for next.

### Parallel Pattern (Build Phase Only)

Dev and QA agents work concurrently:

```
Dev Agent: Implements task
    ├─ (spawns Test Generator if TDD)
    ├─ (spawns Refactor Engine if needed)
    └─ (code changes)
    ↓
QA Agent: Validates task
    ├─ (spawns Coverage Analyzer)
    ├─ Pass → Next task
    └─ Fail → Dev Agent retries
```

**Tight feedback loop**: QA validates immediately after Dev completes each task.

## Product Agent

### Role

Requirements clarification specialist.

**Goal**: Transform vague intent → structured specification.

### Behavior

**Socratic questioner**:

- Asks 3-7 clarifying questions per request.
- Probes for edge cases ("What if X fails?").
- Validates assumptions ("I'm assuming Y, correct?").
- Doesn't accept ambiguity ("faster" → "what's target latency?").

**Domain awareness**:

- Recognizes common patterns (OAuth, CRUD, caching).
- Asks domain-specific questions (auth → providers, sessions).
- Suggests related concerns ("OAuth also needs error handling for provider downtime").

**Context sensitivity**:

- New feature: Broad questions (scope, users, constraints).
- Refactor: Different questions (current problems, test coverage).
- Bug fix: Focused questions (reproduction, impact, rollback).

### Example Interaction

```
Human: "Add caching"

Product Agent: "Let me clarify the caching requirements:

1. What should be cached? (API responses, database queries, computed values?)
2. Cache scope? (per-user, global, per-tenant?)
3. Invalidation strategy? (TTL, explicit invalidate, write-through?)
4. Cache backend? (in-memory, Redis, Memcached?)
5. Cache miss behavior? (block and fetch, return stale, fail fast?)
6. Performance target? (current latency, target latency?)

These details will shape the architecture significantly."
```

### Outputs

- `project_overview.md` (structured requirements)

### Knowledge Sources

- Conversation history (current project)
- Evolution knowledge base (common gaps from past projects)
- Domain patterns (typical requirements for auth, API, UI, etc.)

## Inventory Agent

### Role

Code pattern analyst.

**Goal**: Understand existing codebase → guide consistent changes.

### Behavior

**Objective observer**:

- Describes patterns without judgment ("3 error handling approaches detected").
- Flags inconsistencies (refactor signals).
- Reports coverage gaps (untested modules).

**Pattern recognition**:

- Detects naming conventions (snake_case, PascalCase).
- Identifies architectural patterns (layered, trait-based, middleware).
- Finds testing patterns (unit, integration, fixtures).
- Spots tech debt (duplication, boundary violations).

**Scope flexibility**:

- Shallow: Module structure, exports, high-level patterns (5-15 min).
- Deep: Control flow, data flow, security patterns (20-45 min).

### Subagents Used

- **Pattern Detector**: AST-level code analysis for structure detection
- **Refactor Signal Analyzer**: Identifies inconsistencies and tech debt
- **Coverage Estimator**: Analyzes test coverage by module

### Example Analysis

```
Inventory Agent analyzing src/auth/:

[Spawning Pattern Detector subagent...]

Patterns detected:
  - Error handling: Result<T, AuthError> (100% consistency)
  - Async: tokio runtime (all functions async)
  - State: axum State extractor (dependency injection)

[Spawning Refactor Signal Analyzer...]

Refactor signals:
  - Medium: Validation split (70% use Validator trait, 30% inline)
  - Low: Test fixture duplication (3 files)

[Spawning Coverage Estimator...]

Test coverage estimate: 85-90% (based on test file presence)

Recommendations:
  - Follow Result<T, AuthError> for new OAuth code
  - Use State extractor for OAuthService
  - Extract test fixtures to tests/common/
```

### Outputs

- `inventory.yaml` (pattern catalog)

### Knowledge Sources

- Codebase (AST-level parsing)
- Evolution patterns (common refactor signals)
- Language idioms (Rust conventions, Python patterns, etc.)

## Architect Agent

### Role

System designer and planner.

**Goal**: Requirements + context → executable plan.

### Behavior

**Architectural thinker**:

- Designs module boundaries (separation of concerns).
- Chooses appropriate patterns (traits, builders, factories).
- Balances trade-offs (performance vs maintainability).
- Considers future extensibility (not over-engineering).

**Methodology selector**:

- TDD for high-risk logic (auth, payments, validation).
- Inventory-driven for integration with existing code.
- Traditional for low-risk UI/glue code.
- Rationale-based (explains why each choice).

**Task decomposer**:

- Breaks work into 30-60 min chunks (optimal size from evolution).
- Orders by dependencies (tests before implementation for TDD).
- Adds validation criteria (how to verify completion).
- Flags risks (external deps, complex logic, security).

### Subagents Used

- **Security Analyzer**: Threat modeling and security pattern validation
- **Estimator**: Duration estimates based on evolution data
- **Dependency Checker**: Identifies required libraries and tools
- **Task Optimizer**: Determines optimal task granularity and ordering

### Example Planning

```
Architect Agent planning OAuth feature:

[Reading project_overview.md and inventory.yaml...]

[Spawning Security Analyzer for OAuth flow...]
Security considerations identified:
- State parameter validation (CSRF protection)
- HTTPS-only redirects
- Secure secret storage (env vars)
- Token validation window (clock skew)

[Spawning Estimator for task durations...]
Based on 15 similar auth tasks:
- OAuth trait + tests: 60-75 min (TDD)
- Provider implementation: 45-60 min each
- Route integration: 40-50 min (inventory-driven)

[Spawning Task Optimizer...]
Optimal task breakdown: 9 tasks averaging 42 min each
Split large tasks (>60 min) into smaller units

Architecture:
  - OAuthProvider trait (abstraction for Google/GitHub)
  - Provider implementations (google.rs, github.rs)
  - OAuthService (orchestration)
  - Routes integration (follows existing axum patterns)

Methodology decisions:
  - TDD for OAuth core (security-critical, complex flow)
  - Inventory-driven for routes (integrate with existing handlers)
  - Traditional for UI buttons (low risk, visual)

Task breakdown: See tasks.yaml
Total estimate: 7.5 hours
```

### Outputs

- `plan.md` (architecture narrative)
- `tasks.yaml` (executable task list)

### Knowledge Sources

- `project_overview.md` (requirements)
- `inventory.yaml` (existing patterns, if available)
- Evolution knowledge base (methodology effectiveness, task granularity)
- Architectural patterns library (common designs)

## Dev Agent

### Role

Code implementer.

**Goal**: Execute tasks from tasks.yaml → working code.

### Behavior

**Methodology-aware**:

- **TDD**: Write failing test → minimal implementation → refactor.
- **Inventory-driven**: Read inventory.yaml → follow patterns → integrate cleanly.
- **Traditional**: Implement first → tests after.

**Pattern follower**:

- Respects inventory patterns (naming, error handling, structure).
- Matches code style (formatting, conventions).
- Reuses existing abstractions (don't reinvent).

**Adaptive**:

- Queries personal preferences (evolution knowledge).
- Applies past learnings (typed errors, explicit naming).
- Asks for clarification when patterns ambiguous.

**Context-preserving**:

- Logs decisions in build_log.md (why, not just what).
- Explains deviations from plan (when necessary).
- Documents edge cases discovered.

### Subagents Used

- **Test Generator**: Creates test boilerplate and fixtures (TDD methodology)
- **Refactor Engine**: Extracts methods, applies patterns, simplifies code
- **Code Formatter**: Applies style conventions and linting rules
- **Pattern Matcher**: Ensures new code follows inventory patterns

### Example Implementation (TDD)

```
Task T1: Write failing tests for OAuth trait

Dev Agent:
  [Spawning Test Generator subagent for TDD RED phase...]

  Test Generator:
    - Creates tests/auth/oauth_test.rs
    - Generates test_oauth_provider_auth_url()
    - Generates test_oauth_provider_exchange_code()
    - Generates test_oauth_provider_get_user_profile()

  [Running tests...]
  All tests fail as expected (TDD RED ✓)

  Logged to build_log.md:
    "Task T1: Created 3 tests for OAuthProvider trait.
     Tests fail as expected (trait not yet defined).
     Ready for T2 implementation."

Task T2: Implement OAuth trait

Dev Agent:
  [Reading Test Generator output from T1...]
  [Querying inventory.yaml for error handling pattern...]

  Pattern Matcher:
    - Error handling: Use Result<T, AuthError> (matches 100% of auth code)
    - Async signatures: All methods should be async (inventory pattern)

  [Implementing trait with minimal types...]

  - Creates src/auth/oauth/mod.rs
  - Defines OAuthProvider trait matching test expectations
  - Creates minimal types (OAuthConfig, AccessToken, UserProfile)
  - Uses Result<T, AuthError> per inventory pattern

  [Running tests...]
  All tests pass (TDD GREEN ✓)

  [Spawning Code Formatter for cleanup...]
  Code Formatter: Applied rustfmt, no clippy warnings

  Logged to build_log.md:
    "Task T2: Implemented OAuthProvider trait.
     Followed inventory pattern (Result<T, AuthError>).
     All T1 tests now pass. Ready for T3."
```

### Outputs

- Code changes (implementation)
- Entries in `build_log.md` (decisions, progress)

### Knowledge Sources

- `tasks.yaml` (current task specification)
- `inventory.yaml` (patterns to follow, if inventory-driven)
- `plan.md` (architectural context)
- Evolution personal preferences (your style)

## QA Agent

### Role

Quality validator.

**Goal**: Verify task completion → ensure correctness.

### Behavior

**Validation executor**:

- Runs commands from tasks.yaml validation section.
- Checks methodology compliance (TDD: tests first?).
- Verifies success criteria met.
- Reports pass/fail with evidence.

**Methodology enforcer**:

- **TDD**: Confirms tests were written before implementation.
- **Inventory-driven**: Checks new code matches inventory patterns.
- **Traditional**: Ensures tests exist after implementation.

**Retry coordinator**:

- On failure: Provides feedback to Dev Agent.
- Max 3 retries per task (prevents infinite loops).
- Escalates to human if retries exhausted.

### Subagents Used

- **Coverage Analyzer**: Calculates test coverage metrics
- **Pattern Validator**: Ensures code matches inventory patterns
- **Lint Runner**: Executes linters and static analysis tools

### Example Validation

```
Task T4: Implement Google OAuth provider (TDD)

QA Agent validation:

  [Verifying methodology compliance...]
  1. Check TDD cycle:
     ✓ Tests exist from T3 (written before implementation)
     ✓ Tests failed before T4 (TDD RED confirmed)
     ✓ Tests pass after T4 (TDD GREEN confirmed)

  [Running validation commands from tasks.yaml...]
  2. Execute: cargo test google_oauth
     ✓ All 3 tests pass

  [Spawning Coverage Analyzer...]
  Coverage Analyzer: 94% coverage on OAuth module ✓

  [Spawning Lint Runner...]
  Lint Runner: cargo clippy --all-targets
     ⚠ Warning: Unused variable 'state' on line 45

  [Spawning Pattern Validator...]
  Pattern Validator:
     ✓ Uses Result<T, AuthError> (matches inventory)
     ✓ Async signatures (matches inventory)
     ✓ State extraction pattern (matches inventory)

QA Agent: "Task T4 validation: CONDITIONAL PASS
  Tests pass ✓
  TDD cycle followed ✓
  Coverage: 94% ✓
  Pattern compliance ✓
  Clippy warning: unused variable (minor)

  Recommend: Fix warning before continuing? [y/n]"
```

### Outputs

- Validation results (pass/fail with details)
- Entries in `build_log.md` (validation outcomes)

### Knowledge Sources

- `tasks.yaml` (validation criteria)
- `plan.md` (methodology context)
- Code diff (what changed)
- Test output (pass/fail evidence)

## Presentation Agent

### Role

Retrospective analyst.

**Goal**: Build artifacts → structured insights.

### Behavior

**Metrics calculator**:

- Time breakdown (per phase, per task, per methodology).
- Code metrics (LOC, files, coverage).
- Quality metrics (revision rate, test count).
- Human interaction patterns (approval speed, custom validations).

**Pattern identifier**:

- What went well (successful approaches).
- What was difficult (challenges, revisions).
- Methodology effectiveness (TDD vs inventory vs traditional).
- Emergent patterns (human behavior, optimal task size).

**Recommendation generator**:

- Process improvements (based on challenges).
- Architectural patterns (reusable designs discovered).
- Follow-up work (tech debt, deferred features).

**Objective reporter**:

- No judgment (doesn't critique performance).
- Evidence-based (metrics, not opinions).
- Actionable (specific recommendations, not vague).

### Subagents Used

- **Metrics Calculator**: Quantitative analysis (time, LOC, coverage)
- **Pattern Detector**: Identifies success patterns and challenges
- **Trend Analyzer**: Compares to evolution baseline and past projects
- **Recommendation Engine**: Generates improvement suggestions

### Example Retrospective

```
Presentation Agent analyzing OAuth project:

[Reading build_log.md, git history, test results...]

[Spawning Metrics Calculator...]
Metrics Calculator:
  - Total time: 7.5 hours
  - Task completion: 9/9 (100%)
  - Average task duration: 42 minutes
  - Revision rate: 11% (1 task revised)
  - Test coverage: 94% (OAuth module)

[Spawning Pattern Detector...]
Pattern Detector:
  - TDD methodology: High confidence, 94% coverage
  - Inventory-driven: 100% pattern consistency
  - Single revision in Task 4 (error handling)
  - Early revision prevented cascading issues

[Spawning Trend Analyzer...]
Trend Analyzer (comparing to evolution baseline):
  - Task duration: 42 min avg (vs 48 min baseline) +12% faster
  - Revision rate: 11% (vs 18% baseline) +39% improvement
  - Coverage: 94% (vs 87% baseline) +8% higher

[Spawning Recommendation Engine...]
Recommendation Engine:
  - Continue TDD for auth/security (proven effective)
  - Specify error types in Plan phase (prevent revisions)
  - Run inventory before route work (saved rework)
  - Add make lint to refactor validation (caught issues)

Retrospective complete (see retrospective.md).
```

### Outputs

- `retrospective.md` (metrics, insights, recommendations)

### Knowledge Sources

- `build_log.md` (task execution history)
- Git history (commits, diffs)
- Test results (coverage, pass rates)
- Evolution metrics (compare to baseline, trends)

## Suggestions Agent

### Role

Technical writer and project closer.

**Goal**: Retrospective → practical outputs (commit, PR, next steps).

### Behavior

**Commit message composer**:

- Conventional Commits format (type, scope, summary, body, footer).
- Imperative mood ("add OAuth" not "added").
- Context from retrospective (challenges, metrics).
- References issues, includes relevant details.

**PR description writer**:

- Overview (what this achieves).
- Changes (high-level, not line-by-line).
- Testing (coverage, manual validation).
- Deployment notes (env vars, dependencies).
- Review checklist (what to verify).

**Next steps planner**:

- Immediate actions (push, PR, link issues).
- Pre-deployment (env config, OAuth app setup).
- Post-deployment (monitoring, smoke tests).
- Follow-up work (tech debt, deferred features).

**Practical focus**:

- Ready-to-use outputs (copy-paste commit messages).
- Commands included (exact bash commands to run).
- Deployment gotchas highlighted (env vars, migrations).

### Subagents Used

- **Commit Message Generator**: Conventional Commits formatter
- **Documentation Writer**: PR descriptions and deployment notes
- **Action Planner**: Organizes next steps and follow-up work

### Example Suggestions

```
Suggestions Agent for OAuth project:

[Reading retrospective.md, git diff, tasks.yaml...]

[Spawning Commit Message Generator...]
Commit Message Generator:

feat(auth): add OAuth 2.0 authentication for Google and GitHub

Implement OAuth 2.0 authorization code flow with PKCE for Google
and GitHub identity providers. Users can now sign in using either
provider, with JWT-based session management (24-hour expiration).

[... full message in commit_message.txt ...]

[Spawning Documentation Writer...]
Documentation Writer created:
- PR description with overview, changes, testing
- Deployment notes with env vars and setup steps
- Review checklist for security validation

[Spawning Action Planner...]
Action Planner organized:
Immediate:
  1. Push branch: git push origin feature/oauth-authentication
  2. Create PR (use pr_description.md)
  3. Configure env vars in production

Post-deployment:
  4. Test OAuth flow in staging
  5. Monitor error rates for 24 hours

Follow-up (deferred):
  - Refresh tokens (4-6 hours)
  - Account linking (8-10 hours)

All artifacts ready (commit_message.txt, pr_description.md, next_steps.md).
```

### Outputs

- `commit_message.txt` (ready to use)
- `pr_description.md` (optional)
- `next_steps.md` (action items)
- `deployment_notes.md` (infrastructure)

### Knowledge Sources

- `retrospective.md` (context, metrics, challenges)
- Git diff (what actually changed)
- `tasks.yaml` (original plan vs delivered)
- Evolution commit patterns (quality examples)

## Agent Communication

### Inter-Agent Protocol

Agents communicate via artifacts (not direct conversation):

```
Product Agent → project_overview.md → Architect Agent
Architect Agent → plan.md + tasks.yaml → Dev Agent + QA Agent
Dev Agent → code changes → QA Agent
Dev/QA Agents → build_log.md → Presentation Agent
Presentation Agent → retrospective.md → Suggestions Agent
```

**Benefits**:

- Clean boundaries (no tight coupling).
- Human-readable communication (you can inspect artifacts).
- Auditable (full paper trail).
- Subagents logged (transparency in what was spawned).

### Human-Agent Protocol

Humans interact at phase boundaries:

```
Human ←→ Product Agent (Discovery questions/answers)
Human → Architect Agent (plan approval/revision)
Human ←→ Dev/QA Agents (build checkpoints, approvals, feedback)
Human → Presentation Agent (retrospective review)
Human → Suggestions Agent (commit message approval)
```

**Interface**: TUI (text-based UI, Vim-style navigation).

## Subagent Transparency

All subagent invocations are logged for transparency:

```
# build_log.md excerpt

Task T2: Implement OAuth trait
  - Spawned: Pattern Matcher (verify inventory compliance)
  - Result: Use Result<T, AuthError> pattern detected
  - Spawned: Code Formatter (apply style)
  - Result: rustfmt applied, no warnings
  - Implementation complete: src/auth/oauth/mod.rs created
  - Duration: 38 minutes
```

You can always see **what** subagents were used and **why** they were invoked.

## Agent Limitations

### What Agents Don't Do

**Never execute git commands**:

- No `git commit`, `git push`, `git merge`.
- Suggest commit messages, never apply them or write to Git history.
- You maintain full git control.

**Never make architecture decisions unilaterally**:

- Architect Agent proposes, you approve.
- Alternative approaches presented when multiple viable.
- Rationale always explained.

**Never access network without permission**:

- OAuth API calls simulated in tests.
- External dependencies declared, not auto-fetched.
- Sandbox environment (isolated from system).

**Never modify files outside project scope**:

- Agents work in project workspace only.
- No access to home directory, system files.
- Explicit file paths in tasks.yaml (controlled scope).

### Error Handling

**Agent failures**:

- Retry mechanism (max 3 attempts).
- Escalate to human if retries fail.
- Preserve state (can resume from checkpoint).

**Subagent failures**:

- Logged in build_log.md (transparency).
- Parent agent continues with fallback (no cascade failure).
- Human notified if critical subagent fails.

**Hallucination prevention**:

- Code validation (syntax check, compile, test).
- QA Agent catches incorrect implementations.
- Human checkpoints catch logic errors.

## Agent Performance

### Resource Usage

Per agent (approximate):

- **Memory**: 500MB-1GB (LLM context).
- **CPU**: 1-2 cores during active work.
- **Disk**: Minimal (artifacts are text files).

Subagents:

- **Memory**: 100-300MB each (specialized, smaller models).
- **Ephemeral**: Only exist during parent agent's task.

Multiple agents in parallel (Build phase):

- Dev + QA + subagents: 2-4 cores, 1.5-2.5GB RAM.
- Comfortable on modern workstation (16GB+ RAM).

### Latency

Agent response times:

- **Product Agent**: 5-15 seconds per question batch.
- **Inventory Agent**: 1-3 minutes for shallow scan (subagents add 10-30s).
- **Architect Agent**: 2-5 minutes for plan (subagents add 30-90s).
- **Dev Agent**: 30-90 seconds per task (subagents add 10-20s).
- **QA Agent**: 10-30 seconds per validation (subagents add 5-15s).
- **Presentation Agent**: 1-2 minutes for retrospective (subagents add 20-40s).
- **Suggestions Agent**: 30-60 seconds for outputs (subagents add 10-20s).

**Total project time**: Mostly agent work (you approve at checkpoints).

## Summary

forge agents are **specialized collaborators with subagent helpers**:

- **Primary agents**: One per phase (Product, Inventory, Architect, Dev, QA,
  Presentation, Suggestions)
- **Subagents**: Programmatically spawned specialists (Test Generator, Refactor Engine,
  Coverage Analyzer, etc.)
- **Communication**: Artifacts between phases, shared context within phase
- **Transparency**: All subagent invocations logged in artifacts
- **Collaboration**: Tight Dev/QA loop in Build phase, sequential otherwise
- **Control**: Humans approve at phase boundaries, maintain git control

**Focused agents + specialized subagents = expert execution without complexity.** 🤖
