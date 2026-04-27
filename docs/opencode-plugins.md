# OpenCode Plugins

Gaeta uses a curated registry at `packs/opencode/plugins.json`.

- `install.type = opencode-plugin`: projected into project `opencode.json` `plugin` field during `gaeta profile sync --install`.
- `install.type = executable`: validated with `command -v` and reported if missing.
- `install.type = manual`: kept as manual guidance until an authoritative package spec is verified.

| Plugin | Profile | Purpose | Security impact | Install method | Scope | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| OCX | recommended, experimental | Curated package-style plugin management | Medium | Manual/operator-driven | Repo-local config + user tool | Do not auto-install untrusted code |
| Envsitter Guard | recommended, experimental | Prevent `.env*` leakage | Low | Manual | Repo-local config | Defense in depth only |
| Opencode Ignore | recommended, experimental | Ignore-policy reinforcement | Low | Manual | Repo-local config | Complements `.gitignore` |
| OpenSpec | recommended, experimental | Spec-driven planning for larger slices | Medium | Manual | Repo-local config | Optional for small fixes |
| Plannotator | recommended, experimental | Plan annotation/review UX | Medium | Manual | Repo-local config | Supports review workflows |
| Micode | recommended, experimental | Brainstorm-plan-build workflow support | Medium | Manual | Repo-local config | Gaeta remains source of truth for phase state |
| Opencode Agents | recommended, experimental | Curated agent pack | Medium | Manual | Repo-local config | Enable selectively |
| Notify | recommended, experimental | Optional UX notifications | Low | Manual | User-global | Not required for profile functionality |
| Opencode Browser | experimental | Browser automation for design loops | High | Manual | Repo-local config + local browser | Optional and local-target-first |
| Opencode Skills | experimental | Skills extensions | High | Manual | Repo-local config | Avoid duplicate skills systems |
| Froggy | experimental | Hook/agent orchestration | High | Manual | Repo-local config | Must remain subordinate to gaeta phases |
| Opencode Mem | experimental | Persistent memory index | High | Manual | Local state | Text/git-reviewable files remain canonical truth |
| Opencode Roadmap | experimental | Strategic planning helpers | Medium | Manual | Repo-local config | May overlap with OpenSpec |
| Opencode Sessions | experimental | Session context storage | High | Manual | Local state | Avoid double source-of-truth with gaeta pause/status |
| Opencode Canvas | experimental | Artifact/canvas workflows | Medium | Manual | Repo-local config | Keep out of recommended by default |
| OpenCode Agent Tmux | experimental | Multi-agent visibility tooling | Medium | Manual | User tooling | Optional power-user feature |
