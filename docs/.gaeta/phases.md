# Phases

## Active delivery model

### Phase 0 - Scope

Purpose:
- freeze target behavior and non-goals.

Exit:
- architecture and ADRs written.

### Phase 1 - Config

Purpose:
- define `~/.config/gaeta` layout and schema.

Exit:
- `gaeta.json` schema and sample config exist.

### Phase 2 - Projection

Purpose:
- map gaeta config/assets into OpenCode-compatible paths.

Exit:
- generated/symlinked compatibility view works.

### Phase 3 - Wrapper

Purpose:
- integrate projection with sandbox launch.

Exit:
- `gaeta` launches OpenCode using projected state.

### Phase 4 - Workflow

Purpose:
- bootstrap repo docs and behavioral rules.

Exit:
- repo template and GAETA rules exist.

### Phase 5 - Sync plugin

Purpose:
- sync todo/checklist/status behavior.

Exit:
- Markdown checklist sync works from plugin events.

### Phase 6 - Validation

Purpose:
- verify sandbox, projection, and workflow behavior.

Exit:
- validation suite covers critical scenarios.

### Phase 7 - UX

Purpose:
- improve ergonomics.

Exit:
- init/doctor/status/sync commands exist.
