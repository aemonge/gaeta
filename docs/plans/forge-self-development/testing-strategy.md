# Testing Strategy - forge Self-Development

## Overview

Due to the agentic and non-deterministic nature of the project, we prioritize **End-to-End (E2E) testing** and **Dogfooding** over granular unit tests in the early phases.

## Testing Layers

### 1. Dogfooding (Primary)
The core test for forge is its ability to build forge. Once Milestone 2 is complete, we will use forge to implement Milestone 3 and beyond.

### 2. E2E Tests
Automated tests in `tests/e2e_tests.rs` that:
- Execute the `forge` binary.
- Verify file generation in expected directories.
- Check exit codes and basic stdout/stderr patterns.

### 3. Comparative Testing (forge+OpenCode vs. Raw OpenCode)
We compare forge output against raw OpenCode output for the same prompt to measure the "Orchestration Premium".

**Key Metrics:**
- **Lines of Code (LOC)**: Measure volume vs. quality (aim for concise, effective code).
- **Compile Success Rate**: Percentage of generated solutions that compile without manual intervention.
- **Test Coverage**: Percentage of generated logic covered by generated tests.
- **Clippy Warning Count**: Number of lints triggered by generated code (target: 0).
- **Architecture Cleanliness**: Subjective review of module boundaries and adherence to patterns.

### 4. Regression Testing
As we implement native Rust features to replace OpenCode (Phase 13), we will use existing OpenCode-generated features as the baseline for regression tests.

## Continuous Validation

The Makefile includes security and quality gates that must pass for every commit:
- `make lint`: Clippy and format checks.
- `make audit`: Security vulnerability scan.
- `make deny`: Dependency policy check.
