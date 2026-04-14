# Multi-Project Orchestration

## Overview

**forge** enables you to work on multiple projects (or features) simultaneously, each
progressing through phases independently. This is the core of the **code director**
model: orchestrating parallel work instead of sequential implementation.

## The Director Model

### Traditional Development (Sequential)

```
Developer working on 3 features:

Feature A: Discovery → Plan → Build → Done (Day 1-2)
  ↓ (blocked, waiting)
Feature B: Discovery → Plan → Build → Done (Day 3-4)
  ↓ (blocked, waiting)
Feature C: Discovery → Plan → Build → Done (Day 5-6)

Total time: 6 days
Developer utilization: 100% (but sequential)
Context switches: Minimal (finish one, start next)
Bottlenecks: Human is the bottleneck for implementation
```

### forge Model (Parallel)

```
Code Director orchestrating 3 features:

09:00 Feature A: Discovery
09:30 Feature B: Discovery (A in Plan)
10:00 Feature A: Plan approved, Build starts
10:15 Feature C: Discovery (A building, B planning)
10:30 Feature B: Plan approved, Build starts
11:00 Feature C: Plan approved, Build starts

Result: A, B, C all building in parallel

Director time: ~2 hours (Discovery + Plan for 3 features)
Agent time: Rest of day (building 3 features in parallel)
Total time: 1 day (vs 6 days sequential)
Context switches: At phase boundaries (natural, high-level)
```

## Core Concepts

### Project vs Feature

**Project**: An independent unit of work with its own:

- Git branch (e.g., `feature/oauth`, `feature/api-refactor`)
- Phase state (Discovery, Plan, Build, Presentation, Suggestions)
- Agents (dedicated to this project)
- Session (artifacts, logs, conversation history)

**Feature**: Within a project, a logical piece of functionality.

- Multiple features within one project execute sequentially
- But multiple projects execute in parallel

**Key insight**: Parallelism is at the **project level**, not feature level within a
project.

### Why Project-Level Parallelism

**Clean boundaries**:

- Each project = one branch
- No merge conflicts between parallel projects
- Independent git histories

**Cognitive simplicity**:

- Each project is conceptually independent
- Switching between projects = switching contexts (not switching between code lines)
- Director-level decisions, not implementation details

**Realistic workflow**:

- Real developers work on multiple features/branches
- forge formalizes this into orchestrated workflow

## Architecture

### Multi-Project Structure

```
┌─────────────────────────────────────────────────────┐
│              forge Orchestrator (You)               │
│              Code Director Dashboard                │
└────┬──────────────┬──────────────┬──────────────────┘
     │              │              │
┌────▼──────┐  ┌────▼──────┐  ┌────▼──────┐
│Project A  │  │Project B  │  │Project C  │
│feature/   │  │feature/   │  │hotfix/    │
│oauth      │  │api-refac  │  │bug-123    │
├───────────┤  ├───────────┤  ├───────────┤
│Phase:     │  │Phase:     │  │Phase:     │
│Build      │  │Plan       │  │Discovery  │
│           │  │           │  │           │
│Agents:    │  │Agents:    │  │Agents:    │
│- Dev      │  │- Architect│  │- Product  │
│- QA       │  │           │  │           │
│           │  │           │  │           │
│Progress:  │  │Progress:  │  │Progress:  │
│Task 5/9   │  │Waiting    │  │Clarifying │
└───────────┘  └───────────┘  └───────────┘

Workspace layout:
/workspace/
  ├─ project-a/  (branch: feature/oauth)
  ├─ project-b/  (branch: feature/api-refactor)
  └─ project-c/  (branch: hotfix/bug-123)

Session storage:
~/.local/share/forge/sessions/
  ├─ project-a/  (state, logs, artifacts)
  ├─ project-b/  (state, logs, artifacts)
  └─ project-c/  (state, logs, artifacts)
```

### TUI Layout (Multi-Project)

```
┌─────────────────────────────────────────────────────────────┐
│ forge - Code Director                                       │
│ [Project A: Build] [Project B: Plan] [Project C: Discovery] │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│ Project A: OAuth Authentication (feature/oauth)             │
│ Phase: Build (Task 5/9)                                     │
│                                                             │
│ Current Task: T5 - Refactor OAuth core                      │
│ Dev Agent: Extracting common logic...                       │
│ QA Agent: Standing by for validation                        │
│                                                             │
│ Recent activity:                                            │
│  ✓ T4 Complete: Google OAuth provider                       │
│  ✓ Human approved (commit: d5f1a3b)                         │
│  → T5 In progress...                                        │
│                                                             │
│ [Switch to Project B: gt]  [Checkpoint: Ctrl+C]             │
└─────────────────────────────────────────────────────────────┘

# Press 'gt' (Vim-style tab navigation)

┌─────────────────────────────────────────────────────────────┐
│ forge - Code Director                                       │
│ [Project A: Build] [Project B: Plan] [Project C: Discovery] │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│ Project B: API Refactor (feature/api-refactor)              │
│ Phase: Plan (Waiting for approval)                          │
│                                                             │
│ Architect Agent has completed planning:                     │
│  - plan.md (12 tasks)                                       │
│  - methodology: Inventory-Driven (existing code)            │
│  - No new dependencies required                             │
│                                                             │
│ Review plan? [y/n]                                          │
│                                                             │
│ [Switch to Project C: gt]  [Switch to A: gT]                │
└─────────────────────────────────────────────────────────────┘
```

## Workflow Examples

### Example 1: Three Features in One Day

**Scenario**: You need to ship OAuth, refactor API, and fix a critical bug.

**Traditional approach**: 3 days (one feature per day, sequential).

**forge approach**: 1 day (parallel orchestration).

```
Timeline (one day):

09:00 - Start Project A: OAuth
  You: "Add OAuth authentication for Google and GitHub"
  Product Agent: Asks questions, generates project_overview.md
  Duration: 30 minutes

09:30 - Approve Project A Discovery
  You review and approve
  Architect Agent begins Plan phase for A

  Meanwhile, start Project B: API Refactor
  You: "Refactor /api/users endpoints to use repository pattern"
  Product Agent: Asks questions
  Duration: 20 minutes

09:50 - Approve Project B Discovery
  Architect Agent begins Plan phase for B

  Meanwhile, start Project C: Critical Bug
  You: "Fix authentication timeout issue (#123)"
  Product Agent: Quick discovery (bug is well-defined)
  Duration: 10 minutes

10:00 - Approve Project C Discovery
  Architect Agent begins Plan phase for C

  Check Project A: Plan ready
  You review Project A plan
  Approve, install dependencies: cargo add oauth2
  Commit: "chore: add oauth2 dependency"
  Project A Build phase begins (3 agents working)

10:30 - Check Project B: Plan ready
  You review Project B plan
  Approve, enable inventory-driven mode
  No new dependencies
  Project B Build phase begins (2 agents working)

11:00 - Check Project C: Plan ready
  You review Project C plan
  Approve, no dependencies
  Project C Build phase begins (2 agents working)

11:00-15:00 - Lunch + All 3 projects building in parallel
  You take a break
  forge continues working (agents building)

15:00 - Check Project C: Build complete (simple bug fix)
  Review checkpoint
  Approve
  Commit: "fix(auth): resolve timeout issue in token refresh"
  Project C → Presentation phase

15:15 - Review Project C Presentation
  Metrics look good
  Approve → Suggestions phase

15:20 - Review Project C Suggestions
  Commit message looks good
  You manually push:
    git push origin hotfix/bug-123
  Create PR, tag for immediate review

  Project C DONE in 6 hours (including 3.5 hours parallel build)

15:30 - Check Project A: Build checkpoint
  Review OAuth core tasks (T1-T5)
  Approve, all look good
  You manually commit all 5 tasks (or batch commit)
  Continue to remaining tasks

16:00 - Check Project B: Build checkpoint
  Review API refactor progress
  Found issue: One pattern not followed
  Reject with feedback: "Use builder pattern for UserRepository"
  Dev Agent revises

16:30 - Check Project A: Build complete
  All 9 tasks done
  Review final checkpoint
  Approve
  Project A → Presentation phase

16:45 - Check Project B: Revision complete
  Dev Agent applied feedback
  Approve
  Continue build

17:00 - Review Project A Presentation
  Metrics: 4.5 hours, 847 lines, 94% coverage
  Approve → Suggestions phase

17:10 - Review Project A Suggestions
  Commit message approved
  You manually push:
    git push origin feature/oauth
  Create PR

  Project A DONE in 7.5 hours

17:15 - Check Project B: Build complete
  All tasks done
  Approve
  Project B → Presentation phase

17:30 - Review Project B Presentation & Suggestions
  Approve
  You manually push:
    git push origin feature/api-refactor
  Create PR

  Project B DONE in 7.5 hours

End of day:
  3 projects complete
  3 PRs created
  All in one day (vs 3 days sequential)
```

### TUI Layout (Multi-Project)

```
┌─────────────────────────────────────────────────────────────┐
│ forge - Code Director                                       │
│ [Project A: Build] [Project B: Plan] [Project C: Discovery] │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│ Project A: OAuth Authentication (feature/oauth)             │
│ Phase: Build (Task 5/9)                                     │
│                                                             │
│ Current Task: T5 - Refactor OAuth core                      │
│ Dev Agent: Extracting common logic...                       │
│ QA Agent: Standing by for validation                        │
│                                                             │
│ Recent activity:                                            │
│  ✓ T4 Complete: Google OAuth provider                       │
│  ✓ Human approved (commit: d5f1a3b)                         │
│  → T5 In progress...                                        │
│                                                             │
│ [Switch to Project B: gt]  [Checkpoint: Ctrl+C]             │
└─────────────────────────────────────────────────────────────┘

# Press 'gt' (Vim-style tab navigation)

┌─────────────────────────────────────────────────────────────┐
│ forge - Code Director                                       │
│ [Project A: Build] [Project B: Plan] [Project C: Discovery] │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│ Project B: API Refactor (feature/api-refactor)              │
│ Phase: Plan (Waiting for approval)                          │
│                                                             │
│ Architect Agent has completed planning:                     │
│  - plan.md (12 tasks)                                       │
│  - methodology: Inventory-Driven (existing code)            │
│  - No new dependencies required                             │
│                                                             │
│ Review plan? [y/n]                                          │
│                                                             │
│ [Switch to Project C: gt]  [Switch to A: gT]                │
└─────────────────────────────────────────────────────────────┘
```

### Example 2: Continuous Flow

**Scenario**: You work on features continuously, starting new ones as old ones complete.

```
Day 1: 09:00 - Start Project A (feature X) 10:00 - Project A building, start Project B
(feature Y) 11:00 - Project B building, start Project C (feature Z) 12:00 - Projects A,
B, C all building (lunch break) 15:00 - Project A done, start Project D (feature W)
17:00 - Project B done, start Project E (feature V)

End of Day 1: 2 projects done, 3 in progress

Day 2: 09:00 - Project C done, start Project F 11:00 - Project D done, start Project G
15:00 - Project E done 17:00 - Project F done

End of Day 2: 4 more projects done, 1 in progress

Result: 6 projects in 2 days (vs 6+ days sequential)
```

## Commands

### Start a New Project

```bash
# Start new project
$ forge new project-a --branch feature/oauth

forge creates:
  - New workspace: /workspace/project-a/
  - Git branch: feature/oauth
  - Session: ~/.local/share/forge/sessions/project-a/
  - TUI tab: Project A

forge starts Discovery phase:
  "Describe what you want to build:"
```

### List Active Projects

```bash
$ forge list

Active projects:
  1. project-a (feature/oauth)        - Phase: Build (Task 5/9)
  2. project-b (feature/api-refactor) - Phase: Plan (Waiting approval)
  3. project-c (hotfix/bug-123)       - Phase: Discovery

$ forge list --all

All projects (including completed):
  1. project-a (feature/oauth)        - Phase: Build (Task 5/9)
  2. project-b (feature/api-refactor) - Phase: Plan (Waiting approval)
  3. project-c (hotfix/bug-123)       - Phase: Discovery
  4. project-d (feature/caching)      - Phase: Suggestions (Complete)
  5. project-e (feature/logging)      - Phase: Suggestions (Complete)
```

### Switch Between Projects

```bash
# In TUI: Use Vim-style tab navigation
gt  - Next project tab
gT  - Previous project tab
3gt - Go to project tab 3

# Or from command line:
$ forge switch project-b

Switched to Project B (feature/api-refactor)
Phase: Plan (Waiting approval)
```

### Resume a Project

```bash
# If you quit forge and want to resume
$ forge resume project-a

Resuming Project A (feature/oauth)...
Phase: Build
Current task: T5 (Refactor OAuth core)
Last activity: 2026-02-02 15:30:00

Continue from where you left off? [y/n]
```

### Project Status

```bash
$ forge status project-a

Project: project-a
Branch: feature/oauth
Phase: Build
Progress: Task 5/9 (56%)

Phase timeline:
  ✓ Discovery: 30 minutes
  ✓ Plan: 45 minutes
  → Build: 2 hours elapsed (estimated 2 more hours)

Recent commits (manual):
  d5f1a3b feat(auth): implement Google OAuth provider
  c2d4e8f test(auth): add Google OAuth provider tests
  b7e9c1a feat(auth): implement OAuth provider trait

Next checkpoint: After Task 5 complete
```

### Close/Archive a Project

```bash
# When project is complete and pushed
$ forge close project-a

Project A complete:
  - Phase: Suggestions (done)
  - Branch: feature/oauth (pushed)
  - Commits: 7 commits
  - Duration: 7.5 hours

Archive session? [y/n] y

Session archived to:
  ~/.local/share/forge/archive/project-a-20260202.tar.gz

Project removed from active list.
```

## TUI Navigation

### Tabs (Projects)

Each project gets its own tab:

```
Tab 1: Project A (feature/oauth)        - Build
Tab 2: Project B (feature/api-refactor) - Plan
Tab 3: Project C (hotfix/bug-123)       - Discovery
```

**Navigation**:

- `gt` - Next tab (like Vim)
- `gT` - Previous tab
- `3gt` - Jump to tab 3
- `:tabnew` - Create new project (opens new project dialog)
- `:tabclose` - Close current project (with confirmation)

### Windows (Within Project)

Each project tab can have multiple windows:

```
┌─────────────────────────────────────────────────────┐
│ Project A: OAuth                           [Build]  │
├──────────────────────┬──────────────────────────────┤
│ Conversation         │ Artifacts                    │
│ (Agent chat)         │ - project_overview.md        │
│                      │ - plan.md                    │
│ Dev Agent:           │ - tasks.yaml                 │
│ Implementing T5...   │ - build_log.md               │
│                      │                              │
│ You: Use builder     │ [Preview: plan.md]           │
│ pattern              │                              │
│                      │ ## Architecture              │
│ Dev Agent: Applying  │ - OAuth trait-based...       │
│ feedback...          │                              │
├──────────────────────┴──────────────────────────────┤
│ Status: Task 5/9 | Next checkpoint: After T5        │
└─────────────────────────────────────────────────────┘
```

**Navigation**:

- `Ctrl+W h/j/k/l` - Move between windows (Vim-style)
- `Ctrl+W s` - Horizontal split
- `Ctrl+W v` - Vertical split
- `Ctrl+W c` - Close window

### Buffers (Artifacts)

Each artifact (file) is a buffer:

```
Buffers for Project A:
  1. conversation      (Agent chat history)
  2. project_overview.md
  3. plan.md
  4. tasks.yaml
  5. build_log.md
  6. src/auth/oauth/mod.rs (code preview)
  7. retrospective.md (when available)
```

**Navigation**:

- `:b project_overview.md` - Switch to buffer
- `:bnext` or `:bn` - Next buffer
- `:bprev` or `:bp` - Previous buffer
- `:ls` - List all buffers

## Session Management

### Session Storage

Each project maintains independent session:

```
~/.local/share/forge/sessions/project-a/
  ├─ state.db (SQLite)
  │  ├─ Current phase
  │  ├─ Task progress
  │  ├─ Agent conversation history
  │  └─ Human decisions (approvals, feedback)
  │
  ├─ artifacts/
  │  ├─ project_overview.md
  │  ├─ plan.md
  │  ├─ tasks.yaml
  │  ├─ build_log.md
  │  ├─ retrospective.md
  │  └─ commit_message.txt
  │
  ├─ workspace/
  │  └─ (symlink to /workspace/project-a/)
  │
  └─ metadata.yaml
     ├─ project_name: project-a
     ├─ branch: feature/oauth
     ├─ created: 2026-02-02T09:00:00Z
     └─ last_active: 2026-02-02T16:45:00Z
```

### Pause and Resume

**Pause** (automatic on quit):

```bash
# You're working on Project A, need to leave
$ forge quit  # or Ctrl+C in TUI

Saving session state...
  ✓ Project A state saved
  ✓ Project B state saved
  ✓ Project C state saved

You can resume later with: forge resume
```

**Resume** (all projects):

```bash
$ forge resume

Found 3 active projects:
  1. project-a (feature/oauth)        - Build (Task 5/9)
  2. project-b (feature/api-refactor) - Plan (Waiting)
  3. project-c (hotfix/bug-123)       - Discovery

Resume all? [y/n] y

Resuming...
  ✓ Project A: Task 5 in progress
  ✓ Project B: Waiting for plan approval
  ✓ Project C: Discovery phase, asking questions

forge TUI launched with 3 tabs.
```

**Resume** (specific project):

```bash
$ forge resume project-a

Resuming Project A only...
Phase: Build
Task: T5 (Refactor OAuth core)

Continue? [y/n]
```

## Resource Management

### Agent Allocation

Each project gets dedicated agents:

```
Project A (Build phase):
  - Dev Agent (implementing tasks)
  - QA Agent (validating)

Project B (Plan phase):
  - Architect Agent (planning)

Project C (Discovery phase):
  - Product Agent (clarifying requirements)

Total: 5 agents active across 3 projects
```

**Limit**: Configurable max agents (default: 10 total).

If you start too many projects:

```
$ forge new project-d

Warning: 10 agents already active (limit reached).

Options:
  1. Wait for a project to complete
  2. Increase limit: forge config set max_agents 15
  3. Pause a project: forge pause project-c

Choose [1/2/3]:
```

### Performance Considerations

**Parallel builds are CPU/memory intensive**:

- Each agent runs in sandbox (isolated process)
- Multiple builds = multiple compilers/test runners

**Recommendations**:

- **2-4 projects**: Comfortable on modern workstation (16GB+ RAM)
- **5-7 projects**: Needs beefy machine (32GB+ RAM)
- **8+ projects**: Specialized setup (64GB+ RAM, high-core CPU)

**Monitor resources**:

```bash
$ forge stats

System resources:
  CPU: 65% (8/12 cores active)
  Memory: 14.2 GB / 32 GB (44%)

Active agents: 7
  - Project A: 2 agents (Dev, QA)
  - Project B: 2 agents (Dev, QA)
  - Project C: 1 agent (Architect)
  - Project D: 2 agents (Dev, QA)

Recommendation: System healthy, can add 1-2 more projects.
```

## Context Switching

### When to Switch

**Natural switching points**:

- Project waiting for approval (Plan, Presentation)
- Project building (agent working, you're idle)
- Checkpoint reached (you just approved, next task starting)
- Break time (pause all, resume later)

**Anti-patterns** (avoid):

- Switching mid-task (let agent finish current task)
- Switching during human input (complete the approval first)
- Rapid switching (< 1 minute per project)

### Cognitive Load

**Director-level switching**:

- Switching between projects = switching architectural contexts
- NOT switching between code lines (that's agent's job)
- Each project is conceptually independent

**Example**:

```
Project A: OAuth authentication (security concern)
  → Your mental model: "This needs to be secure, CSRF protection critical"

Project B: API refactor (architecture concern)
  → Your mental model: "This needs to follow repository pattern"

Project C: Bug fix (debugging concern)
  → Your mental model: "Timeout is likely token expiration logic"

Switching: High-level context changes, not low-level code details
```

### Dashboard View

See all projects at a glance:

```bash
$ forge dashboard

┌───────────────────────────────────────────────────────┐
│              forge Code Director Dashboard            │
└───────────────────────────────────────────────────────┘

Active Projects (3):

┌───────────────────────────────────────────────────────┐
│ Project A: OAuth (feature/oauth)          [Build]     │
│ Progress: ████████████░░░░░ 56% (Task 5/9)            │
│ Status: Dev Agent implementing T5                     │
│ Next: Checkpoint after T5                             │
│ [Switch: 1gt]                                         │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────┐
│ Project B: API Refactor (feature/api-refactor) [Plan] │
│ Progress: ████████████████████ 100% (Plan done)       │
│ Status: ⏸  Waiting for your approval                  │
│ Action: Review plan.md and approve                    │
│ [Switch: 2gt]                                         │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────┐
│ Project C: Bug Fix (hotfix/bug-123)    [Discovery]    │
│ Progress: ██████░░░░░░░░░░░░ 30% (Clarifying)         │
│ Status: Product Agent asking questions                │
│ Next: Answer pending questions                        │
│ [Switch: 3gt]                                         │
└───────────────────────────────────────────────────────┘

Overall stats:
  - Projects active: 3
  - Agents working: 5
  - Commits today: 12 (manual)
  - Estimated completion: 2-3 hours

[Press any key to return to current project]
```

## Best Practices

### Start Small, Scale Up

**Week 1**: 1-2 projects max

- Get comfortable with workflow
- Learn TUI navigation
- Understand phase transitions

**Week 2**: 2-3 projects

- Practice context switching
- Find your checkpoint rhythm
- Optimize commit patterns

**Week 3+**: 3-5 projects

- Full director mode
- Efficient orchestration
- Pattern recognition across projects

### Project Sizing

**Small projects** (2-4 hours):

- Bug fixes
- Simple features
- UI tweaks

**Medium projects** (4-8 hours):

- New feature with moderate complexity
- Refactoring existing module
- Integration with external service

**Large projects** (1-3 days):

- Major feature (e.g., complete authentication system)
- Architectural refactor
- Multiple related features

**Recommendation**: Mix sizes for parallel work.

- 1-2 large (background, long-running)
- 2-3 small (quick wins, interleaved)

### Batching Strategy

**Batch similar phases**:

```
Morning (Discovery focus):
  - Start 3 new projects
  - All in Discovery phase
  - Clarify requirements for all
  - Approve all discoveries in batch

Late morning (Plan focus):
  - All 3 move to Plan
  - Architect agents plan in parallel
  - Review all 3 plans
  - Approve all, install dependencies

Afternoon (Build focus):
  - All 3 building in parallel
  - You take lunch, agents work
  - Periodic checkpoints (every hour)

End of day (Presentation focus):
  - Review retrospectives
  - Approve suggestions
  - Manually push all branches
```

## Comparison to Alternatives

| Aspect                   | Traditional Dev     | GitHub Copilot | Cursor      | **forge Multi-Project**       |
| ------------------------ | ------------------- | -------------- | ----------- | ----------------------------- |
| **Parallel features**    | ❌ Manual switching | ❌ No          | ❌ No       | ✅ **Built-in orchestration** |
| **Context management**   | Manual              | Per-file       | Per-project | ✅ **Per-project + phase**    |
| **Director model**       | ❌ You code         | ❌ You code    | ❌ You code | ✅ **You orchestrate**        |
| **Independent branches** | ✅ Manual           | ❌ No          | Partial     | ✅ **Managed**                |
| **Session persistence**  | ❌ No               | ❌ No          | Basic       | ✅ **Full state**             |

## Summary

**Multi-project orchestration** is what elevates forge from "AI coding assistant" to
"code director platform":

- **Parallel execution**: Multiple projects in different phases simultaneously
- **Director-level switching**: Context switches at architectural boundaries, not code
  level
- **Session management**: Full state preservation, pause/resume anytime
- **TUI navigation**: Vim-style tabs/windows/buffers for efficient control
- **Resource aware**: Monitors system, prevents overload

**Result**: 3-5x productivity gain by orchestrating parallel work instead of sequential
implementation.

**You are the conductor. Each project is an instrument in your orchestra.** 🎼
