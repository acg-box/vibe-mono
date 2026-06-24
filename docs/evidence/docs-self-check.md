---
type: Drift Audit
title: Docs Self-Check Audit
description: Audits whether the docs bundle has the required OKF and LLM Wiki shape for this template.
status: active
authority: evidence
owner: maintainers
last_verified: 2026-06-25
tags:
  - docs
  - drift-audit
  - okf
source_refs: []
code_refs:
  - Makefile.toml
related:
  - ../index.md
  - ../policy.md
  - ../log.md
  - ../decisions/docs-okf-template-foundation.md
  - ../runbook/repo-checks.md
drift_watch:
  - docs/**
  - Makefile.toml
---

# Docs Self-Check Audit

## Watched Claims

- `docs/` is the repository LLM Wiki and strict OKF bundle.
- Every populated docs directory has an `index.md`.
- Non-index, non-log Markdown files are OKF concepts with required
  frontmatter.
- `docs/evidence/` includes at least one Drift Audit concept anchoring the docs
  self-check loop.
- `cargo make check-docs` runs the docs readiness gate.

## Evidence Anchors

- `docs/index.md` routes agents to policy, lane indexes, log, research, and
  evidence.
- `docs/policy.md` defines concept fields, lane ownership, docs impact, and the
  validation gate.
- `Makefile.toml` defines `check-docs` as the repo-native wrapper for
  `decodex docs check`.
- `docs/log.md` records the template docs foundation change.

## Reverse Checks

- Run `decodex docs check` after docs, policy, evidence, research, or routing
  changes.
- Run `cargo make check-docs` to verify the repo-native wrapper.
- Inspect `docs/log.md` when navigation, promotion, rename, or docs maintenance
  behavior changes.

## Verdict

pass

## Required Updates

- Update this audit when the docs profile, docs check command, or evidence lane
  contract changes.
- Add a new drift audit when a specific docs/code/config/status claim needs
  narrower proof.

## Citations

- `docs/index.md`
- `docs/policy.md`
- `docs/log.md`
- `Makefile.toml`
