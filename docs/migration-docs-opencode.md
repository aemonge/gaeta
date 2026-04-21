# Migration Note: `docs/.opencode` to `.opencode`

Some repositories still keep OpenCode templates under `docs/.opencode/`.
gaeta now treats repo-root `.opencode/` as canonical for command and agent
templates.

## Canonical layout

- `./.opencode/commands/*.md`
- `./.opencode/agents/*.md`

Legacy layout to migrate away from:

- `./docs/.opencode/commands/*.md`
- `./docs/.opencode/agents/*.md`

## Why this migration is required

- Keeps command/agent discovery deterministic across local runs.
- Aligns repository layout with `make build` template installation behavior.
- Avoids duplicate templates drifting between two locations.

## Migration steps

1. Create canonical directories if missing.
2. Move templates from `docs/.opencode/` into `.opencode/`.
3. Remove now-empty legacy directories.
4. Rebuild and validate.

Example commands:

```bash
mkdir -p .opencode/commands .opencode/agents
mv docs/.opencode/commands/*.md .opencode/commands/ 2>/dev/null || true
mv docs/.opencode/agents/*.md .opencode/agents/ 2>/dev/null || true
rmdir docs/.opencode/commands docs/.opencode/agents docs/.opencode 2>/dev/null || true
make build
make lint && make test
```

## Verification checklist

- `.opencode/commands/` and `.opencode/agents/` contain expected templates.
- `docs/.opencode/` is absent or empty.
- `./gaeta doctor --verbose .` reports expected command/agent wiring.

## Rollback

If migration causes regressions, restore from git history:

```bash
git restore .opencode docs/.opencode
```

Then re-run:

```bash
make build
make lint && make test
```
