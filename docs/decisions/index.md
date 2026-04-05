# Decisions Index

Purpose: Route agents to durable rationale documents that explain why an accepted technical or
product tradeoff was chosen and what consequences follow from that choice.

Question this index answers: "why was this tradeoff accepted?"

## Use this index when

- You need the reasoning behind an accepted architecture or product decision.
- You need to understand which alternatives were considered and rejected.
- You need long-lived context before revisiting or superseding an earlier choice.

## Do not use this index when

- You need the current authoritative behavior contract.
- You need the current implementation shape or ownership map.
- You need a step-by-step operational sequence.

## What belongs in `docs/decisions/`

- Durable architecture decisions.
- Accepted product or platform tradeoffs with long-lived consequences.
- Records that explain alternatives considered and follow-on constraints.

## Decision document contract

Start each decision record with:

- `Status`
- `Date`
- `Context`
- `Decision`
- `Alternatives considered`
- `Consequences`

## Current decision records

No durable decision records have been written yet. Add one when a tradeoff needs to remain
discoverable beyond commit history and code comments.
