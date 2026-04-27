---
description: Prepare focused next-session handoff
agent: plan
---
Use existing gaeta pause/status continuity instead of creating a second state system.

Flow:
1. Run `/status` for current snapshot.
2. Run `/pause` to checkpoint `docs/.gaeta/pause.md`.
3. Provide a concise next-session prompt containing:
   - current profile,
   - current phase,
   - objective,
   - recent changes,
   - files touched,
   - open decisions,
   - sem observations if available,
   - next step,
   - top pending sprint items,
   - blockers,
   - first implementation slice,
   - validation commands.
