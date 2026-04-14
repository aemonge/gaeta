# Provider Integration Strategy

## Overview

forge's development follows a pragmatic, phased approach that prioritizes native provider integration while keeping optional external builder integration for the future. This strategy balances speed-to-market with long-term autonomy.

### Development Phases

**Phase 1 (Current)**: Documentation-first design
- Complete specification of all five phases
- Definition of core principles and sandbox requirements
- Architecture design
- Agent roles and responsibilities mapped

**Phase 2**: Native provider integration (MVP)
- forge orchestrator manages workflow (phases, approvals, checkpoints)
- Dev Agent uses a native provider layer for code generation
- All other agents implemented in Rust
- forge provides phase enforcement, security sandbox, and evolution system

**Phase 3**: Expand native capabilities
- Add provider features (streaming, tool calls, retries)
- Improve context management and validation loops
- Incremental improvements based on real usage

**Phase 4**: Optional long-term path
- Fully native provider stack
- Optional external builder integration as a plugin (if desired)
- Decision made based on Phase 3 results

## Why Start with Native Providers

### Strategic Benefits

**Immediate Capability**:
- OpenAI-compatible providers are widely available
- Configurable base URL + headers make integration flexible
- Native control over request/response handling

**Focus on Core Problem**:
- forge's core value is **orchestration**, not a specific external builder
- Native providers let us focus on:
  - Phase enforcement
  - Multi-project management
  - Evolution system
  - Security sandbox
  - Agent coordination

**Time-to-Value**:
- Implement 80% of needed functionality with a thin provider layer
- Proves concept with real workflow
- Gather data for future enhancements

**Learning Opportunity**:
- Run real projects with native provider integration
- Measure effectiveness
- Identify which native features to prioritize
- Data-driven decisions for Phase 3

## Provider Capabilities

### What the Provider Layer Provides

**Code Generation**:
- Generate new files and modules
- Multi-file simultaneous changes
- Context-aware suggestions
- Self-contained implementations

**Self-Correction**:
- Run tests and validate
- Detect failures
- Fix errors and retry
- Iterative improvement loop

**Context Management**:
- Track file relationships
- Understand codebase structure
- Maintain consistency across changes
- Handle dependencies

**Agentic Planning**:
- Perceive (understand task requirements)
- Plan (decompose into steps)
- Execute (generate code)
- Reflect (validate and improve)

## Provider Integration Strategy

### Architecture

```
┌────────────────────────────────────────────────────────────┐
│                 forge Orchestrator (Rust)                  │
│  - Multi-project management                                │
│  - Phase workflow (5 phases + optional inventory)          │
│  - Human approval gates                                    │
│  - Security sandbox (Bubblewrap + Landlock)                │
│  - Evolution engine (Darwin Gödel Machine)                 │
│  - TUI interface (ratatui)                                 │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼ (subprocess coordination)
┌────────────────────────────────────────────────────────────┐
│         Dev Agent (Rust, via Rig framework)                │
│  - Reads tasks.yaml                                         │
│  - Enforces methodology (TDD, Inventory-Driven, etc.)      │
│  - Coordinates validation                                   │
│  - Manages checkpoints                                      │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼ (managed provider call)
┌────────────────────────────────────────────────────────────┐
│        Native Provider Layer (Builder Capability)          │
│  - API requests via provider adapters                      │
│  - Sandboxed execution                                      │
│  - Input: context, task, requirements                      │
│  - Output: generated code, test results                    │
└────────────────────────────────────────────────────────────┘
```

### Integration Points

**Dev Agent responsibilities**:
1. Parse task from tasks.yaml
2. Gather context (inventory, codebase, patterns)
3. **Call native provider**:
   - Pass: requirement, context, constraints
   - Receive: generated code, execution results
4. Validate output in sandbox
5. Report results to orchestrator

**Provider responsibilities** (when called):
1. Accept context and task
2. Generate code
3. Return output
4. No knowledge of phases, approvals, or orchestration

**Sandbox provides**:
- Process isolation
- Filesystem restrictions
- Network controls
- Resource limits

## Capability Expansion Path

### Phase 3 Strategy

**Priority Selection**:
- Identify high-value, frequently-used features
- Measure provider usage patterns from Phase 2
- Data-driven decision: which features to implement next

**Example priorities**:
1. **High priority** (implement first):
   - Context management (understand codebase structure)
   - Test runner integration (run tests, parse results)
   - Error parsing (extract error messages, suggest fixes)

2. **Medium priority** (implement if time permits):
   - Code generation for simple patterns (CRUD, routes)
   - Refactoring operations (extract method, rename)
   - Test generation

3. **Low priority** (defer or keep minimal):
   - Complex multi-file generation
   - Novel architecture patterns
   - Advanced context management

**Incremental Expansion**:
```
Phase 2: Core provider integration
Phase 2.5: Add streaming + retries
Phase 3: Add test runner integration
Phase 3.5: Add simple generation helpers
Phase 4: Mature native provider stack
```

**Maintain Compatibility**:
- Native implementations must match expected behavior
- All tests continue to pass
- No visible change to user experience
- Gradual, non-disruptive transition

## Long-Term Vision

### Option A: Fully Native

**Path**: Implement all features natively in Rust.

**Benefits**:
- Single binary, no dependencies
- Full control over behavior
- Optimized for forge workflow
- Self-contained, portable

**Trade-offs**:
- Higher implementation cost
- Requires more Rust expertise
- May lack some advanced features
- Longer development timeline

### Option B: External Builder Plugin

**Path**: Add external builder integration as an optional plugin.

**Benefits**:
- Access to advanced features when needed
- Keeps core forge lean and portable
- Optional dependency, not required for core workflow

**Trade-offs**:
- Extra integration surface to maintain
- Inconsistent behavior across providers

## Decision Timeline

### Phase 2 Milestones
- Track which features the provider layer is used for
- Measure effectiveness per feature type
- Gather performance metrics
- Collect user feedback

### End of Phase 2 (Decision Point)
- Review data from Phase 2
- **Option A vs B decision** based on:
  - Provider reliability and stability
  - Feature coverage adequacy
  - Team resources for Phase 3
  - Community feedback

### Phase 3+
- Implement Phase 3 strategy based on chosen path
- Continue learning, adjust as needed

## Success Criteria

### Phase 2 Success
- ✅ forge orchestration works end-to-end
- ✅ Multi-project parallelism functions
- ✅ Phase enforcement is enforced
- ✅ Security sandbox is effective
- ✅ Evolution system learns patterns
- ✅ Native provider integration is stable
- ✅ Real projects complete successfully

### Phase 3+ Success
- ✅ Incremental progress toward chosen path
- ✅ Zero regressions in capability
- ✅ Measurable improvements in metrics (speed, reliability)
- ✅ Clear roadmap and progress tracking

## FAQ

**Q: Why not start fully native in Rust?**\
A: Faster time-to-value. forge's value is orchestration, not a single provider. A thin provider layer gives early capability while keeping control.

**Q: What if a provider changes incompatibly?**\
A: Risk acknowledged. Phase 2 will measure provider reliability. If unreliable, Phase 3 accelerates to harden adapters or swap providers. We own the decision.

**Q: Can we add external builders later?**\
A: Yes, Option B is viable. If it adds value and stays maintained, a plugin path is acceptable. This is a pragmatic decision based on Phase 2 results.

**Q: How do we ensure provider quality matches expectations?**\
A: Rigorous testing in Phase 3. All existing tests must pass. New capabilities are validated against defined workflows before release. Gradual rollout prevents regressions.

**Q: Does using providers compromise forge's security model?**\
A: No. Provider calls run inside the same sandbox and follow the same filesystem/network policies. The sandbox protects against all agents/tools equally.

## Summary

Provider integration strategy is **pragmatic and data-driven**:

- **Phase 2**: Native provider integration, prove orchestration concept
- **Phase 3**: Learn from real usage, decide on long-term path
- **Phase 4+**: Execute chosen path (native stack or optional plugin)

This approach balances **speed-to-value** with **long-term autonomy**, making forge viable without massive upfront investment while maintaining optionality for the future.
