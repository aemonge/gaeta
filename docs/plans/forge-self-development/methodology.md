# Methodology - forge Self-Development

## Language & Frameworks

- **Rust**: Chosen for performance, memory safety, and strong type system. Essential for building a robust orchestrator and security sandbox.
- **Rig**: Agent framework for LLM abstraction and tool integration.
- **Ratatui**: TUI framework for building the interactive dashboard.
- **Bubblewrap + Landlock**: Linux-native security technologies for isolation.

## Security Philosophy

- **Mandatory Sandboxing**: forge-bin is strictly prohibited from running outside the mandated security sandbox. This ensures all operations are isolated and reproducible.
- **Defense-in-Depth**: We use a two-layer security model:
    1. **Landlock (Syscall Level)**: Mandatory protection via `landrun` to restrict syscalls.
    2. **Bubblewrap (Namespace Level)**: Isolation of filesystem, users, and IPC.
- **Sandbox Awareness**: The core binary verifies its environment on startup and refuses to execute if security markers (environment variables and isolated filesystem paths) are missing.

## Implementation Approach

### Hardcode → Iterate → Polish
We avoid premature abstraction. The first version will use hardcoded questions and templates. We will then iterate to use LLM generation and more flexible configurations.

### OpenCode Wrapper Strategy
We leverage OpenCode's mature builder capabilities initially. This allows us to focus on the unique value of forge: **orchestration, phase enforcement, and security**.

### Comparative Testing
Every feature built by forge will be compared against what OpenCode would produce alone. forge + Orchestration should consistently produce more organized, better-tested, and more maintainable code than raw generation.

## Task Format Decision

We chose **Markdown + YAML frontmatter** for `tasks.md`:
1. **Readable**: Humans can read it without special tools.
2. **Standard**: Markdown renders perfectly on Codeberg/GitHub.
3. **Parsable**: The YAML frontmatter allows forge to track machine-readable state.
4. **TUI-friendly**: Libraries like `termimad` make rendering markdown in terminal easy.

## Directory Structure Decision

We chose a **Hybrid structure**:
- **`docs/plans/{session}/`**: For persistent artifacts. These are committed to git as they represent the project's institutional knowledge.
- **`.forge/`**: For ephemeral runtime state and logs. This is git-ignored to keep the repository clean.
- **`.forge/opencode/`**: Dedicated local storage for OpenCode (config, state, share). This ensures session databases and AI agent history are contained within the project, enabling portable and isolated development context.
