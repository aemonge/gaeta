# Gate: Decision - No OpenCode Wrapper

**Status**: ✅ Approved
**Date**: 2026-02-18
**Decision**: Do not wrap OpenCode as the core builder.

## Context

We evaluated integrating GPT Codex "Unlimited" services and determined the access surface is unclear. Rather than depend on an external builder with unknown compatibility, forge will proceed with a native provider layer.

## Decision

- Phase 2 will implement native provider integration (OpenAI-compatible or similar).
- External builders are deferred to an optional plugin path.

## Implications

- Update strategy and master plan to remove OpenCode wrapper as the MVP.
- Prioritize provider abstraction, config, and request/response handling in Phase 2.

## Next Step

- Re-sequence Milestone 2 around native provider integration.
