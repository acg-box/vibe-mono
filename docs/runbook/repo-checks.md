# Repository Checks Runbook

Goal: Run the repository's standard format, lint, and test commands in the right order before
landing changes.

Read this when: You are validating a local diff, checking whether the template still passes its
quality gates, or deciding which repo-native command to use for a full verification pass.

Inputs: `Makefile.toml`

Depends on: `Makefile.toml`

Verification: A passing repo-native validation run with no formatting drift, lint failures, or
test regressions.

## Fast path

Use the top-level gate when you want the same full sweep the repository expects by default:

```sh
cargo make checks
```

That runs:

- `cargo make lint`
- `cargo make test`
- `cargo make fmt-check`

## Targeted commands

Use the smaller command that matches the change surface:

- Formatting only:
  - `cargo make fmt`
  - `cargo make fmt-check`
- Lint only:
  - `cargo make lint`
  - `cargo make lint-fix`
- Tests only:
  - `cargo make test`

## When to use each task

- Use `cargo make fmt` when you changed Rust or TOML files and want to rewrite formatting.
- Use `cargo make lint-fix` when you want automatic Rust or vstyle fixes before a full validation
  pass.
- Use `cargo make checks` before commit, review, or merge unless you have a documented reason to
  run a narrower command set.

## Expected tooling

- Rust toolchains required by `cargo` and `cargo +nightly fmt`
- `cargo-nextest` for `cargo make test`
- `taplo` for TOML formatting tasks

## Failure handling

- Formatting failures:
  run `cargo make fmt`, then rerun `cargo make fmt-check`.
- Lint failures:
  fix the reported issue directly or run `cargo make lint-fix` when the repository supports an
  automatic fix.
- Test failures:
  treat them as behavioral regressions or broken assumptions in the current diff until proven
  otherwise.
