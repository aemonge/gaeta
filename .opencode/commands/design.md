---
description: Artifact-first design workflow with local preview
agent: build
---
Goal:
- generate or update HTML design artifacts,
- preview via local artifact server,
- produce concise design review notes.

Default flow (no browser automation required):
1. write/update HTML under `.gaeta/artifacts/`.
2. run `/serve` or `gaeta serve`.
3. report local URL and changed artifact paths.
4. include visual review notes and next improvements.

If experimental profile is active and browser tooling is available, you may include optional browser automation notes, but do not require it.
