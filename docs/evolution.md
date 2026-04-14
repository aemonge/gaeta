# Evolution (Darwin Gödel Machine)

## What is a Darwin Gödel Machine?

The **Darwin Gödel Machine** is a self-improving AI system concept that combines:

- **Darwin**: Evolutionary principles (variation, selection, adaptation)
- **Gödel**: Self-referential reasoning (system can reason about and modify itself)
- **Machine**: Automated, empirical validation (not theoretical proofs)

### Core Concepts

1. **Evolutionary Loop**: Generate variants → Test empirically → Select best → Archive
2. **Self-Reference**: System can modify its own prompts, validation rules, and behavior
3. **Empirical Validation**: Changes proven through real benchmarks, not proofs
4. **Archive**: Growing library of agent variants with performance data

### How forge Uses DGM

forge's evolution system continuously:
- Analyzes completed projects for patterns
- Proposes improvements to agent behavior
- Tests variants in sandbox before deployment
- Archives all experiments (successful or not) for learning
- Applies successful patterns to future projects automatically

This makes forge progressively better at directing code development with every project you complete.

---

## Overview

Evolution is the **continuous background learning system** based on the Darwin Gödel Machine approach. It runs constantly across all projects, analyzing patterns from completed work, identifying improvements, and automatically adapting forge's behavior over time.

**Input**: Aggregated data from all projects (retrospectives, metrics, patterns)\
**Output**: Process improvements, updated templates, refined agent behavior

## Purpose

Learn from experience. Transform individual project insights into systemic improvements:

- Detect cross-project patterns (what works consistently).
- Identify bottlenecks (what slows down repeatedly).
- Optimize agent behavior (methodology selection, task granularity).
- Refine templates (better questions, clearer tasks).
- Surface global recommendations (architectural patterns, tech choices).

This makes each project better than the last—without explicit tuning.

## The Darwin Gödel Machine System

### Architecture

**Not**: A standalone phase.

**Is**: Continuous background analysis system + knowledge base.

Components:

- **Pattern Detector**: Analyzes retrospectives, finds recurring themes.
- **Metrics Aggregator**: Tracks velocity, quality, methodology effectiveness.
- **Recommendation Engine**: Generates improvements based on patterns.
- **Knowledge Base**: Stores learnings, feeds into future projects.

### Learning Approach

**Passive observation, active application**:

- Runs in background after each project completes.
- No human interaction required (fully automated).
- Insights automatically influence future Discovery, Plan, Build phases.
- Optional: Review evolution insights periodically (dashboard).

## Process Flow

```
Project completes (Suggestions phase done)
    ↓
Evolution System: Ingest project data
    ├─ retrospective.md (metrics, challenges, patterns)
    ├─ build_log.md (task execution, revisions, timings)
    ├─ Git history (commit patterns, change sizes)
    └─ Human interactions (approvals, feedback, custom validations)
    ↓
Pattern Detector: Analyze across all projects
    ├─ Methodology effectiveness (TDD vs inventory vs traditional)
    ├─ Task granularity (too large, too small, just right)
    ├─ Common challenges (recurring issues across projects)
    ├─ Success patterns (what leads to fast, quality delivery)
    └─ Human feedback patterns (frequent revisions, approval speed)
    ↓
Metrics Aggregator: Calculate trends
    ├─ Velocity: Tasks/hour over time (getting faster?)
    ├─ Quality: Coverage, revision rate (improving?)
    ├─ Efficiency: Plan accuracy (estimates vs actuals)
    └─ Methodology ROI (TDD cost vs benefit)
    ↓
Recommendation Engine: Generate improvements
    ├─ Adjust agent behavior (e.g., "prefer TDD for auth features")
    ├─ Refine templates (add common questions to Discovery)
    ├─ Update task patterns (optimal granularity detected)
    └─ Surface architectural patterns (reusable designs)
    ↓
Knowledge Base: Store learnings
    ├─ Global patterns (apply to all future projects)
    ├─ Domain patterns (apply to similar work, e.g., auth)
    ├─ Personal patterns (your specific preferences)
    └─ Temporal patterns (trends over time)
    ↓
Future projects: Benefit automatically
    ├─ Discovery: Better questions based on past gaps
    ├─ Plan: Optimal task size, proven methodologies
    ├─ Build: Avoid known pitfalls, follow successful patterns
    └─ Suggestions: Better commit messages, deployment checklists
```

## Learning Categories

### Methodology Effectiveness

Tracks which methodologies work best for which scenarios.

**Example insights**:

```
After 10 projects:

TDD:
- Average task duration: 45 min
- Revision rate: 8%
- Coverage: 92% average
- Best for: Auth, payments, security-critical logic
- Avoid for: UI tweaks, simple CRUD

Inventory-Driven:
- Average task duration: 35 min
- Revision rate: 12%
- Consistency score: 95% (matches existing patterns)
- Best for: Extending existing modules, refactors
- Avoid for: Greenfield projects

Traditional:
- Average task duration: 25 min
- Revision rate: 15%
- Coverage: 65% average
- Best for: UI, templates, simple glue code
- Avoid for: Complex logic, security features
```

**Application**: Architect Agent uses these insights during Plan to tag tasks with
optimal methodology.

### Task Granularity

Learns optimal task size based on completion patterns.

**Example insights**:

```
Task duration analysis (20 projects):

Sweet spot: 30-60 minutes per task
- 95% completion rate on first attempt
- 5% revision rate
- Clean git history (atomic commits)

Too small (<15 minutes):
- 10% of tasks
- Overhead: Context switching reduces efficiency
- Recommendation: Merge with adjacent tasks

Too large (>90 minutes):
- 15% of tasks
- 25% revision rate (scope creep, multiple concerns)
- Recommendation: Split into 2-3 smaller tasks

Optimal task breakdown:
- Core logic: 45-60 min (allows for TDD cycle + refactor)
- Integration: 30-45 min (follows existing patterns)
- UI/templates: 20-30 min (quick iterations)
- Tests (standalone): 15-25 min (focused test writing)
```

**Application**: Architect Agent adjusts task granularity in tasks.yaml to hit sweet
spot.

### Common Challenges

Detects recurring issues and suggests preventive measures.

**Example insights**:

```
Recurring challenges (15 projects):

1. Error handling ambiguity (40% of projects)
   - Symptom: Revision during implementation (String vs typed errors)
   - Prevention: Plan phase now includes explicit error type design
   - Impact: Revision rate dropped 15% after implementing

2. Dependency installation timing (30% of projects)
   - Symptom: Build blocked waiting for crate installation
   - Prevention: Discovery phase now asks "Do you have dependencies ready?"
   - Impact: Reduced mid-build interruptions by 80%

3. Route pattern inconsistency (25% of projects)
   - Symptom: Multiple patterns detected, human must choose
   - Prevention: Inventory phase now flags inconsistencies upfront
   - Impact: Refactor tasks added proactively in Plan

4. Test fixture duplication (20% of projects)
   - Symptom: Similar mocks created across test files
   - Prevention: Inventory phase detects, suggests extraction task
   - Impact: Test maintainability improved (fewer duplicate changes)
```

**Application**: Discovery and Plan agents proactively address these known issues.

### Success Patterns

Identifies what leads to high-quality, fast delivery.

**Example insights**:

```
High-performing projects (top 25% by velocity + quality):

Common characteristics:
- Clear requirements in Discovery (avg 6 clarifying questions answered)
- Inventory run before refactors (100% of high-quality refactors)
- TDD for core logic (94% coverage on critical paths)
- Human checkpoints every 2-3 tasks (early feedback)
- Atomic commits (avg 50-100 LOC per commit)
- Custom validation at logical boundaries (make lint after refactor)

Pattern: "Slow to plan, fast to build"
- Projects with 15+ min in Discovery/Plan: 30% faster build
- Projects rushing to Build: 40% more revisions

Pattern: "Early feedback prevents rework"
- Revisions in first 25% of tasks: Minimal impact
- Revisions in last 25% of tasks: 3x time cost (cascading changes)

Pattern: "Inventory pays off for integration"
- Inventory run: 20 min upfront, 45 min saved in build
- No inventory: Inconsistent patterns, refactor tasks added later
```

**Application**: Product Agent encourages thorough Discovery, Architect Agent recommends
inventory proactively.

### Human Feedback Patterns

Learns your personal preferences and work style.

**Example insights**:

```
Your patterns (25 projects):

Approval speed by task type:
- Tests: 2 min average (fast approval, high trust)
- Core logic: 6 min average (careful review, occasional custom validation)
- UI: 3 min average (quick visual check)
- Refactors: 8 min average (always runs make lint)

Revision triggers:
- Error handling: 60% of revisions (prefer typed errors over strings)
- Naming: 20% of revisions (prefer explicit over terse)
- Documentation: 10% of revisions (want inline comments for complex logic)
- Architecture: 10% of revisions (prefer composition over inheritance)

Custom validations:
- make lint: 80% of refactor tasks
- make test: 60% of integration tasks
- make coverage: 30% of feature tasks
- Custom benchmarks: 10% of performance tasks

Preferred checkpoint frequency:
- Small tasks (<30 min): Batch 2-3 before checkpoint
- Medium tasks (30-60 min): Checkpoint each
- Large tasks (>60 min): Request mid-task check-in

Commit style:
- Atomic commits: 90% (prefer per-task commits)
- Batch commits: 10% (group related tasks occasionally)
- Average commit size: 75 LOC
```

**Application**: All agents adapt to your style automatically—you don't notice, but
forge "feels" more natural over time.

## Knowledge Base Structure

Persistent storage of learnings, queryable by agents.

```
~/.local/share/forge/knowledge/
  ├─ global_patterns.db (SQLite)
  │  ├─ methodology_effectiveness
  │  ├─ task_granularity
  │  ├─ common_challenges
  │  └─ success_patterns
  │
  ├─ domain_patterns.db
  │  ├─ auth_features (patterns specific to authentication)
  │  ├─ api_design (REST/GraphQL patterns)
  │  ├─ database_migrations (schema change patterns)
  │  └─ ui_components (frontend patterns)
  │
  ├─ personal_preferences.db
  │  ├─ approval_patterns (your review behavior)
  │  ├─ revision_triggers (what you commonly request changed)
  │  ├─ validation_preferences (make targets, custom commands)
  │  └─ commit_style (atomic vs batch, message tone)
  │
  └─ metrics_history.db
     ├─ velocity_over_time (tasks/hour trend)
     ├─ quality_over_time (coverage, revision rate)
     ├─ methodology_roi (cost vs benefit by methodology)
     └─ efficiency_trends (plan accuracy, estimate vs actual)
```

### Query Examples

Agents query knowledge base during phases:

**Discovery Phase**:

```sql
-- Product Agent: What questions commonly missed?
SELECT question, frequency
FROM common_challenges
WHERE phase = 'discovery' AND resulted_in_revision = true
ORDER BY frequency DESC
LIMIT 5;

-- Result: Add these questions proactively
-- e.g., "Error handling strategy?" (missed 40% of the time)
```

**Plan Phase**:

```sql
-- Architect Agent: Optimal methodology for auth feature?
SELECT methodology, avg_duration, revision_rate, coverage
FROM methodology_effectiveness
WHERE domain = 'auth'
ORDER BY (revision_rate * 0.3 + (100 - coverage) * 0.7) ASC
LIMIT 1;

-- Result: TDD (lowest revision rate + highest coverage for auth)
```

**Build Phase**:

```sql
-- Dev Agent: What's the user's preferred error handling pattern?
SELECT pattern, frequency
FROM personal_preferences
WHERE category = 'error_handling' AND resulted_in_approval = true
ORDER BY frequency DESC
LIMIT 1;

-- Result: Typed enums (60% of approvals), not Strings
```

## Evolution Dashboard

Optional: Periodic review of learnings (not required, but insightful).

### Example Dashboard

```
┌─────────────────────────────────────────────────────┐
│ forge Evolution Dashboard                           │
│ Data: 25 completed projects (last 3 months)         │
└─────────────────────────────────────────────────────┘

## Velocity Trend

Projects 1-5:   4.2 tasks/hour
Projects 6-10:  4.8 tasks/hour (+14%)
Projects 11-15: 5.3 tasks/hour (+26%)
Projects 16-20: 5.7 tasks/hour (+36%)
Projects 21-25: 6.1 tasks/hour (+45%)

Trend: Accelerating (learning curve effect)

## Quality Metrics

Average test coverage: 87% (target: 85%) ✓
Average revision rate: 10% (down from 18% initially)
Builds passing on first try: 92%

Trend: Stable quality while accelerating

## Methodology Effectiveness

TDD:
  - Used: 45% of tasks
  - Avg duration: 45 min
  - Revision rate: 8%
  - Coverage: 94%
  - ROI: High (time investment pays off in quality)

Inventory-Driven:
  - Used: 30% of tasks
  - Avg duration: 35 min
  - Revision rate: 12%
  - Consistency: 95%
  - ROI: High (prevents rework from pattern mismatch)

Traditional:
  - Used: 25% of tasks
  - Avg duration: 25 min
  - Revision rate: 15%
  - Coverage: 68%
  - ROI: Medium (fast but lower confidence)

## Top Learnings

1. **TDD for security-critical code** (applied 12 times)
   - Pattern: Auth, payments, validation logic
   - Impact: Zero security bugs in production

2. **Inventory before refactors** (applied 8 times)
   - Pattern: Refactors, route additions, handler changes
   - Impact: 95% pattern consistency maintained

3. **Explicit error types in Plan** (applied 15 times)
   - Pattern: Added after Challenge #1 detected
   - Impact: Revision rate dropped 15%

4. **Custom validation at refactor boundaries** (applied 20 times)
   - Pattern: make lint after refactor tasks
   - Impact: Caught 8 clippy warnings before commit

5. **Checkpoint every 2-3 tasks** (your preference)
   - Pattern: Detected from approval speed analysis
   - Impact: Optimal feedback timing (not too frequent, not too late)

## Recommendations

Based on 25 projects, consider:

1. **Increase TDD usage for API endpoints**
   - Current: 30% of API tasks use TDD
   - Observation: TDD API tasks have 20% fewer prod bugs
   - Suggestion: Bump to 60% TDD for API work

2. **Extract common test fixtures**
   - Detected: Test fixture duplication in 40% of projects
   - Impact: 15% of test changes are duplicate fixture updates
   - Action: Add "extract fixtures" refactor task proactively

3. **Pre-run inventory for all route work**
   - Current: 60% of route tasks run inventory first
   - Observation: 95% consistency when inventory used, 70% without
   - Suggestion: Make inventory mandatory for route additions

Press [Enter] to return, [d] for detailed metrics, [r] for raw data
```

## Automatic Adaptations

Evolution system applies learnings automatically—no configuration needed.

### Example: Discovery Improvements

**Before evolution** (first 5 projects):

```
Product Agent: "Add OAuth authentication"
Human: [answers 4 questions]
# Build starts

# Later, revision in Task 4: "Oh, we need typed errors"
```

**After evolution** (projects 6+):

```
Product Agent: "Add OAuth authentication"
Agent asks 5 questions (added: "Error handling strategy?")
Human: "Typed errors with enum for different failure modes"
# Plan includes explicit error type design
# No revision needed in Build
```

**What changed**: Evolution detected "error handling ambiguity" in 40% of projects,
added question to Discovery template.

### Example: Plan Adjustments

**Before evolution** (first 10 projects):

```
# tasks.yaml
- id: T3
  title: "Implement OAuth provider"
  estimated_duration: 60 min
  # Actual: 90 min (scope too large)
```

**After evolution** (projects 11+):

```
# tasks.yaml
- id: T3
  title: "Write failing tests for OAuth provider"
  estimated_duration: 25 min

- id: T4
  title: "Implement OAuth provider (minimal)"
  estimated_duration: 40 min

- id: T5
  title: "Refactor OAuth provider (cleanup)"
  estimated_duration: 25 min

# Total: 90 min, but split into 3 manageable tasks
```

**What changed**: Evolution detected tasks >60 min have 25% revision rate, auto-splits
into smaller tasks.

### Example: Build Behavior

**Before evolution** (early projects):

```
Dev Agent: Implements OAuth with String errors
QA Agent: Tests pass ✓
Human: ✗ "Use typed errors" (revision)
```

**After evolution** (later projects):

```
Dev Agent: Reads personal_preferences.db
  "User prefers typed errors (60% revision trigger)"
Dev Agent: Implements OAuth with OAuthError enum
QA Agent: Tests pass ✓
Human: ✓ (approved, no revision)
```

**What changed**: Evolution learned your preference, Dev Agent proactively applies it.

## Benefits

**Continuous improvement**:

- Each project slightly better than the last.
- No manual tuning required (happens automatically).
- Learnings compound over time.

**Personalization**:

- forge adapts to your style (not generic defaults).
- Feels more natural over time.
- Reduces friction (fewer revisions, better suggestions).

**Pattern reuse**:

- Successful architectures surface as recommendations.
- Common pitfalls avoided proactively.
- Domain expertise builds up (auth patterns, API patterns, etc.).

**Data-driven decisions**:

- Not "best practices" from blog posts.
- Your actual data (what works for your projects, your style).
- Objective metrics (revision rates, coverage, velocity).

## Privacy & Control

### Data Collection

**What's collected**:

- Project metrics (duration, LOC, coverage, task counts).
- Patterns (methodologies used, task sizes, challenges).
- Human interactions (approval speed, revision triggers, custom commands).

**What's NOT collected**:

- Code content (your actual code never leaves your machine).
- Sensitive data (credentials, API keys, personal info).
- Project names or domains (anonymized in aggregation).

### Data Storage

**Local only** (by default):

- All data stored in `~/.local/share/forge/`
- Never transmitted to external servers
- Fully under your control

**Optional cloud sync**:

- If you use forge on multiple machines
- Encrypted, E2E (only you can decrypt)
- Opt-in only (disabled by default)

### Control

**Reset learnings**:

```bash
# Clear all evolution data, start fresh
$ forge evolution reset

Warning: This will delete all learnings. Continue? [y/n]
```

**Export data**:

```bash
# Export for analysis or backup
$ forge evolution export --format json > evolution_data.json
```

**Disable evolution**:

```yaml
# forge.yaml
evolution:
  enabled: false  # Disables learning (still works, but no adaptation)
```

## Timeline

Evolution impact grows over time:

```
Projects 1-5:    Minimal impact (collecting baseline data)
Projects 6-10:   Early improvements (common issues addressed)
Projects 11-20:  Noticeable acceleration (patterns refined)
Projects 21-50:  Significant personalization (adapts to your style)
Projects 51+:    Mature system (anticipates needs, rare surprises)
```

## Integration with Other Phases

### All Phases → Evolution

Every phase contributes data:

- **Discovery**: Questions asked, gaps found, clarity achieved.
- **Inventory**: Patterns detected, refactor signals, coverage gaps.
- **Plan**: Task sizes, methodologies chosen, estimates.
- **Build**: Execution times, revisions, human interactions.
- **Presentation**: Retrospectives, challenges, insights.
- **Suggestions**: Commit quality, deployment complexity.

### Evolution → All Phases

Evolution improves all phases:

- **Discovery**: Better questions, proactive clarifications.
- **Inventory**: Focus on high-value analysis areas.
- **Plan**: Optimal task granularity, proven methodologies.
- **Build**: Avoid known pitfalls, match preferences.
- **Presentation**: Richer insights (compare to baseline).
- **Suggestions**: Better commit messages (learn from past).

## Anti-Patterns

### Ignoring Evolution Insights

**Bad**: Dashboard shows TDD beneficial for API work, continue using traditional.

```
Dashboard: "TDD for API endpoints: 20% fewer prod bugs"
You: "Nah, TDD is slow" (ignores data)
# Continues with bugs in production
```

**Good**: Adapt based on your own data.

```
Dashboard: "TDD for API endpoints: 20% fewer prod bugs"
You: "Interesting, let me try TDD for next API feature"
# Sees benefit, adopts pattern
```

### Resetting Prematurely

**Bad**: Reset learnings after 5 projects because "it's not perfect yet".

```
$ forge evolution reset
# Loses all data, starts from scratch
# Evolution needs data to learn
```

**Good**: Let it accumulate (10-20 projects minimum).

```
# After 20 projects, review dashboard
# See trends, understand learnings
# Make informed decision (keep or adjust)
```

### Treating as Silver Bullet

**Bad**: "Evolution will fix all my problems."

```
# Expects perfect code generation after 3 projects
# Evolution is gradual improvement, not magic
```

**Good**: Understand evolution enhances, not replaces judgment.

```
# Evolution provides data and suggestions
# You make final decisions
# Best results: Your expertise + Evolution insights
```

## Summary

Evolution is **continuous learning**:

- **Analyzes**: All completed projects (metrics, patterns, interactions).
- **Learns**: What works (methodologies, granularity, patterns).
- **Adapts**: Future projects automatically improved.
- **Personalizes**: Matches your style and preferences.
- **Privacy**: Local-only by default, no external transmission.

**Evolution makes forge smarter with every project. The 50th is better than the 1st.**
📈
