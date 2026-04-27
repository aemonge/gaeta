---
description: Serve local gaeta artifacts safely
agent: build
---
Resolve gaeta launcher in this order:
1. `gaeta` from PATH.
2. `./gaeta` when present in current project root.
3. `~/.config/gaeta/bin/gaeta` as per-user fallback launcher.

If no launcher exists, explain manual fallback:
- `python3 -m http.server --bind 127.0.0.1 --directory .gaeta/artifacts`

When launcher exists, run:
- `<gaeta-launcher> serve .`
- `<gaeta-launcher> serve status .`

Reply with:
- artifact URL,
- artifact root,
- metadata file (`.gaeta/server.json`).
