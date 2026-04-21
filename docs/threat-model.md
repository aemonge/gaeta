# Threat Model

## Scope

This document defines the security threat model for gaeta as it exists today: a
wrapper around OpenCode with projection, sandbox orchestration, and
documentation-first workflow controls.

In scope:

- Wrapper launch path (`./gaeta`) and argument forwarding.
- Config and projection materialization under `./.gaeta/projection/`.
- Workflow state artifacts under `./docs/.gaeta/` and runtime metadata under
  `./.gaeta/`.
- Agent command/permission boundaries defined through projected config.

Out of scope:

- Physical host compromise.
- Upstream LLM provider compromise.
- Malicious behavior explicitly approved by the human operator.

## Security Objectives

- Protect host system integrity from agent-driven or prompt-driven misuse.
- Minimize blast radius to repository-local paths.
- Preserve workflow artifact integrity (`status.md`, `checklist.md`, `backlog.md`,
  `pause.md`) as the source of operational truth.
- Prevent silent drift between configured policy and projected runtime policy.

## Assets

- Project source code and local secrets in repository files.
- Workflow control-plane files in `docs/.gaeta/`.
- Runtime metadata and projection artifacts in `./.gaeta/`.
- Operator trust in reported state (`gaeta status`, `gaeta doctor`, `/go` role
  rotation state).

## Trust Boundaries

1. Human operator boundary
   - Trusted to approve operations and evaluate suggested changes.
2. Agent/runtime boundary
   - Untrusted model output constrained by configured permissions and wrapper
     controls.
3. Host OS boundary
   - Linux sandbox features (`bwrap`, optional `landrun`) provide primary
     isolation where available.
4. External provider boundary
   - LLM/search/network providers are external systems and not trusted for data
     confidentiality by default.

## Assumptions

- Linux receives strongest isolation guarantees; macOS support is functional but
  has reduced sandbox parity.
- Bubblewrap and optional Landlock may be unavailable or partially constrained
  in some environments.
- Operators retain final approval responsibility for commits and risky changes.

## Threats and Mitigations

## T1: Unauthorized host filesystem modification

- Scenario: generated or malicious commands attempt writes outside project scope.
- Primary controls:
  - Bubblewrap filesystem isolation in wrapper flow (Linux).
  - Mirror-only projection into repo-local `.gaeta/projection/` (no symlink
    projection).
  - Agent permission model with explicit allow/deny and minimal shared deny set.
- Residual risk:
  - Reduced protection on platforms/environments without equivalent namespace
    isolation.

## T2: Policy bypass through projection drift or stale artifacts

- Scenario: projected config does not reflect intended merged policy, enabling
  unexpected agent capability.
- Primary controls:
  - Deterministic mirror projection policy.
  - `gaeta doctor` checks for projection artifacts and projected config
    consistency.
  - Runtime projection manifest (`.gaeta/projection/projection.json`).
- Residual risk:
  - Manual edits to generated artifacts between checks can create temporary drift
    until next doctor/run.

## T3: Workflow state tampering or accidental corruption

- Scenario: status/checklist/rotation state is altered or corrupted, causing
  incorrect handoff and unsafe role assumptions.
- Primary controls:
  - Documentation-first control plane with explicit phase/status/checklist files.
  - `/go` cycle-state hardening and self-healing behavior.
  - Backup flow under `docs/.gaeta/backups/`.
- Residual risk:
  - Intentional repository tampering by a user with write access remains in
    scope of human review, not technical prevention.

## T4: Unsafe command execution by agents

- Scenario: model output attempts destructive or privilege-escalating commands.
- Primary controls:
  - Global deny baseline for known destructive/system escape patterns.
  - Per-agent allowlists with fallback ask behavior.
  - Build agent restriction on `git*` to preserve human-in-the-loop repo control.
- Residual risk:
  - Unknown command forms may still require strong operator review when surfaced
    via fallback ask paths.

## T5: Data exfiltration to external services

- Scenario: sensitive content leaks through networked tools/providers.
- Primary controls:
  - Linux-first sandbox model supports stronger runtime containment where
    available.
  - Operator-controlled provider/network usage.
  - Local artifact persistence by default for workflow memory.
- Residual risk:
  - Any enabled external provider receives submitted prompt/context payloads.

## T6: Denial-of-service via resource exhaustion or environment limits

- Scenario: nested sandbox checks or workloads fail because of host constraints
  (for example namespace limits).
- Primary controls:
  - Doctor checks surface sandbox failures and partial validation state.
  - Explicit operator guidance for constrained environments
    (`GAETA_DOCTOR_SKIP_SANDBOX=1`).
- Residual risk:
  - In constrained environments, runtime assurance is partially reduced and must
    be acknowledged operationally.

## Non-goals and Accepted Risks

- gaeta does not attempt to protect against a malicious or compromised human
  operator.
- gaeta does not guarantee confidentiality against all external LLM/provider
  paths when networked tools are used.
- gaeta does not provide identical sandbox guarantees across all operating
  systems.

## Verification

Recommended checks after security-relevant changes:

- `make lint`
- `make test`
- `./gaeta doctor --verbose .`

When namespace constraints prevent nested sandbox validation:

- `GAETA_DOCTOR_SKIP_SANDBOX=1 ./gaeta doctor --verbose .`

## Maintenance

- Update this document whenever wrapper isolation, projection policy, permission
  policy, or workflow control-plane semantics change.
- Keep `docs/architecture.md` as a high-level pointer and maintain this file as
  the detailed threat-model source of truth.
