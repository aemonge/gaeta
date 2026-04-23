# Config Sample: gaeta -> projection

This document provides a concrete sample pair for config projection behavior.

Merge rule: recursive key-level overlay (`opencode` base + `gaeta` override).

## Base config (`~/.config/opencode/opencode.json`)

```json
{
  "server": {
    "hostname": "127.0.0.1"
  },
  "model": "openai/gpt-5.3-codex",
  "base_only": "from_opencode",
  "nested": {
    "from_base": true,
    "overridden": "base"
  },
  "agent": {
    "plan": {
      "permission": {
        "edit": "deny"
      }
    },
    "build": {
      "permission": {
        "edit": "allow"
      }
    }
  }
}
```

## gaeta override (`~/.config/gaeta/opencode.json`)

```json
{
  "server": {
    "hostname": "localhost"
  },
  "gaeta_only": "from_gaeta",
  "nested": {
    "overridden": "gaeta"
  },
  "agent": {
    "review": {
      "permission": {
        "edit": "deny"
      }
    }
  }
}
```

## Generated projection (`.gaeta/projection/opencode.json`)

```json
{
  "server": {
    "hostname": "localhost"
  },
  "model": "openai/gpt-5.3-codex",
  "base_only": "from_opencode",
  "gaeta_only": "from_gaeta",
  "nested": {
    "from_base": true,
    "overridden": "gaeta"
  },
  "agent": {
    "plan": {
      "permission": {
        "edit": "deny"
      }
    },
    "build": {
      "permission": {
        "edit": "allow"
      }
    },
    "review": {
      "permission": {
        "edit": "deny"
      }
    }
  }
}
```

## Inclusion and precedence notes

- Base-only keys are preserved.
- gaeta-only keys are added.
- Overlapping keys are overridden by gaeta.
- Nested maps are merged recursively.
- Agent map contains merged `plan`, `build`, and `review` entries.
- For OpenCode Monitor attach/browser flows, use `server.hostname: "localhost"` so the HTTP server starts while remaining loopback-only.
