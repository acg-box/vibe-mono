# Evidence Index

Purpose: Route agents to public-safe proof, drift audits, and reverse checks for
claims made by repository docs.

Question this index answers: "what evidence supports or audits the current
claim?"

## Use This Index When

- You need a drift audit before claiming docs/code/status/config alignment.
- You need public-safe evidence for a docs readiness claim.
- You need to inspect reverse checks for a maintained claim.

## Do Not Use This Index When

- You need the current normative contract.
- You need a procedure to execute.
- You need exploratory research that has not been accepted.

## What Belongs In `docs/evidence/`

- Drift audits.
- Public-safe validation evidence.
- Reverse checks that keep docs aligned with code, config, status text, or
  runtime behavior.

## Evidence Contract

Evidence concepts must include OKF frontmatter. Drift Audit concepts must
include the required sections listed in `docs/policy.md`.

Do not store secrets, credentials, private user data, or local-only machine state
in evidence concepts.

## Current Evidence

- `docs/evidence/docs-self-check.md` audits the docs bundle shape and the local
  docs check loop.
