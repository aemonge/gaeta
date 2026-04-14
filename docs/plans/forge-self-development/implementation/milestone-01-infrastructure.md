# Milestone 1: Build Infrastructure

## Goal
Set up a professional Rust development environment with automated quality and security checks.

## Implementation Details

### T1.1 - Project Skeleton
Create `Cargo.toml` with:
- Strict linting rules.
- Dependencies: `clap`, `serde`, `tokio`, `anyhow`, `thiserror`.
- Workspace configuration.

### T1.2 - Makefile
Targets required:
- `setup`: Install audit and deny tools.
- `lint`: Comprehensive check (fmt + clippy + audit + deny).
- `test-all`: Run lib and E2E tests.
- `build-release`: Optimized binary.

### T1.3 - Git Hooks
Scripts in `.githooks/`:
- `pre-commit`: Runs `make fmt-check` and `make lint`.
- `pre-push`: Runs `make test-all`.

### T1.4 - Woodpecker CI
Config in `.woodpecker.yml`:
- Pipeline mirroring the git hooks for server-side validation.

### T1.5 - CLI Skeleton
Basic `clap` parsing for:
- `forge build "task"`
- `forge discover "feature"`
- `forge status`
- `forge doctor`
- `forge init`

### T1.9 - Session Branding
- Implement a `Context` struct that handles active session identification.
- Use `colored` or `ansiterm` crate for ANSI color support.
- Color palettes:
  - **Solarized Light**: Blue (#268bd2), Green (#859900), Orange (#cb4b16).
  - **Gruvbox**: Aqua (#8ec07c), Purple (#d3869b), Yellow (#fabd2f).
- Logic: `[forge:session-name]` printed at the start of all operations.
- Background highlighting for critical warnings or when explicitly configured to enhance visibility.
