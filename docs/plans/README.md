# forge Development Plans

This directory contains forge session artifacts for all development work.

## Current Sessions

- **forge-self-development** - Building forge itself (Active - Build phase)

### Current Checkpoint

- Milestones 1-3 are complete.
- OpenAI Pro browser OAuth login flow is validated (`forge provider openai-pro login` + `forge doctor ping-provider` => `HTTP 200`).
- Global provider/session path is validated across fresh workspaces (`~/.config/forge/*`) with bootstrap workspace deferral.
- Sandbox fallback path (landrun -> bubblewrap) is integration-tested.
- UI baseline decision is locked: `forge test-uis` default is UI 4 (`control-room`, pcenter-style table readability, progress variant selected).
- Shared UI primitives are extracted to `src/ui.rs` and reused by Discovery recap output.
- Discovery TUI vim wave is in progress with core parity now stabilized: hybrid-blue default, modal editing, operators/text-objects, search/find, marks/registers, command mode (`:w/:q/:wq/:x`), and count prefixes.
- Discovery tab navigation is now aligned to vim-like flow (`Ctrl-N/Ctrl-P`, `gt/gT`).
- Next implementation task: `T4.2 - Write discovery.md`.
- Status authority: `docs/plans/forge-self-development/tasks.md`.

### Security Sandbox Migration Guardrail

Before enabling Rust `landlock` crate enforcement by default, the team must complete a staged migration with strict testing at each step:

- **Manual validation (director/human)**: run real workflows and confirm allowed writes succeed and forbidden writes are blocked.
- **Automated validation (AI agents)**: add and pass unit, integration, and end-to-end tests for policy rules, enforcement behavior, and fallback paths.
- **Gate policy**: do not flip defaults until both manual and automated checks are consistently green.

## Session Structure

Each session directory contains:
- `discovery.md` - Discovery summary
- `plan.md` - Master plan and roadmap
- `tasks.md` - Detailed task breakdown (Markdown + YAML frontmatter)
- `methodology.md` - Development approach decisions
- `testing-strategy.md` - E2E & comparative testing
- `build_log.md` - Execution logs (git ignored)
- `retrospective.md` - Post-completion analysis
- `implementation/` - Detailed per-milestone plans

## Creating a New Session

```bash
$ forge new {session-name}
```

This creates `docs/plans/{session-name}/` and initializes the Discovery phase.
