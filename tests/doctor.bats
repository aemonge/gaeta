#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  GAETA_BIN="${REPO_ROOT}/gaeta"

  TEST_ROOT="$(mktemp -d)"
  TEST_HOME="${TEST_ROOT}/home"
  TEST_PROJECT="${TEST_ROOT}/project"

  mkdir -p "${TEST_HOME}/.config/gaeta"
  mkdir -p "${TEST_HOME}/.config/opencode"
  mkdir -p "${TEST_PROJECT}/docs/.gaeta"

  cat >"${TEST_HOME}/.config/opencode/opencode.json" <<'JSON'
{
  "base_only": "from_opencode",
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
  },
  "nested": {
    "from_base": true,
    "overridden": "base"
  }
}
JSON

  cat >"${TEST_HOME}/.config/gaeta/opencode.json" <<'JSON'
{
  "agent": {
    "review": {
      "permission": {
        "edit": "deny"
      }
    }
  },
  "gaeta_only": "from_gaeta",
  "nested": {
    "overridden": "gaeta"
  }
}
JSON

  cat >"${TEST_HOME}/.config/opencode/tui.json" <<'JSON'
{
  "theme": "base",
  "keybinds": {
    "open": "ctrl+o"
  }
}
JSON

  cat >"${TEST_HOME}/.config/gaeta/tui.json" <<'JSON'
{
  "theme": "gaeta",
  "keybinds": {
    "quit": "ctrl+q"
  }
}
JSON

  cat >"${TEST_PROJECT}/docs/.gaeta/phases.md" <<'MD'
# phases
MD

  cat >"${TEST_PROJECT}/docs/.gaeta/status.md" <<'MD'
# Status

## Current phase

Phase X

## Next step

Implement sync behavior.

## Blockers

- none
MD

  cat >"${TEST_PROJECT}/docs/.gaeta/checklist.md" <<'MD'
# Checklist

## Current Sprint

- [ ] Implement sync behavior.
- [ ] Add methodology-enforced instructions.
MD

  cat >"${TEST_PROJECT}/docs/.gaeta/backlog.md" <<'MD'
# backlog
MD

  cat >"${TEST_PROJECT}/PROJECT.md" <<'MD'
# PROJECT

## Resume Prompt

`continue from resume helper output`
MD

  cat >"${TEST_PROJECT}/GAETA.md" <<'MD'
# GAETA
MD
}

teardown() {
  rm -rf "$TEST_ROOT"
}

@test "doctor --json includes populated checks and merged config" {
  local json_path="${TEST_ROOT}/doctor.json"

  HOME="$TEST_HOME" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 GAETA_TTY_MODE=compat \
    "$GAETA_BIN" doctor --json "$TEST_PROJECT" >"$json_path"

  run python3 - "$json_path" "$TEST_PROJECT" <<'PY'
import json
import pathlib
import sys

doctor_path = pathlib.Path(sys.argv[1])
project = pathlib.Path(sys.argv[2])
payload = json.loads(doctor_path.read_text(encoding="utf-8"))

assert payload["summary"]["fail"] == 0, payload
assert payload["status"] == "ok", payload

checks = payload["checks"]
for key in [
    "dependencies",
    "config_sources",
    "directory_sources",
    "projection_artifacts",
    "sandbox_check",
    "workflow_files",
]:
    assert len(checks[key]) > 0, (key, payload)

config_rows = {row["label"]: row for row in checks["config_sources"]}
assert "mode=merged" in config_rows["opencode.json"]["details"], config_rows
assert "mode=merged" in config_rows["tui.json"]["details"], config_rows

sandbox_rows = {row["label"]: row for row in checks["sandbox_check"]}
assert "mode=compat" in sandbox_rows["tty session policy"]["details"], sandbox_rows
assert "skipped" in sandbox_rows["sandbox execution"]["details"], sandbox_rows

projection_rows = {row["label"]: row for row in checks["projection_artifacts"]}
assert projection_rows["core agent profiles"]["status"] == "ok", projection_rows

projected_config = json.loads((project / ".gaeta" / "projection" / "opencode.json").read_text(encoding="utf-8"))
projected_tui = json.loads((project / ".gaeta" / "projection" / "tui.json").read_text(encoding="utf-8"))

assert projected_config["base_only"] == "from_opencode", projected_config
assert projected_config["gaeta_only"] == "from_gaeta", projected_config
assert projected_config["nested"]["from_base"] is True, projected_config
assert projected_config["nested"]["overridden"] == "gaeta", projected_config
assert "plan" in projected_config["agent"], projected_config
assert "build" in projected_config["agent"], projected_config
assert projected_config["agent"]["review"]["permission"]["edit"] == "deny", projected_config

assert projected_tui["theme"] == "gaeta", projected_tui
assert projected_tui["keybinds"]["open"] == "ctrl+o", projected_tui
assert projected_tui["keybinds"]["quit"] == "ctrl+q", projected_tui
PY

  [ "$status" -eq 0 ]
}

@test "doctor human output is quiet by default and expanded with --verbose" {
  run env HOME="$TEST_HOME" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 "$GAETA_BIN" doctor "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gaeta doctor"* ]]
  [[ "$output" == *"summary:"* ]]
  [[ "$output" != *"Dependencies"* ]]

  run env HOME="$TEST_HOME" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 "$GAETA_BIN" doctor --verbose "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Dependencies"* ]]
  [[ "$output" == *"Summary"* ]]
}

@test "doctor sandbox check does not inject --agent for custom binaries" {
  local fake_bin_dir="${TEST_ROOT}/fake-bin"
  mkdir -p "$fake_bin_dir"

  cat >"${fake_bin_dir}/bwrap" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  printf '%s\n' "bubblewrap mock --disable-userns"
  exit 0
fi

bash_seen=0
for arg in "$@"; do
  if [[ "$arg" == "/bin/bash" ]]; then
    bash_seen=1
    continue
  fi
  if [[ "$bash_seen" -eq 1 && "$arg" == "--agent" ]]; then
    printf '%s\n' "/bin/bash: --agent: invalid option" >&2
    exit 2
  fi
done

printf '%s\n' "GAETA_DOCTOR_SANDBOX_OK"
SH
  chmod +x "${fake_bin_dir}/bwrap"

  run env HOME="$TEST_HOME" OPENCODE_BIN=/bin/true PATH="${fake_bin_dir}:$PATH" "$GAETA_BIN" doctor --verbose "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sandbox execution"* ]]
  [[ "$output" != *"--agent: invalid option"* ]]
}

@test "init scaffolds missing workflow files and unblocks resume" {
  local uninit_project="${TEST_ROOT}/uninitialized-project"
  mkdir -p "$uninit_project"

  run env HOME="$TEST_HOME" "$GAETA_BIN" resume --show "$uninit_project"
  [ "$status" -ne 0 ]
  [[ "$output" == *"requires an initialized gaeta project"* ]]
  [[ "$output" == *"gaeta init"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" init "$uninit_project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"initialized workflow files"* ]]

  run python3 - "$uninit_project" <<'PY'
import pathlib
import sys

project = pathlib.Path(sys.argv[1])
required = [
    "PROJECT.md",
    "GAETA.md",
    "docs/.gaeta/phases.md",
    "docs/.gaeta/status.md",
    "docs/.gaeta/checklist.md",
    "docs/.gaeta/backlog.md",
]
for rel in required:
    path = project / rel
    assert path.exists(), path
PY
  [ "$status" -eq 0 ]

  run env HOME="$TEST_HOME" "$GAETA_BIN" resume --show "$uninit_project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gaeta resume"* ]]
}

@test "resume and r show launch prompt context" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" resume --show "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gaeta resume"* ]]
  [[ "$output" == *"launch:"* ]]
  [[ "$output" == *"--agent plan"* ]]
  [[ "$output" == *"--prompt"* ]]
  [[ "$output" == *"continue from resume helper output"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" r --show "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gaeta resume"* ]]
}

@test "status shows phase next pending and blockers" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" status "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gaeta status"* ]]
  [[ "$output" == *"phase: Phase X"* ]]
  [[ "$output" == *"next step: Implement sync behavior."* ]]
  [[ "$output" == *"top pending sprint items:"* ]]
  [[ "$output" == *"- Implement sync behavior."* ]]
  [[ "$output" == *"- Add methodology-enforced instructions."* ]]
  [[ "$output" == *"blockers:"* ]]
  [[ "$output" == *"- none"* ]]
}

@test "resume prefers docs/.gaeta/pause.md context when present" {
  cat >"${TEST_PROJECT}/docs/.gaeta/pause.md" <<'MD'
# Pause

## Current phase

Phase 1

## Project update

- Wrapper projection rules aligned with current sprint.

## Conversation summary

- Decided to keep a single /pause command.

## Attempts and outcomes

- Attempted alias approach and rejected it to stay lean.

## Decisions

- Keep /pause as the canonical pause command.

## Frozen items

- No alias commands.

## Next step

Implement pause-first resume prompt parsing.

## Blockers

- none
MD

  run env HOME="$TEST_HOME" "$GAETA_BIN" resume --show "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Project update:"* ]]
  [[ "$output" == *"single /pause command"* ]]
  [[ "$output" == *"Frozen items:"* ]]
}

@test "resume does not use legacy handoff.md fallback" {
  cat >"${TEST_PROJECT}/docs/.gaeta/handoff.md" <<'MD'
# Handoff

## Project update

- LEGACY-HANDOFF-SENTINEL
MD

  run env HOME="$TEST_HOME" "$GAETA_BIN" resume --show "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"LEGACY-HANDOFF-SENTINEL"* ]]
  [[ "$output" == *"continue from resume helper output"* ]]
}

@test "tasks sync works without mdt and updates status" {
  run env HOME="$TEST_HOME" GAETA_TASKS_FORCE_FALLBACK=1 bash -lc "cd \"$TEST_PROJECT\" && \"$GAETA_BIN\" tasks sync"
  [ "$status" -eq 0 ]

  run python3 - "$TEST_PROJECT" <<'PY'
import pathlib
import sys

project = pathlib.Path(sys.argv[1])
status_text = (project / "docs" / ".gaeta" / "status.md").read_text(encoding="utf-8")
assert "## In progress" in status_text, status_text
assert "- Implement sync behavior." in status_text, status_text
assert "- Add methodology-enforced instructions." in status_text, status_text
assert "## Next step" in status_text, status_text
assert "Implement sync behavior." in status_text, status_text
PY
  [ "$status" -eq 0 ]
}

@test "pause writes pause snapshot and updates dashboard" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" pause "$TEST_PROJECT"
  [ "$status" -eq 0 ]

  run python3 - "$TEST_PROJECT" <<'PY'
import pathlib
import sys

project = pathlib.Path(sys.argv[1])
pause_text = (project / "docs" / ".gaeta" / "pause.md").read_text(encoding="utf-8")
project_text = (project / "PROJECT.md").read_text(encoding="utf-8")
session_log = (project / ".gaeta" / "session.log").read_text(encoding="utf-8")

assert "# Pause" in pause_text, pause_text
assert "## Current phase" in pause_text, pause_text
assert "Phase X" in pause_text, pause_text
assert "## Project update" in pause_text, pause_text
assert "Pending capture via /pause." in pause_text, pause_text
assert "## Top pending sprint items" in pause_text, pause_text
assert "Implement sync behavior." in pause_text, pause_text
assert "Add methodology-enforced instructions." in pause_text, pause_text

assert "## Next Step" in project_text, project_text
assert "Implement sync behavior." in project_text, project_text
assert "pause: synced status and wrote docs/.gaeta/pause.md" in session_log, session_log
PY
  [ "$status" -eq 0 ]
}

@test "pause slash command runs with build agent" {
  run python3 - "$REPO_ROOT/.opencode/commands/pause.md" <<'PY'
import pathlib
import sys

text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
assert "agent: build" in text, text
PY
  [ "$status" -eq 0 ]
}

@test "proposal workflow create approve reject works" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" proposal create "$TEST_PROJECT" "Build a terminal todo list MVP"
  [ "$status" -eq 0 ]

  proposal_path="$output"
  [[ "$proposal_path" == *"docs/.gaeta/proposals/"* ]]

  run python3 - "$proposal_path" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
assert "- Status: pending" in text, text
assert "## Summary" in text, text
assert "Pending capture via /propose." in text, text
PY
  [ "$status" -eq 0 ]

  run env HOME="$TEST_HOME" "$GAETA_BIN" proposal approve "$TEST_PROJECT" latest
  [ "$status" -eq 0 ]

  run python3 - "$output" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
assert "- Status: approved" in text, text
assert "approved via gaeta proposal approve" in text, text
PY
  [ "$status" -eq 0 ]

  run env HOME="$TEST_HOME" "$GAETA_BIN" proposal create "$TEST_PROJECT" "Implement a ping-pong score tracker"
  [ "$status" -eq 0 ]

  run env HOME="$TEST_HOME" "$GAETA_BIN" proposal reject "$TEST_PROJECT" latest "Need tighter validation"
  [ "$status" -eq 0 ]

  run python3 - "$output" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
assert "- Status: rejected" in text, text
assert "Need tighter validation" in text, text
PY
  [ "$status" -eq 0 ]
}

@test "slash command pack files have expected agent bindings" {
  run python3 - "$REPO_ROOT" <<'PY'
import pathlib
import sys
import json

repo = pathlib.Path(sys.argv[1])
commands = repo / ".opencode" / "commands"
agents_dir = repo / ".opencode" / "agents"
expected = {
    "pause.md": "agent: build",
    "review.md": "agent: review",
    "evolve.md": "agent: plan",
    "resume.md": "agent: plan",
    "status.md": "agent: plan",
}

for name, marker in expected.items():
    text = (commands / name).read_text(encoding="utf-8")
    assert marker in text, (name, marker)

config = json.loads((repo / "opencode.json").read_text(encoding="utf-8"))
for agent_name in ["plan", "build", "review"]:
    assert agent_name in config["agent"], agent_name
for removed in ["discovery", "orchestrator", "reviewer", "qa", "evolution", "architect", "implementer", "handoff-writer"]:
    assert removed not in config["agent"], removed

assert config["agent"]["plan"]["permission"]["bash"]["git status *"] == "allow", config
assert config["agent"]["build"]["permission"]["bash"]["git*"] == "deny", config

for agent_name in ["plan", "build", "review"]:
    path = agents_dir / f"{agent_name}.md"
    assert path.exists(), path
    assert path.read_text(encoding="utf-8").strip(), path
PY
  [ "$status" -eq 0 ]
}
