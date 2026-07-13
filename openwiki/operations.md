# Operations And Validation

## Preconditions

Repository-native tasks are declared in `Makefile.toml` and invoked with `cargo make <task>`. Install only what the selected task needs:

| Tool | Needed by |
| --- | --- |
| Stable Rust/Cargo/Clippy | Rust check, lint, test, and build tasks |
| Nightly toolchain with rustfmt | `fmt-rust`, `fmt-rust-check` |
| `cargo-make` | Every `cargo make` entrypoint |
| `taplo` | TOML format tasks |
| `cargo-vstyle` | vstyle tasks and the composite lint/full gates |
| `cargo-nextest` | test tasks |

`rust-toolchain.toml` pins stable only. Nightly rustfmt and all third-party Cargo tools are separate prerequisites. The Rust CI job sets up stable with rustfmt/Clippy, then separately installs nightly rustfmt because repository formatting tasks explicitly run it; the TOML job separately installs Taplo.

Sources: `Makefile.toml`, `rust-toolchain.toml`, `.github/workflows/language.yml`.

## Public Check Aggregate

```sh
cargo make check
```

`check` is a cargo-make composite whose dependencies are `check-rust`, `fmt-check`, `lint`, and `test`. `Makefile.toml` establishes the dependency set but does not state a runtime ordering contract. When deterministic, fail-fast diagnosis matters, invoke the targeted commands explicitly in this recommended sequence:

```sh
cargo make fmt-check
cargo make check-rust
cargo make lint
cargo make test
```

This diagnostic order catches mechanical formatting drift before compilation/lint/test analysis; it does not change the task definitions. `check` is the public aggregate for source validation, but it no longer includes the deleted Decodex `check-docs` task. Review OpenWiki separately with the focused checks in [Knowledge Maintenance](knowledge-maintenance.md#openwiki-drift-check).

## Complete Task Matrix

| Task | Exact behavior | Mutates files? |
| --- | --- | --- |
| `check` | Composite: `check-rust`, `fmt-check`, `lint`, `test` | Build cache only |
| `check-rust` | `cargo check --all-features --all-targets --workspace` | Build cache only |
| `fmt` | Composite: `fmt-rust`, `fmt-toml` | Yes |
| `fmt-check` | Composite: `fmt-rust-check`, `fmt-toml-check` | No |
| `fmt-rust` | `rustup run nightly cargo fmt --all` | Yes |
| `fmt-rust-check` | Same with `-- --check` | No |
| `fmt-toml` | `taplo fmt` | Yes |
| `fmt-toml-check` | `taplo fmt --check` | No |
| `lint` | Composite: `lint-rust`, `lint-vstyle` | No |
| `lint-fix` | Composite: `lint-fix-rust`, `lint-fix-vstyle` | Yes |
| `lint-rust` | Workspace/all-target/all-feature Clippy with repository deny policy | Build cache only |
| `lint-fix-rust` | Same Clippy policy with `--fix --allow-dirty` | Yes |
| `lint-vstyle` | Composite: `lint-vstyle-rust` | No |
| `lint-vstyle-rust` | `cargo vstyle curate --language rust --workspace --all-features --strict` | No |
| `lint-fix-vstyle` | Composite: `lint-fix-vstyle-rust` | Yes |
| `lint-fix-vstyle-rust` | `cargo vstyle tune --language rust --workspace --all-features --strict` | Yes |
| `test` | Composite: `test-rust` | Build cache only |
| `test-rust` | `cargo nextest run --workspace --all-targets --all-features` | Build cache only |

The Clippy tasks deny `clippy::all`, `clippy::too_many_lines`, `clippy::unwrap_used`, `clippy::use_self`, `clippy::wildcard_imports`, `missing-docs`, `unused-crate-dependencies`, and all warnings. `clippy.toml` allows unwrap only in tests, sets a 120-line threshold, and warns on wildcard imports. Rust formatting intentionally uses nightly features from `.rustfmt.toml`; Taplo excludes `Makefile.toml` and generated/local trees.

History: commit `452039e` separated `cargo check` from Clippy and made task contracts explicit; `b250fc0` split vstyle wrappers by language for monorepo extension.

Sources: `Makefile.toml`, `clippy.toml`, `.rustfmt.toml`, `.taplo.toml`; history: commits `452039e`, `b250fc0`.

## Build, Install, Run, And Bundle

Common Cargo commands are not cargo-make tasks:

```sh
cargo build -p name_placeholder
cargo build --release -p name_placeholder
cargo build -p name_placeholder --profile final-release --locked
cargo install --path apps/name_placeholder --force
cargo run -p name_placeholder -- --help
```

- Default release output: `target/release/name_placeholder` (or `.exe`).
- `final-release` output: `target/final-release/name_placeholder` unless `--target` adds a target-triple directory.
- macOS app bundling is optional and requires `cargo-bundle`; run it from `apps/name_placeholder/` as documented in the README.
- Release reproducibility relies on `--locked`; an out-of-date lockfile is a release blocker rather than permission to omit the flag.

Sources: `README.md`, `Cargo.toml`, `.github/workflows/release.yml`.

## CI Checks

Current `.github/workflows/language.yml` runs on pushes and pull requests targeting `main`, plus merge queues. It has no path filters, so documentation-only changes trigger the language checks too.

Two jobs run independently:

- **Rust check:** rustfmt check → Cargo check → vstyle action → Clippy → nextest. It installs nightly rustfmt, cargo-make, and nextest; vstyle comes from `hack-ink/vibe-style`.
- **TOML check:** installs cargo-make and Taplo, then runs `fmt-toml-check`.

CI does **not** invoke `cargo make check` or validate OpenWiki. Running on a documentation-only diff does not turn this workflow into a documentation-readiness gate: green proves only the listed language/TOML checks. The former CodeQL workflow—push/PR analysis for `main` plus weekly Actions/Rust scans—has been removed, so no tracked workflow currently provides that security-analysis coverage. Actions are SHA-pinned in current tracked workflows; preserve that supply-chain posture when updating them.

Source: `.github/workflows/language.yml`.

## Release Pipeline

A tag matching `v<major>.<minor>.<patch>` triggers `.github/workflows/release.yml`:

1. Build `name_placeholder` with locked `final-release` for Apple arm64, Linux x86_64 GNU, and Windows x86_64 MSVC.
2. Package macOS/Windows as ZIP and Linux as tar.gz; upload one-day intermediate artifacts.
3. After all builds, combine and publish artifacts to a GitHub Release with generated notes.
4. Independently publish package `name_placeholder` to crates.io using the configured repository secret.

The crates.io job does not depend on the build or GitHub release jobs; GitHub Actions may run it concurrently. A failure in one branch does not imply the other branch never ran. All names, package selectors, and archive paths are still template placeholders and must change together during adoption.

Sources: `.github/workflows/release.yml`, `Cargo.toml`, `apps/name_placeholder/Cargo.toml`.

## Failure Interpretation

- Missing command/tool: satisfy the prerequisite; do not rewrite the task to bypass the expected tool without a deliberate contract change.
- Format failure: run `cargo make fmt`, inspect changes, then rerun `fmt-check`.
- Cargo check failure: resolve compilation/features/targets before interpreting downstream lint/test noise.
- Clippy/vstyle failure: fix directly or use the matching `lint-fix*` task, then review all mutations before rerunning read-only gates.
- Test failure: treat as a regression or broken assumption in the current diff until evidence shows an environment/tool issue.
- Release failure: distinguish build, packaging/path, GitHub publication, and crates.io publication; they have different ownership and dependency edges.

Before merge, prefer `cargo make check` plus the focused OpenWiki drift checks and any release-specific dry checks justified by the changed surface. Record unavailable tools and unrun checks explicitly rather than claiming readiness.
