# forge Overview

## The Vision: Code Directors, Not Coders

The era of writing code line-by-line is ending. The future is **directing AI agents**
that implement in parallel while you focus on architecture, vision, and validation.

**forge** is a terminal-native environment that positions you as a **code director**:

- Orchestrate multiple projects/features in parallel (same repo, different branches)
- Manage multiple phases simultaneously across projects
- Formal Gate Documentation: Audit trail of decisions and blockers
- Define architecture and validation criteria
- Let AI handle implementation details
- Review and approve output at strategic checkpoints

## What forge Is

A self-improving, TUI/CLI-first AI development environment with:

### Core Capabilities

- **Multi-project orchestration**: Run multiple projects in parallel, each with
  specialized agents
- **Phase-based workflow**: Discovery → (Inventory) → Plan → Build → Presentation → Suggestions
- **Gate Documentation**: Formal tracking of decision points, blockers, and pause reasons
- **Built-in security**: Integrated sandbox (not external tool) with Bubblewrap + Landlock
- **Human control**: Explicit approval gates, never autonomous. Write operations in Git are ALWAYS manual.
- **Continuous Evolution**: Background system based on the Darwin Gödel Machine approach
- **Language-agnostic**: Works with any language via tree-sitter + LSP
- **OpenCode integration**: Strategic integration for advanced code generation; dependency will be phased out as forge matures.

### Planned Detailed Specs

- **Extended Diff Tool Requirements**: See `docs/extended-diff.md` for the planned AST-aware review summary and CLI usage.

### What Makes It Different

**Traditional AI Coding:**

```
You: "Add OAuth"
AI: *writes code*
You: *reviews 500 lines of changes*
AI: *might have broken things*
You: *spends hours debugging*
```

**forge (Code Director Model):**

```
You: "I need 3 features: OAuth, API refactor, and UI update"

You create 3 projects (same repo, different branches):
  - Project A: feature/oauth (branch)
  - Project B: feature/api-refactor (branch)
  - Project C: feature/ui-update (branch)

Timeline (parallel):
09:00 - Start Project A Discovery
09:15 - Start Project B Discovery (while A completes)
09:30 - Approve A Discovery → A moves to Plan
09:45 - Start Project C Discovery (while B completes, A planning)
10:00 - Approve B Discovery → B moves to Plan (A still planning)
10:15 - Approve A Plan → A moves to Build (B planning, C discovering)
10:30 - Approve C Discovery → C moves to Plan (A building, B planning)
11:00 - Approve B Plan → B moves to Build (A building, C planning)
11:15 - Approve C Plan → C moves to Build (A, B, C all building)

Result: 3 features in parallel, director-level context switching
```

**Key insight**: Parallelism is at the **project/feature level**, not individual tasks
within a project.

## The Paradigm Shift

We are moving from **sequential coding** to **parallel orchestration**:

### Old Paradigm: Developer as Coder

- Write code line by line
- Debug errors manually
- Test after implementation
- Single-threaded workflow
- Human bottleneck

### New Paradigm: Developer as Director

- Define architecture and goals
- AI agents implement in parallel across features
- Continuous validation during build
- Multi-threaded workflow (multiple projects/branches)
- AI handles details, human handles vision

**Analogy**: You're not playing every instrument anymore. You're conducting the
orchestra.

## Core Design Philosophy

### 1. Human Control Over AI Capability

**Not about**: Letting AI do whatever it wants.

**About**: Empowering humans to direct AI effectively.

**How**:

- Explicit approval gates at every phase
- Humans install dependencies, not AI
- Humans commit and deploy, not AI. System can suggest, but NEVER executes or writes to Git.
- AI proposes, human decides

### 2. Parallel Over Sequential

**Not about**: Single AI assistant helping one task.

**About**: Multiple projects progressing simultaneously in a background Darwin Gödel Machine evolution loop.

**How**:

- Multiple projects can be in different phases
- Same repository, different branches per project
- Each project has independent agents
- Director (you) coordinates at high level
- Context switching happens at phase boundaries, not code level

### 3. Security by Design, Not Afterthought

**Not about**: Adding security later.

**About**: Security integrated from day one.

**How**:

- Built-in sandbox (Bubblewrap + Landlock) in forge binary
- All agents run isolated by default
- No way to run without sandbox (except explicit --no-sandbox for debugging)
- Secrets invisible, manifests read-only, system files protected

### 4. Feedback Loops Everywhere

**Not about**: Linear waterfall workflow.

**About**: Continuous learning and refinement.

**How**:

- Forward feedback: Each phase informs the next
- Backward feedback: Can return to previous phase with learnings
- Lateral feedback: Phases inform evolution engine
- Meta feedback: Human feedback improves agent behavior

### 5. Empirical Improvement Over Theoretical

**Not about**: Assuming AI works perfectly.

**About**: Measuring, learning, evolving.

**How**:

- Metrics collected every project
- Retrospectives analyze what worked
- Agent variants archived and compared
- Evolution based on real outcomes, not theory

## The Five-Phase Workflow

### Phase 1: Discovery (Understanding)

**Purpose**: Define WHAT to build and WHY.

**Who**: Product Agent + Human

**Outputs** (minimal → maximal):

- `project_overview.md` - Vision, goals, constraints [REQUIRED]
- `user_stories.yaml` - User stories with acceptance criteria [OPTIONAL]

**Human Gate**: ✓ Approve / ✗ Reject / 🔧 Modify

**Time**: Minutes to hours (depending on project scope)

**Note**: Minimal viable discovery = project_overview.md only. User stories optional for
complex features.

### Phase 2: Plan (Strategy)

**Purpose**: Define HOW to build and HOW to validate.

**Who**: Architect Agent + Human

**Outputs** (minimal → maximal):

- `plan.md` - Architecture decisions, module design [REQUIRED]
- `tasks.yaml` - Ordered task breakdown [REQUIRED]
- `methodology.yaml` - TDD/Inventory/Traditional per feature [OPTIONAL]
- `features.yaml` - Features with validation rules [OPTIONAL]
- `inventory.yaml` - Codebase analysis (if inventory-driven enabled) [OPTIONAL]

**Dependencies**: Lists what human needs to install before Build [REQUIRED section in
plan.md]

**Human Gate**: ✓ Approve / ✗ Reject / 🔧 Modify

**Time**: Hours (complex architecture) to minutes (simple changes)

**Note**: Minimal viable plan = plan.md + tasks.yaml. Other files add rigor for complex
projects.

### Phase 3: Build (Implementation)

**Purpose**: Implement features according to plan.

**Who**: Dev Agent + QA Agent + Human (checkpoints)

**Process**:

- Dev Agent implements tasks in order
- QA Agent validates each task
- Human checkpoints after features
- **Within a single project**: Tasks run sequentially (not parallel)
- **Across projects**: Multiple builds can run simultaneously

**Outputs** (minimal → maximal):

- Code changes (uncommitted) [REQUIRED]
- `build_log.md` - Detailed progress [REQUIRED]
- Test files [REQUIRED if methodology requires]
- `progress.yaml` - Task completion status [OPTIONAL]

**Human Gates**: Checkpoints per feature or batch

**Time**: Hours to days (most time-consuming phase)

**Note**: Minimal viable build = code changes + build_log.md. Tests required if TDD or
validation rules demand it.

### Phase 4: Presentation (Analysis)

**Purpose**: Retrospective analysis and learning.

**Who**: Analysis Agent + Human

**Outputs** (minimal → maximal):

- `retrospective.md` - Timeline, metrics, insights [REQUIRED]
- `improvement_suggestions.yaml` - Process improvements [OPTIONAL]

**Human Gate**: Review and provide feedback

**Time**: Minutes

**Note**: Minimal viable presentation = retrospective.md with basic metrics. Improvement
suggestions optional.

### Phase 5: Suggestions (Proposals)

**Purpose**: Propose commit and deployment steps.

**Who**: Suggestions Agent + Human (executor)

**Outputs** (minimal → maximal):

- `commit_message.txt` - Conventional commits format [REQUIRED]
- `deployment_plan.md` - Step-by-step instructions [OPTIONAL]
- `rollback_plan.md` - Contingency plan [OPTIONAL]
- `dependency_changes.yaml` - If any dependencies added [OPTIONAL]

**Human Gate**: Accept / Modify / Discard / Execute

**Time**: Minutes

**IMPORTANT**: AI never executes commits or deployments. Human does.

**Note**: Minimal viable suggestion = commit_message.txt. Deployment/rollback plans
optional for simple changes.

## Multi-Project Orchestration (The Real Power)

### The Director's Dashboard

```
┌─────────────────────────────────────────────────────────┐
│              forge Orchestrator (You)                   │
│                  Code Director                          │
└───────┬──────────────┬──────────────┬──────────────────┘
        │              │              │
   ┌────▼────┐    ┌────▼────┐   ┌────▼────┐
   │Project A│    │Project B│   │Project C│
   │feature/ │    │feature/  │   │feature/  │
   │oauth    │    │api-refac │   │ui-update │
   │(branch) │    │(branch)  │   │(branch)  │
   ├─────────┤    ├──────────┤   ├──────────┤
   │ Build   │    │ Plan     │   │Discovery │
   │(Phase 3)│    │(Phase 2) │   │(Phase 1) │
   └────┬────┘    └────┬─────┘   └────┬─────┘
        │              │              │
   ┌────▼────┐    ┌────▼─────┐   ┌────▼─────┐
   │Dev Agent│    │Architect │   │Product   │
   │QA Agent │    │Agent     │   │Agent     │
   └─────────┘    └──────────┘   └──────────┘
```

### Key Capabilities

**Parallel Project Management**:

- Same repository, different branches per project/feature
- Work on Project A (Build phase) while Project B is in Plan
- Switch context at director level (not implementation level)
- Each project has independent agents and phase state
- TUI tabs per project (gt/gT to switch)

**Sequential Within Project, Parallel Across Projects**:

- Within Project A: Tasks execute sequentially (Task 1 → Task 2 → Task 3)
- But: Project A Build, Project B Plan, Project C Discovery all happen simultaneously
- Human reviews at phase boundaries (checkpoints)
- No parallel tasks within a single project (keeps it simple and predictable)

**Context Preservation**:

- Each project maintains full session state
- Switch between projects without losing context
- Resume work exactly where you left off
- Audit trail per project

### Example Scenario: Director Orchestrating 3 Features

**Monday morning** (You as Director):

```
09:00 - Start Project A (OAuth feature, branch: feature/oauth)
        Phase 1: Discovery with Product Agent

09:15 - While A in Discovery, start Project B (API refactor, branch: feature/api-refactor)
        Phase 1: Discovery with Product Agent

09:30 - Approve Project A Discovery
        Phase 2: Plan phase begins for A

09:45 - While A planning, start Project C (UI update, branch: feature/ui-update)
        Phase 1: Discovery for C

10:00 - Approve Project B Discovery
        Phase 2: Plan phase begins for B
        (Now: A planning, B planning, C discovering)

10:15 - Approve Project A Plan
        Install dependencies: cargo add oauth2
        Phase 3: Build phase begins for A

10:30 - Approve Project C Discovery
        Phase 2: Plan phase begins for C
        (Now: A building, B planning, C planning)

11:00 - Approve Project B Plan
        Phase 3: Build phase begins for B
        (Now: A building, B building, C planning)

11:15 - Approve Project C Plan
        Phase 3: Build phase begins for C
        (Now: A building, B building, C building - all parallel!)

12:00 - Lunch (All 3 builds running, will checkpoint later)

14:00 - Review Project A checkpoint (OAuth implementation done)
        Approve, A Build complete

14:15 - Review Project A Presentation
        Metrics look good, provide feedback

14:30 - Review Project A Suggestions
        Commit message approved, execute:
        $ git checkout feature/oauth
        $ git commit -F commit_message.txt
        $ git push

14:45 - Review Project B checkpoint (API refactor done)
        Found issue, request changes, B continues Build

15:15 - Review Project C checkpoint (UI update done)
        Approve, C Build complete

15:30 - Review Project C Presentation & Suggestions
        Commit and push feature/ui-update

16:00 - Review Project B checkpoint (fixes applied)
        Approve, B Build complete

16:15 - Review Project B Presentation & Suggestions
        Commit and push feature/api-refactor

16:30 - All 3 features complete and pushed
        Ready for PR review or merge
```

**Result**: Managed 3 features in parallel on 3 branches in one day.

### Why This Model Works

**Context switching efficiency**:

- Switch between projects at natural boundaries (phase transitions)
- Not switching between individual code edits (too granular)
- Director-level decisions, not coder-level details

**Predictable within project**:

- Each project runs sequentially through phases
- Tasks within Build phase execute in order
- No complexity of parallel task coordination within a project

**Scalable across projects**:

- Add more projects without overwhelming cognitive load
- Each project is independent
- TUI manages context for you

### OpenCode Integration

forge uses a **phased integration strategy** with OpenCode:

- **Phase 2**: Wrap OpenCode as the initial builder capability
- **Phase 3+**: Gradually implement features natively in Rust
- **Long-term**: OpenCode may remain as inspiration or become optional

See [OpenCode Integration Strategy](./opencode-strategy.md) for full details.

### What OpenCode Provides (Phase 2)

- Advanced code understanding and context management
- Multi-file simultaneous changes
- Self-correction loops (runs tests, fixes errors, retries)
- Agentic planning (Perceive → Plan → Execute → Reflect)

### How forge Integrates OpenCode

During Phase 2, forge wraps OpenCode to leverage its builder capabilities. This allows
forge to focus on orchestration while using OpenCode's proven code generation. As forge
matures, features can be reimplemented natively in Rust based on real usage patterns and
performance requirements.

## Target Users

### Primary: Individual Developers Transitioning to Directors

- Currently writing code manually
- Want to scale productivity 10x
- Need to maintain control over architecture
- Prefer terminal/keyboard workflows
- Value security and auditability

### Secondary: Engineering Teams

- Need standardized AI workflows
- Require audit trails for compliance
- Want parallel development capabilities
- Need security guarantees
- Multiple projects/features in flight

### Who forge Is NOT For

- Teams wanting fully autonomous AI (no human oversight)
- Organizations without terminal/CLI culture
- Projects that can't use sandboxing (incompatible environments)
- Developers expecting AI to make all decisions

## Success Metrics

### For Users

- **10x productivity**: Features shipped per week (measured)
- **Zero security incidents**: No breaches from AI actions
- **90%+ approval rate**: Human rarely rejects AI work
- **< 5% time coding**: Mostly reviewing and directing

### For System

- **Agent accuracy improves**: Validation pass rates increase over time
- **Human intervention decreases**: Fewer escalations as agents learn
- **Cost efficiency**: $ per feature decreases with learning
- **Methodology optimization**: Best practices emerge from data

## Comparison to Alternatives

| Aspect                 | Copilot   | Cursor | Aider      | Claude Code | **forge**             |
| ---------------------- | --------- | ------ | ---------- | ----------- | --------------------- |
| **Philosophy**         | Assistant | Editor | CLI Helper | Agent       | **Director**          |
| **Multi-project**      | ❌        | ❌     | ❌         | ❌          | **✅**                |
| **Phase workflow**     | ❌        | ❌     | ❌         | Partial     | **✅ 5 phases**       |
| **Approval gates**     | ❌        | ❌     | Partial    | Partial     | **✅ Every phase**    |
| **Sandbox**            | ❌        | ❌     | ❌         | ❌          | **✅ Built-in**       |
| **Dependency control** | ❌        | ❌     | ❌         | ❌          | **✅ Human-only**     |
| **Evolution**          | ❌        | ❌     | ❌         | ❌          | **✅ Darwin Gödel**   |
| **Parallel projects**  | ❌        | ❌     | ❌         | ❌          | **✅ Multi-branch**   |

## Next Steps

1. **Understand Principles**: Read [Core Principles](core-principles.md)
2. **Learn Workflow**: Study [Workflow Guide](workflow.md)
3. **Explore Architecture**: Review [Architecture](architecture.md)
4. **Multi-Project**: See [Multi-Project Orchestration](multi-project-orchestration.md)

**You're not a coder anymore. You're a director. Let's build.** 🎬
