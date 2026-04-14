# Discovery Phase

## Overview

Discovery is the **requirements clarification** phase where the Product Agent
collaborates with you to understand what needs to be built. This phase transforms vague
requests into structured, actionable specifications.

## Purpose

Convert human intent → machine-actionable requirements

**Input**: Natural language description (vague or detailed) **Output**:
`project_overview.md` (structured specification)

## The Product Agent

### Role

Requirements engineer that asks clarifying questions to eliminate ambiguity.

**Not**: Order-taker that blindly accepts requirements **Is**: Collaborative partner
that probes for edge cases, constraints, and context

### Philosophy

**Socratic method**: Guide through questions rather than assume.

Every vague statement triggers clarification:

- "Add authentication" → Which providers? Session vs token? Password requirements?
- "Make it fast" → What's the target latency? Which operations? Current baseline?
- "Refactor the API" → Which endpoints? What's broken? Maintain compatibility?

## Process Flow

```
You: Initial request (1 sentence to 3 paragraphs)
    ↓
Product Agent: Analyzes request
    ├─ Identifies known aspects
    ├─ Detects ambiguities
    ├─ Generates clarifying questions (3-7 questions)
    └─ Presents in conversational format
    ↓
You: Answer questions (can be brief, agent probes further if needed)
    ↓
Product Agent: Follow-up questions (if needed)
    ↓
You: Final answers
    ↓
Product Agent: Generates project_overview.md
    ├─ Goal
    ├─ Context
    ├─ Requirements (functional)
    ├─ Constraints (non-functional)
    ├─ Success criteria
    ├─ Out of scope
    └─ Open questions (if any remain)
    ↓
You: Review project_overview.md
    ├─ Approve → Continue to Plan phase
    ├─ Revise → Provide feedback, agent updates
    └─ Reject → Return to clarification
```

## Interaction Style

### Initial Request Examples

**Minimal** (agent does heavy lifting):

```
You: "Add OAuth login"

Product Agent: "Got it. Let me clarify a few things:

1. Which OAuth providers? (Google, GitHub, GitLab, custom?)
2. Do you need to support existing password-based auth alongside OAuth?
3. What user data should we fetch from OAuth providers?
4. Session management: JWT tokens or server-side sessions?
5. Do you need account linking (merge OAuth with existing accounts)?
6. Any specific UI requirements for the login flow?"
```

**Detailed** (agent fills gaps):

```
You: "Add OAuth authentication for Google and GitHub. Users should be able
to sign in with either provider. We need to fetch their email, name, and
profile picture. Use JWT tokens for session management. Don't worry about
account linking for now—OAuth-only users."

Product Agent: "Clear picture. A few follow-ups:

1. JWT token expiration time? (e.g., 1 hour, 24 hours)
2. Refresh token strategy? (auto-refresh, explicit refresh endpoint, none)
3. Where to store OAuth client credentials? (env vars, config file, secret manager)
4. Redirect URI after successful auth? (dashboard, profile page, original page)
5. Error handling: What should happen if OAuth provider is down?"
```

**Refactor/bug fix** (needs different questions):

```
You: "Refactor the authentication module—it's a mess."

Product Agent: "I'll help structure this. First, let me understand the current state:

1. What specific problems are you facing? (hard to test, duplicated code, unclear boundaries?)
2. What's the current architecture? (monolithic handler, trait-based, middleware?)
3. Do you have an inventory of the current code? (forge can analyze if needed)
4. Are there any behavioral changes, or pure refactor (same external behavior)?
5. Test coverage: Do you have tests we need to maintain compatibility with?
6. Timeline: Is this blocking other work, or can we take time to do it right?"
```

## Question Types

### Functional Requirements

**What**: Core functionality

- "What should happen when X occurs?"
- "Which features are in scope?"
- "What's the expected output for input Y?"

**Who**: Users and roles

- "Who can perform this action?"
- "Are there different permission levels?"
- "What's the user journey?"

**When**: Timing and triggers

- "When should this happen?"
- "What triggers this behavior?"
- "Are there time-based constraints?"

### Non-Functional Requirements

**Performance**:

- "What's the acceptable latency?"
- "Expected throughput/load?"
- "Baseline for 'faster'?"

**Security**:

- "What data is sensitive?"
- "Authentication/authorization requirements?"
- "Compliance constraints (GDPR, etc.)?"

**Compatibility**:

- "Must maintain backward compatibility?"
- "Which versions to support?"
- "Breaking changes acceptable?"

### Constraints

**Technical**:

- "Technology restrictions? (specific libraries, languages)"
- "Existing architecture constraints?"
- "Dependencies to avoid?"

**Timeline**:

- "Deadline?"
- "MVP vs full feature?"
- "Phased delivery?"

**Resources**:

- "External services needed?"
- "API keys/credentials available?"
- "Infrastructure ready?"

## Conversation Patterns

### Progressive Refinement

Agent starts broad, narrows down:

```
Round 1: High-level scope
  "Which OAuth providers?"
  "What user data to fetch?"

Round 2: Technical details
  "JWT or sessions?"
  "Token expiration?"

Round 3: Edge cases
  "Handle provider downtime how?"
  "What if email already exists?"
```

### Disambiguation

When you say something ambiguous:

```
You: "Make the API RESTful"

Agent: "I see the term 'RESTful' can mean different things. Which aspects:
  1. Use HTTP verbs correctly (GET/POST/PUT/DELETE)?
  2. Stateless (no server-side session)?
  3. HATEOAS (hypermedia links)?
  4. Richardson Maturity Model level? (0-3)"
```

### Assumption Validation

Agent makes assumptions but validates them:

```
Agent: "Based on your request for OAuth, I'm assuming:
  1. You want standard OAuth 2.0 (not OAuth 1.0a)
  2. Authorization Code flow (not Implicit or Client Credentials)
  3. PKCE enabled for security

Correct? Or need to adjust any of these?"
```

## Artifacts

### project_overview.md

Primary output of Discovery phase.

```markdown
# Project Overview: OAuth Authentication

## Goal

Add OAuth authentication to the application, supporting Google and GitHub as identity
providers. Users can sign in using either provider, and we'll manage sessions using JWT
tokens.

## Context

**Current state**: Password-based authentication exists. We're adding OAuth as an
additional option (not replacing passwords).

**Motivation**:

- Reduce friction for new users (no password creation)
- Leverage existing accounts (Google/GitHub)
- Improve security (no password storage for OAuth users)

**Target users**: New and existing users who prefer OAuth over passwords.

## Functional Requirements

### FR1: OAuth Provider Support

- Support Google OAuth 2.0
- Support GitHub OAuth
- Use Authorization Code flow with PKCE
- OAuth supersedes password login (no account linking for MVP)

### FR2: User Data Fetching

Fetch from OAuth provider:

- Email (required)
- Full name
- Profile picture URL

### FR3: Session Management

- Generate JWT token after successful OAuth
- Token expiration: 24 hours
- Refresh token: Not implemented in MVP (user re-authenticates)
- Token includes: user_id, email, provider

### FR4: Login Flow

1. User clicks "Sign in with Google/GitHub"
2. Redirect to OAuth provider
3. User authorizes
4. Provider redirects back with auth code
5. Exchange code for token
6. Fetch user profile
7. Create or update user record
8. Generate JWT
9. Redirect to dashboard

### FR5: UI Changes

- Add OAuth buttons to login page
- Handle OAuth callback route
- Show loading state during OAuth flow
- Display error messages if OAuth fails

## Non-Functional Requirements

### NFR1: Security

- Store OAuth client secrets in environment variables
- Validate state parameter (CSRF protection)
- Use HTTPS for all OAuth redirects
- No plaintext storage of OAuth tokens

### NFR2: Performance

- OAuth flow should complete in < 3 seconds (excluding provider time)
- JWT validation should be < 10ms

### NFR3: Error Handling

- If OAuth provider is down: Show friendly error, option to use password
- If user denies authorization: Redirect to login with message
- If network fails during token exchange: Retry once, then error

## Constraints

### Technical

- Language: Rust
- Existing auth framework: Must integrate with current middleware
- OAuth library: Use `oauth2` crate (version 4.4+)
- JWT library: Use `jsonwebtoken` crate

### Timeline

- MVP target: 1 week
- No account linking in MVP (future iteration)
- No admin panel for OAuth config (hardcoded for now)

### Resources

- OAuth client credentials: Provided by human
- Test accounts: Human will create test OAuth apps

## Success Criteria

1. **Functional**: User can sign in with Google and GitHub successfully
2. **Security**: No security vulnerabilities (CSRF protection, secure token storage)
3. **User experience**: OAuth flow completes smoothly with clear error messages
4. **Test coverage**: >90% coverage for OAuth-related code
5. **Documentation**: Clear setup instructions for OAuth credentials

## Out of Scope (for MVP)

- Account linking (merge OAuth with password accounts)
- Additional OAuth providers (Facebook, Twitter, etc.)
- OAuth for API access (only for web UI login)
- Admin panel to configure OAuth clients
- Single Sign-Out (SSO logout)
- Refresh tokens (re-authenticate after 24 hours)

## Open Questions

None remaining. All clarifications addressed.

## Dependencies

**Crates**:

- `oauth2 = "4.4"` (OAuth 2.0 client)
- `jsonwebtoken = "8.0"` (JWT handling, may already exist)
- `reqwest = "0.11"` (HTTP client for OAuth API calls, may already exist)

**External Services**:

- Google OAuth 2.0 API (requires client ID/secret)
- GitHub OAuth API (requires client ID/secret)

## Next Phase

After approval: Proceed to **Plan Phase** (Architect Agent will design the
implementation).
```

## Review and Approval

After `project_overview.md` is generated:

```
┌─────────────────────────────────────────────────────┐
│ Discovery Phase Complete                            │
│                                                     │
│ Artifact: project_overview.md                       │
│                                                     │
│ Summary:                                            │
│  - Goal: OAuth authentication (Google + GitHub)     │
│  - Functional requirements: 5                       │
│  - Non-functional requirements: 3                   │
│  - Constraints: Technical, timeline, resources      │
│  - Open questions: None                             │
│                                                     │
│ Review the document:                                │
│  [v] View in editor                                 │
│  [✓] Approve (continue to Plan phase)               │
│  [✗] Revise (provide feedback)                      │
│  [r] Reject (restart discovery)                     │
└─────────────────────────────────────────────────────┘
```

### Approval

You review, looks good:

```
You: ✓

forge: "Discovery approved. Proceeding to Plan phase..."

Architect Agent begins planning.
```

### Revision

You want changes:

```
You: ✗

forge: "What would you like to revise?"

You: "Add requirement: remember last used OAuth provider (cookie)"

Product Agent: "Got it. Updating FR4 to include cookie for last provider.
Any other changes?"

You: "No"

Product Agent: "Updated project_overview.md. Review again? [y/n]"

You: y

# Reviews updated document

You: ✓

forge: "Discovery approved. Proceeding to Plan phase..."
```

### Rejection

Discovery went wrong direction:

```
You: r

forge: "Restarting discovery. What wasn't clear or needs different direction?"

You: "Actually, I want to replace password auth with OAuth, not add alongside it."

Product Agent: "Understood—OAuth-only authentication. Let me re-clarify:
  1. What happens to existing password users? (force migration, disable accounts?)
  2. How to handle password reset requests after migration?
  3. ..."

# Discovery restarts with new direction
```

## Duration

**Typical**: 10-30 minutes

- Simple features: 10-15 minutes
- Complex features: 20-30 minutes
- Refactors/bug fixes: 15-25 minutes (requires understanding current state)

**Depends on**:

- Initial request clarity (more detail → faster)
- Domain complexity (authentication vs UI tweak)
- Your response time (instant vs think-time)

## Special Cases

### Inventory-Driven Discovery

For refactors or additions to existing code:

```
You: "Refactor the authentication module"

Product Agent: "I see this involves existing code. Would you like me to:
  1. Analyze the current code first (Inventory phase)?
  2. Continue based on your description of current state?

Recommendation: Run inventory first for accurate refactor planning."

You: "1"

forge: "Starting Inventory phase to analyze current authentication code..."

# After inventory completes, return to Discovery with context

Product Agent: "I've analyzed the current code (see inventory.yaml). Based on
that, I see the authentication module has:
  - 847 lines across 4 files
  - Mixed responsibilities (auth + session + validation)
  - 3 different error handling patterns

For the refactor, should we:
  1. Split into separate modules (auth, session, validation)?
  2. Unify error handling?
  3. Extract traits for testability?
  ..."
```

### Vague Requests

Extremely vague input:

```
You: "Make it better"

Product Agent: "I need more context. What would you like to improve?
  1. Performance (faster)?
  2. Code quality (cleaner, more maintainable)?
  3. User experience (easier to use)?
  4. Security (more secure)?
  5. Specific feature or bug?

Or describe the problem you're facing."
```

### Blocked on External Info

Can't proceed without information:

```
Product Agent: "To proceed, I need:
  1. OAuth client ID and secret (Google and GitHub)

Do you have these, or should I include setup instructions in the plan?

Options:
  - [h] I have them (continue)
  - [s] Include setup instructions (agent will add steps to create OAuth apps)
  - [p] Pause discovery (resume when you have credentials)"
```

## Anti-Patterns

### Over-Specification

**Bad**: Product Agent acts like Architect Agent

```
Product Agent: "I'll create a trait-based architecture with async handlers,
using tower middleware for OAuth validation, and store tokens in Redis..."
```

**Good**: Product Agent focuses on requirements, not implementation

```
Product Agent: "Requirements clarified. The Architect Agent will design the
implementation in the Plan phase."
```

### Under-Clarification

**Bad**: Accepting vague requirements

```
You: "Add OAuth"

Product Agent: "Got it. Moving to Plan phase."

# Later in Build: "Wait, which providers? What data to fetch?"
```

**Good**: Probing until clear

```
You: "Add OAuth"

Product Agent: "Which providers? What user data? JWT or sessions? ..."

# All ambiguity resolved before Plan phase
```

### Assumption Overload

**Bad**: Silent assumptions

```
Product Agent generates project_overview.md with:
  "Use OAuth 2.0 with implicit flow..."

# But you wanted authorization code flow
```

**Good**: Validate assumptions

```
Product Agent: "I'm assuming OAuth 2.0 Authorization Code flow (most secure).
If you need a different flow (Implicit, Client Credentials), let me know."
```

## Benefits

**Reduces rework**:

- Clarify upfront → less backtracking during Build
- Explicit requirements → fewer surprises

**Shared understanding**:

- `project_overview.md` = contract between you and agents
- Future reference (what was the original goal?)

**Catches scope creep**:

- "Out of scope" section makes explicit what's deferred
- Prevents feature creep during Build

**Documents decisions**:

- Why certain choices made (context section)
- Constraints that influenced design

## Feedback Loops

**Forward (to Inventory/Plan)**:

- If refactor/existing code → Inventory phase first
- If greenfield → Plan phase directly
- `project_overview.md` is input to Architect Agent

**Backward (iterate Discovery)**:

- Revise after reviewing `project_overview.md`
- Rare: Usually get it right in one pass with questions

**Lateral (to Evolution)**:

- Patterns in questions → improve future clarifications
- Common missing details → add to question templates

## Comparison to Alternatives

| Aspect        | Manual Requirements | PRD Document        | **forge Discovery**                  |
| ------------- | ------------------- | ------------------- | ------------------------------------ |
| **Format**    | Unstructured        | Formal doc          | ✅ **Structured but conversational** |
| **Ambiguity** | Common              | Depends on author   | ✅ **Proactively eliminated**        |
| **Time**      | Hours/days          | Hours               | ✅ **10-30 minutes**                 |
| **Iteration** | Slow (meetings)     | Slow (doc rewrites) | ✅ **Real-time Q&A**                 |
| **Context**   | Often lost          | Verbose             | ✅ **Concise, relevant**             |

## Summary

Discovery phase is **collaborative requirements engineering**:

- **Product Agent** asks clarifying questions (Socratic method)
- **You** provide answers (brief or detailed)
- **Output**: `project_overview.md` (structured, unambiguous specification)
- **Duration**: 10-30 minutes (vs hours for traditional PRDs)
- **Result**: Shared understanding, ready for planning

**Discovery is the foundation. Time invested here pays off in every subsequent phase.**
🎯
