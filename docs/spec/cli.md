---
type: Spec
title: CLI Contract
description: Defines the template repository command-line entrypoint and runtime bootstrap contract.
status: active
authority: normative
owner: maintainers
last_verified: 2026-06-25
tags:
  - cli
  - runtime
  - template
source_refs: []
code_refs:
  - src/main.rs
  - src/cli.rs
related:
  - ../runbook/template-adoption.md
  - ../reference/workspace-layout.md
drift_watch:
  - src/main.rs
  - src/cli.rs
  - Cargo.toml
---

# CLI Contract

Purpose: Define the current normative command-line and runtime bootstrap
contract for this template repository.

Status: normative

Read this when: You are implementing, reviewing, or replacing the default CLI
entrypoint, argument surface, startup logging, or panic behavior.

Not this document: Step-by-step repo validation, layout guidance, or design
rationale. Use `docs/runbook/` for procedures, `docs/reference/` for current
structure, and `docs/decisions/` for durable tradeoffs.

Defines:

- the current single-binary CLI shape
- the startup logging and panic behavior contract
- the placeholder argument behavior shipped by the template

## Binary Shape

- The template currently builds a single binary entrypoint from `src/main.rs`.
- The CLI surface is defined through `clap::Parser` in `src/cli.rs`.
- The current template does not define subcommands.

## Startup Behavior

- `main` installs `color-eyre` before CLI execution.
- Runtime logs are written through `tracing_subscriber` to the app data
  directory resolved by `directories::ProjectDirs`.
- The current log sink rotates weekly and keeps at most three log files.
- If the `RUST_LOG` environment variable is absent, the default log filter is
  `info`.

## Panic Behavior

- The template preserves the default panic hook output.
- After the panic hook runs, the process aborts.

## Placeholder Argument Behavior

- The default CLI includes a `--placeholder` / `-p` string argument.
- If omitted, the default placeholder value is
  `Welcome to use name_placeholder!`.

## Change Rule

If a generated project replaces this placeholder CLI shape, update or replace
this spec so the normative docs continue to match the real entrypoint and
runtime contract.
