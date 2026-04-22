# Fence Wishlist (Deferred)

## Purpose

Capture a future sandbox portability option without changing current gaeta runtime behavior.

## Current default

- Keep Linux-first backend unchanged: bubblewrap (`bwrap`) + optional Landlock via `landrun`.
- Treat Fence as deferred exploration, not active implementation.

## Revisit triggers

- macOS support becomes an active product priority.
- Linux backend maintenance burden materially increases.
- Operator demand for unified cross-platform sandbox policy increases.

## Decision gates before any default switch

- Parity checklist passes for launch, doctor, status, resume, go, and pause flows.
- Dependency review passes for `fence` and `socat` in local + CI environments.
- Rollback path is documented and validated (rapid return to current backend).
- Threat model language remains accurate after backend changes.

## Out of scope now

- No runtime/backend code changes.
- No default backend changes.
- No removal of `bwrap`/`landrun` path.
