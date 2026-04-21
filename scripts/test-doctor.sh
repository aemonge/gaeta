#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAETA_BIN="${REPO_ROOT}/gaeta"
FIXTURE_ROOT="${REPO_ROOT}/tests/fixtures"

[[ -x "$GAETA_BIN" ]] || printf '%s\n' "missing executable: ${GAETA_BIN}" >&2
[[ -x "$GAETA_BIN" ]] || exit 1

TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEST_ROOT}"' EXIT

TEST_HOME="${TEST_ROOT}/home"
TEST_PROJECT="${TEST_ROOT}/project"

mkdir -p "${TEST_HOME}/.config"
cp -R "${FIXTURE_ROOT}/config/opencode" "${TEST_HOME}/.config/opencode"
cp -R "${FIXTURE_ROOT}/config/gaeta" "${TEST_HOME}/.config/gaeta"
cp -R "${FIXTURE_ROOT}/project/." "${TEST_PROJECT}/"

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

FAKE_LAUNCH_BIN_DIR="${TEST_ROOT}/fake-launch-bin"
mkdir -p "$FAKE_LAUNCH_BIN_DIR"
cat >"${FAKE_LAUNCH_BIN_DIR}/bwrap" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  printf '%s\n' "bubblewrap mock --disable-userns"
  exit 0
fi

printf '%s\n' "GAETA_BWRAP_EXECUTED"
exit 0
SH
chmod +x "${FAKE_LAUNCH_BIN_DIR}/bwrap"

LAUNCH_NOT_PARANOID_OUTPUT="$(HOME="$TEST_HOME" OPENCODE_BIN=/bin/true PATH="${FAKE_LAUNCH_BIN_DIR}:$PATH" "$GAETA_BIN" --not-paranoid "$TEST_PROJECT")"
[[ "$LAUNCH_NOT_PARANOID_OUTPUT" == *"GAETA_BWRAP_EXECUTED"* ]]

FAKE_NO_LANDRUN_BIN_DIR="${TEST_ROOT}/fake-no-landrun-bin"
mkdir -p "$FAKE_NO_LANDRUN_BIN_DIR"
cat >"${FAKE_NO_LANDRUN_BIN_DIR}/bwrap" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  printf '%s\n' "bubblewrap mock --disable-userns"
  exit 0
fi

printf '%s\n' "GAETA_BWRAP_UNEXPECTED"
exit 0
SH
chmod +x "${FAKE_NO_LANDRUN_BIN_DIR}/bwrap"

set +e
LAUNCH_REQUIRE_LANDLOCK_OUTPUT="$(HOME="$TEST_HOME" OPENCODE_BIN=/bin/true PATH="${FAKE_NO_LANDRUN_BIN_DIR}:/bin" "$GAETA_BIN" --require-landlock "$TEST_PROJECT" 2>&1)"
LAUNCH_REQUIRE_LANDLOCK_STATUS=$?
set -e
[[ "$LAUNCH_REQUIRE_LANDLOCK_STATUS" -ne 0 ]]
[[ "$LAUNCH_REQUIRE_LANDLOCK_OUTPUT" != *"GAETA_BWRAP_UNEXPECTED"* ]]

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
GO_ONE_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT")"
GO_TWO_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT")"
GO_THREE_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT")"
GO_SHOW_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" go --show "$TEST_PROJECT")"
GO_AGENT_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" go --show --format agent "$TEST_PROJECT")"

mkdir -p "$TEST_PROJECT/.gaeta"
cat >"$TEST_PROJECT/.gaeta/go-cycle.json" <<'JSON'
not-json
JSON
GO_RECOVER_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT")"

git -C "$TEST_PROJECT" init >/dev/null
git -C "$TEST_PROJECT" add .
git -C "$TEST_PROJECT" -c user.name=gaeta -c user.email=gaeta@example.com commit -m "init" >/dev/null
GO_POST_INIT_ONE="$(HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT")"
GO_POST_INIT_TWO="$(HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT")"
cat >"$TEST_PROJECT/docs/.gaeta/head-reset-note.md" <<'MD'
head reset trigger
MD
git -C "$TEST_PROJECT" add .
git -C "$TEST_PROJECT" -c user.name=gaeta -c user.email=gaeta@example.com commit -m "advance" >/dev/null
GO_HEAD_RESET_OUTPUT="$(HOME="$TEST_HOME" "$GAETA_BIN" go "$TEST_PROJECT")"
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

python3 - "$TEST_PROJECT" "$proposal_one" "$proposal_two" "$REPO_ROOT" "$STATUS_OUTPUT" "$BACKUP_PATH" "$GO_ONE_OUTPUT" "$GO_TWO_OUTPUT" "$GO_THREE_OUTPUT" "$GO_SHOW_OUTPUT" "$GO_AGENT_OUTPUT" "$GO_RECOVER_OUTPUT" "$GO_POST_INIT_ONE" "$GO_POST_INIT_TWO" "$GO_HEAD_RESET_OUTPUT" <<'PY'
import json
import pathlib
import sys

project = pathlib.Path(sys.argv[1])
proposal_one = pathlib.Path(sys.argv[2])
proposal_two = pathlib.Path(sys.argv[3])
repo_root = pathlib.Path(sys.argv[4])
status_output = sys.argv[5]
backup_dir = pathlib.Path(sys.argv[6])
go_one_output = sys.argv[7]
go_two_output = sys.argv[8]
go_three_output = sys.argv[9]
go_show_output = sys.argv[10]
go_agent_output = sys.argv[11]
go_recover_output = sys.argv[12]
go_post_init_one = sys.argv[13]
go_post_init_two = sys.argv[14]
go_head_reset_output = sys.argv[15]
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
assert "selected role: plan" in go_one_output, go_one_output
assert "next role in cycle: build" in go_one_output, go_one_output
assert "selected role: build" in go_two_output, go_two_output
assert "next role in cycle: review" in go_two_output, go_two_output
assert "selected role: review" in go_three_output, go_three_output
assert "next role in cycle: plan" in go_three_output, go_three_output
assert "gaeta go" in go_show_output, go_show_output
assert "selected role:" in go_show_output, go_show_output
assert "validation commands before /review:" not in go_show_output, go_show_output
assert "validation commands before /review:" in go_agent_output, go_agent_output
assert "make lint && make test" in go_agent_output, go_agent_output
assert "selected role: plan" in go_recover_output, go_recover_output
assert "selected role: build" in go_post_init_one, go_post_init_one
assert "selected role: review" in go_post_init_two, go_post_init_two
assert "selected role: plan" in go_head_reset_output, go_head_reset_output
assert "rotation note: reset to plan because git HEAD changed." in go_head_reset_output, go_head_reset_output

cycle_payload = json.loads((project / ".gaeta" / "go-cycle.json").read_text(encoding="utf-8"))
assert cycle_payload["schema_version"] == 1, cycle_payload
assert "last_head" in cycle_payload, cycle_payload
assert "go: recovered cycle state to safe defaults" in session_log, session_log
assert "go: reset rotation to plan after git HEAD change" in session_log, session_log
assert "# Pause" in pause_text, pause_text
assert "Phase X" in pause_text, pause_text
assert "## /go cycle" in pause_text, pause_text
assert "selected role: plan" in pause_text, pause_text
assert "next role in cycle: build" in pause_text, pause_text
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
    "go.md": "agent: plan",
    "review.md": "agent: review",
    "evolve.md": "agent: plan",
    "resume.md": "agent: plan",
    "status.md": "agent: plan",
}
for name, marker in expected.items():
    text = (commands_dir / name).read_text(encoding="utf-8")
    assert marker in text, (name, marker)
    assert "~/.config/gaeta/bin/gaeta" in text, name

evolve_text = (commands_dir / "evolve.md").read_text(encoding="utf-8")
assert "native OpenCode semantics first (`/approve` / `/reject`)" in evolve_text, evolve_text
assert "fallback commands: `gaeta proposal approve . latest`" in evolve_text, evolve_text

review_text = (commands_dir / "review.md").read_text(encoding="utf-8")
assert "Suggested commit:" in review_text, review_text
assert "Conventional Commit" in review_text, review_text
assert "sandbox/bubblewrap visibility prevents direct verification" in review_text, review_text
assert "host-side verification commands" in review_text, review_text
assert "Workflow writeback rule:" in review_text, review_text
assert "must add it to `docs/.gaeta/checklist.md` or `docs/.gaeta/backlog.md`" in review_text, review_text

pause_text = (commands_dir / "pause.md").read_text(encoding="utf-8")
assert "host-side verification is required" in pause_text, pause_text

review_agent_text = (agents_dir / "review.md").read_text(encoding="utf-8")
assert "do not claim direct verification" in review_agent_text, review_agent_text
assert "write it into `docs/.gaeta/checklist.md` or `docs/.gaeta/backlog.md`" in review_agent_text, review_agent_text

build_agent_text = (agents_dir / "build.md").read_text(encoding="utf-8")
assert "host-side verification commands" in build_agent_text, build_agent_text

config_sample = (repo_root / "docs" / "config-sample.md").read_text(encoding="utf-8")
assert "~/.config/opencode/opencode.json" in config_sample, config_sample
assert "~/.config/gaeta/opencode.json" in config_sample, config_sample
assert ".gaeta/projection/opencode.json" in config_sample, config_sample

architecture_text = (repo_root / "docs" / "architecture.md").read_text(encoding="utf-8")
assert "docs/config-sample.md" in architecture_text, architecture_text
assert "Projection safety matrix (gaeta policy)" in architecture_text, architecture_text
assert "mirror-only" in architecture_text, architecture_text
assert "Linux/macOS portability notes" in architecture_text, architecture_text
assert "GAETA_DOCTOR_SKIP_SANDBOX=1 ./gaeta doctor --verbose ." in architecture_text, architecture_text

project_text = (repo_root / "PROJECT.md").read_text(encoding="utf-8")
assert "Linux/macOS portability notes are documented in `docs/architecture.md`." in project_text, project_text

gaeta_text = (repo_root / "GAETA.md").read_text(encoding="utf-8")
assert "Default build-agent behavior keeps practical validation commands enabled" in gaeta_text, gaeta_text
assert "`gaeta backup` remains supported (not deprecated)" in gaeta_text, gaeta_text
assert "Strict-repo override example" in gaeta_text, gaeta_text
assert "Defer deprecation unless there is a validated replacement" in gaeta_text, gaeta_text

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
