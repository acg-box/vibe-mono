---
type: Policy
title: Documentation Policy
description: Defines the repository OKF and LLM Wiki profile, lane ownership, update workflow, and validation gate.
status: active
authority: normative
owner: maintainers
last_verified: 2026-06-25
tags:
  - docs
  - okf
  - llm-wiki
  - template
source_refs: []
code_refs:
  - Makefile.toml
related:
  - index.md
  - log.md
  - decisions/docs-okf-template-foundation.md
  - evidence/docs-self-check.md
drift_watch:
  - docs/**
  - Makefile.toml
---

# Documentation Policy

Purpose: Define how agent-facing documentation is organized, updated, checked,
and inherited by repositories generated from this template.

Status: normative

Read this when: You are adding, moving, or updating documentation; deciding where
a claim belongs; or checking whether docs are ready.

Not this document: Product behavior contracts, validation procedures, current
layout details, or decision rationale. Use the lane indexes for those owners.

Defines:

- the repository OKF concept shape
- the LLM Wiki navigation rules
- the docs impact workflow
- the docs validation gate

## OKF Bundle Contract

`docs/` is the repository's strict Markdown OKF bundle and LLM Wiki root.

Required files and directories:

- `docs/index.md`
- `docs/policy.md`
- `docs/log.md`
- `docs/spec/index.md`
- `docs/runbook/index.md`
- `docs/reference/index.md`
- `docs/decisions/index.md`
- `docs/research/index.md`
- `docs/evidence/index.md`

Every populated directory must have an `index.md`. Non-index, non-log Markdown
files are OKF concepts and must start with YAML frontmatter delimited by `---`.

Every concept must include:

- `type`
- `title`
- `description`
- `status`
- `authority`
- `owner`
- `last_verified`

Allowed concept types:

- `Decision`
- `Drift Audit`
- `Evidence`
- `Policy`
- `Reference`
- `Research Contract`
- `Runbook`
- `Spec`

Allowed `status` values:

- `draft`
- `active`
- `deprecated`
- `superseded`

Allowed `authority` values:

- `normative`
- `procedural`
- `current_state`
- `rationale`
- `evidence`
- `non_authoritative`

Recommended fields:

- `tags`
- `source_refs`
- `code_refs`
- `related`
- `promotes_to`
- `drift_watch`

Structured field rules:

- `tags` and `drift_watch` must be lists of strings when present.
- `source_refs` must contain only `http` or `https` URLs.
- `code_refs` must contain existing normalized repository-relative file paths
  without fragments or query strings.
- `related` must contain Markdown file paths that are relative to the current
  concept or prefixed with `docs/`; the resolved target must stay inside
  `docs/`. Heading fragments are allowed, but the file path must still resolve.
- `promotes_to` may point only at `docs/spec`, `docs/runbook`,
  `docs/reference`, `docs/decisions`, or `docs/evidence`.

Spell the acronym `OKF` in prose. Use lowercase `okf` only in slugs, command
names, or identifiers.

## Lane Ownership

| Lane | Location | Answers | Source of truth for | Update trigger |
| --- | --- | --- | --- | --- |
| Policy | `docs/policy.md` | How should docs be shaped and checked? | OKF fields, lane rules, docs workflow | Any docs workflow or validation change |
| Spec | `docs/spec/` | What must be true? | Contracts, schemas, invariants, required behavior | Any behavior or schema change |
| Runbook | `docs/runbook/` | Which sequence should I execute? | Runbooks, migrations, validation, troubleshooting | Any procedure or operational change |
| Reference | `docs/reference/` | How is it currently organized or implemented? | Ownership maps and descriptive technical context | Any layout, ownership, or current-state explanation change |
| Decisions | `docs/decisions/` | Why was this tradeoff accepted? | Durable rationale and accepted consequences | Any accepted decision with long-lived consequences |
| Research | `docs/research/` | What is being evaluated but is not authoritative? | Latent proposals and research contracts | Any exploratory work that may later promote |
| Evidence | `docs/evidence/` | What proves or audits a claim? | Drift audits and public-safe evidence | Any docs/code/status/config drift audit |

## Placement Rules

- If a document defines correctness, put it in `docs/spec/`.
- If a document defines an execution sequence, put it in `docs/runbook/`.
- If a document explains current layout, ownership, defaults, or implementation
  shape without defining correctness, put it in `docs/reference/`.
- If a document records why a durable tradeoff was accepted, put it in
  `docs/decisions/`.
- If a document explores a candidate idea that is not yet authoritative, put it
  in `docs/research/`.
- If a document proves, audits, or reverse-checks a claim, put it in
  `docs/evidence/`.
- Do not duplicate authoritative content across documents. Link to the owning
  concept instead.
- A runbook may summarize why a step exists, but normative statements still live
  in the governing spec.

## Concept Headers

Each concept starts with OKF frontmatter and then a compact routing header.

Spec concepts include:

- `Purpose`
- `Status: normative`
- `Read this when`
- `Not this document`
- `Defines`

Runbook concepts include:

- `Goal`
- `Read this when`
- `Inputs` or `Preconditions`
- `Depends on`
- `Outputs` or `Verification`

Reference concepts include:

- `Purpose`
- `Read this when`
- `Inputs` or `Sources`
- `Depends on`
- `Covers`

Decision concepts include:

- `Status`
- `Date`
- `Context`
- `Decision`
- `Alternatives considered`
- `Consequences`

Research Contract concepts include:

- `Question`
- `Scope`
- `Evidence`
- `Options`
- `Judgment`
- `Challenge`
- `Decision`
- `Promotion`
- `Drift Impact`
- `Citations`

Drift Audit concepts include:

- `Watched Claims`
- `Evidence Anchors`
- `Reverse Checks`
- `Verdict`
- `Required Updates`
- `Citations`

## Docs Impact

Classify docs impact before claiming a change is ready:

- `none`: no docs, command, behavior, config, status, or workflow claim changed.
- `update_required`: update a durable concept in the owning lane.
- `research_required`: create or update a research contract before promotion.
- `drift_required`: create or update drift audit evidence.

Docs changes that alter routing, promotion, naming, or maintenance behavior must
update `docs/log.md`.

## Template Inheritance

Generated repositories should inherit this structure first, then replace
template-specific claims with project-specific owners:

- Replace `name_placeholder` and `description_placeholder` in public metadata,
  code, README, and docs.
- Replace `docs/spec/cli.md` when the generated project changes the CLI,
  runtime bootstrap, logging, or panic behavior.
- Keep the lane indexes and policy unless the generated repository has a better
  checked-in docs owner.
- Add real decisions only when a tradeoff needs to outlive commit history.
- Keep `docs/research/` non-authoritative until promotion is explicit.
- Keep `docs/evidence/` public-safe and free of secrets, credentials, or local
  machine-only data.

## Validation

Run the docs gate before claiming docs readiness:

```sh
decodex docs check
```

The repo-native wrapper is:

```sh
cargo make check-docs
```

For a full local sweep, use:

```sh
cargo make check
```

Treat docs check failure as a completion blocker for docs, policy, routing,
research, evidence, or OKF changes.
