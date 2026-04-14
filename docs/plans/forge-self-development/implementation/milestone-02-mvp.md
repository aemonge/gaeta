# Milestone 2: OpenCode Wrapper (MVP)

## Goal
A functional CLI tool that can delegate coding tasks to OpenCode within a secure sandbox.

## Implementation Details

### T2.1 - OpenCode Integration
- Use `std::process::Command` to invoke `/usr/bin/opencode`.
- Pass task description via the `--file tasks.txt` flag.
- Stream output to terminal for real-time visibility.

### T2.2 - Security Sandbox
- Implement `bwrap` command generation.
- Allowed zones:
  - RO: `/usr`, `/lib`, `/bin`, `/etc`.
  - RW: `/home/scoder/workspace` (limited to current session).
- Block network access during build phase.

### T2.3 - Logging
- Generate session ID.
- Create `.forge/logs/{session}.log`.
- Log all commands sent to OpenCode and their resulting stdout/stderr.
