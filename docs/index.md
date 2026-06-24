# Documentation Index

Purpose: Route agents to the smallest correct document set for the current task.

Audience: All documentation in this repository is written for AI agents and LLM
workflows. The `docs/` tree is both the repository LLM Wiki and the strict OKF
bundle; do not create a parallel `wiki/` or `okf/` root for repository knowledge.

## Read Order

1. Read `README.md` for the public project shape and template placeholders.
2. Read `docs/policy.md` for OKF concept rules, lane ownership, and docs gates.
3. Read `Makefile.toml` when the task depends on repo task names or execution
   entrypoints.
4. Choose one primary lane index, then the smallest owning concept.

## Lane Router

| Need | Read |
| --- | --- |
| Documentation shape, OKF fields, promotion, or update rules | `docs/policy.md` |
| Required behavior, contracts, schemas, state, or invariants | `docs/spec/index.md` |
| Repeatable procedures, validation, migration, or troubleshooting | `docs/runbook/index.md` |
| Current layout, ownership, implementation shape, or template placeholders | `docs/reference/index.md` |
| Durable rationale for an accepted tradeoff | `docs/decisions/index.md` |
| Latent ideas, research questions, or not-yet-authoritative proposals | `docs/research/index.md` |
| Drift audits, public-safe proof, or docs self-check evidence | `docs/evidence/index.md` |
| Routing, promotion, rename, or maintenance history | `docs/log.md` |

## Current Owners

- `docs/policy.md` owns the repository documentation profile.
- `docs/spec/cli.md` owns the default CLI and runtime bootstrap contract.
- `docs/runbook/repo-checks.md` owns local validation commands.
- `docs/runbook/template-adoption.md` owns the sequence for deriving a real
  repository from this template.
- `docs/reference/workspace-layout.md` owns the current layout map and
  template-local path boundaries.
- `docs/decisions/docs-okf-template-foundation.md` records why this template uses
  a strict docs-backed OKF/LLM Wiki profile.
- `docs/evidence/docs-self-check.md` records the latest docs self-check audit.

## Retrieval Rules

- Optimize for agent routing and execution, not narrative flow.
- Keep one authoritative concept per claim. Link instead of copying.
- Start each concept with OKF frontmatter plus a short routing header.
- Keep links explicit and stable.
- Keep `docs/research/` non-authoritative until a concept is promoted.
- Record navigation, promotion, rename, and maintenance changes in `docs/log.md`.
- Run `decodex docs check` or `cargo make check-docs` before claiming docs
  readiness.
