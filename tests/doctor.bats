#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  GAETA_BIN="${REPO_ROOT}/gaeta"
  FIXTURE_ROOT="${REPO_ROOT}/tests/fixtures"

  TEST_ROOT="$(mktemp -d)"
  TEST_HOME="${TEST_ROOT}/home"
  TEST_PROJECT="${TEST_ROOT}/project"

  mkdir -p "${TEST_HOME}/.config"
  cp -R "${FIXTURE_ROOT}/config/opencode" "${TEST_HOME}/.config/opencode"
  cp -R "${FIXTURE_ROOT}/config/gaeta" "${TEST_HOME}/.config/gaeta"

  cp -R "${FIXTURE_ROOT}/project/." "${TEST_PROJECT}/"
}

teardown() {
  rm -rf "$TEST_ROOT"
}

@test "doctor --json includes populated checks and merged config" {
  local json_path="${TEST_ROOT}/doctor.json"

  HOME="$TEST_HOME" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 GAETA_TTY_MODE=compat \
    "$GAETA_BIN" doctor --no-strict --json "$TEST_PROJECT" >"$json_path"

  run python3 - "$json_path" "$TEST_PROJECT" <<'PY'
import json
import pathlib
import sys

doctor_path = pathlib.Path(sys.argv[1])
project = pathlib.Path(sys.argv[2])
payload = json.loads(doctor_path.read_text(encoding="utf-8"))

assert payload["summary"]["fail"] == 0, payload
assert payload["status"] in {"ok", "warn"}, payload

checks = payload["checks"]
for key in [
    "dependencies",
    "config_sources",
    "directory_sources",
    "projection_artifacts",
    "sandbox_check",
    "workflow_files",
    "safety_checks",
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
assert projection_rows["opencode monitor local-only"]["status"] == "ok", projection_rows
assert "localhost" in projection_rows["opencode monitor local-only"]["details"], projection_rows
assert projection_rows["projected plugin"]["status"] == "ok", projection_rows

projected_config = json.loads((project / ".gaeta" / "projection" / "opencode.json").read_text(encoding="utf-8"))
projected_tui = json.loads((project / ".gaeta" / "projection" / "tui.json").read_text(encoding="utf-8"))

assert projected_config["base_only"] == "from_opencode", projected_config
assert projected_config["gaeta_only"] == "from_gaeta", projected_config
assert projected_config["server"]["hostname"] == "localhost", projected_config
assert projected_config["nested"]["from_base"] is True, projected_config
assert projected_config["nested"]["overridden"] == "gaeta", projected_config
assert "plan" in projected_config["agent"], projected_config
assert "build" in projected_config["agent"], projected_config
assert projected_config["agent"]["review"]["permission"]["edit"] == "deny", projected_config

assert projected_tui["theme"] == "gaeta", projected_tui
assert projected_tui["keybinds"]["open"] == "ctrl+o", projected_tui
assert projected_tui["keybinds"]["quit"] == "ctrl+q", projected_tui

projected_plugin = project / ".gaeta" / "projection" / "plugin" / "opencode-monitor.js"
assert projected_plugin.exists(), projected_plugin
PY

  [ "$status" -eq 0 ]
}

@test "doctor warns when monitor local-only server mode is not configured" {
  local disabled_home="${TEST_ROOT}/home-disabled"
  mkdir -p "${disabled_home}/.config"
  cp -R "${FIXTURE_ROOT}/config/opencode" "${disabled_home}/.config/opencode"
  cp -R "${FIXTURE_ROOT}/config/gaeta" "${disabled_home}/.config/gaeta"

  run python3 - "${disabled_home}/.config/gaeta/opencode.json" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
payload = json.loads(path.read_text(encoding="utf-8"))
payload.pop("server", None)
path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
PY
  [ "$status" -eq 0 ]

  local json_path="${TEST_ROOT}/doctor-monitor-warn.json"
  HOME="$disabled_home" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 GAETA_TTY_MODE=compat \
    "$GAETA_BIN" doctor --no-strict --json "$TEST_PROJECT" >"$json_path"

  run python3 - "$json_path" <<'PY'
import json
import pathlib
import sys

payload = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
projection_rows = {row["label"]: row for row in payload["checks"]["projection_artifacts"]}
monitor_row = projection_rows["opencode monitor local-only"]

assert payload["status"] == "warn", payload
assert monitor_row["status"] == "warn", monitor_row
assert "server.hostname=localhost" in monitor_row["details"], monitor_row
assert "OPENCODE_SERVER_HOST=127.0.0.1" in monitor_row["details"], monitor_row
PY
  [ "$status" -eq 0 ]
}

@test "doctor human output is quiet by default and expanded with --verbose" {
  run env HOME="$TEST_HOME" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 "$GAETA_BIN" doctor --no-strict "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gaeta doctor"* ]]
  [[ "$output" == *"summary:"* ]]
  [[ "$output" != *"Dependencies"* ]]

  run env HOME="$TEST_HOME" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 "$GAETA_BIN" doctor --no-strict --verbose "$TEST_PROJECT"
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

  run env HOME="$TEST_HOME" OPENCODE_BIN=/bin/true PATH="${fake_bin_dir}:$PATH" "$GAETA_BIN" doctor --no-strict --verbose "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sandbox execution"* ]]
  [[ "$output" != *"--agent: invalid option"* ]]
}

@test "launch --not-paranoid executes bubblewrap path" {
  local fake_bin_dir="${TEST_ROOT}/fake-launch-bin"
  mkdir -p "$fake_bin_dir"

  cat >"${fake_bin_dir}/bwrap" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  printf '%s\n' "bubblewrap mock --disable-userns"
  exit 0
fi

printf '%s\n' "GAETA_BWRAP_EXECUTED"
exit 0
SH
  chmod +x "${fake_bin_dir}/bwrap"

  run env HOME="$TEST_HOME" OPENCODE_BIN=/bin/true PATH="${fake_bin_dir}:$PATH" \
    "$GAETA_BIN" --not-paranoid "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"GAETA_BWRAP_EXECUTED"* ]]
}

@test "launch --require-landlock fails when landrun missing" {
  local fake_bin_dir="${TEST_ROOT}/fake-no-landrun-bin"
  mkdir -p "$fake_bin_dir"

  cat >"${fake_bin_dir}/bwrap" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  printf '%s\n' "bubblewrap mock --disable-userns"
  exit 0
fi

printf '%s\n' "GAETA_BWRAP_UNEXPECTED"
exit 0
SH
  chmod +x "${fake_bin_dir}/bwrap"

  run env HOME="$TEST_HOME" OPENCODE_BIN=/bin/true PATH="${fake_bin_dir}:/bin" \
    "$GAETA_BIN" --require-landlock "$TEST_PROJECT"
  [ "$status" -ne 0 ]
  [[ "$output" != *"GAETA_BWRAP_UNEXPECTED"* ]]
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
  [[ "$output" == *"profile: recommended"* ]]
  [[ "$output" == *"gaeta profile sync"* ]]

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
    ".mcp.json.example",
    ".gaeta/profile.json",
    "opencode.json",
    ".gaeta/profile.lock.json",
    ".opencode/gaeta.generated.json",
    ".opencode/gaeta-profile.md",
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

@test "init accepts explicit profiles and profile command reports active profile" {
  local profile_project="${TEST_ROOT}/profile-project"
  mkdir -p "$profile_project"

  run env HOME="$TEST_HOME" "$GAETA_BIN" init --profile minimal "$profile_project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"profile: minimal"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" profile "$profile_project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"active: minimal"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" profile set experimental "$profile_project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"active: experimental"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" profile "$profile_project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"active: experimental"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" profile list
  [ "$status" -eq 0 ]
  [[ "$output" == *"minimal"* ]]
  [[ "$output" == *"recommended"* ]]
  [[ "$output" == *"experimental"* ]]
}

@test "profile sync dry-run previews without writing lockfile" {
  local sync_project="${TEST_ROOT}/sync-dry-run-project"
  mkdir -p "$sync_project"
  run env HOME="$TEST_HOME" "$GAETA_BIN" init --profile recommended --no-install "$sync_project"
  [ "$status" -eq 0 ]

  cat >"$sync_project/opencode.json" <<'JSON'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "opencode-monitor"
  ]
}
JSON

  local before_hash
  before_hash="$(
    python3 - "$sync_project/opencode.json" <<'PY'
import hashlib
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
print(hashlib.sha256(path.read_bytes()).hexdigest())
PY
  )"

  run env HOME="$TEST_HOME" "$GAETA_BIN" profile sync --dry-run "$sync_project"
  [ "$status" -eq 0 ]
  [[ "$output" == *"mode: dry-run"* ]]
  [[ "$output" == *"missing expected:"* ]]
  [[ "$output" == *"next: gaeta profile sync --install"* ]]

  local after_hash
  after_hash="$(
    python3 - "$sync_project/opencode.json" <<'PY'
import hashlib
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
print(hashlib.sha256(path.read_bytes()).hexdigest())
PY
  )"

  [ "$before_hash" = "$after_hash" ]

  [ ! -f "$sync_project/.gaeta/profile.lock.json" ]
  [ ! -f "$sync_project/.opencode/gaeta.generated.json" ]
}

@test "profile sync writes lockfile and generated profile context" {
  cat >"$TEST_PROJECT/opencode.json" <<'JSON'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "opencode-monitor"
  ]
}
JSON

  run env HOME="$TEST_HOME" "$GAETA_BIN" profile sync "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"mode: sync"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" profile sync --install "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"note: restart OpenCode for plugin changes to load"* ]]
  [[ "$output" == *"unresolved manual installs:"* ]]

  run python3 - "$TEST_PROJECT" <<'PY'
import json
import pathlib
import sys

project = pathlib.Path(sys.argv[1])
lock_path = project / ".gaeta" / "profile.lock.json"
generated_json = project / ".opencode" / "gaeta.generated.json"
generated_md = project / ".opencode" / "gaeta-profile.md"

assert lock_path.exists(), lock_path
assert generated_json.exists(), generated_json
assert generated_md.exists(), generated_md

payload = json.loads(lock_path.read_text(encoding="utf-8"))
assert payload["profile"] == "recommended", payload
expected = set(payload["plugins"]["expected_ids"])
assert "ocx" in expected, expected
assert "envsitter-guard" in expected, expected
assert "opencode-ignore" in expected, expected
assert "openspec" in expected, expected
assert "plannotator" in expected, expected
assert "micode" in expected, expected
assert "opencode-agents" in expected, expected
assert "notify" in expected, expected
assert "opencode-browser" not in expected, expected
assert "opencode-skills" not in expected, expected

policy_blocked = set(payload["policy"]["blocked_plugin_ids"])
for blocked in ["google-ai-search", "telegram-bot", "swarm-plugin", "agent-of-empires", "devcontainers"]:
    assert blocked in policy_blocked, payload

project_config = json.loads((project / "opencode.json").read_text(encoding="utf-8"))
specs = project_config["plugin"]
assert "opencode-monitor" in specs, specs
assert "opencode-plugin-openspec" in specs, specs
assert "@plannotator/opencode" in specs, specs
assert "micode" in specs, specs
assert "opencode-notify" in specs, specs
assert "opencode-ignore" in specs, specs

manual_ids = set(payload["plugins"]["manual_ids"])
assert "envsitter-guard" in manual_ids, manual_ids
assert "opencode-agents" in manual_ids, manual_ids

missing_ids = set(payload["plugins"]["missing_ids"])
assert "opencode-ignore" not in missing_ids, missing_ids

generated = json.loads(generated_json.read_text(encoding="utf-8"))
assert generated["gaeta"]["profile"] == "recommended", generated
PY
  [ "$status" -eq 0 ]
}

@test "profile sync supports experimental and minimal policy boundaries" {
  local exp_project="${TEST_ROOT}/sync-exp-project"
  mkdir -p "$exp_project"
  run env HOME="$TEST_HOME" "$GAETA_BIN" init --profile experimental "$exp_project"
  [ "$status" -eq 0 ]

  run env HOME="$TEST_HOME" "$GAETA_BIN" profile sync "$exp_project"
  [ "$status" -eq 0 ]

  run env HOME="$TEST_HOME" "$GAETA_BIN" profile sync --install "$exp_project"
  [ "$status" -eq 0 ]

  run python3 - "$exp_project/.gaeta/profile.lock.json" <<'PY'
import json
import pathlib
import sys

payload = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
expected = set(payload["plugins"]["expected_ids"])
for plugin in [
    "opencode-browser",
    "opencode-skills",
    "froggy",
    "opencode-mem",
    "opencode-roadmap",
    "opencode-sessions",
    "opencode-canvas",
    "opencode-agent-tmux",
]:
    assert plugin in expected, (plugin, expected)

specs = set(payload["plugins"]["configured_specs"])
assert "opencode-agent-browser" in specs, specs
assert "opencode-mem" in specs, specs
PY
  [ "$status" -eq 0 ]

  local min_project="${TEST_ROOT}/sync-min-project"
  mkdir -p "$min_project"
  run env HOME="$TEST_HOME" "$GAETA_BIN" init --profile minimal "$min_project"
  [ "$status" -eq 0 ]
  run env HOME="$TEST_HOME" "$GAETA_BIN" profile sync "$min_project"
  [ "$status" -eq 0 ]

  run python3 - "$min_project/.gaeta/profile.lock.json" <<'PY'
import json
import pathlib
import sys

payload = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
assert payload["profile"] == "minimal", payload
assert payload["plugins"]["expected_ids"] == [], payload
PY
  [ "$status" -eq 0 ]
}

@test "profile sync --no-notify skips optional notify projection" {
  local no_notify_project="${TEST_ROOT}/sync-no-notify-project"
  mkdir -p "$no_notify_project"
  run env HOME="$TEST_HOME" "$GAETA_BIN" init --profile recommended --no-install "$no_notify_project"
  [ "$status" -eq 0 ]

  run env HOME="$TEST_HOME" "$GAETA_BIN" profile sync --install --no-notify "$no_notify_project"
  [ "$status" -eq 0 ]

  run python3 - "$no_notify_project/opencode.json" "$no_notify_project/.gaeta/profile.lock.json" <<'PY'
import json
import pathlib
import sys

project_config = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
assert "opencode-notify" not in project_config.get("plugin", []), project_config

lock_payload = json.loads(pathlib.Path(sys.argv[2]).read_text(encoding="utf-8"))
assert "notify" in lock_payload["plugins"]["optional_skipped_ids"], lock_payload
PY
  [ "$status" -eq 0 ]
}

@test "serve lifecycle uses localhost and artifacts root" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" serve "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: running"* ]]
  [[ "$output" == *"host: 127.0.0.1"* ]]
  [[ "$output" == *"root: $TEST_PROJECT/.gaeta/artifacts"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" serve status "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gaeta serve"* ]]
  [[ "$output" == *"host: 127.0.0.1"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" serve stop "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: stopped"* ]]
}

@test "doctor strict fails on warnings" {
  local strict_home="${TEST_ROOT}/strict-home"
  mkdir -p "${strict_home}/.config"
  cp -R "${FIXTURE_ROOT}/config/opencode" "${strict_home}/.config/opencode"
  cp -R "${FIXTURE_ROOT}/config/gaeta" "${strict_home}/.config/gaeta"

  run python3 - "${strict_home}/.config/gaeta/opencode.json" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
payload = json.loads(path.read_text(encoding="utf-8"))
payload.pop("server", None)
path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
PY
  [ "$status" -eq 0 ]

  run env HOME="$strict_home" "$GAETA_BIN" profile sync --install "$TEST_PROJECT"
  [ "$status" -eq 0 ]

  run env HOME="$strict_home" OPENCODE_BIN=/bin/true GAETA_DOCTOR_SKIP_SANDBOX=1 "$GAETA_BIN" doctor --strict "$TEST_PROJECT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"unresolved:"* ]]
}

@test "status shows phase next pending and blockers" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" profile sync "$TEST_PROJECT"
  [ "$status" -eq 0 ]

  run env HOME="$TEST_HOME" "$GAETA_BIN" status "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gaeta status"* ]]
  [[ "$output" == *"gaeta profile: recommended"* ]]
  [[ "$output" == *"direnv mode: off"* ]]
  [[ "$output" == *"artifact server:"* ]]
  [[ "$output" == *"sem status:"* ]]
  [[ "$output" == *"expected profile plugins:"* ]]
  [[ "$output" == *"missing profile plugins:"* ]]
  [[ "$output" == *"next suggested command:"* ]]
  [[ "$output" == *"phase: Phase X"* ]]
  [[ "$output" == *"next step: Implement sync behavior."* ]]
  [[ "$output" == *"top pending sprint items:"* ]]
  [[ "$output" == *"- Implement sync behavior."* ]]
  [[ "$output" == *"- Add methodology-enforced instructions."* ]]
  [[ "$output" == *"blockers:"* ]]
  [[ "$output" == *"- none"* ]]
}

@test "go rotates plan build review cycle" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"selected role: plan"* ]]
  [[ "$output" == *"next role in cycle: build"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"selected role: build"* ]]
  [[ "$output" == *"next role in cycle: review"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"selected role: review"* ]]
  [[ "$output" == *"next role in cycle: plan"* ]]
}

@test "go supports show mode" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" go --show "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gaeta go"* ]]
  [[ "$output" == *"selected role:"* ]]
  [[ "$output" != *"validation commands before /review:"* ]]
}

@test "go agent format includes validation commands" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" go --show --format agent "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"validation commands before /review:"* ]]
  [[ "$output" == *"make lint && make test"* ]]
}

@test "go recovers from corrupted cycle state and resets on git head change" {
  mkdir -p "$TEST_PROJECT/.gaeta"
  cat >"$TEST_PROJECT/.gaeta/go-cycle.json" <<'JSON'
not-json
JSON

  run env HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"selected role: plan"* ]]

  run python3 - "$TEST_PROJECT/.gaeta/go-cycle.json" "$TEST_PROJECT/.gaeta/session.log" <<'PY'
import json
import pathlib
import sys

cycle = pathlib.Path(sys.argv[1])
session_log = pathlib.Path(sys.argv[2])
payload = json.loads(cycle.read_text(encoding="utf-8"))
assert payload["schema_version"] == 1, payload
assert payload["last_agent"] == "plan", payload
assert "go: recovered cycle state to safe defaults" in session_log.read_text(encoding="utf-8")
PY
  [ "$status" -eq 0 ]

  run git -C "$TEST_PROJECT" init
  [ "$status" -eq 0 ]
  run git -C "$TEST_PROJECT" add .
  [ "$status" -eq 0 ]
  run git -C "$TEST_PROJECT" -c user.name=gaeta -c user.email=gaeta@example.com commit -m "init"
  [ "$status" -eq 0 ]

  run env HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"selected role: build"* ]]

  run env HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"selected role: review"* ]]

  cat >"$TEST_PROJECT/docs/.gaeta/head-reset-note.md" <<'MD'
head reset trigger
MD
  run git -C "$TEST_PROJECT" add .
  [ "$status" -eq 0 ]
  run git -C "$TEST_PROJECT" -c user.name=gaeta -c user.email=gaeta@example.com commit -m "advance"
  [ "$status" -eq 0 ]

  run env HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"selected role: plan"* ]]
  [[ "$output" == *"rotation note: reset to plan because git HEAD changed."* ]]
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
assert "## /go cycle" in pause_text, pause_text
assert "selected role: plan" in pause_text, pause_text
assert "next role in cycle: build" in pause_text, pause_text

assert "## Next Step" in project_text, project_text
assert "Implement sync behavior." in project_text, project_text
assert "pause: synced status and wrote docs/.gaeta/pause.md" in session_log, session_log
PY
  [ "$status" -eq 0 ]
}

@test "backup writes hard-save backup and excludes runtime artifacts" {
  run env HOME="$TEST_HOME" "$GAETA_BIN" backup "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  local backup_path="${output##*$'\n'}"
  [[ "$backup_path" == *"docs/.gaeta/backups/backup-"* ]]

  run python3 - "$backup_path" "$TEST_PROJECT" <<'PY'
import pathlib
import sys

backup_dir = pathlib.Path(sys.argv[1])
project = pathlib.Path(sys.argv[2])

required = [
    "PROJECT.md",
    "GAETA.md",
    "docs/.gaeta/phases.md",
    "docs/.gaeta/status.md",
    "docs/.gaeta/checklist.md",
    "docs/.gaeta/backlog.md",
]
for rel in required:
    path = backup_dir / rel
    assert path.exists(), path

manifest = (backup_dir / "manifest.md").read_text(encoding="utf-8")
assert "do not assume direct host-home visibility" in manifest, manifest
assert "## Excluded runtime artifacts" in manifest, manifest
for rel in [
    ".gaeta/phase",
    ".gaeta/command.json",
    ".gaeta/session.log",
    ".gaeta/approval.log",
    ".gaeta/projection/",
]:
    assert rel in manifest, manifest

assert not (backup_dir / ".gaeta" / "session.log").exists(), backup_dir
assert not (backup_dir / ".gaeta" / "projection").exists(), backup_dir

session_log = (project / ".gaeta" / "session.log").read_text(encoding="utf-8")
assert "backup: wrote docs/.gaeta/backups/backup-" in session_log, session_log
PY
  [ "$status" -eq 0 ]
}

@test "backup requires initialized project" {
  local uninit_project="${TEST_ROOT}/backup-uninitialized"
  mkdir -p "$uninit_project"

  run env HOME="$TEST_HOME" "$GAETA_BIN" backup "$uninit_project"
  [ "$status" -ne 0 ]
  [[ "$output" == *"requires an initialized gaeta project"* ]]
  [[ "$output" == *"gaeta init"* ]]
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
    "brainstorm.md": "agent: plan",
    "plan.md": "agent: plan",
    "build.md": "agent: build",
    "doctor.md": "agent: review",
    "serve.md": "agent: build",
    "design.md": "agent: build",
    "handoff.md": "agent: plan",
    "pause.md": "agent: build",
    "go.md": "agent: plan",
    "review.md": "agent: review",
    "evolve.md": "agent: plan",
    "resume.md": "agent: plan",
    "status.md": "agent: plan",
}

for name, marker in expected.items():
    text = (commands / name).read_text(encoding="utf-8")
    assert marker in text, (name, marker)

for name in ["pause.md", "go.md", "review.md", "evolve.md", "resume.md", "status.md", "doctor.md", "serve.md"]:
    text = (commands / name).read_text(encoding="utf-8")
    assert "1. `gaeta` from PATH." in text, name
    assert "2. `./gaeta` when present in current project root." in text, name
    assert "~/.config/gaeta/bin/gaeta" in text, name

evolve_text = (commands / "evolve.md").read_text(encoding="utf-8")
assert "native OpenCode semantics first (`/approve` / `/reject`)" in evolve_text, evolve_text
assert "fallback commands: `gaeta proposal approve . latest`" in evolve_text, evolve_text

review_text = (commands / "review.md").read_text(encoding="utf-8")
assert "Suggested commit:" in review_text, review_text
assert "Conventional Commit" in review_text, review_text
assert "changed-symbol observations" in review_text, review_text
assert "sandbox/bubblewrap visibility prevents direct verification" in review_text, review_text
assert "host-side verification commands" in review_text, review_text
assert "Workflow writeback rule:" in review_text, review_text
assert "must add it to `docs/.gaeta/checklist.md` or `docs/.gaeta/backlog.md`" in review_text, review_text

status_text = (commands / "status.md").read_text(encoding="utf-8")
assert "profile sync --dry-run" in status_text, status_text
assert "Gaeta cockpit snapshot" in status_text, status_text
assert "gaeta profile" in status_text, status_text
assert "artifact server status" in status_text, status_text
assert "sem status/freshness" in status_text, status_text

doctor_text = (commands / "doctor.md").read_text(encoding="utf-8")
assert "doctor --strict" in doctor_text, doctor_text
assert "profile sync --dry-run" in doctor_text, doctor_text
assert "profile sync --install" in doctor_text, doctor_text

plan_text = (commands / "plan.md").read_text(encoding="utf-8")
assert "Sem/AST context" in plan_text, plan_text
assert "sem-based outline/diff" in plan_text, plan_text

design_text = (commands / "design.md").read_text(encoding="utf-8")
assert "no browser automation required" in design_text, design_text

handoff_text = (commands / "handoff.md").read_text(encoding="utf-8")
assert "current profile" in handoff_text, handoff_text
assert "sem observations" in handoff_text, handoff_text

pause_text = (commands / "pause.md").read_text(encoding="utf-8")
assert "host-side verification is required" in pause_text, pause_text
assert "continue without invoking gaeta" in pause_text, pause_text
assert "update `docs/.gaeta/pause.md` directly" in pause_text, pause_text

review_agent_text = (agents_dir / "review.md").read_text(encoding="utf-8")
assert "do not claim direct verification" in review_agent_text, review_agent_text
assert "write it into `docs/.gaeta/checklist.md` or `docs/.gaeta/backlog.md`" in review_agent_text, review_agent_text

build_agent_text = (agents_dir / "build.md").read_text(encoding="utf-8")
assert "host-side verification commands" in build_agent_text, build_agent_text

config_sample = (repo / "docs" / "config-sample.md").read_text(encoding="utf-8")
assert "~/.config/opencode/opencode.json" in config_sample, config_sample
assert "~/.config/gaeta/opencode.json" in config_sample, config_sample
assert ".gaeta/projection/opencode.json" in config_sample, config_sample

architecture_text = (repo / "docs" / "architecture.md").read_text(encoding="utf-8")
assert "docs/config-sample.md" in architecture_text, architecture_text
assert "Projection safety matrix (gaeta policy)" in architecture_text, architecture_text
assert "mirror-only" in architecture_text, architecture_text
assert "Linux/macOS portability notes" in architecture_text, architecture_text
assert "GAETA_DOCTOR_SKIP_SANDBOX=1 ./gaeta doctor --verbose ." in architecture_text, architecture_text

for rel in [
    "docs/opencode-integration.md",
    "docs/opencode-profiles.md",
    "docs/opencode-plugins.md",
    "docs/artifacts.md",
]:
    path = repo / rel
    assert path.exists(), path

project_text = (repo / "PROJECT.md").read_text(encoding="utf-8")
assert "Linux/macOS portability notes are documented in `docs/architecture.md`." in project_text, project_text

gaeta_text = (repo / "GAETA.md").read_text(encoding="utf-8")
assert "Default build-agent behavior keeps practical validation commands enabled" in gaeta_text, gaeta_text
assert "`gaeta backup` remains supported (not deprecated)" in gaeta_text, gaeta_text
assert "Strict-repo override example" in gaeta_text, gaeta_text
assert "Defer deprecation unless there is a validated replacement" in gaeta_text, gaeta_text
assert "## Operator Role Matrix" in gaeta_text, gaeta_text
assert "Lost-context recovery" in gaeta_text, gaeta_text
assert "no deprecation window" in gaeta_text, gaeta_text

config = json.loads((repo / "opencode.json").read_text(encoding="utf-8"))
for agent_name in ["plan", "build", "review"]:
    assert agent_name in config["agent"], agent_name
for removed in ["discovery", "orchestrator", "reviewer", "qa", "evolution", "architect", "implementer", "handoff-writer"]:
    assert removed not in config["agent"], removed

assert config["agent"]["plan"]["permission"]["bash"]["git status *"] == "allow", config
assert config["agent"]["plan"]["permission"]["todowrite"] == "deny", config
assert config["agent"]["build"]["permission"]["bash"]["git*"] == "deny", config
build_bash = config["agent"]["build"]["permission"]["bash"]
for removed in ["python", "python *", "cargo", "cargo *", "go", "go *", "npm", "npm *"]:
    assert removed not in build_bash, removed

for agent_name in ["plan", "build", "review"]:
    path = agents_dir / f"{agent_name}.md"
    assert path.exists(), path
    assert path.read_text(encoding="utf-8").strip(), path
PY
  [ "$status" -eq 0 ]
}
