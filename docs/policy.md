# Documentation Policy

Purpose: Define how agent-facing documentation is organized, updated, and kept consistent
across this repository.

Audience: All documentation under `docs/` is written for AI agents and LLM workflows.
The split between `spec`, `runbook`, `reference`, and `decisions` is by task shape, not by
reader type.

## Principles

- Optimize for retrieval, routing, and execution.
- Keep one authoritative document per topic.
- Separate normative truth, execution steps, descriptive current-state reference, and durable
  design rationale.
- Prefer explicit section labels and stable links over prose-heavy narrative.
- Let structure emerge from real topics. Avoid premature folder taxonomies.

## Document classes

| Class | Location | Answers | Source of truth for | Update trigger |
| --- | --- | --- | --- | --- |
| Spec | `docs/spec/` | What must be true? | Contracts, schemas, invariants, required behavior | Any behavior or schema change |
| Runbook | `docs/runbook/` | Which sequence should I execute? | Runbooks, migrations, validation, troubleshooting | Any procedure or operational change |
| Reference | `docs/reference/` | How is it currently organized or implemented? | Ownership maps, implementation-model notes, non-normative technical context | Any layout, ownership, or current-implementation explanation change |
| Decisions | `docs/decisions/` | Why was this tradeoff accepted? | Durable rationale for accepted technical or product choices | Any accepted decision with long-lived consequences |

## Placement rules

- If a document defines correctness, it belongs in `docs/spec/`.
- If a document defines an execution sequence, it belongs in `docs/runbook/`.
- If a document explains current layout, ownership, defaults, or implementation shape without
  defining correctness, it belongs in `docs/reference/`.
- If a document records why a durable tradeoff was accepted, which alternatives were considered,
  and what consequences follow from that choice, it belongs in `docs/decisions/`.
- Do not duplicate the same authoritative content across documents. Link to the source
  of truth instead.
- A runbook may summarize why a step exists, but normative statements still live in the
  governing spec.

## Document contracts

Every document should start with a short routing header.

Spec header:

- `Purpose`
- `Status: normative`
- `Read this when`
- `Not this document`
- `Defines`

Runbook header:

- `Goal`
- `Read this when`
- `Inputs` or `Preconditions`
- `Depends on`
- `Outputs` or `Verification`

Reference header:

- `Purpose`
- `Read this when`
- `Inputs` or `Sources`
- `Depends on`
- `Covers`

Decision header:

- `Status`
- `Date`
- `Context`
- `Decision`
- `Alternatives considered`
- `Consequences`

## Structure rules

- Prefer shallow paths by default.
- Add subfolders only when they mirror stable system boundaries or improve retrieval.
- Prefer descriptive kebab-case file names for tracked Markdown documents.
- Prefer stable subject names over phase labels, version labels, or document-status labels.
- Let the parent directory carry the document class; filenames should carry the topic.
- Keep existing file paths stable unless a rename materially improves retrieval or removes
  ambiguity.
- Do not require fixed filename prefixes unless a real ambiguity appears.
- Do not create empty folders, empty indexes, or placeholder documents to satisfy a
  taxonomy.

## Canonical entry points

- Unified documentation router: `docs/index.md`
- Normative router: `docs/spec/index.md`
- Procedural router: `docs/runbook/index.md`
- Descriptive router: `docs/reference/index.md`
- Decision router: `docs/decisions/index.md`
- Repo task and automation entrypoints: `Makefile.toml`

## LLM reading guidance

When answering a repository question:

1. Read `docs/index.md` for routing.
2. Route by question type:
   - "What must be true?" -> `docs/spec/index.md`
   - "Which sequence should I execute?" -> `docs/runbook/index.md`
   - "How is it currently organized or implemented?" -> `docs/reference/index.md`
   - "Why was this tradeoff accepted?" -> `docs/decisions/index.md`
3. Read `Makefile.toml` when the task depends on repository automation or named tasks.

## Update workflow

- Behavior or schema change: update the relevant spec.
- Procedure change: update the relevant runbook.
- Layout, ownership, or current-implementation explanation change: update the relevant reference.
- Durable accepted tradeoff change: add or update the relevant decision record.
- If a change touches both truth and procedure, update both documents and keep their
  boundary explicit.
- If a change touches truth plus descriptive context, update both the spec and the reference.
- When a runbook starts carrying normative content, move that content into spec and link
  to it.
- When a runbook starts carrying mostly descriptive context instead of executable steps, move that
  content into reference and keep only the runbook in `docs/runbook/`.
