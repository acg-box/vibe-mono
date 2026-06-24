# Reference Index

Purpose: Route agents to descriptive documents that explain the current
repository layout, implementation shape, and chosen technical approach without
defining normative truth or an execution sequence.

Question this index answers: "how is it currently organized or implemented?"

## Use This Index When

- You need the current file or directory ownership map.
- You need a descriptive explanation of the current implementation model.
- You need change-planning context before editing code, but not a normative
  contract or a runbook.

## Do Not Use This Index When

- You need the authoritative contract, schema, invariant, or required behavior.
- You need a step-by-step runbook, validation sequence, or troubleshooting flow.
- You need durable rationale for why an accepted tradeoff was chosen.

## What Belongs In `docs/reference/`

- Repository maps and ownership notes.
- Current implementation-model explanations.
- Non-normative technical context that should stay separate from runbooks.

## Reference Contract

Reference concepts must include OKF frontmatter and the routing header required
by `docs/policy.md`.

## Current References

- `docs/reference/workspace-layout.md` for repository layout, ownership
  boundaries, template placeholders, and local-only directories.
