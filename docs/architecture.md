# Technical Architecture

## Overview

forge is a **phase-enforced AI coding agent** that orchestrates development workflows
through mandatory sequential phases. Built in Rust for performance and safety, it wraps
battle-tested libraries with custom phase enforcement logic and cross-project learning.

**Philosophy**: 70% library reuse + 30% unique orchestration = faster time to value

## System Architecture

### High-Level Flow

```
User runs: forge build
    ↓
┌─────────────────────────────────────────────────────┐
│  forge (bash wrapper)                               │
│  - bwrap sandbox (namespaces, seccomp)              │
│  - Environment isolation                            │
│  - Security hardening                               │
│  - Launches forge binary in isolated env            │
└──────────────┬──────────────────────────────────────┘
               │
┌──────────────▼──────────────────────────────────────┐
│  forge-bin (Rust orchestrator)                      │
│  - Phase state machine (enforced sequence)          │
│  - Session management                               │
│  - Gate documentation & blocker tracking            │
│  - TUI (phase-specific views)                       │
│  - Artifact generation/parsing                      │
│  - Evolution learning (SQLite)                      │
│  - Coordinates agents & tools                       │
└──┬───────────┬──────────┬──────────┬────────────┬───┘
   │           │          │          │            │
┌──▼───┐    ┌──▼───┐   ┌──▼───┐   ┌──▼───┐      ┌──▼──────┐
│ Rig  │    │ LSP  │   │ MCP  │   │ Web  │      │Evolution│
│Agent │    │Client│   │Client│   │Search│      │ SQLite  │
└──────┘    └──────┘   └──────┘   └──────┘      └─────────┘
```

## Core Components

### 1. forge (Bash Wrapper)

**Purpose**: Security and isolation layer

**Responsibilities**:

- Sandbox setup via bwrap (bubblewrap) + Landlock
- Filesystem isolation (project directory only)
- Network restrictions (optional, per phase)
- Seccomp filters (syscall whitelisting)
- Resource limits (CPU, memory, disk)
- Launch forge binary in sandboxed environment

**Why bash**: System-level isolation requires shell scripting, bwrap integration native
to Linux

**Security model**:

- No home directory access
- No system file modifications
- Read-only /usr, /lib, /etc
- Writable project workspace only
- Optional network (enabled for Discovery/research, disabled for Build)

### 2. forge-bin (Rust Orchestrator)

**Purpose**: Phase enforcement and workflow coordination

**Responsibilities**:

- **Phase state machine**: Enforce Discovery → (Inventory) → Plan → Build → Presentation
  → Suggestions
- **Continuous Evolution**: Darwin Gödel Machine background system integration
- **Session management**: Persist state, handle interruptions, resume capability
- **Gate Management**: Track decision points, blockers, and pause reasons in persistent documentation
- **Human checkpoints**: Block phase transitions until approval
- **Artifact orchestration**: Generate/parse project_overview.md, tasks.yaml, etc.
- **TUI coordination**: Render phase-specific views, handle input
- **Agent lifecycle**: Initialize agents per phase, coordinate with tools

**Why Rust**: Memory safety, async runtime (tokio), zero-cost abstractions, strong type
system

**Key workflows**:

- Discovery: Product Agent asks questions → generate project_overview.md → human
  approval
- Plan: Architect Agent designs system → generate plan.md + tasks.yaml → human approval
- Build: Dev/QA Agents execute tasks → checkpoints every N tasks → human validation
- Presentation: Generate retrospective.md with metrics
- Suggestions: Generate commit_message.txt, next_steps.md

### 3. Rig (Agent Framework)

**Purpose**: LLM abstraction and agent execution

**Library**: [rig.rs](https://rig.rs) - Production-ready Rust LLM framework

**Responsibilities**:

- Multi-provider LLM support (OpenAI, Anthropic, Ollama, etc.)
- Tool execution framework (register custom tools)
- Prompt management and templating
- RAG (Retrieval-Augmented Generation) for codebase context
- Streaming responses (for TUI live updates)

**Integration with forge**:

- Product Agent (Discovery): Built on Rig, uses web search tool
- Architect Agent (Plan): Built on Rig, uses LSP + MCP for code analysis
- Dev Agent (Build): Built on Rig, uses LSP + file operations
- QA Agent (Build): Built on Rig, executes tests via sandbox

**Why Rig**: Battle-tested, modular, supports our multi-provider requirement, active
community

### 4. LSP Client

**Purpose**: Language server integration for code intelligence

**Library**: `tower-lsp` or `lsp-types` (Rust LSP ecosystem)

**Responsibilities**:

- Connect to language servers (rust-analyzer, gopls, typescript-language-server, etc.)
- Provide diagnostics (errors, warnings)
- Hover information (function signatures, docs)
- Go-to-definition, find-references
- Code actions (quick fixes, refactors)

**Integration with forge**:

- Inventory phase: Analyze code structure, detect patterns
- Plan phase: Understand existing architecture
- Build phase: Provide context to agents (what functions exist, type signatures)

**Configuration**: forge.yaml specifies LSPs per language (like OpenCode)

```yaml
lsp:
  rust:
    command: rust-analyzer
  go:
    command: gopls
  typescript:
    command: typescript-language-server
    args: ["--stdio"]
```

### 5. MCP Client

**Purpose**: Model Context Protocol server integration

**Status**: Custom implementation (no mature Rust MCP client exists)

**Responsibilities**:

- **stdio transport**: Spawn MCP servers as child processes (e.g., context7)
- **http transport**: Connect to HTTP MCP endpoints
- **sse transport**: Subscribe to Server-Sent Events streams
- Expose MCP tools to Rig agents
- Handle tool calls with proper serialization

**Integration with forge**:

- Discovery phase: Access external context (GitHub repos, docs)
- Plan phase: Query codebase metadata (via context7 or similar)
- Build phase: File operations, git info (via MCP filesystem servers)

**Configuration**: forge.yaml specifies MCP servers (like OpenCode/Crush)

```yaml
mcp:
  context7:
    type: stdio
    command: context7
    args: ["--mode", "server"]
    timeout: 120
  github:
    type: http
    url: "https://api.githubcopilot.com/mcp/"
    headers:
      Authorization: "Bearer $GITHUB_TOKEN"
```

**Why custom**: No mature Rust MCP library exists; we implement minimal transports

### 6. Web Search

**Purpose**: Internet search capability for agents

**Library**: `websearch` crate - Multi-provider Rust web search

**Responsibilities**:

- Search across providers (Google, DuckDuckGo, Tavily, Brave, etc.)
- Aggregation strategies (combine results, failover, race)
- Rate limiting and caching
- Result parsing and ranking

**Integration with forge**:

- Discovery phase: Research technologies, libraries, best practices
- Plan phase: Find architectural patterns, similar projects
- Build phase: Stack Overflow search for error messages

**Providers supported**:

- Google Custom Search
- DuckDuckGo (no API key required)
- Tavily (AI-optimized search)
- Brave Search
- ArXiv (academic papers)

### 7. TUI (Terminal User Interface)

**Purpose**: Interactive interface for human-agent collaboration

**Library**: `ratatui` - Rust terminal UI framework

**Responsibilities**:

- **Phase-specific views**: Different layouts per phase
- **Conversation panel**: Agent questions, human responses
- **Artifact viewer**: Real-time preview of generated files
- **Progress tracking**: Task completion, phase status
- **Keyboard shortcuts**: Vim-style navigation
- **Multi-session dashboard**: Overview of parallel projects

**Key views**:

- **Discovery view**: Q&A interface, research panel
- **Plan view**: Architecture diagram, task list
- **Build view**: Code diff, test output, task progress
- **Presentation view**: Metrics charts, retrospective
- **Dashboard view**: Multi-project overview (orchestration)

**Why Ratatui**: Mature, performant, event-driven, cross-platform

### 8. Evolution System (Darwin Gödel Machine)

**Purpose**: Cross-project learning and pattern detection

**Storage**: SQLite database (`~/.local/share/forge/evolution.db`)

**Responsibilities**:

- Record project metrics (duration, LOC, coverage, revision rate)
- Detect methodology effectiveness (TDD vs inventory vs traditional)
- Identify common challenges (recurring issues)
- Track human preferences (approval patterns, validation commands)
- Surface success patterns (what leads to quality outcomes)

**Data collected**:

- Project metadata (name anonymized via hash, duration, phase timings)
- Task data (methodology, duration, revision count)
- Metrics (test coverage, LOC changes)
- Patterns (challenges faced, solutions applied)
- Preferences (human feedback patterns, custom validations)

**Integration with forge**:

- Discovery phase: Suggest questions based on past gaps
- Plan phase: Recommend optimal task sizes, methodologies
- Build phase: Apply learned preferences (error handling style, etc.)
- Presentation phase: Compare to baseline metrics

**Privacy**: Local-only by default, no external transmission

### 8. Task Management (dstask Integration)

**Purpose**: Git-powered task tracking and synchronization

**Backend**: Exclusive integration with [dstask](https://github.com/naggie/dstask)

**Responsibilities**:
- Store development tasks as versioned YAML files in `~/.dstask`
- Provide bidirectional synchronization via Git
- Map forge sessions to dstask projects
- Persist validation rules and methodologies in task notes

**Why dstask**: Terminal-native, Git-powered, zero-lock-in, and perfectly aligns with the forge "Code Director" model.

## Component Interactions

### Discovery Phase Flow

```
Human: "Add OAuth authentication"
    ↓
forge → Rig (Product Agent)
    ↓
Rig → Web Search (research OAuth patterns)
    ↓
Rig → MCP (query similar code via context7)
    ↓
Product Agent → TUI (display clarifying questions)
    ↓
Human → TUI (answer questions)
    ↓
forge → Artifact Storage (project_overview.md)
    ↓
TUI → Human (approval checkpoint)
    ↓
Human approves → forge transitions to Plan phase
```

### Plan Phase Flow

```
forge loads project_overview.md
    ↓
forge → Rig (Architect Agent)
    ↓
Rig → LSP Client (analyze existing auth code structure)
    ↓
Rig → MCP (query codebase patterns)
    ↓
Rig → Evolution DB (query methodology effectiveness for auth)
    ↓
Architect Agent generates plan.md + tasks.yaml
    ↓
TUI displays architecture + task breakdown
    ↓
Human → TUI (approval checkpoint)
    ↓
Human approves → forge transitions to Build phase
```

### Build Phase Flow (TDD Task)

```
forge loads tasks.yaml
    ↓
Task T1: "Write failing tests for OAuth trait"
    ↓
forge → Rig (Dev Agent)
    ↓
Rig → LSP Client (get type signatures, existing patterns)
    ↓
Dev Agent generates tests
    ↓
forge → forge sandbox (run tests, verify FAIL)
    ↓
Task T2: "Implement OAuth trait"
    ↓
Dev Agent generates implementation
    ↓
forge → forge sandbox (run tests, verify PASS)
    ↓
forge → Rig (QA Agent)
    ↓
QA Agent validates (coverage, lint, methodology compliance)
    ↓
TUI → Human (checkpoint, show diff)
    ↓
Human approves → forge continues to next task
```

## Technology Stack

### Languages & Runtimes

| Component | Language       | Runtime     | Rationale                         |
| --------- | -------------- | ----------- | --------------------------------- |
| forge     | Bash           | Shell       | System-level isolation (bwrap)    |
| forge-bin | Rust           | Tokio async | Performance, safety, async agents |
| Agents    | Rust (via Rig) | LLM APIs    | Type-safe, composable             |

### Key Dependencies

| Library   | Purpose                          | Version | License        |
| --------- | -------------------------------- | ------- | -------------- |
| rig       | Agent framework, LLM abstraction | latest  | MIT            |
| ratatui   | TUI framework                    | 0.28+   | MIT            |
| websearch | Web search multi-provider        | latest  | MIT            |
| tower-lsp | LSP client                       | latest  | MIT            |
| sqlx      | SQLite async driver              | 0.8+    | MIT/Apache-2.0 |
| tokio     | Async runtime                    | 1.x     | MIT            |
| serde     | Serialization (YAML, JSON)       | 1.x     | MIT/Apache-2.0 |

### External Tools

| Tool        | Purpose           | Integration       |
| ----------- | ----------------- | ----------------- |
| bwrap       | Sandbox isolation | Called by forge   |
| LSP servers | Code intelligence | Launched by forge |
| MCP servers | Context providers | Spawned by forge  |
| Git         | Version control   | Read-only access  |

### OpenCode Integration (Development Strategy)

| Component | Purpose                    | Integration Strategy      |
| --------- | -------------------------- | ------------------------- |
| OpenCode  | Initial builder capability | Phase 2: Wrapper approach |

**Strategy**: See [OpenCode Integration Strategy](./opencode-strategy.md) for details.

During Phase 2 development, OpenCode will be wrapped as:

```
┌──────────────────────────────────────────────────────┐
│           forge Orchestrator (Rust)                  │
│  - Multi-project management                          │
│  - Phase workflow (5 phases + optional inventory)    │
│  - Human approval gates                              │
│  - Security sandbox (Bubblewrap + Landlock)          │
│  - Evolution engine (Darwin Gödel Machine)           │
│  - TUI interface (ratatui)                           │
└──────────────────┬───────────────────────────────────┘
                   │
                   ▼ (subprocess coordination)
┌──────────────────────────────────────────────────────┐
│         Dev Agent (Rust, via Rig framework)          │
│  - Reads tasks.yaml                                  │
│  - Enforces methodology (TDD, etc.)                  │
│  - Manages checkpoints                               │
└──────────────────┬───────────────────────────────────┘
                   │
                   ▼ (wraps as managed subprocess)
┌──────────────────────────────────────────────────────┐
│        OpenCode (Builder Capability - Phase 2)       │
│  - Code generation subprocess                        │
│  - Sandboxed execution                               │
│  - Input: context, task, requirements                │
│  - Output: generated code, test results              │
└──────────────────────────────────────────────────────┘
```

Over time, OpenCode features will be implemented natively in Rust, allowing OpenCode to
become optional or serve as permanent inspiration.

## Data Storage

### Artifacts (Project-Specific)

Location: `./docs/plans/{session}/` (persistent) and `./.forge/` (ephemeral)

Files:

- `session.json` - Current phase, state (ephemeral)
- `discovery.md` - Discovery output (persistent)
- `inventory.yaml` - Code analysis (if run) (persistent)
- `plan.md` - Architecture narrative (persistent)
- `tasks.md` - Task breakdown (Markdown + YAML) (persistent)
- `gates/` - Gate documentation and blocker tracking (persistent)
- `build_log.md` - Task execution log (ephemeral)
- `retrospective.md` - Metrics and insights (persistent)
- `commit_message.txt` - Suggested commit (persistent)
- `logs/forge.log` - Debug logs (ephemeral)

### Evolution Database (Global)

Location: `~/.local/share/forge/evolution.db` (SQLite)

Tables:

- `projects` - Project metadata (ID, duration, status)
- `tasks` - Task data (methodology, duration, revisions)
- `metrics` - Quantitative metrics (coverage, LOC)
- `patterns` - Detected patterns (challenges, solutions)
- `preferences` - Human behavior patterns

### Configuration

**Global**: `~/.config/forge/forge.yaml` **Project**: `./.forge.yaml` (optional,
overrides global)

Configuration includes:

- LLM provider settings
- LSP server definitions
- MCP server configurations
- Tool permissions
- UI preferences

### gaeta projection sample

For a concrete `~/.config/opencode/opencode.json` + `~/.config/gaeta/opencode.json`
example and the expected `.gaeta/projection/opencode.json` output, see
`docs/config-sample.md`.

### Projection safety matrix (gaeta policy)

gaeta policy is `mirror-only` for projection artifacts. Direct symlink projection is
intentionally disabled to keep behavior deterministic and sandbox-safe.

| Artifact | Mode | Why | Risk / fallback |
| -------- | ---- | --- | --------------- |
| `opencode.json` | mirror-only | deterministic merged file; stable bind target under `.gaeta/projection/` | if merge fails, doctor should fail and surface the projection error; no symlink fallback |
| `tui.json` | mirror-only | same projection semantics as `opencode.json`; prevents host-path drift | if source missing, projection omits file and OpenCode uses defaults |
| `agents/` | mirror-only | merged directory view with gaeta precedence; avoids host symlink exposure | if projection fails, launch should stop before sandbox execution |
| `commands/` | mirror-only | stable slash-command surface and deterministic role bindings | if projection fails, doctor/launch should fail with explicit path checks |
| `modes/` | mirror-only | predictable mode visibility with no host-home assumptions | if neither source exists, directory can remain absent (mode=none) |
| `plugins/` | mirror-only | same isolation and precedence guarantees as modes | if neither source exists, directory can remain absent (mode=none) |
| `.gaeta/projection/projection.json` | mirror-only | explicit runtime manifest for debugging and doctor validation | on mismatch, regenerate projection and fail doctor until consistent |
| `.gaeta/projection/*` bind targets | mirror-only | concrete repo-local bind paths are reproducible across sessions | if files are stale, refresh projection before launch; never bind symlinks |

### Linux/macOS portability notes

gaeta targets Linux-first sandbox behavior and degrades safely when Linux-only
primitives are unavailable.

| Capability | Linux | macOS | Operator guidance |
| ---------- | ----- | ----- | ----------------- |
| Wrapper launch (`gaeta`) | supported | supported | core wrapper and workflow commands are expected to run on both platforms |
| Bubblewrap isolation (`bwrap`) | supported | not supported | macOS runs without bubblewrap parity; treat host execution as reduced isolation |
| Landlock via `landrun` | optional defense-in-depth | not available | Landlock checks are Linux-specific and should be treated as unavailable on macOS |
| Projection/mirror artifacts (`.gaeta/projection/*`) | supported | supported | mirror-only projection policy is cross-platform and remains deterministic |
| `gaeta doctor` sandbox runtime check | partial in constrained namespaces (`bwrap` ENOSPC possible) | limited by missing `bwrap`/Landlock | use `GAETA_DOCTOR_SKIP_SANDBOX=1` when environment cannot run nested sandbox checks |

Recommended verification commands:

- Linux: `make lint && make test`, `./gaeta status .`, `./gaeta doctor --verbose .`
- macOS: `make lint && make test`, `./gaeta status .`, `GAETA_DOCTOR_SKIP_SANDBOX=1 ./gaeta doctor --verbose .`

Known constraints:

- Namespace-constrained Linux environments may fail nested `bwrap` checks with `ENOSPC`.
- macOS does not provide Linux namespace/Landlock primitives; sandbox validation is
  intentionally partial there.

## Security Model

### Isolation Layers

**Layer 1: forge (bwrap sandbox)**

- Filesystem isolation (project directory only)
- Network control (per-phase basis)
- Syscall filtering (seccomp)
- Resource limits (cgroups)

**Layer 2: forge-bin (Rust memory safety)**

- No unsafe code in orchestrator
- Type-safe LLM interactions
- Validated artifact parsing

**Layer 3: Tool permissions**

- Agents declare required tools
- Human approval for dangerous operations
- Read-only mode available (plan agent)

### Threat Model

The detailed gaeta threat model now lives in `docs/threat-model.md`.

At a high level, gaeta is designed to reduce risk through:

- Linux-first sandbox isolation and optional defense-in-depth controls.
- Mirror-only projection for deterministic repo-local runtime artifacts.
- Explicit per-agent command policies with human-in-the-loop approval for risky
  operations.

Known limitations and accepted risks are documented in
`docs/threat-model.md` and should be treated as the source of truth.

### Privacy

**Data never leaves machine**:

- Code context (sent to LLM, but chosen provider)
- Evolution metrics (stored locally in SQLite)
- Session state (local filesystem only)

**Optional cloud sync**:

- Encrypted end-to-end
- Opt-in only
- For multi-machine workflows

## Performance Characteristics

### Latency

**Phase transitions**: <100ms (state machine + artifact I/O) **LLM calls**: 1-5 seconds
(depends on provider, model) **LSP queries**: 50-200ms (depends on language server)
**MCP tool calls**: 100-500ms (depends on server) **TUI rendering**: 16ms target (60
FPS)

### Concurrency

**Async agents**: Multiple Rig agents can run in parallel (Build phase: Dev + QA) **Tool
calls**: Parallelized when independent (web search + LSP) **Session isolation**:
Multiple forge instances on different projects (no shared state)

### Resource Usage

**Memory**: 500MB-1GB (LLM context, TUI buffers) **CPU**: 1-2 cores active (async
runtime, occasional spikes for LLM) **Disk**: Minimal (artifacts are text files,
evolution DB <10MB) **Network**: Bursty (LLM API calls, web search)

## Design Decisions

### Phase Enforcement is Mandatory

**Decision**: Phases progress sequentially, no skipping

**Rationale**:

- Prevents "skip to coding" anti-pattern
- Ensures artifacts exist for downstream phases
- Enforces quality checkpoints

**Trade-off**: Less flexible, but more reliable outcomes

### Agents Communicate via Artifacts

**Decision**: Structured files, not in-memory messages

**Rationale**:

- Human-readable (inspect/edit artifacts)
- Auditable (full paper trail)
- Resumable (session state on disk)

**Trade-off**: More I/O, but worth transparency

### Git is Read-Only for Agents

**Decision**: Agents never execute git commands

**Rationale**:

- Human maintains control (decides when to commit)
- No accidental pushes or branch changes
- Clean git history

**Trade-off**: Manual git operations required

### Local-First, Cloud Optional

**Decision**: Everything runs locally by default

**Rationale**:

- Privacy (code never leaves machine, except to chosen LLM)
- No network dependency (works offline with local LLMs)
- Fast (no API latency for local operations)

**Trade-off**: Need local LLM or API keys

### Library Reuse Over Custom Implementation

**Decision**: Use Rig, websearch, tower-lsp instead of building from scratch

**Rationale**:

- Faster time to value (70% reuse)
- Battle-tested code (production reliability)
- Community support (bug fixes, features)

**Trade-off**: Dependency on external crates, but worth speed

## Extensibility

### Adding New Phases

Implement phase trait, register in state machine:

- Define phase logic (what agents to run)
- Specify input artifacts (from previous phase)
- Define output artifacts (for next phase)
- Add TUI view for phase

### Adding New Agents

Build on Rig framework:

- Define agent prompt templates
- Register tools (web search, LSP, MCP)
- Specify phase assignment
- Add to orchestrator

### Adding New Tools

Implement Rig Tool trait:

- Define tool interface (name, description, parameters)
- Implement execution logic
- Register with agents that need it

### Adding New LLM Providers

Rig already supports 75+ providers via adapters:

- OpenAI, Anthropic, Google, Cohere, etc.
- Local models via Ollama
- Configure in forge.yaml

### Adding New MCP Servers

Define in forge.yaml:

- Specify transport (stdio, http, sse)
- Provide command/URL
- Optional: disable specific tools
- forge spawns/connects automatically

## Deployment

### Distribution

**Binary**: Single Rust executable (`forge-bin`) **Wrapper**: Bash script (`forge`)

**Package managers**:

- Homebrew (macOS/Linux): `brew install forge-code-director`
- Cargo (Rust): `cargo install forge-code-director`
- AUR (Arch Linux): `yay -S forge-code-director`

**Install script**:

```bash
curl -fsSL https://forge.dev/install | bash
# Installs forge + forge-bin to ~/.local/bin or /usr/local/bin
```
