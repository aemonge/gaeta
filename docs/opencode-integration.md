# OpenCode Integration

Gaeta is TUI-first.

- `gaeta` CLI is the airlock/launcher/safety wrapper.
- OpenCode TUI is the cockpit for daily workflow actions.
- Gaeta profiles are curated distro layers projected into OpenCode-compatible config paths.

## Process boundary

```text
User
  -> gaeta CLI
  -> sandbox / policy / env hygiene
  -> OpenCode TUI
  -> Gaeta agents / commands / selected plugins
```

Authority stays outside OpenCode:

- Gaeta owns sandboxing, env sanitation, profile selection, secret hygiene, doctor checks, and artifact server lifecycle.
- OpenCode slash commands own workflow ergonomics (`/brainstorm`, `/plan`, `/build`, `/review`, `/design`, `/serve`, `/handoff`, `/status`).

Gaeta intentionally avoids becoming a generic agent framework or plugin soup.
