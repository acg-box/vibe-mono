---
type: "Reference"
title: "Operations And Validation"
openwiki_generated: true
sources:
  - id: openwiki-source-79b37831c9c81206da1d88ec
    resource: repo://.github/dependabot.yml
  - id: openwiki-source-4d1d392666be6dfdd7a91a2e
    resource: repo://.github/workflows/release.yml
  - id: openwiki-source-7437def7410a3f1ed2549b16
    resource: repo://.node-version
  - id: openwiki-source-c8b1a2a9f2113ec43d4066da
    resource: repo://Makefile.toml
  - id: openwiki-source-5093b074f16e0b77479219b2
    resource: repo://package-lock.json
  - id: openwiki-source-5b54a58d1b51cd490b0e7162
    resource: repo://package.json
  - id: openwiki-source-23775c3de52f3ab95a13cb8b
    resource: repo://README.md
  - id: openwiki-source-b7793decf9d7c9ba48e57e0f
    resource: repo://rust-toolchain.toml
generated: { by: "codex", at: "2026-08-27T11:43:58.604Z" }
verified:
  - by: openwiki/0.4.3
    at: 2026-08-27T11:43:58.604Z
---

# Operations And Validation

## Preconditions

Repository-native tasks are declared in `Makefile.toml` and invoked with `cargo make <task>`. Install only what the selected task needs:

| Tool | Needed by |
| --- | --- |
| Project Rust selection from `rust-toolchain.toml` | Stable toolchain with the minimal profile and Clippy for repository lint tasks |
| Separately managed nightly rustfmt | `fmt-rust` |
| Node.js/npm from `.node-version` | TypeScript typecheck, format, lint, test, and template-marker tasks |
| Exact local npm development graph from `package-lock.json` | TypeScript, Oxfmt, Oxlint, and type-aware lint support |
| `cargo-make` | Every `cargo make` entrypoint |
| `taplo` | TOML format tasks |
| `cargo-vstyle` | vstyle tasks and the composite lint/full gates |
| `cargo-nextest` | test tasks |

`rust-toolchain.toml` selects stable with the minimal profile and installs Clippy for repository lint tasks. The formatting task uses rustfmt from the separately managed nightly toolchain; stable rustfmt and LLVM tools are not repository requirements. The release and crates.io jobs use the pinned toolchain setup action with caching and do not request workflow-specific extra components. Third-party Cargo tools remain separate prerequisites. `.node-version`, `package.json`, and `package-lock.json` pin Node.js, npm, and the complete local TypeScript/Oxc development graph. Run `npm ci --ignore-scripts` before a TypeScript task or the full aggregate; repository tasks invoke the installed tools through deterministic `node_modules` entrypoints and do not install dependencies. Source validation is local-only; tracked GitHub Actions do not install or run this complete tool graph for pull requests, merge queues, or branch pushes.

Sources: `rust-toolchain.toml`, `Makefile.toml`, `.node-version`, `package.json`, `package-lock.json`, `.github/workflows/release.yml`.

`Makefile.toml` sets `default_to_workspace = false` and `skip_core_tasks = true`, so repository tasks run from the repository root without per-task workspace overrides or cargo-make core hooks.

## Public Check Aggregate

```sh
cargo make check
```

`check` is the complete cargo-make source-validation aggregate. Its dependencies are `typecheck`, `lint`, and `test`; `typecheck` runs TypeScript `tsc --noEmit`, while lint's Clippy task owns Rust compilation/static analysis and test's nextest task owns Rust tests. It does not inspect or modify formatting; run the separate mutating `cargo make fmt` task when formatting needs correction. `Makefile.toml` establishes the dependency set but does not state a runtime ordering contract. After formatting is corrected, invoke the targeted commands explicitly in this recommended sequence when deterministic, fail-fast diagnosis matters:

```sh
cargo make typecheck
cargo make lint
cargo make test
```

This diagnostic order covers TypeScript typechecking, Rust compilation/static analysis, and tests after formatting has been corrected; it does not change the task definitions. `check` is the public aggregate for source validation, but it no longer includes the deleted Decodex `check-docs` task. Review OpenWiki separately with the focused checks in [Knowledge Maintenance](knowledge-maintenance.md#openwiki-drift-check).

## Complete Task Matrix

| Task | Exact behavior | Mutates files? |
| --- | --- | --- |
| `check` | Composite: `typecheck`, `lint`, `test` | Build/tool caches only |
| `typecheck` | `node node_modules/typescript/bin/tsc --noEmit --project tsconfig.json` | Tool cache only |
| `fmt` | Composite: `fmt-rust`, `fmt-toml`, `fmt-typescript` | Yes |
| `fmt-rust` | `rustup run nightly cargo fmt --all` | Yes |
| `fmt-toml` | `git ls-files -z -- '*.toml' \| xargs -0 taplo fmt` | Yes |
| `fmt-typescript` | Run `node_modules/oxfmt/bin/oxfmt` through Node over `scripts/` and the owned TypeScript JSON configuration files | Yes |
| `lint` | Composite: `lint-rust`, `lint-typescript`, `lint-vstyle` | No |
| `lint-fix` | Composite: `lint-fix-rust`, `lint-fix-typescript`, `lint-fix-vstyle` | Yes |
| `lint-rust` | Rust compilation/static analysis through workspace/all-target/all-feature Clippy with `--locked` and repository deny policy | Build cache only |
| `lint-fix-rust` | Same locked Clippy policy with `--fix --allow-dirty` | Yes |
| `lint-typescript` | Run `node_modules/oxlint/bin/oxlint` through Node over `scripts/` with the checked-in type-aware deny policy | No |
| `lint-fix-typescript` | Run the same local Oxlint entrypoint with safe `--fix`; suggestions and dangerous fixes remain disabled | Yes |
| `lint-vstyle` | Composite: `lint-vstyle-rust` | No |
| `lint-vstyle-rust` | `cargo --locked vstyle curate --language rust --workspace --all-features --strict` | No |
| `lint-fix-vstyle` | Composite: `lint-fix-vstyle-rust` | Yes |
| `lint-fix-vstyle-rust` | `cargo --locked vstyle tune --language rust --workspace --all-features --strict` | Yes |
| `list-template-markers` | Run the tracked-file marker inventory through Node.js | No |
| `test` | Composite: `test-rust`, `test-typescript` | Build/tool caches only |
| `test-rust` | `cargo nextest run --locked --workspace --all-targets --all-features` | Build cache only |
| `test-typescript` | `node --test` over the discovered `*.test.ts` files | Tool cache only |

The Clippy tasks deny `clippy::all`, `clippy::too_many_lines`, `clippy::unwrap_used`, `clippy::use_self`, `clippy::wildcard_imports`, `missing-docs`, `unused-crate-dependencies`, and all warnings. `clippy.toml` allows unwrap only in tests, sets a 120-line threshold, and warns on wildcard imports. Rust formatting intentionally uses nightly features from `.rustfmt.toml`. TOML selection uses Git-tracked paths in the `fmt-toml` tasks; `.taplo.toml` supplies formatting policy, including a scoped `reorder_arrays = false` rule for `Makefile.toml` while global `reorder_keys = true` remains active.

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
cargo build -p name_placeholder --locked
cargo build --release -p name_placeholder --locked
cargo install --path apps/name_placeholder --locked --force
cargo run -p name_placeholder --locked -- --help
```

- Default release output: `target/release/name_placeholder` (or `.exe`).
- Targeted release output: `target/<triple>/release/name_placeholder` (or `.exe`).
- macOS app bundling is optional and requires `cargo-bundle`; run it from `apps/name_placeholder/` as documented in the README.
- Release reproducibility relies on `--locked`; an out-of-date lockfile is a release blocker rather than permission to omit the flag.

Sources: `README.md`, `Cargo.toml`, `.github/workflows/release.yml`.

## Local Validation Policy

No tracked GitHub Actions workflow validates pull requests, merge queues, or branch pushes. Run `cargo make check` locally before integration; this repository does not define an independent hosted reproduction of that result.

Repository-owned tracked Actions are reserved for tag-based release and publishing work. This policy removes repository-owned hosted PR feedback and its runner latency and resource use. GitHub organization or enterprise rulesets can still inject checks that are not controlled by this repository's YAML; audit that provider configuration separately. Revisit this policy if local-only validation no longer provides sufficient integration confidence or if the repository again requires an enforceable pre-merge gate.

The former CodeQL workflow has also been removed, so no tracked workflow provides hosted security-analysis coverage. Actions used by the release pipeline remain SHA-pinned; preserve that supply-chain posture when updating them. Dependabot still covers Cargo, root npm, and GitHub Actions; the TypeScript compiler, types, formatter, linter, and type-aware backend update as one review group.

Sources: `Makefile.toml`, `.github/workflows/release.yml`, `.github/dependabot.yml`.

## Release Pipeline

A tag matching `v<major>.<minor>.<patch>` triggers `.github/workflows/release.yml`:

1. Select stable minimal with the repository-declared Clippy component from `rust-toolchain.toml` and preserve the toolchain action cache without requesting workflow-specific extra components. Then remove cached outputs for the workspace binary and build `name_placeholder` with the standard release profile and `--locked` for Apple arm64, Linux x86_64 GNU, and Windows x86_64 MSVC. The standard release profile uses thin LTO. Dependency caches remain reusable, but the application code generation and final link must run for the tag source. macOS continues to use Apple ld, and Windows continues to use MSVC link.exe. Linux first downloads the pinned mold archive over HTTPS, verifies its SHA-256 digest and reported version, then invokes `cargo rustc --release --locked` with target-specific linker flags that replace Rust's self-contained LLD with mold.
2. Execute each native binary before packaging and require its reported source SHA and target triple to match the workflow source and matrix target. Also require the Linux binary's ELF `.comment` section to report the pinned mold version. A missing linker, checksum or version mismatch, unsupported linker flags, identity mismatch, or absent mold marker fails that matrix branch before packaging.
3. Package macOS/Windows as ZIP and Linux as tar.gz using the explicit archive name in each matrix entry. Upload each archive without an extra artifact wrapper, fail if it is missing, and retain it for one day.
4. After every matrix build succeeds, download matching archives into `artifacts/` with digest mismatches treated as errors and decompression disabled.
5. Require exactly the three expected filenames and test each ZIP or tar.gz for readability before publishing a GitHub Release with generated notes. Missing, extra, renamed, corrupt, or digest-mismatched artifacts block this branch before publication.
6. Independently publish package `name_placeholder` to crates.io using the configured repository secret.

The Linux linker selection does not change the standard release profile: it still uses thin LTO. Mold changes only the final link step; it does not remove dependency or workspace compilation, LLVM code generation, or LTO.

The crates.io job does not depend on the build or GitHub release jobs; GitHub Actions may run it concurrently. A failure in one branch does not imply the other branch never ran. The explicit archive names form a contract across the matrix, upload, download pattern, verification commands, and release files. The pinned mold version and SHA-256 value form an additional Linux supply-chain contract: update them together and preserve both the version check and post-link provenance check. All names, package selectors, and archive paths are still template placeholders and must change together during [Template Adoption](template-adoption.md#4-reconcile-build-and-release).

Sources: `.github/workflows/release.yml`, `.github/actions/install-mold/action.yml`, `.github/actions/install-mold/install-mold.sh`, `Cargo.toml`, `apps/name_placeholder/Cargo.toml`.

## Reusable mold Action

`.github/actions/install-mold` is the template's reusable composite action for
installing mold on Linux CI runners. It derives the host archive architecture,
downloads the official archive over HTTPS, verifies the caller-supplied SHA-256
digest and reported version, and exposes `mold_libexec` and `mold_binary`
outputs. It does not replace `/usr/bin/ld` or change the runner's global linker.
The action fails closed on non-Linux hosts, unsupported architectures, missing
tools, checksum mismatch, archive layout mismatch, and version mismatch.

The template Release workflow uses the local action. An adopted repository should
reference the public action from `acg-box/vibe-mono` at a reviewed full commit
SHA:

```yaml
- id: mold
  uses: acg-box/vibe-mono/.github/actions/install-mold@93305bc90481fef8163ea970e026c08197824f64
  with:
    version: 2.41.0
    sha256: <digest-for-the-host-architecture>
```

Keep the version and digest together. If the downloaded binary lacks
`libatomic.so.1`, the action installs Debian/Ubuntu's `libatomic1` package with
`apt-get` and passwordless `sudo` when needed; other distributions must provide
it. The action installs mold; each caller must still select it explicitly in its
compiler or Cargo linker configuration and verify the final artifact. The
upstream `rui314/setup-mold` action remains an alternative for repositories that
accept its contract, but this wrapper keeps the template's checksum,
no-global-linker, and fail-closed requirements.

## Failure Interpretation

- Missing command/tool: satisfy the prerequisite; do not rewrite the task to bypass the expected tool without a deliberate contract change.
- Formatting issue: run `cargo make fmt`, inspect changes, then rerun `cargo make check`.
- Rust compilation failure: resolve Clippy compilation/features/targets before interpreting downstream lint/test noise.
- TypeScript check failure: resolve compiler diagnostics under the pinned Node/TypeScript versions before interpreting type-aware lint noise.
- Clippy/vstyle failure: fix directly or use the matching `lint-fix*` task, then review all mutations before rerunning read-only gates.
- Oxlint failure: fix the diagnostic directly or use `lint-fix-typescript` for safe fixes only; review every mutation before rerunning compiler, lint, and tests.
- Test failure: treat as a regression or broken assumption in the current diff until evidence shows an environment/tool issue.
- Release failure: distinguish mold download/integrity/provenance, platform build, packaging/path, GitHub publication, and crates.io publication; they have different ownership and dependency edges.

Before merge, run `cargo make fmt` when formatting needs correction, then prefer `cargo make check` plus the focused OpenWiki drift checks and any release-specific dry checks justified by the changed surface. Record unavailable tools and unrun checks explicitly rather than claiming readiness.
