# Spec Index

Purpose: Route agents to normative documents that define repository truth.

Question this index answers: "what must remain true?"

## Use This Index When

- You need an invariant, contract, schema, enum, state model, interface, or
  required behavior.
- You are deciding whether code or data is correct.
- A runbook says "see the governing spec" and you need the authoritative source.

## Do Not Use This Index When

- You need step-by-step instructions, maintenance actions, migrations, or
  incident response.
- You need current implementation context, ownership mapping, or design
  rationale.
- You want rationale only, without an authoritative contract.

## What Belongs In `docs/spec/`

- Contracts and invariants.
- Data shapes, canonical field names, enums, defaults, units, and limits.
- State transitions and protocol rules.
- Behavior that tests, code, or operators should treat as authoritative.

## Spec Contract

Spec concepts must include OKF frontmatter and the routing header required by
`docs/policy.md`.

Keep the body explicit:

- Prefer concrete nouns over pronouns.
- Separate facts from rationale.
- Include canonical names exactly as code or data uses them.
- Include a small example when it removes ambiguity.
- Link to related runbooks instead of embedding procedures.

## Current Specs

- `docs/spec/cli.md` for the current command-line and runtime bootstrap contract.
