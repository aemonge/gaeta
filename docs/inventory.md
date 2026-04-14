# Inventory Phase

## Overview

Inventory is an **optional analysis phase** that runs before Plan when working with
existing codebases. It systematically examines code to detect patterns, boundaries, and
conventions—so the Architect and Dev agents respect what's already there instead of
inventing new structures.

**Input**: Existing codebase (specific modules or entire project)\
**Output**: `inventory.yaml` (structured pattern catalog)

## Purpose

Understand before changing. Extract implicit knowledge from code:

- Existing patterns (module structure, naming, error handling).
- Boundaries and responsibilities.
- Testing conventions.
- Tech debt signals (inconsistencies, duplication).

This guides **inventory-driven development**: follow existing patterns when extending
code.

## When to Use

### Run Inventory When

- **Refactoring**: Need to understand current architecture before redesigning.
- **Extending existing modules**: Adding features to established code areas.
- **Unfamiliar codebase**: Joining project or returning after time away.
- **Pattern detection**: Want to document implicit conventions.
- **Pre-planning**: Before Discovery/Plan for context-heavy work.

### Skip Inventory When

- **Greenfield projects**: No existing code to analyze.
- **Well-known codebase**: You wrote it recently, patterns fresh in mind.
- **Isolated new feature**: Zero interaction with existing code.
- **Time-sensitive hotfix**: Bug is clear, no pattern analysis needed.

## The Inventory Agent

### Role

Code archaeologist that reads without judgment.

**Not**: Code reviewer (doesn't critique quality).\
**Is**: Pattern detector (describes what exists, not what should exist).

### Analysis Approach

**Descriptive, not prescriptive**:

- "This module uses Result<T, AppError> for errors" (not "errors are handled
  well/poorly").
- "3 different patterns detected for validation" (flags inconsistency, doesn't pick
  winner).
- "No tests found for X module" (reports gap, doesn't demand tests).

## Process Flow

```
Human: Trigger inventory (explicit command or suggested by Product Agent)
    ↓
Inventory Agent: Scan specified modules/files
    ├─ Parse code structure (AST level)
    ├─ Detect patterns (naming, types, error handling, testing)
    ├─ Identify boundaries (trait definitions, module exports)
    ├─ Flag inconsistencies (multiple patterns for same concern)
    └─ Build inventory.yaml
    ↓
Inventory Agent: Generate summary
    ├─ Key patterns found
    ├─ Refactor signals (tech debt indicators)
    ├─ Test coverage estimate
    └─ Recommendations for Plan phase
    ↓
Human: Review inventory.yaml
    ├─ Approve → Continue to Discovery/Plan with context
    ├─ Expand → Analyze additional modules
    └─ Skip → Ignore inventory, proceed without
    ↓
Architect Agent: Use inventory.yaml during Plan
    ├─ Match existing patterns when possible
    ├─ Flag deviations from patterns in plan.md
    └─ Tag tasks as "inventory-driven" in tasks.yaml
    ↓
Dev Agent: Use inventory.yaml during Build
    ├─ Follow detected patterns for consistency
    ├─ Avoid introducing new patterns unnecessarily
    └─ Flag when must deviate (explain in build_log.md)
```

## inventory.yaml Structure

### Top-Level Sections

- `project`: Project metadata.
- `modules`: Per-module analysis.
- `patterns`: Cross-cutting patterns detected.
- `refactor_signals`: Inconsistencies or tech debt.
- `test_coverage`: Testing conventions and gaps.
- `recommendations`: Guidance for Plan/Build phases.

### Example inventory.yaml

```yaml
project:
  name: "myapp"
  language: "rust"
  analyzed_at: "2026-02-03T12:00:00Z"
  scope:
    - "src/auth/"
    - "src/routes/"
    - "tests/"

modules:
  - name: "src/auth/mod.rs"
    lines: 234
    exports:
      - "AuthService"
      - "AuthError"
      - "middleware::require_auth"
    imports:
      - "axum::extract::State"
      - "jsonwebtoken"
    patterns:
      - type: "error_handling"
        pattern: "Result<T, AuthError>"
        examples:
          - "fn validate_token(...) -> Result<Claims, AuthError>"
      - type: "async"
        pattern: "async fn with tokio runtime"
        examples:
          - "async fn authenticate(...)"
    notes: "Central auth module, well-structured"

  - name: "src/auth/password.rs"
    lines: 156
    exports:
      - "hash_password"
      - "verify_password"
    imports:
      - "argon2"
    patterns:
      - type: "error_handling"
        pattern: "Result<T, AuthError>"
      - type: "security"
        pattern: "Constant-time comparison"
    notes: "Password hashing isolated, no DB coupling"

  - name: "src/routes/auth.rs"
    lines: 312
    exports:
      - "router() -> Router"
    imports:
      - "axum::{Router, Json}"
      - "crate::auth::AuthService"
    patterns:
      - type: "route_handler"
        pattern: "Async handler with State extraction"
        examples:
          - "async fn login(State(auth): State<AuthService>, Json(body): Json<LoginRequest>) -> Result<Json<LoginResponse>, AppError>"
      - type: "error_handling"
        pattern: "Return AppError, middleware converts to HTTP response"
      - type: "validation"
        pattern: "Validator trait on request structs"
    notes: "Consistent handler signatures, good separation"

  - name: "tests/auth/"
    lines: 487
    structure:
      - "password_test.rs"
      - "token_test.rs"
      - "integration_test.rs"
    patterns:
      - type: "unit_tests"
        pattern: "#[tokio::test] for async tests"
      - type: "fixtures"
        pattern: "test_utils::mock_auth_service()"
      - type: "assertions"
        pattern: "assert! and assert_eq!, no custom macros"
    coverage_estimate: "~85% (based on file count and LOC)"
    notes: "Good test structure, integration tests separate"

patterns:
  error_handling:
    description: "Consistent Result<T, DomainError> pattern"
    examples:
      - "AuthError for auth module"
      - "AppError for top-level handlers"
    consistency: "High (95%+ adherence)"
    notes: "AppError implements IntoResponse (axum)"

  async_runtime:
    description: "tokio runtime, async/await throughout"
    examples:
      - "All route handlers async"
      - "Service methods async"
    consistency: "Complete"

  validation:
    description: "Validator trait implemented on request DTOs"
    examples:
      - "LoginRequest::validate()"
      - "RegisterRequest::validate()"
    consistency: "Medium (70%)"
    notes: "Some routes validate manually instead of trait"

  state_management:
    description: "axum State extractor for dependency injection"
    examples:
      - "State<AuthService>"
      - "State<DbPool>"
    consistency: "High"

  naming:
    description: "snake_case for functions, PascalCase for types"
    examples:
      - "fn hash_password"
      - "struct AuthService"
    consistency: "Complete (enforced by rustfmt)"

refactor_signals:
  - signal: "Multiple validation patterns"
    severity: "medium"
    description: >
      70% of routes use Validator trait, 30% validate inline.
      Inconsistency may confuse future maintainers.
    affected_files:
      - "src/routes/auth.rs (mixed)"
      - "src/routes/user.rs (inline only)"
    recommendation: "Standardize on Validator trait"

  - signal: "Error conversion boilerplate"
    severity: "low"
    description: >
      Many From<X> for AppError implementations scattered.
      Could centralize or use thiserror derive.
    affected_files:
      - "src/errors.rs"
      - "src/auth/mod.rs"
    recommendation: "Consider thiserror crate for cleaner derives"

  - signal: "Test fixture duplication"
    severity: "low"
    description: >
      Mock creation logic duplicated across test files.
    affected_files:
      - "tests/auth/password_test.rs"
      - "tests/auth/token_test.rs"
    recommendation: "Extract to tests/common/fixtures.rs"

test_coverage:
  overall_estimate: "80-85%"
  by_module:
    - module: "src/auth/"
      estimate: "90%"
      notes: "Excellent coverage, includes edge cases"
    - module: "src/routes/"
      estimate: "75%"
      notes: "Integration tests present, some edge cases missing"
    - module: "src/models/"
      estimate: "60%"
      notes: "Basic tests only, no validation edge cases"
  conventions:
    - "Unit tests in tests/ directory (external tests)"
    - "Integration tests use test database (docker-compose)"
    - "Async tests use #[tokio::test]"
    - "Fixtures in tests/common/ (shared)"
  gaps:
    - "Error handling edge cases (network failures)"
    - "Validation boundary tests (max length, special chars)"

recommendations:
  for_plan_phase:
    - "Follow Result<T, AuthError> pattern for OAuth code"
    - "Use axum State extraction for OAuthService"
    - "Implement Validator trait for OAuth request DTOs"
    - "Match existing async handler signatures in routes"

  for_build_phase:
    - "Place OAuth code in src/auth/oauth/ (follows src/auth/password.rs pattern)"
    - "Add tests in tests/auth/oauth/ (mirrors existing test structure)"
    - "Use #[tokio::test] for async tests (consistent with codebase)"
    - "Reuse test_utils::mock_* pattern for OAuth test fixtures"

  for_refactor:
    - "Consider unifying validation approach (medium priority)"
    - "Extract common test fixtures (low priority, quality-of-life)"
    - "Evaluate thiserror for error types (low priority, optional)"
```

## Analysis Depth

### Shallow Inventory (default)

Analyzes:

- Module structure and exports.
- Function signatures and return types.
- Import patterns (dependencies).
- High-level error handling patterns.
- Test file presence and naming.

Duration: 5–15 minutes for medium codebase.

### Deep Inventory (explicit request)

Adds:

- Control flow analysis (how functions call each other).
- Data flow (how types transform through layers).
- Performance patterns (async boundaries, cloning).
- Security patterns (input validation, sanitization).

Duration: 20–45 minutes for medium codebase.

Use deep inventory for:

- Major refactors.
- Security-sensitive changes.
- Performance optimization.

## Inventory-Driven Development

Once `inventory.yaml` exists, agents use it as a reference guide.

### In Plan Phase

Architect Agent:

- Reads `inventory.yaml` before generating `plan.md`.
- Proposes architecture that **extends** existing patterns.
- Flags when must deviate (explains why in plan).
- Tags tasks in `tasks.yaml` as `methodology: inventory`.

### In Build Phase

Dev Agent:

- For tasks tagged `methodology: inventory`:
  - Reads relevant sections of `inventory.yaml`.
  - Follows detected patterns (naming, structure, error handling).
  - Matches existing code style implicitly.
  - Only deviates when pattern is inadequate (logs reason).

QA Agent:

- Validates that new code follows inventory patterns.
- Flags deviations (not necessarily failures, but highlights).
- Ensures tests match existing test conventions.

### Example: Following Inventory

**Without inventory**:

```rust
// Dev Agent might invent new pattern
pub fn oauth_login(provider: String) -> Result<Token, OAuthErr> {
    // ...
}
```

**With inventory** (knows existing pattern is `Result<T, AuthError>`):

```rust
// Dev Agent follows existing pattern
pub async fn oauth_login(
    State(auth): State<AuthService>,
    provider: String
) -> Result<Token, AuthError> {
    // Matches inventory: async, State extraction, AuthError
}
```

## Refactor Signals

Inventory detects **inconsistencies** that suggest refactor opportunities.

Common signals:

- **Multiple patterns for same concern**: 3 different error types for similar errors.
- **Duplication**: Same logic in 4 places.
- **Boundary violations**: Module A directly accessing Module B's internals.
- **Test gaps**: Core logic untested.
- **Naming inconsistency**: `getUserProfile` in one place, `get_user_data` elsewhere.

Severity levels:

- **High**: Blocks new work or introduces bugs.
- **Medium**: Slows development, confuses maintainers.
- **Low**: Quality-of-life, technical debt.

Architect Agent uses these during Plan to:

- Propose refactor tasks before new features.
- Avoid amplifying problematic patterns.
- Suggest post-feature cleanup tasks.

## Commands

### Run Inventory

```bash
# Analyze specific modules
$ forge inventory src/auth/ src/routes/

Analyzing modules...
  src/auth/ (5 files)
  src/routes/ (3 files)
  tests/ (12 files)

Patterns detected:
  - Error handling: Result<T, AuthError>
  - Async: tokio runtime
  - Validation: Validator trait (70% consistency)

Refactor signals:
  - Medium: Multiple validation patterns
  - Low: Test fixture duplication

Generated: inventory.yaml

Review and continue? [y/n]
```

### Expand Inventory

If initial inventory missed areas:

```bash
$ forge inventory --expand src/models/

Expanding inventory...
  Added: src/models/ (8 files)

Updated: inventory.yaml

New patterns:
  - Database: sqlx macros for queries

New refactor signals:
  - Medium: Model validation scattered (some in DB, some in handlers)
```

### Deep Inventory

```bash
$ forge inventory --deep src/auth/

Running deep analysis...
  Control flow analysis...
  Data flow analysis...
  Security pattern detection...

Duration: ~25 minutes

Generated: inventory.yaml (deep mode)

Additional insights:
  - Async boundaries: 12 .await points per request
  - Clone patterns: User struct cloned 5x per auth check (potential optimization)
  - Security: Constant-time comparison used correctly
```

## Integration with Other Phases

### Discovery → Inventory → Plan

Typical flow for refactors:

```
Discovery Phase:
  You: "Refactor authentication module"
  Product Agent: "Should I analyze current code first?"
  You: "Yes"

Inventory Phase:
  Inventory Agent: Scans src/auth/
  Output: inventory.yaml

Discovery Phase (continued):
  Product Agent: "Based on inventory, I see 3 validation patterns.
                  Should refactor unify these?"
  You: "Yes"
  Output: project_overview.md (with inventory context)

Plan Phase:
  Architect Agent: Uses inventory.yaml + project_overview.md
  Output: plan.md + tasks.yaml (refactor tasks tagged inventory-driven)
```

### Plan → Inventory (on-demand)

Sometimes Plan phase reveals need for inventory:

```
Plan Phase:
  Architect Agent: "To plan OAuth integration with routes, I need
                    to understand existing route patterns."

Inventory Phase (ad-hoc):
  Inventory Agent: Analyzes src/routes/
  Output: inventory.yaml (routes section)

Plan Phase (resumed):
  Architect Agent: "Routes use State extraction. Plan updated to match."
  Output: plan.md + tasks.yaml
```

## Anti-Patterns

### Over-Reliance on Inventory

**Bad**: Blindly follow patterns, even if inadequate.

```
Inventory: "All errors use String for messages"
Dev Agent: Uses String (perpetuates poor pattern)
```

**Good**: Follow when appropriate, deviate with reason.

```
Inventory: "All errors use String for messages"
Dev Agent: "String errors lose type info. Using enum for OAuth errors.
            Logged deviation in build_log.md."
```

### Inventory Without Purpose

**Bad**: Running inventory "just because."

```
$ forge inventory entire-codebase

# 2 hours later, huge inventory.yaml, never used
```

**Good**: Targeted inventory for specific work.

```
$ forge inventory src/auth/  # Relevant for OAuth feature
$ forge inventory src/routes/auth.rs  # Narrow scope
```

### Ignoring Refactor Signals

**Bad**: See signals, proceed anyway.

```
Inventory: "High severity: Module boundary violations"
Plan: Adds new feature that crosses same boundaries
# Tech debt compounds
```

**Good**: Address or explicitly defer.

```
Inventory: "High severity: Module boundary violations"
Plan: "Task T1: Refactor boundaries (prerequisite)"
      "Task T2-T5: Add OAuth feature (clean foundation)"
# Or: "Deferring boundary refactor to post-MVP (documented)"
```

## Duration

- **Shallow inventory**: 5–15 minutes (typical).
- **Deep inventory**: 20–45 minutes (large refactors).
- **Expand inventory**: +2–5 minutes per additional module.

## Artifacts

**Primary**: `inventory.yaml`\
**Usage**: Referenced by Architect Agent (Plan), Dev Agent (Build), QA Agent
(validation).

## Benefits

- **Consistency**: New code matches existing patterns automatically.
- **Onboarding**: Documents implicit conventions (great for new team members).
- **Refactor safety**: Understand before changing.
- **Reduced bike-shedding**: Patterns already decided (follow inventory).

## Summary

Inventory phase is **code archaeology**:

- **Optional**: Run when working with existing codebases.
- **Descriptive**: Reports patterns without judgment.
- **Output**: `inventory.yaml` (structured pattern catalog).
- **Usage**: Guides Plan and Build to respect existing code.
- **Signals**: Flags inconsistencies for potential refactor.

**Inventory is your codebase's memory. Respect it, or consciously deviate.** 🗺️
