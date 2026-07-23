---
type: "Reference"
title: "Operations And Validation"
openwiki_generated: true
---

# Operations And Validation

## Preconditions

Repository-native tasks are declared in `Makefile.toml` and invoked with `cargo make <task>`. Install only what the selected task needs:

| Tool | Needed by |
| --- | --- |
| Project Rust toolchain from `rust-toolchain.toml` | Rust check, lint, test, and build tasks |
| Nightly toolchain with rustfmt | `fmt-rust`, `fmt-rust-check` |
| Node.js/npm from `.node-version` | TypeScript check, format, lint, test, and template-marker tasks |
| `cargo-make` | Every `cargo make` entrypoint |
| `taplo` | TOML format tasks |
| `cargo-vstyle` | vstyle tasks and the composite lint/full gates |
| `cargo-nextest` | test tasks |

`rust-toolchain.toml` is the sole selector for ordinary Rust commands. It selects stable with the minimal profile and adds Clippy; Cargo and rustc come from that profile. Rust formatting is the only explicit toolchain exception: `fmt-rust` and `fmt-rust-check` run nightly rustfmt because `.rustfmt.toml` uses nightly features. Third-party Cargo tools remain separate prerequisites. `.node-version`, `package.json`, and `package-lock.json` pin Node.js, npm, and the TypeScript development graph. Run `npm ci --ignore-scripts` before a TypeScript task or the full aggregate; repository tasks validate but do not install dependencies. CI reads the ordinary Rust toolchain and components from `rust-toolchain.toml`, installs nightly rustfmt separately, installs Taplo for the TOML job, and performs the locked npm install for the TypeScript job.

Sources: `rust-toolchain.toml`, `Makefile.toml`, `.node-version`, `package.json`, `package-lock.json`, `.github/workflows/language.yml`, `.github/workflows/release.yml`.

## Public Check Aggregate

```sh
cargo make check
```

`check` is a cargo-make composite whose dependencies are `check-rust`, `check-typescript`, `fmt-check`, `lint`, and `test`. `Makefile.toml` establishes the dependency set but does not state a runtime ordering contract. When deterministic, fail-fast diagnosis matters, invoke the targeted commands explicitly in this recommended sequence:

```sh
cargo make fmt-check
cargo make check-rust
cargo make check-typescript
cargo make lint
cargo make test
```

This diagnostic order catches mechanical formatting drift before compilation/lint/test analysis; it does not change the task definitions. `check` is the public aggregate for source validation, but it no longer includes the deleted Decodex `check-docs` task. Review OpenWiki separately with the focused checks in [Knowledge Maintenance](knowledge-maintenance.md#openwiki-drift-check).

## Complete Task Matrix

| Task | Exact behavior | Mutates files? |
| --- | --- | --- |
| `check` | Composite: `check-rust`, `check-typescript`, `fmt-check`, `lint`, `test` | Build/tool caches only |
| `check-rust` | `cargo check --all-features --all-targets --workspace` | Build cache only |
| `check-typescript` | Run the installed TypeScript compiler with `--noEmit --project tsconfig.json` | Tool cache only |
| `fmt` | Composite: `fmt-rust`, `fmt-toml`, `fmt-typescript` | Yes |
| `fmt-check` | Composite: `fmt-rust-check`, `fmt-toml-check`, `fmt-typescript-check` | No |
| `fmt-rust` | `rustup run nightly cargo fmt --all` | Yes |
| `fmt-rust-check` | Same with `-- --check` | No |
| `fmt-toml` | `taplo fmt` | Yes |
| `fmt-toml-check` | `taplo fmt --check` | No |
| `fmt-typescript` | Oxfmt over `scripts/` and the owned TypeScript JSON configuration files | Yes |
| `fmt-typescript-check` | Same Oxfmt scope with `--check` | No |
| `lint` | Composite: `lint-rust`, `lint-typescript`, `lint-vstyle` | No |
| `lint-fix` | Composite: `lint-fix-rust`, `lint-fix-typescript`, `lint-fix-vstyle` | Yes |
| `lint-rust` | Workspace/all-target/all-feature Clippy with repository deny policy | Build cache only |
| `lint-fix-rust` | Same Clippy policy with `--fix --allow-dirty` | Yes |
| `lint-typescript` | Oxlint over `scripts/` with the checked-in type-aware deny policy | No |
| `lint-fix-typescript` | Same Oxlint policy with safe `--fix`; suggestions and dangerous fixes remain disabled | Yes |
| `lint-vstyle` | Composite: `lint-vstyle-rust` | No |
| `lint-vstyle-rust` | `cargo vstyle curate --language rust --workspace --all-features --strict` | No |
| `lint-fix-vstyle` | Composite: `lint-fix-vstyle-rust` | Yes |
| `lint-fix-vstyle-rust` | `cargo vstyle tune --language rust --workspace --all-features --strict` | Yes |
| `list-template-markers` | Run the tracked-file marker inventory through Node.js | No |
| `test` | Composite: `test-rust`, `test-typescript` | Build/tool caches only |
| `test-rust` | `cargo nextest run --workspace --all-targets --all-features` | Build cache only |
| `test-typescript` | `node --test` over the discovered `*.test.ts` files | Tool cache only |

The Clippy tasks deny `clippy::all`, `clippy::too_many_lines`, `clippy::unwrap_used`, `clippy::use_self`, `clippy::wildcard_imports`, `missing-docs`, `unused-crate-dependencies`, and all warnings. `clippy.toml` allows unwrap only in tests, sets a 120-line threshold, and warns on wildcard imports. Rust formatting intentionally uses nightly features from `.rustfmt.toml`; Taplo excludes `Makefile.toml` and generated/local trees.

The TypeScript compiler enables strict checking, indexed-access uncertainty, exact optional-property semantics, control-flow checks, and Node-erasable syntax. Oxlint denies correctness, suspicious, and performance diagnostics plus explicit `any`, unsafe type operations, non-null assertions, unhandled or misused promises, non-`Error` throws, and non-exhaustive switches. Warnings and unused suppression directives fail the task. Oxfmt is the sole TypeScript formatter; the prior root Prettier files were unused and are removed. The npm lock contains platform-specific optional binary packages for TypeScript and Oxc; `.npmrc` disables lifecycle scripts and requires exact saved versions.

History: commit `452039e` separated `cargo check` from Clippy and made task contracts explicit; `b250fc0` split vstyle wrappers by language for monorepo extension.

Sources: `Makefile.toml`, `clippy.toml`, `.rustfmt.toml`, `.taplo.toml`, `tsconfig.json`, `.oxfmtrc.json`, `.oxlintrc.json`, `.npmrc`; history: commits `452039e`, `b250fc0`.

## TypeScript Template Maintenance

Install the exact development graph and list every tracked template marker:

```sh
npm ci --ignore-scripts
cargo make list-template-markers
```

The marker script forwards `git grep` output as `path:line:text` records. A marker record means the repository still contains template identity. No marker records means no configured marker was found; cargo-make can still print its own task status. Both inventory results are successful; inability to execute Git or another Git failure fails the task. The helper scans all tracked files, so it does not read untracked or ignored secret-bearing files.

Before Node/npm is installed, use the equivalent scoped `rg` fallback from [Template Adoption](template-adoption.md#1-establish-identity-and-inventory). Keep that fallback for bootstrap only; `list-template-markers` owns the installed repository command.

Sources: `scripts/list-template-markers.ts`, `scripts/list-template-markers.test.ts`, `Makefile.toml`, `openwiki/template-adoption.md`.

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

Three jobs run independently:

- **Rust check:** rustfmt check → Cargo check → vstyle action → Clippy → nextest. The setup action reads the ordinary toolchain and Clippy component from `rust-toolchain.toml`; the job installs nightly rustfmt with the minimal profile, installs cargo-make and nextest separately, and gets vstyle from `hack-ink/vibe-style`.
- **TOML check:** installs cargo-make and Taplo, then runs `fmt-toml-check`.
- **TypeScript check:** reads the exact Node.js version from `.node-version`, installs the locked npm graph without lifecycle scripts, then runs TypeScript format, compiler, type-aware lint, and test tasks through cargo-make.

CI does **not** invoke `cargo make check` or validate OpenWiki. Running on a documentation-only diff does not turn this workflow into a documentation-readiness gate: green proves only the listed Rust/TOML/TypeScript checks. The former CodeQL workflow—push/PR analysis for `main` plus weekly Actions/Rust scans—has been removed, so no tracked workflow currently provides that security-analysis coverage. Actions are SHA-pinned in current tracked workflows; preserve that supply-chain posture when updating them. Dependabot covers Cargo, root npm, and GitHub Actions; the TypeScript compiler, types, formatter, linter, and type-aware backend update as one review group.

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
- TypeScript check failure: resolve compiler diagnostics under the pinned Node/TypeScript versions before interpreting type-aware lint noise.
- Clippy/vstyle failure: fix directly or use the matching `lint-fix*` task, then review all mutations before rerunning read-only gates.
- Oxlint failure: fix the diagnostic directly or use `lint-fix-typescript` for safe fixes only; review every mutation before rerunning compiler, lint, and tests.
- Test failure: treat as a regression or broken assumption in the current diff until evidence shows an environment/tool issue.
- Release failure: distinguish build, packaging/path, GitHub publication, and crates.io publication; they have different ownership and dependency edges.

Before merge, prefer `cargo make check` plus the focused OpenWiki drift checks and any release-specific dry checks justified by the changed surface. Record unavailable tools and unrun checks explicitly rather than claiming readiness.
