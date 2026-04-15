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
  "nested": {
    "from_base": true,
    "overridden": "base"
  }
}
JSON

  cat >"${TEST_HOME}/.config/gaeta/opencode.json" <<'JSON'
{
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

projected_config = json.loads((project / ".gaeta" / "projection" / "opencode.json").read_text(encoding="utf-8"))
projected_tui = json.loads((project / ".gaeta" / "projection" / "tui.json").read_text(encoding="utf-8"))

assert projected_config["base_only"] == "from_opencode", projected_config
assert projected_config["gaeta_only"] == "from_gaeta", projected_config
assert projected_config["nested"]["from_base"] is True, projected_config
assert projected_config["nested"]["overridden"] == "gaeta", projected_config

assert projected_tui["theme"] == "gaeta", projected_tui
assert projected_tui["keybinds"]["open"] == "ctrl+o", projected_tui
assert projected_tui["keybinds"]["quit"] == "ctrl+q", projected_tui
PY

  [ "$status" -eq 0 ]
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

@test "resume prefers docs/.gaeta/handoff.md context when present" {
  cat >"${TEST_PROJECT}/docs/.gaeta/handoff.md" <<'MD'
# Handoff

## Current phase

Phase 1

## Project update

- Wrapper projection rules aligned with current sprint.

## Conversation summary

- Decided to keep a single /handoff command with no aliases.

## Attempts and outcomes

- Attempted alias approach and rejected it to stay lean.

## Decisions

- Keep /handoff as the canonical handoff entrypoint.

## Frozen items

- No alias commands.

## Next step

Implement handoff-first resume prompt parsing.

## Blockers

- none
MD

  run env HOME="$TEST_HOME" "$GAETA_BIN" resume --show "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Project update:"* ]]
  [[ "$output" == *"single /handoff command with no aliases"* ]]
  [[ "$output" == *"Frozen items:"* ]]
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

@test "handoff writes handoff snapshot and updates dashboard" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" handoff "$TEST_PROJECT"
  [ "$status" -eq 0 ]

  run python3 - "$TEST_PROJECT" <<'PY'
import pathlib
import sys

project = pathlib.Path(sys.argv[1])
handoff_text = (project / "docs" / ".gaeta" / "handoff.md").read_text(encoding="utf-8")
project_text = (project / "PROJECT.md").read_text(encoding="utf-8")
session_log = (project / ".gaeta" / "session.log").read_text(encoding="utf-8")

assert "# Handoff" in handoff_text, handoff_text
assert "## Current phase" in handoff_text, handoff_text
assert "Phase X" in handoff_text, handoff_text
assert "## Project update" in handoff_text, handoff_text
assert "Pending capture via /handoff." in handoff_text, handoff_text
assert "## Top pending sprint items" in handoff_text, handoff_text
assert "Implement sync behavior." in handoff_text, handoff_text
assert "Add methodology-enforced instructions." in handoff_text, handoff_text

assert "## Next Step" in project_text, project_text
assert "Implement sync behavior." in project_text, project_text
assert "handoff: synced status and wrote docs/.gaeta/handoff.md" in session_log, session_log
PY
  [ "$status" -eq 0 ]
}

@test "handoff slash command runs with build agent" {
  run python3 - "$REPO_ROOT/.opencode/commands/handoff.md" <<'PY'
import pathlib
import sys

text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
assert "agent: build" in text, text
PY
  [ "$status" -eq 0 ]
}
