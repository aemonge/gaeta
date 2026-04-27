# OpenCode Profiles

Gaeta supports three profiles:

- `minimal`
- `recommended` (default)
- `experimental`

Profile metadata is written to `.gaeta/profile.json` and is inspectable.

## minimal

Safe baseline with Gaeta-owned components only.

Includes:

- workflow docs (`PROJECT.md`, `GAETA.md`, `docs/.gaeta/*`)
- `.mcp.json.example`
- profile metadata
- artifact root scaffolding (`.gaeta/artifacts`)
- ignore and secret-hygiene checks

Does not include third-party plugin dependencies.

## recommended

Default curated distro layer.

Includes minimal plus curated plugin entries/config guidance for:

- OCX
- Envsitter Guard
- Opencode Ignore
- OpenSpec
- Plannotator
- Micode
- Opencode Agents
- Notify (optional)

Direnv remains gated off unless explicitly allowed.

## experimental

Includes recommended plus higher-variance entries:

- Opencode Browser
- Opencode Skills
- Froggy
- Opencode Mem
- Opencode Roadmap
- Opencode Sessions
- Opencode Canvas
- OpenCode Agent Tmux

## Removed plugins

These are excluded from all profiles:

- Google AI Search
- Telegram Bot
- Swarm Plugin
- Agent of Empires
- Devcontainers

Reasoning: unnecessary remote control surface, weak auditability, and mismatch with gaeta's wrapper-first safety model.
