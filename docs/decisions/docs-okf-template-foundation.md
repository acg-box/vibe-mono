---
type: Decision
title: Docs OKF Template Foundation
description: Records why the template repository uses a strict docs-backed OKF and LLM Wiki profile.
status: active
authority: rationale
owner: maintainers
last_verified: 2026-06-25
tags:
  - docs
  - okf
  - llm-wiki
  - template
source_refs: []
related:
  - ../policy.md
  - ../index.md
  - ../runbook/template-adoption.md
  - ../evidence/docs-self-check.md
drift_watch:
  - docs/policy.md
  - docs/index.md
---

# Docs OKF Template Foundation

Status: accepted

Date: 2026-06-25

Context: This repository is a template intended to seed future repositories. A
template README alone does not preserve enough implementation context for agents
to route work, distinguish normative claims from procedures, or verify docs
shape after the project grows.

Decision: Treat `docs/` as the repository LLM Wiki and strict Markdown OKF
bundle. Keep lane indexes, concept frontmatter, maintenance logs, and drift
evidence in the template so generated repositories inherit a working knowledge
structure instead of adding one later.

Alternatives considered:

- README-only guidance:
  simpler at first, but forces agents to infer ownership from prose and commit
  history.
- A separate `wiki/` or `okf/` tree:
  makes the knowledge layer visible, but splits authority away from checked-in
  repository docs.
- Strict docs-backed OKF:
  adds a small amount of frontmatter and index maintenance, but creates a
  checkable owner model from the first commit.

Consequences:

- New docs concepts need OKF frontmatter.
- `docs/log.md` records routing, promotion, rename, and maintenance changes.
- `docs/evidence/` carries public-safe drift audits.
- `cargo make check-docs` is the local docs readiness gate.
- Generated repositories should update or replace template concepts when their
  real contracts diverge.
