# Runbook Index

Purpose: Route agents to procedural documents that tell them which execution
sequence to run safely and repeatably.

Question this index answers: "which sequence should I execute?"

## Use This Index When

- You need a runbook, how-to, validation flow, troubleshooting path, or
  maintenance procedure.
- You already know the relevant spec and need the operational steps.
- You need a bounded sequence with prerequisites and verification.

## Do Not Use This Index When

- You need the authoritative contract, schema, or invariant.
- You need descriptive current-state context such as repository layout or
  implementation strategy.
- You need durable rationale for why an accepted tradeoff exists.
- You need broad documentation policy or repo task-entrypoint rules.

## What Belongs In `docs/runbook/`

- Task-oriented runbooks.
- Validation and test procedures.
- Migration, rollout, rollback, and recovery sequences.
- Troubleshooting flows and operator checklists.
- Short operational recipes that depend on a governing spec and end in explicit
  verification.

## Runbook Contract

Runbook concepts must include OKF frontmatter and the routing header required by
`docs/policy.md`.

Structure the body for execution:

- Write steps in the order an agent should perform them.
- Keep commands, checks, and rollback points explicit.
- Link to specs for normative truth instead of restating contracts.
- Include failure branches only when they change the next action.
- End with verification so an agent can tell whether the runbook succeeded.

## Current Runbooks

- `docs/runbook/repo-checks.md` for repo-native docs, lint, test, and format
  validation.
- `docs/runbook/template-adoption.md` for deriving a real repository from this
  template while preserving OKF/LLM Wiki structure.
