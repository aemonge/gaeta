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
# status
MD

cat >"${TEST_PROJECT}/docs/.gaeta/checklist.md" <<'MD'
# checklist
MD

cat >"${TEST_PROJECT}/docs/.gaeta/backlog.md" <<'MD'
# backlog
MD

DOCTOR_JSON_PATH="${TEST_ROOT}/doctor.json"

HOME="$TEST_HOME" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 "$GAETA_BIN" doctor --json "$TEST_PROJECT" >"$DOCTOR_JSON_PATH"

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

projection_file = project / ".gaeta" / "projection" / "opencode.json"
projection_tui = project / ".gaeta" / "projection" / "tui.json"

projected_config = json.loads(projection_file.read_text(encoding="utf-8"))
projected_tui = json.loads(projection_tui.read_text(encoding="utf-8"))

assert projected_config["base_only"] == "from_opencode", projected_config
assert projected_config["gaeta_only"] == "from_gaeta", projected_config
assert projected_config["nested"]["from_base"] is True, projected_config
assert projected_config["nested"]["overridden"] == "gaeta", projected_config

assert projected_tui["theme"] == "gaeta", projected_tui
assert projected_tui["keybinds"]["open"] == "ctrl+o", projected_tui
assert projected_tui["keybinds"]["quit"] == "ctrl+q", projected_tui

print("doctor json and config inheritance tests passed")
PY
