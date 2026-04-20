#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAETA_BIN="${REPO_ROOT}/gaeta"

if [[ ! -x "$GAETA_BIN" ]]; then
  echo "missing executable: ${GAETA_BIN}" >&2
  exit 1
fi

TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEST_ROOT}"' EXIT

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

## In progress

- Implement sync behavior.

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

DOCTOR_JSON_PATH="${TEST_ROOT}/doctor.json"

HOME="$TEST_HOME" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 GAETA_TTY_MODE=compat "$GAETA_BIN" doctor --json "$TEST_PROJECT" >"$DOCTOR_JSON_PATH"

python3 - "$DOCTOR_JSON_PATH" "$TEST_PROJECT" <<'PY'
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

projection_file = project / ".gaeta" / "projection" / "opencode.json"
projection_tui = project / ".gaeta" / "projection" / "tui.json"

projected_config = json.loads(projection_file.read_text(encoding="utf-8"))
projected_tui = json.loads(projection_tui.read_text(encoding="utf-8"))

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

print("doctor json and config inheritance tests passed")
PY

DOCTOR_HUMAN_OUTPUT="$(HOME="$TEST_HOME" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 "$GAETA_BIN" doctor "$TEST_PROJECT")"
[[ "$DOCTOR_HUMAN_OUTPUT" == *"gaeta doctor"* ]]
[[ "$DOCTOR_HUMAN_OUTPUT" == *"summary:"* ]]
[[ "$DOCTOR_HUMAN_OUTPUT" != *"Dependencies"* ]]

DOCTOR_VERBOSE_OUTPUT="$(HOME="$TEST_HOME" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 "$GAETA_BIN" doctor --verbose "$TEST_PROJECT")"
[[ "$DOCTOR_VERBOSE_OUTPUT" == *"Dependencies"* ]]
[[ "$DOCTOR_VERBOSE_OUTPUT" == *"Summary"* ]]

UNINIT_PROJECT="${TEST_ROOT}/uninitialized-project"
mkdir -p "$UNINIT_PROJECT"

set +e
UNINIT_RESUME_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" resume --show "$UNINIT_PROJECT" 2>&1)"
UNINIT_RESUME_STATUS=$?
set -e
[[ "$UNINIT_RESUME_STATUS" -ne 0 ]]
[[ "$UNINIT_RESUME_OUTPUT" == *"requires an initialized gaeta project"* ]]
[[ "$UNINIT_RESUME_OUTPUT" == *"gaeta init"* ]]

HOME="$TEST_HOME" "$GAETA_BIN" init "$UNINIT_PROJECT" >/dev/null

python3 - "$UNINIT_PROJECT" <<'PY'
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

HOME="$TEST_HOME" "$GAETA_BIN" resume --show "$UNINIT_PROJECT" >/dev/null

cat >"${TEST_PROJECT}/docs/.gaeta/handoff.md" <<'MD'
# Handoff

## Project update

- LEGACY-HANDOFF-SENTINEL
MD

LEGACY_RESUME_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" resume --show "$TEST_PROJECT")"
[[ "$LEGACY_RESUME_OUTPUT" != *"LEGACY-HANDOFF-SENTINEL"* ]]
[[ "$LEGACY_RESUME_OUTPUT" == *"continue from resume helper output"* ]]

HOME="$TEST_HOME" GAETA_TASKS_FORCE_FALLBACK=1 bash -lc "cd \"$TEST_PROJECT\" && \"$GAETA_BIN\" tasks sync"
STATUS_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" status "$TEST_PROJECT")"
HOME="$TEST_HOME" "$GAETA_BIN" pause "$TEST_PROJECT"
BACKUP_PATH="$(HOME="$TEST_HOME" "$GAETA_BIN" backup "$TEST_PROJECT")"
proposal_one="$(HOME="$TEST_HOME" "$GAETA_BIN" proposal create "$TEST_PROJECT" "Build a terminal todo list MVP")"
HOME="$TEST_HOME" "$GAETA_BIN" proposal approve "$TEST_PROJECT" latest >/dev/null
proposal_two="$(HOME="$TEST_HOME" "$GAETA_BIN" proposal create "$TEST_PROJECT" "Implement a ping-pong score tracker")"
HOME="$TEST_HOME" "$GAETA_BIN" proposal reject "$TEST_PROJECT" latest "Need tighter validation" >/dev/null

UNINIT_BACKUP_PROJECT="${TEST_ROOT}/backup-uninitialized"
mkdir -p "$UNINIT_BACKUP_PROJECT"
set +e
UNINIT_BACKUP_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" backup "$UNINIT_BACKUP_PROJECT" 2>&1)"
UNINIT_BACKUP_STATUS=$?
set -e
[[ "$UNINIT_BACKUP_STATUS" -ne 0 ]]
[[ "$UNINIT_BACKUP_OUTPUT" == *"requires an initialized gaeta project"* ]]
[[ "$UNINIT_BACKUP_OUTPUT" == *"gaeta init"* ]]

python3 - "$TEST_PROJECT" "$proposal_one" "$proposal_two" "$REPO_ROOT" "$STATUS_OUTPUT" "$BACKUP_PATH" <<'PY'
import json
import pathlib
import sys

project = pathlib.Path(sys.argv[1])
proposal_one = pathlib.Path(sys.argv[2])
proposal_two = pathlib.Path(sys.argv[3])
repo_root = pathlib.Path(sys.argv[4])
status_output = sys.argv[5]
backup_dir = pathlib.Path(sys.argv[6])
status_text = (project / "docs" / ".gaeta" / "status.md").read_text(encoding="utf-8")
pause_text = (project / "docs" / ".gaeta" / "pause.md").read_text(encoding="utf-8")
project_text = (project / "PROJECT.md").read_text(encoding="utf-8")
session_log = (project / ".gaeta" / "session.log").read_text(encoding="utf-8")
proposal_one_text = proposal_one.read_text(encoding="utf-8")
proposal_two_text = proposal_two.read_text(encoding="utf-8")
manifest_text = (backup_dir / "manifest.md").read_text(encoding="utf-8")

assert "## In progress" in status_text, status_text
assert "Implement sync behavior." in status_text, status_text
assert "Add methodology-enforced instructions." in status_text, status_text
assert "gaeta status" in status_output, status_output
assert "phase: Phase X" in status_output, status_output
assert "next step: Implement sync behavior." in status_output, status_output
assert "blockers:" in status_output, status_output
assert "- none" in status_output, status_output
assert "# Pause" in pause_text, pause_text
assert "Phase X" in pause_text, pause_text
assert "## Next Step" in project_text, project_text
assert "pause: synced status and wrote docs/.gaeta/pause.md" in session_log, session_log
assert "backup: wrote docs/.gaeta/backups/backup-" in session_log, session_log

required_backup = [
    "PROJECT.md",
    "GAETA.md",
    "docs/.gaeta/phases.md",
    "docs/.gaeta/status.md",
    "docs/.gaeta/checklist.md",
    "docs/.gaeta/backlog.md",
]
for rel in required_backup:
    assert (backup_dir / rel).exists(), rel

assert "do not assume direct host-home visibility" in manifest_text, manifest_text
assert "## Excluded runtime artifacts" in manifest_text, manifest_text
assert not (backup_dir / ".gaeta" / "session.log").exists(), backup_dir
assert not (backup_dir / ".gaeta" / "projection").exists(), backup_dir

assert "- Status: approved" in proposal_one_text, proposal_one_text
assert "approved via gaeta proposal approve" in proposal_one_text, proposal_one_text
assert "- Status: rejected" in proposal_two_text, proposal_two_text
assert "Need tighter validation" in proposal_two_text, proposal_two_text

commands_dir = repo_root / ".opencode" / "commands"
agents_dir = repo_root / ".opencode" / "agents"
expected = {
    "pause.md": "agent: build",
    "review.md": "agent: review",
    "evolve.md": "agent: plan",
    "resume.md": "agent: plan",
    "status.md": "agent: plan",
}
for name, marker in expected.items():
    text = (commands_dir / name).read_text(encoding="utf-8")
    assert marker in text, (name, marker)

review_text = (commands_dir / "review.md").read_text(encoding="utf-8")
assert "Suggested commit:" in review_text, review_text
assert "Conventional Commit" in review_text, review_text

config = json.loads((repo_root / "opencode.json").read_text(encoding="utf-8"))
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

print("tasks sync and pause tests passed")
PY
