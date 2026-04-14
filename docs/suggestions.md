# Suggestions Phase

## Overview

Suggestions is the **finalization phase** that runs after Presentation. It generates
practical outputs for completing the project: commit messages, PR descriptions, next
steps, and deployment considerations.

**Input**: `retrospective.md`, build artifacts, git history\
**Output**: `commit_message.txt`, optional PR template, next steps

## Purpose

Bridge development → delivery. Provide:

- **Commit message**: Conventional, informative, ready to use.
- **PR description**: Context for reviewers (if applicable).
- **Next steps**: What to do after merge (deployment, docs, follow-up work).
- **Deployment notes**: Environment changes, migrations, configuration.

This is the final checkpoint before you manually commit and push.

## The Suggestions Agent

### Role

Technical writer + project manager.

**Not**: Decision-maker (doesn't commit or push for you).\
**Is**: Assistant that drafts outputs based on what actually happened.

### Output Style

**Practical and actionable**:

- Commit messages follow conventions (Conventional Commits by default).
- PR descriptions highlight value, not just change list.
- Next steps are concrete commands or clear actions.
- Deployment notes cover gotchas, not obvious steps.

## Process Flow

```
Input: retrospective.md + build artifacts
    ↓
Suggestions Agent: Analyze completed work
    ├─ Read retrospective (scope, challenges, metrics)
    ├─ Review git diff (actual changes)
    ├─ Check tasks.yaml (original plan vs delivered)
    └─ Identify deployment requirements (new deps, env vars, migrations)
    ↓
Suggestions Agent: Generate commit message
    ├─ Type and scope (feat/fix/refactor/etc + module)
    ├─ Summary line (<72 chars, imperative mood)
    ├─ Body (what changed, why, notable details)
    ├─ Footer (breaking changes, references, metrics)
    └─ Format: Conventional Commits
    ↓
Suggestions Agent: Generate PR description (if multi-commit)
    ├─ Overview (what this achieves)
    ├─ Changes (high-level)
    ├─ Testing (coverage, manual validation)
    ├─ Deployment notes (if any)
    └─ Checklist (review items)
    ↓
Suggestions Agent: Generate next steps
    ├─ Immediate (push, create PR)
    ├─ Short-term (deployment, testing)
    ├─ Follow-up (deferred work, tech debt)
    └─ Commands (ready to copy-paste)
    ↓
Human: Review suggestions
    ├─ Approve commit message → Copy and use
    ├─ Edit commit message → Adjust to preference
    ├─ Review next steps → Follow or adapt
    └─ Close project → Archive session
```

## Commit Message Format

### Conventional Commits

Default format used by forge:

```
<type>(<scope>): <summary>

<body>

<footer>
```

**Type**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`, `build`,
`revert`

**Scope**: Module or area (e.g., `auth`, `api`, `ui`, `build`)

**Summary**: Imperative mood, <72 chars, no period

**Body**: Optional, explains what and why (not how—code does that)

**Footer**: Optional, breaking changes, issue references, metrics

### Example: Single Commit

For projects where you commit once at the end:

```
feat(auth): add OAuth authentication for Google and GitHub

Implement OAuth 2.0 authorization code flow with PKCE for Google
and GitHub identity providers. Users can now sign in using either
provider, with JWT-based session management (24-hour expiration).

Key changes:
- OAuthProvider trait for provider abstraction
- GoogleOAuthProvider and GitHubOAuthProvider implementations
- OAuth routes (/auth/oauth/{provider} and /callback)
- JWT token generation after successful OAuth
- UI updates (sign-in buttons on login page)

Security:
- State parameter validation (CSRF protection)
- HTTPS-only redirects
- OAuth secrets stored in environment variables

Testing:
- 23 new test functions (94% coverage for OAuth module)
- Integration tests for full OAuth flow
- Manual testing with live Google/GitHub OAuth apps

Dependencies:
- Added oauth2 = "4.4" (OAuth 2.0 client)
- Added reqwest = "0.11" (HTTP client for provider APIs)

Duration: 7.5 hours
Files changed: 8 files (+847/-24 lines)

Refs: #123
```

### Example: Multiple Commits

If you committed atomically during build (recommended):

**Individual commit messages** (already done by you):

```
test(auth): add OAuth provider trait tests (TDD RED)
feat(auth): implement OAuth provider trait (TDD GREEN)
test(auth): add Google OAuth provider tests (TDD RED)
feat(auth): implement Google OAuth provider with detailed errors
refactor(auth): extract common OAuth logic
feat(routes): add OAuth routes following existing patterns
feat(ui): add OAuth sign-in buttons to login page
test(ui): add tests for OAuth sign-in buttons
```

**Suggestions Agent provides PR description**:

```markdown
# OAuth Authentication (Google + GitHub)

## Overview

Adds OAuth 2.0 authentication for Google and GitHub identity providers, allowing users
to sign in without creating passwords.

## Changes

- **Core logic**: OAuthProvider trait with Google/GitHub implementations
- **Routes**: OAuth init and callback endpoints
- **Session**: JWT-based tokens (24-hour expiration)
- **UI**: Sign-in buttons on login page
- **Security**: State validation, HTTPS redirects, secure secret storage

## Implementation Details

Followed TDD for core OAuth logic (94% coverage), inventory-driven approach for route
integration (matched existing patterns), and traditional development for UI changes.

## Testing

- 23 new test functions
- Integration tests cover full OAuth flow
- Manual testing with live OAuth apps (Google + GitHub)
- Overall project coverage: 87% (+3% from baseline)

## Deployment Notes

### Environment Variables Required

GOOGLE_CLIENT_ID=your-google-client-id GOOGLE_CLIENT_SECRET=your-google-client-secret
GITHUB_CLIENT_ID=your-github-client-id GITHUB_CLIENT_SECRET=your-github-client-secret
OAUTH_REDIRECT_URI=https://yourdomain.com/auth/oauth/callback

### OAuth Provider Setup

Before deploying, create OAuth apps:

1. **Google**: https://console.cloud.google.com/apis/credentials
   - Authorized redirect URI: https://yourdomain.com/auth/oauth/callback

2. **GitHub**: https://github.com/settings/developers
   - Authorization callback URL: https://yourdomain.com/auth/oauth/callback

### Database

No migrations required (reuses existing users table).

### Dependencies

New crates added (already in Cargo.toml/Cargo.lock):

- oauth2 = "4.4"
- reqwest = "0.11" (may already exist)

## Review Checklist

- [ ] Environment variables configured in production
- [ ] OAuth apps created and redirect URIs configured
- [ ] HTTPS enforced (OAuth requires secure redirects)
- [ ] JWT secret rotated if needed (JWT_SECRET env var)
- [ ] Manual test: Sign in with Google
- [ ] Manual test: Sign in with GitHub
- [ ] Error handling: Try with invalid credentials
- [ ] Security review: State validation, token storage

## Follow-up Work

Deferred to future iterations (documented in retrospective):

- [ ] Refresh tokens (auto-extend sessions)
- [ ] Account linking (merge OAuth with password accounts)
- [ ] Additional providers (LinkedIn, Azure AD)
- [ ] Admin panel for OAuth app configuration

## Metrics

- Duration: 7.5 hours (Discovery through Build)
- Tasks: 9/9 completed
- Coverage: 94% (OAuth module), 87% (overall, +3%)
- Commits: 7 atomic commits
- Files: 8 files changed (+847/-24 lines)

Closes #123
```

## Next Steps Format

Concrete actions to take after Suggestions phase.

### Example: Next Steps Output

```markdown
# Next Steps

## Immediate (Before Merge)

1. **Review commit message** (or individual commits):
   - File: commit_message.txt
   - Edit if needed, then use for commit/PR

2. **Push branch**: git push origin feature/oauth-authentication

3. **Create Pull Request**:
   - Title: "feat(auth): add OAuth authentication for Google and GitHub"
   - Description: Use PR template from pr_description.md
   - Reviewers: Tag security-aware team members (OAuth is security-critical)

4. **Link issue**:
   - Add "Closes #123" to PR description

## Before Deployment

1. **Configure environment variables** (production):
   # Add to your deployment system (Kubernetes secrets, AWS SSM, etc.)
   GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=... GITHUB_CLIENT_ID=...
   GITHUB_CLIENT_SECRET=...
   OAUTH_REDIRECT_URI=https://yourdomain.com/auth/oauth/callback

2. **Create OAuth apps** (if not done):
   - Google: https://console.cloud.google.com/apis/credentials
   - GitHub: https://github.com/settings/developers
   - Configure redirect URIs to match OAUTH_REDIRECT_URI

3. **Security verification**:
   - Ensure HTTPS enforced (OAuth spec requirement)
   - Rotate JWT_SECRET if old/weak
   - Review OAuth scope requests (minimal necessary)

4. **Test in staging**:
   # Deploy to staging first
   make deploy-staging

   # Manual smoke tests
   curl -I https://staging.yourdomain.com/auth/oauth/google
   # Should redirect to Google OAuth

## Post-Deployment

1. **Monitor OAuth flow**:
   - Check logs for OAuth errors (provider downtime, invalid state)
   - Alert on elevated error rates
   - Dashboard: OAuth sign-in success rate

2. **User communication** (if applicable):
   - Announce new sign-in options
   - Document OAuth flow for support team

3. **Archive forge session**: forge close project-oauth

## Follow-up Work (Future Iterations)

From retrospective recommendations:

1. **Short-term** (next sprint):
   - [ ] Unify route handler patterns (2-3 hours)
   - [ ] Extract OAuth credential management pattern (documentation)

2. **Medium-term** (next quarter):
   - [ ] Add refresh token support (4-6 hours)
   - [ ] Account linking for existing users (8-10 hours)

3. **Long-term** (roadmap):
   - [ ] Additional OAuth providers (LinkedIn, Azure AD)
   - [ ] Admin panel for OAuth configuration
   - [ ] Single Sign-Out (SSO logout)

Create issues for follow-up work: gh issue create --title "Add OAuth refresh token
support"\
--body "Support automatic session extension via refresh tokens"\
--label enhancement --milestone "Q2 2026"
```

## Deployment Notes

Highlights environment changes, migrations, configuration needed.

### Example: Deployment Notes

```markdown
# Deployment Notes: OAuth Authentication

## Prerequisites

- HTTPS enforced (OAuth 2.0 spec requires secure redirects)
- OAuth apps created on Google/GitHub with correct redirect URIs

## Environment Variables

**New** (required): GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret
OAUTH_REDIRECT_URI=https://yourdomain.com/auth/oauth/callback

**Existing** (verify): JWT_SECRET=your-jwt-secret # Should be strong (32+ chars)

## Dependencies

New Rust crates (already in Cargo.lock, will be installed on build):

- oauth2 = "4.4"
- reqwest = "0.11"

No system-level dependencies.

## Database Migrations

None required. OAuth users reuse existing users table schema.

## Configuration Changes

None. OAuth routes registered automatically on startup.

## Rollback Plan

If issues arise, disable OAuth routes:

# Option 1: Remove OAuth buttons from UI

# Revert commit: git revert <commit-hash>

# Option 2: Feature flag (if implemented)

OAUTH_ENABLED=false

# Option 3: Full rollback

git revert HEAD~7..HEAD # Revert all 7 OAuth commits

OAuth is additive—existing password auth unaffected. Users who already signed in via
OAuth will be unable to login until re-enabled.

## Health Checks

Add to monitoring:

1. **OAuth provider health**:
   - Ping Google OAuth: https://accounts.google.com/.well-known/openid-configuration
   - Ping GitHub OAuth: https://github.com/login/oauth/authorize (should return 302)

2. **Application metrics**:
   - OAuth sign-in attempts (counter)
   - OAuth sign-in success rate (gauge, alert if <95%)
   - OAuth error types (counter by error variant)

3. **Security alerts**:
   - Invalid state parameter (possible CSRF attempt)
   - Repeated OAuth failures for same user (possible attack)

## Security Considerations

- OAuth secrets stored in environment (never in code/logs)
- State parameter validated on every callback (CSRF protection)
- HTTPS enforced (non-negotiable for OAuth)
- JWT secret should be rotated periodically (not automated yet)

## Known Issues / Limitations

- No refresh tokens: Users re-authenticate after 24 hours (by design for MVP)
- No account linking: OAuth users are separate from password users (future work)
- Single redirect URI: All providers use same callback endpoint (simplified setup)

## Testing in Production

After deployment, manually test:

1. **Google OAuth**:
   # Visit in browser (replace with your domain)
   https://yourdomain.com/auth/oauth/google

   # Should redirect to Google, then back to your app

2. **GitHub OAuth**: https://yourdomain.com/auth/oauth/github

3. **Error handling**:
   - Try with invalid OAuth app credentials (should show user-friendly error)
   - Deny authorization on provider screen (should redirect with message)

## Support Documentation

Update docs:

- User guide: How to sign in with Google/GitHub
- Admin guide: How to configure OAuth apps
- Troubleshooting: Common OAuth errors and solutions
```

## Review and Approval

### What You Review

- **Commit message**: Accurate summary, appropriate type/scope, useful body.
- **PR description** (if applicable): Clear context for reviewers.
- **Next steps**: Actionable, complete, covers deployment needs.
- **Deployment notes**: Accurate environment changes, no missing steps.

### Typical Adjustments

- Edit commit message (tone, emphasis, details).
- Adjust next steps (different deployment process).
- Add deployment context (company-specific infra, compliance requirements).
- Reorder follow-up work (different priorities).

### Example Review

```
┌─────────────────────────────────────────────────────┐
│ Suggestions Phase Complete                          │
│                                                     │
│ Artifacts generated:                                │
│  - commit_message.txt (Conventional Commits format) │
│  - pr_description.md (optional, if multi-commit)    │
│  - next_steps.md (immediate + follow-up actions)    │
│  - deployment_notes.md (env vars, config, health)   │
│                                                     │
│ Suggested commit message preview:                   │
│  feat(auth): add OAuth authentication for Google... │
│                                                     │
│ Review suggestions:                                 │
│  [v] View commit_message.txt                        │
│  [c] Copy commit message to clipboard               │
│  [e] Edit commit message                            │
│  [✓] Approve (ready to commit and push)             │
└─────────────────────────────────────────────────────┘

You: v ↵

# Opens commit_message.txt in $EDITOR
# Looks good, minor adjustment to summary line

You: e ↵

# Edit summary: "add OAuth authentication" → "add OAuth 2.0 authentication"

You: ✓ ↵

forge: "Suggestions approved. Ready to finalize project."

Next actions:
  1. Commit: git commit -F commit_message.txt
  2. Push: git push origin feature/oauth-authentication
  3. Create PR using pr_description.md

Would you like to close this project session? [y/n]
```

## Duration

- **Generation**: 5-10 minutes (automated).
- **Review**: 5-15 minutes (depends on editing depth).

## Artifacts

**Primary**:

- `commit_message.txt` (ready to use)
- `pr_description.md` (optional, for PRs)
- `next_steps.md` (action items)
- `deployment_notes.md` (infra changes)

**Usage**:

- Commit: `git commit -F commit_message.txt`
- PR: Copy pr_description.md into GitHub/GitLab PR form
- Deploy: Follow next_steps.md and deployment_notes.md

## Benefits

**Consistency**:

- Conventional Commit format (parseable, changelog-friendly).
- Detailed enough for future context, concise enough to scan.

**Completeness**:

- Doesn't forget deployment steps (env vars, configs).
- Captures follow-up work (doesn't disappear).

**Time savings**:

- No "what should I write in this commit message?" paralysis.
- Ready-to-use outputs (copy-paste).

**Knowledge transfer**:

- PR descriptions provide context for reviewers.
- Deployment notes help ops team.
- Next steps guide less experienced team members.

## Integration with Other Phases

### Presentation → Suggestions

Retrospective provides context:

- Metrics → Include in commit footer.
- Challenges → Mention in body if relevant.
- Scope → Determines commit type (feat/fix/refactor).

### Suggestions → Manual Finalization

Suggestions phase is last automated step:

- After approval, you manually commit, push, create PR.
- forge does **not** execute git commands (you maintain control).

### Suggestions → Evolution

Commit message quality feeds learning:

- Well-structured commits → Track over time.
- Deployment note patterns → Detect common infra changes.
- Follow-up work completion → Measure tech debt paydown.

## Commit Message Best Practices

### Summary Line

- **Imperative mood**: "add OAuth" (not "added" or "adds").
- **Lowercase first word** (except proper nouns): "add", "fix", "refactor".
- **No period at end**: "add OAuth authentication" (not "add OAuth authentication.").
- **<72 characters**: Fits in git log, GitHub UI.
- **Descriptive**: "add OAuth authentication" (not "auth changes").

### Body

- **What and why**, not how (code shows how).
- **Bullet points** for multiple changes (readable).
- **Blank line** between summary and body.
- **Context** for non-obvious decisions.

### Footer

- **Breaking changes**: `BREAKING CHANGE: Removed password-only auth support`
- **Issue references**: `Refs: #123`, `Closes #456`, `Fixes #789`
- **Metrics** (optional): `Duration: 7.5 hours`, `Coverage: 94%`
- **Co-authors** (if applicable): `Co-authored-by: Name <email>`

## Anti-Patterns

### Generic Commit Messages

**Bad**:

```
fix: update code
```

**Good**:

```
fix(auth): resolve token expiration race condition

Tokens issued within 1 second of expiration time could be rejected
due to clock skew. Added 10-second buffer to token validation.

Fixes: #456
```

### Skipping Deployment Notes

**Bad**:

```
# next_steps.md
1. Push branch
2. Create PR
3. Merge
```

**Good**:

```
# next_steps.md
1. Push branch
2. Create PR
3. Before merge: Configure OAUTH_CLIENT_ID and OAUTH_CLIENT_SECRET in prod
4. After merge: Test OAuth flow in production
5. Monitor error rates for 24 hours
```

### Ignoring Follow-up Work

**Bad**:

```
Retrospective: "Refactor route patterns (medium priority)"
# Never documented, forgotten
```

**Good**:

```
# next_steps.md
## Follow-up Work
- [ ] Refactor route patterns (issue #789, 2-3 hours, medium priority)
- [ ] Add refresh tokens (issue #790, 4-6 hours, low priority)

# Issues created, tracked, prioritized
```

## Customization

### Commit Message Style

forge defaults to Conventional Commits, but you can configure:

```yaml
# forge.yaml (project config)
commit_style: conventional  # Default
# commit_style: angular     # Angular style
# commit_style: custom      # Your own template
```

### PR Template

If your team uses PR templates:

```yaml
# forge.yaml
pr_template: .github/PULL_REQUEST_TEMPLATE.md

# forge will inject generated content into your template
```

### Deployment Checklist

Company-specific deployment steps:

```yaml
# forge.yaml
deployment_checklist:
  - "Update CHANGELOG.md"
  - "Tag release (vX.Y.Z)"
  - "Notify #deployments Slack channel"
  - "Update internal docs wiki"
```

forge adds these to next_steps.md automatically.

## Summary

Suggestions phase is **practical finalization**:

- **Generates**: Commit message, PR description, next steps, deployment notes.
- **Format**: Conventional Commits (parseable, consistent).
- **Content**: Based on retrospective + actual changes (not generic).
- **Output**: Ready-to-use artifacts (copy-paste or edit).
- **Control**: You manually commit/push (forge never touches git).

**Suggestions bridges development and delivery. Skip it, lose context.** 📝
