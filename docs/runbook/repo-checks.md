# Repository Checks Runbook

Goal: Run the repository's standard check, format, lint, and test commands in the right order
before landing changes.

Read this when: You are validating a local diff, checking whether the template still passes its
quality gates, or deciding which repo-native command to use for a full verification pass.

Inputs: `Makefile.toml`

Depends on: `Makefile.toml`

Verification: A passing repo-native validation run with no formatting drift, lint failures, or
test regressions.

## Fast path

Use the top-level gate when you want the same full sweep the repository expects by default:

```sh
cargo make check
```

That runs:

- `cargo make check-rust`
- `cargo make fmt-check`
- `cargo make lint`
- `cargo make test`

## Targeted commands

Use the smaller command that matches the change surface:

- Formatting only:
  - `cargo make fmt`
  - `cargo make fmt-check`
- Lint only:
  - `cargo make lint`
  - `cargo make lint-fix`
  - `cargo make lint-fix-vstyle`
  - `cargo make lint-fix-vstyle-rust`
  - `cargo make lint-vstyle`
  - `cargo make lint-vstyle-rust`
- Tests only:
  - `cargo make test`

## When to use each task

- Use `cargo make fmt` when you changed Rust or TOML files and want to rewrite formatting.
- Use `cargo make lint-vstyle` when you want all vstyle checks for currently supported languages.
- Use `cargo make lint-vstyle-rust` when you want to run the Rust vstyle checks without other
  lint gates.
- Use `cargo make lint-fix-vstyle` when you want automatic vstyle fixes for currently supported
  languages.
- Use `cargo make lint-fix` when you want automatic Rust clippy or vstyle fixes before a full
  validation pass.
- Use `cargo make check` before commit, review, or merge unless you have a documented reason to
  run a narrower command set.

## Expected tooling

- Rust toolchains required by `cargo` and nightly `rustfmt`
- `cargo-vstyle` for `cargo make lint-vstyle*`, `cargo make lint-fix-vstyle*`,
  `cargo make lint`, `cargo make lint-fix`, and `cargo make check`
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
