# Core Principles (Immutable)

These principles govern **every interaction** in forge. They are:

- **Non-negotiable**: Cannot be overridden
- **Enforced in prompts**: All agents receive them in system messages
- **Validated at checkpoints**: Automated checks verify adherence
- **Documented everywhere**: User guides, architecture docs, prompts

## Principle 1: AI = Code Writer (Not Package Manager)

### The Rule

**AI is a code writer, not a package manager or deployment system.**

### What AI CAN Do

✅ **Source Code**

- Write new source files (src/, tests/, docs/)
- Modify existing source files
- Delete/refactor source files
- Create directory structures (within allowed zones)

✅ **Build & Test**

- Run tests using existing dependencies (cargo test, npm test, pytest)
- Build projects using existing dependencies (cargo build, npm run build)
- Run linters and formatters (clippy, eslint, rustfmt, prettier)
- Generate documentation (cargo doc, jsdoc)

✅ **Read Configuration**

- Read dependency manifests (Cargo.toml, package.json) - **READ ONLY**
- Read lock files (Cargo.lock, package-lock.json) - **READ ONLY**
- Read build configs (.cargo/config.toml, tsconfig.json) - **READ ONLY**

✅ **Propose Changes**

- Suggest dependency additions/updates (proposals only, not executed)
- Propose architecture improvements
- Recommend tooling changes

### What AI CANNOT Do

❌ **Dependency Management**

- Modify dependency manifests (Cargo.toml, package.json, requirements.txt, etc.)
- Modify lock files (Cargo.lock, package-lock.json, poetry.lock, etc.)
- Execute package manager commands (cargo add, npm install, pip install, etc.)
- Add, update, or remove dependencies

❌ **Version Control**

- Create commits (git commit) - **HUMAN ONLY**
- Push commits (git push) - **HUMAN ONLY**
- Create branches (git branch, git checkout -b) - **HUMAN ONLY**
- Merge branches (git merge) - **HUMAN ONLY**
- Tag releases (git tag) - **HUMAN ONLY**

**forge NEVER writes to or executes Git commands. It only suggests messages.**

❌ **CI/CD & Infrastructure**

- Modify CI/CD configs (.github/workflows/, .gitlab-ci.yml, etc.)
- Modify deployment scripts
- Modify Docker configs (Dockerfile, docker-compose.yml)
- Modify infrastructure as code (Terraform, CloudFormation, etc.)

### Why This Principle

**Supply chain security**: Humans control what code enters the project.

**Deployment control**: Humans decide when and how to deploy.

**Architecture ownership**: Humans own dependency decisions.

**Audit trail**: Clear separation between AI work (code) and human decisions
(dependencies, deployment).

### Enforcement Mechanisms

1. **Sandbox**: Dependency manifests and lock files mounted read-only
2. **Tool system**: Package manager commands not exposed to agents
3. **Validation**: Checkpoints verify no forbidden files modified
4. **Prompts**: Every agent receives this principle in system message

### What Happens When Dependency Needed

**Scenario**: AI is implementing OAuth feature, needs `oauth2` crate.

**AI behavior**:

1. Detects missing dependency during compilation
2. Checks if listed in plan.md (should be from Plan phase)
3. **STOPS implementation**
4. Escalates to human:
   ```
   Feature F1 requires dependency: oauth2 = "4.4"

   This dependency was planned in Phase 2 (see plan.md).

   To proceed, please install:
   $ cargo add oauth2@4.4

   Then resume Build phase.
   ```

**Human response**:

1. Reviews dependency (is it needed? trusted? right version?)
2. Installs: `cargo add oauth2@4.4`
3. Reviews Cargo.lock changes
4. Commits separately: `git commit -m "chore: add oauth2 dependency"`
5. Resumes Build phase

**Result**: Clear audit trail, human controls supply chain.

## Principle 2: Human-in-the-Loop (Explicit Approval Gates)

### The Rule

**No phase transition without explicit human approval.**

### Approval Process

Every phase ends with a **human gate**:

```
Agent: "Phase 1 (Discovery) complete. Artifacts generated:
- project_overview.md

Please review and decide:
[✓] Approve (proceed to Plan)
[✗] Reject (provide feedback, I'll regenerate)
[🔧] Approve with changes (list changes, I'll apply then proceed)
[?] Questions (I'll clarify)"
```

Human responds with one of:

- **✓ Approve**: Agent proceeds to next phase
- **✗ Reject**: Agent regenerates with feedback
- **🔧 Approved with changes**: Agent applies changes, then proceeds
- **?** Questions: Agent provides clarifications

### What Requires Approval

**Phase transitions**:

- Discovery → Plan
- Plan → Build
- Build → Presentation
- Presentation → Suggestions

**Within Build phase (checkpoints)**:

- After feature completion (default)
- Or after batch of N tasks (configurable)
- On escalations (agent stuck, ambiguity, etc.)

**Never auto-proceed**:

- ❌ No "just do it" mode
- ❌ No "trust me" mode
- ❌ No silent transitions

### Why This Principle

**Architectural control**: Humans make key decisions.

**Risk management**: Catch issues early (Discovery/Plan cheaper than Build).

**Learning opportunities**: Human feedback improves agents.

**Compliance**: Audit trail shows human reviewed and approved.

### Enforcement Mechanisms

1. **Orchestrator**: Phase manager blocks transition without approval
2. **TUI**: Approval prompt blocks UI, requires explicit input
3. **Logging**: All decisions logged with timestamp and reason
4. **Validation**: Checkpoints verify approval exists before proceeding

### Exception: Internal Loops

**Within a phase**, agents can iterate without approval:

- Dev agent writes code → QA agent validates → Dev agent fixes
- This is internal iteration, not phase transition

**But**: Human checkpoints still occur at feature boundaries.

## Principle 3: Security by Default (Built-in Sandbox)

### The Rule

**All AI agents run in a secure, built-in sandbox using Bubblewrap + Landlock with minimal privileges.**

### Sandbox Architecture

forge includes a **built-in sandbox** (not external project):

- Implemented in Rust (integrated with forge binary)
- Uses Bubblewrap for namespace isolation
- Uses Landlock for syscall filtering
- Not a separate tool, part of forge itself

### Defense Layers

**Layer 1: Environment Filtering**

- Blocks env vars: *KEY*, *SECRET*, *TOKEN*, *PASSWORD*, *CREDENTIALS*
- Allowlist: PATH, HOME, USER, TERM, LANG, FORGE_*
- Applied before sandbox launch

**Layer 2: Filesystem Isolation (Bubblewrap)**

- **RW zones (AI can modify)**:
  - /workspace/src
  - /workspace/tests
  - /workspace/docs
  - /workspace/examples
  - /workspace/benches

- **RO zones (AI can read)**:
  - /usr, /lib, /bin (system)
  - /workspace/Cargo.toml, /workspace/package.json (manifests)
  - /workspace/Cargo.lock, /workspace/package-lock.json (lock files)
  - /workspace/.git (history)
  - /workspace/node_modules, /workspace/target (build artifacts)

- **Invisible zones (AI cannot see)**:
  - ~/.ssh (SSH keys)
  - ~/.aws, ~/.gcp (cloud credentials)
  - /workspace/.env (secrets)
  - /workspace/.github, /workspace/.gitlab-ci.yml (CI configs)

**Layer 3: Syscall Enforcement (Landlock)**

- Kernel-level MAC (Mandatory Access Control)
- Path-based restrictions (enforced by kernel)
- No root required (user namespace)
- Cannot be bypassed by agent

**Layer 4: Process Isolation (Namespaces)**

- PID namespace: Cannot see other processes
- IPC namespace: No inter-process communication
- Mount namespace: Private filesystem view
- User namespace: Unprivileged inside sandbox

**Layer 5: Permission Gates (Application Layer)**

- Human approval for dangerous operations
- Audit log of all tool executions
- Dry-run mode for validation

### Performance

- **Overhead**: ~1ms per agent launch (negligible)
- **Isolation**: Complete (kernel-enforced)
- **Auditability**: Full (every action logged)

### Why Built-in (Not External)

**Integration**: Tightly coupled with orchestrator.

**Simplicity**: No external tools to install/configure.

**Performance**: Direct Rust bindings to Bubblewrap/Landlock.

**Maintenance**: Single codebase, consistent behavior.

**Distribution**: Single binary, no dependencies.

### Enforcement Mechanisms

1. **Forge binary**: Sandbox code embedded, always active
2. **No bypass**: Cannot run agents outside sandbox
3. **Validation**: Startup checks sandbox is active and configured
4. **Testing**: Security test suite runs on every build

### What If Sandbox Disabled

**For development/debugging only**:

```
$ forge --no-sandbox --i-understand-the-risks build
Warning: Running without sandbox. All security guarantees VOID.
Proceed? [y/N]
```

**Production**: Flag not available in release builds.

## Principle 4: Transparency & Auditability

### The Rule

**Every action is logged. Nothing is hidden from humans.**

### What Gets Logged

**File operations**:

- read_file(path)
- write_file(path, size)
- delete_file(path)
- create_directory(path)

**Tool executions**:

- Command: `cargo test`
- Arguments: `["test", "--lib"]`
- Exit code: 0
- Duration: 2.3s
- Output: (captured)

**Agent decisions**:

- "Implementing task T5: Write OAuth provider"
- "Chosen approach: Trait-based abstraction"
- "Reasoning: Allows future providers easily"

**Human interactions**:

- Phase 1 approval: ✓ Approved
- Reason: "Scope looks good"
- Timestamp: 2026-02-02 13:15:00 CET

**Validation results**:

- Check: test_execution
- Rule: "cargo test oauth passes"
- Result: PASS
- Evidence: "All 12 tests passed in 1.2s"

**Errors**:

- Action: write_file("src/auth.rs")
- Error: "Permission denied (read-only mount)"
- Context: "Attempted to modify in Discovery phase (RO)"

### Log Storage

**Per-project session**:

```
~/.local/share/forge/sessions/<project_name>/
  ├── session_20260202_131500.db (SQLite)
  ├── build_log.md (Markdown summary)
  ├── retrospective.md (Analysis)
  └── audit_trail.json (Machine-readable)
```

**Searchable**:

```
$ forge search "oauth implementation"
→ Found in session_20260202_131500:
  - Phase 2: Architect Agent designed OAuth module
  - Phase 3: Dev Agent implemented src/auth/oauth.rs
  - Phase 3: QA Agent validated OAuth tests
```

### Real-Time Visibility

**TUI shows**:

- Current phase and active agent
- Ongoing tool execution (streaming output)
- Recent decisions (last 10 actions)
- Validation results (pass/fail indicators)

**Dashboard view**:

- All projects (if multi-project mode)
- Progress per project
- Alerts/escalations

### Audit Trail Format

**JSON structure** (machine-readable):

```json
{
  "timestamp": "2026-02-02T13:15:42Z",
  "session_id": "sess_abc123",
  "phase": "build",
  "agent": "dev_agent",
  "action": "write_file",
  "parameters": {
    "path": "src/auth/oauth.rs",
    "size_bytes": 1247
  },
  "result": "success",
  "duration_ms": 5
}
```

### Why This Principle

**Trust**: Humans can verify AI did what it claimed.

**Debugging**: Detailed logs help diagnose issues.

**Learning**: Retrospectives use logs to improve.

**Compliance**: Audit trail proves human oversight.

### Enforcement Mechanisms

1. **Tool layer**: All tool calls log before and after execution
2. **Agent layer**: All decisions logged before proceeding
3. **Orchestrator**: All phase transitions logged
4. **Validation**: Logs verified to exist and be complete

## Principle 5: Methodology Flexibility (Not Dogmatic)

### The Rule

**Choose development methodology per project or per feature, not globally mandated.**

### Available Methodologies

**Test-Driven Development (TDD)**:

- Write failing test first (RED)
- Implement minimal code to pass (GREEN)
- Refactor while keeping tests green (REFACTOR)
- Use when: Critical logic, greenfield features, APIs

**Inventory-Driven Development**:

- Generate codebase inventory first (tree-sitter AST analysis)
- Understand existing patterns, dependencies, architecture
- Respect patterns and avoid introducing refactor signals
- Use when: Modifying existing complex codebases, refactoring

**Behavior-Driven Development (BDD)**:

- Write Gherkin scenarios first (Given/When/Then)
- Implement step definitions
- Make scenarios pass
- Use when: User-facing features, integration testing

**Traditional Development**:

- Implement feature first
- Write tests after
- Validate manually
- Use when: Simple changes, prototypes, exploration

**Hybrid (Mix & Match)**:

- Different methodology per feature
- Example:
  - Feature F1: TDD (critical auth logic)
  - Feature F2: Inventory-Driven (refactor existing API)
  - Feature F3: Traditional (simple UI form)

### How Methodology Is Chosen

**Plan phase (Phase 2)**:

- Architect Agent proposes methodology per feature
- Documented in methodology.yaml (optional file)
- Or in plan.md (minimal approach)
- Human reviews and can override

**Example in plan.md** (minimal):

```markdown
## Methodology

- Task T1-T5 (OAuth core): TDD (critical authentication logic)
- Task T6-T8 (API integration): Inventory-Driven (modifying existing API)
- Task T9-T10 (UI forms): Traditional (simple implementation)
```

**Example methodology.yaml** (maximal):

```yaml
project_methodology:
  global_defaults:
    # No global mandate, choose per feature
    tdd: false
    inventory_driven: false

  features:
    - feature: F1
      methodology: tdd
      rationale: "Critical authentication logic, test-first essential"

    - feature: F2
      methodology: inventory_driven
      rationale: "Modifying existing API, must respect patterns"

    - feature: F3
      methodology: traditional
      rationale: "Simple UI form, straightforward implementation"
```

### How Methodology Is Enforced

**Build phase (Phase 3)**:

- Dev Agent reads methodology per task
- Follows prescribed approach
- QA Agent validates adherence where possible

**TDD example**:

```
Task T1: Feature F1, Phase RED
- Dev Agent writes failing test
- QA Agent verifies test fails
- If test passes initially: ERROR (not TDD)

Task T2: Feature F1, Phase GREEN
- Dev Agent implements minimal code
- QA Agent verifies test passes
- If test still fails: Retry or escalate

Task T3: Feature F1, Phase REFACTOR
- Dev Agent refactors code
- QA Agent verifies tests still pass
```

**Inventory-Driven example**:

```
Task T1: Feature F2, Phase ANALYSIS
- Dev Agent generates inventory.yaml for affected modules
- Analyzes existing patterns
- Plans implementation to match patterns

Task T2: Feature F2, Phase IMPLEMENTATION
- Dev Agent implements following inventory guidance
- QA Agent validates no new refactor signals introduced
```

### Methodology Feedback

**Presentation phase (Phase 4)**:

- Retrospective analyzes effectiveness per methodology
- Example:
  ```markdown
  ## Methodology Effectiveness

  Feature F1 (TDD):

  - Time: 1.5 hours (planned: 1.0 hours)
  - Outcome: 2 bugs caught in RED phase
  - Verdict: Worth the overhead

  Feature F2 (Inventory-Driven):

  - Time: 1.0 hours (planned: 1.5 hours)
  - Outcome: No refactor signals introduced
  - Verdict: Analysis time saved implementation time

  Feature F3 (Traditional):

  - Time: 0.5 hours (planned: 0.5 hours)
  - Outcome: Minimal tests, fast delivery
  - Verdict: Appropriate for simple changes
  ```

**Evolution**: Learns which methodologies work for which project types.

### Why This Principle

**Pragmatism**: Different projects need different approaches.

**Flexibility**: Teams can use familiar methodologies.

**Learning**: System learns what works where.

**No dogma**: Not forcing TDD or any single approach.

### Enforcement Mechanisms

1. **Plan phase**: Methodology declared explicitly
2. **Build phase**: Tasks tagged with methodology
3. **Agent prompts**: Context-aware based on methodology
4. **Validation**: Checks adherence where feasible (e.g., TDD test-first)
5. **Retrospective**: Effectiveness tracked and reported

## Principle 6: Continuous Evolution (Darwin Gödel Machine)

### The Rule

**The system improves through a background Darwin Gödel Machine evolution loop, validating through empiricism, not theoretical claims.**

### Darwin Gödel Machine Approach

**Inspired by**: Research on self-improving AI systems.

**Core concepts**:

- **Agent archive**: Growing library of agent variants
- **Empirical validation**: Real benchmarks, not proofs
- **Open-ended evolution**: Multiple improvement paths
- **Self-referential**: System can modify its own prompts/behavior

### How It Works

**Step 1: Complete Project**

- Phases 1-5 execute normally
- All metrics collected
- Retrospective generated

**Step 2: Human Feedback**

- Human reviews retrospective
- Provides ratings (accuracy, efficiency, quality)
- Notes what worked and what didn't

**Step 3: Evolution Proposals**

- Evolution Agent analyzes:
  - Metrics (time, cost, validation rates)
  - Human feedback
  - Methodology effectiveness
  - Patterns that emerged
- Proposes improvements:
  - Adjust agent prompts
  - Change validation rules
  - Suggest methodology defaults
  - Refine tool usage

**Step 4: Validation**

- Proposals tested in sandbox
- Run against benchmark suite
- Compare to previous agent variant
- Metrics: accuracy, speed, cost, human satisfaction

**Step 5: Archive Decision**

- **Better**: Archive as new variant, mark active
- **Different trade-off**: Archive for diversity
- **Worse**: Archive with notes (learn from failure)

**Step 6: Meta-Learning**

- Which improvements worked?
- Which patterns emerged?
- Update evolution strategy itself

### What Gets Archived

**Agent variant** contains:

```yaml
id: agent_042_split_orchestrator
parent_id: agent_041_baseline
timestamp: "2026-02-02T13:15:00Z"
change_description: "Split orchestrator.rs into phase_manager + agent_coordinator"
reason: "High refactor signal in inventory analysis"

metrics:
  accuracy: 0.87  # Up from 0.82
  speed: 38s      # Down from 42s (faster)
  cost: 2.35      # Down from 2.47 (cheaper)
  human_satisfaction: 4.5/5  # Up from 4.0/5

artifacts:
  - system_prompts/*.md
  - validation_rules/*.yaml
  - methodology_defaults.yaml
  - tool_configurations/*.toml

kept: true  # This variant is active
```

### Metrics Tracked

**Per-project metrics**:

- Total time (per phase, per task)
- API cost (tokens, calls, $)
- Files modified (lines added/deleted)
- Validation pass/fail rates
- Retry/escalation counts
- Human intervention frequency
- Methodology effectiveness
- Human satisfaction rating

**Aggregate metrics** (across projects):

- Average accuracy (validation pass rate)
- Average speed (time per feature)
- Average cost ($ per feature)
- Human satisfaction trend
- Evolution success rate

### Feedback Loops

**Phase → Phase**:

- Discovery feedback informs Plan
- Plan feedback informs Build
- Build feedback informs Presentation
- Presentation feedback informs Suggestions

**Phase → Evolution**:

- Every phase contributes metrics
- Retrospective synthesizes learnings
- Evolution agent proposes improvements

**Evolution → Agents**:

- Successful improvements update prompts
- Failed experiments inform caution
- Patterns become heuristics

**Human → System**:

- Explicit feedback (✓/✗/🔧 with reasons)
- Implicit feedback (approval rates, modification frequency)
- Satisfaction ratings

### Why This Principle

**Continuous improvement**: System gets better over time.

**Empirical validation**: Not based on theory, based on results.

**Human-guided evolution**: Humans provide direction via feedback.

**Safety**: All evolution tested in sandbox before deployment.

### Enforcement Mechanisms

1. **Presentation phase**: Mandatory retrospective generation
2. **Evolution agent**: Runs after human provides feedback
3. **Archive**: SQLite database tracks all variants and metrics
4. **Validation**: All evolution proposals tested before activation
5. **Human control**: Evolution is opt-in, human activates variants

---

## Summary

These six principles form the **immutable foundation** of forge:

1. **AI = Code Writer**: Clear separation of responsibilities
2. **Human-in-the-Loop**: Explicit approval at every gate
3. **Security by Default**: Built-in sandbox, always active
4. **Transparency**: Complete audit trail
5. **Methodology Flexibility**: Choose what works for you
6. **Self-Improvement**: Learn from every project

They are:

- **Enforced in code**: Validation, sandbox, orchestrator
- **Enforced in prompts**: Every agent receives them
- **Enforced at checkpoints**: Automated verification
- **Enforced by design**: Architecture makes violations hard

**Violating a principle = Immediate escalation to human.**
