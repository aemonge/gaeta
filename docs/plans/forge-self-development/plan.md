# Master Plan - forge Self-Development

## Overview

This plan outlines the staged development of forge, starting from a minimal native provider integration and evolving into a full-featured, self-improving code director platform.

## Development Strategy

- **Pragmatic MVP**: Native provider integration first to keep control and flexibility.
- **Dogfooding**: Use forge to build forge starting as soon as Milestone 2 is complete.
- **Incremental Value**: Each milestone delivers a functional system with improved capability.
- **Comparative Testing**: Validate forge's output against defined workflows and regression tests.

## Roadmap & Milestones

| Milestone | Capability | Version | Status |
|-----------|------------|---------|--------|
| M1 | Build Infrastructure | - | ✅ Completed |
| M2 | Native Provider Integration (MVP) | v0.1.0 | ✅ Completed |
| M3 | Task Synchronization (dstask Integration) | - | ✅ Completed |
| M4 | Discovery Phase Implementation | - | 🚧 In Progress (next: T4.2) |
| M5 | Task-Based Build | - | ⏳ Pending |
| M6 | Presentation & Suggestions | - | ⏳ Pending |
| M7 | Full Workflow Integration | v0.2.0 | ⏳ Pending |
| **M7.1** | **🎉 Self-Building** | - | ⏳ Pending |
| M8 | Core Workflow Polish | - | ⏳ Pending |
| M9 | Inventory Phase (Optional) | - | ⏳ Pending |
| M10 | Agent Framework (Rig) | - | ⏳ Pending |
| M11 | TUI Interface | v0.3.0 | 🚧 In Progress (vim editor core stabilized; remaining polish) |
| M12 | Multi-Project Orchestration | v0.4.0 | ⏳ Pending |
| M13 | Evolution (DGM) | - | ⏳ Pending |
| M14 | Native Implementation | - | ⏳ Pending |
| M15 | Production Hardening | v1.0.0 | ⏳ Pending |

## Status Source

For day-to-day execution state (completed vs pending tasks), use `tasks.md` as the source of truth.
This `plan.md` file is the roadmap view.

## Success Criteria

1. **Functional**: forge can successfully drive a native provider to build new features.
2. **Quality**: forge output passes all security and lint checks.
3. **Productive**: forge reduces the time needed to manage parallel development tasks.
4. **Reliable**: Security sandbox prevents any unauthorized filesystem or network access.

## Detailed Tasks

See [tasks.md](./tasks.md) for the complete task breakdown.
