# Decisions Index

Purpose: Route agents to durable rationale documents that explain why an
accepted technical or product tradeoff was chosen and what consequences follow.

Question this index answers: "why was this tradeoff accepted?"

## Use This Index When

- You need the reasoning behind an accepted architecture or product decision.
- You need to understand which alternatives were considered and rejected.
- You need long-lived context before revisiting or superseding an earlier
  choice.

## Do Not Use This Index When

- You need the current authoritative behavior contract.
- You need the current implementation shape or ownership map.
- You need a step-by-step operational sequence.

## What Belongs In `docs/decisions/`

- Durable architecture decisions.
- Accepted product or platform tradeoffs with long-lived consequences.
- Records that explain alternatives considered and follow-on constraints.

## Decision Contract

Decision concepts must include OKF frontmatter and the routing header required
by `docs/policy.md`.

## Current Decision Records

- `docs/decisions/docs-okf-template-foundation.md` explains why this template
  uses a strict docs-backed OKF/LLM Wiki profile.
