---
type: Runbook
title: Repository Checks Runbook
description: Defines the local validation sequence for docs, Rust, TOML, style, lint, and tests.
status: active
authority: procedural
owner: maintainers
last_verified: 2026-06-25
tags:
  - validation
  - cargo-make
  - docs
source_refs: []
code_refs:
  - Makefile.toml
related:
  - ../policy.md
  - ../evidence/docs-self-check.md
drift_watch:
  - Makefile.toml
  - .github/workflows/language.yml
---

# Repository Checks Runbook

Goal: Run the repository's standard docs, check, format, lint, and test commands
in the right order before landing changes.

Read this when: You are validating a local diff, checking whether the template
still passes its quality gates, or deciding which repo-native command to use for
a verification pass.

Inputs: `Makefile.toml`; `docs/policy.md`

Depends on: `Makefile.toml`

Verification: A passing repo-native validation run with no docs shape failures,
formatting drift, lint failures, or test regressions.

## Fast Path

Use the top-level gate when you want the full local sweep the repository expects
by default:

```sh
cargo make check
```

That runs:

- `cargo make check-docs`
- `cargo make check-rust`
- `cargo make fmt-check`
- `cargo make lint`
- `cargo make test`

## Targeted Commands

Use the smaller command that matches the change surface:

- Docs only:
  - `cargo make check-docs`
  - `decodex docs check`
- Formatting only:
  - `cargo make fmt`
  - `cargo make fmt-check`
- Lint only:
  - `cargo make lint`
  - `cargo make lint-fix`
  - `cargo make lint-fix-rust`
  - `cargo make lint-fix-vstyle`
  - `cargo make lint-fix-vstyle-rust`
  - `cargo make lint-vstyle`
  - `cargo make lint-vstyle-rust`
- Rust check only:
  - `cargo make check-rust`
- Tests only:
  - `cargo make test`

## When To Use Each Task

- Use `cargo make check-docs` after changing `docs/`, docs policy, OKF fields,
  LLM Wiki navigation, or docs validation expectations.
- Use `cargo make fmt` when you changed Rust or TOML files and want to rewrite
  formatting.
- Use `cargo make lint-vstyle` when you want all vstyle checks for currently
  supported languages.
- Use `cargo make lint-vstyle-rust` when you want to run the Rust vstyle checks
  without other lint gates.
- Use `cargo make lint-fix-vstyle` when you want automatic vstyle fixes for
  currently supported languages.
- Use `cargo make lint-fix` when you want automatic Rust clippy or vstyle fixes
  before a full validation pass.
- Use `cargo make check` before commit, review, or merge unless you have a
  documented reason to run a narrower command set.

## Expected Tooling

- `decodex` for `cargo make check-docs`
- Rust toolchains required by `cargo` and nightly `rustfmt`
- `cargo-vstyle` for `cargo make lint-vstyle*`, `cargo make lint-fix-vstyle*`,
  `cargo make lint`, `cargo make lint-fix`, and `cargo make check`
- `cargo-nextest` for `cargo make test`
- `taplo` for TOML formatting tasks

## Failure Handling

- Docs failures:
  update the owning concept, index, or `docs/log.md`, then rerun
  `cargo make check-docs`.
- Formatting failures:
  run `cargo make fmt`, then rerun `cargo make fmt-check`.
- Lint failures:
  fix the reported issue directly or run `cargo make lint-fix` when the
  repository supports an automatic fix.
- Test failures:
  treat them as behavioral regressions or broken assumptions in the current diff
  until proven otherwise.
