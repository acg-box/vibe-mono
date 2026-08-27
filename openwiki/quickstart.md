---
type: "Reference"
title: "Repository Quickstart"
openwiki_generated: true
sources:
  - id: openwiki-source-4d1d392666be6dfdd7a91a2e
    resource: repo://.github/workflows/release.yml
  - id: openwiki-source-7437def7410a3f1ed2549b16
    resource: repo://.node-version
  - id: openwiki-source-27406d23c7732a24a700fbf9
    resource: repo://apps/name_placeholder/Cargo.toml
  - id: openwiki-source-651d1fb6c9e49916a916ab51
    resource: repo://Cargo.toml
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

# Repository Quickstart

## What This Repository Is

This is a Rust 2024, workspace-first monorepo **template**, not an adopted product. Its runnable Rust example is still named `name_placeholder`, its private npm tool package is still named `name-placeholder-workspace`, public metadata still says `description_placeholder`, and the README contains unfinished product, dependency, configuration, and platform sections. Treat those values as replacement markers, not product facts.

The root workspace currently includes every Cargo package under `apps/*`. The only package is the placeholder CLI in `apps/name_placeholder/`; `packages/` is reserved for reusable libraries but contains no package yet. `scripts/` owns Node.js-executed TypeScript maintenance programs and currently contains the tracked template-marker inventory helper and its integration test. The source of truth is the implementation and configuration, with this OpenWiki as its retrieval and maintenance layer.

Sources: `README.md`, `Cargo.toml`, `rust-toolchain.toml`, `package.json`, `tsconfig.json`, `apps/name_placeholder/Cargo.toml`, `apps/name_placeholder/README.md`, `scripts/list-template-markers.ts`.

## Start Here

Prerequisites for the common local path:

- Rust via `rust-toolchain.toml` (stable with the minimal profile and the Clippy component used by repository lint tasks).
- Rustfmt from the separately managed nightly toolchain for `fmt-rust`; stable rustfmt and LLVM tools are not repository requirements.
- Node.js 26.8.1 via `.node-version` and npm 11.19.0 via the package manifest; `npm ci --ignore-scripts` installs the exact local TypeScript/Oxc tool graph from `package-lock.json`.
- `cargo-make` to invoke repository-native tasks.
- Taplo, `cargo-vstyle`, and `cargo-nextest` for the complete gate.

The release jobs honor the repository toolchain file and use the pinned Rust toolchain setup action with caching; the workflows do not request extra components of their own.

Build and run the template CLI:

```sh
cargo build -p name_placeholder
cargo run -p name_placeholder -- --help
cargo run -p name_placeholder -- --placeholder example
```

List tracked template markers through the TypeScript adoption helper:

```sh
npm ci --ignore-scripts
cargo make list-template-markers
```

Run the repository-defined source-validation aggregate:

```sh
cargo make check
```

`typecheck` runs the repository-local TypeScript compiler from `node_modules` without emitting files. `lint` runs repository-declared Clippy for Rust compilation/static analysis, local type-aware Oxlint, and vstyle; `test` runs Rust and TypeScript tests. `check` combines these three validation groups. Oxfmt and Oxlint are local development dependencies, and their tasks use deterministic `node_modules` entrypoints rather than global commands. Run `cargo make fmt` separately to correct Rust, TypeScript, and TOML formatting; `fmt` is intentionally not a `check` dependency. `Makefile.toml` declares the composite dependencies but does not itself document their runtime ordering; use the explicit diagnostic sequence in [Operations](operations.md) when order matters. OpenWiki is reviewed with the focused drift checks in [Knowledge Maintenance](knowledge-maintenance.md#openwiki-drift-check).

## Wiki Map

- [Architecture and Runtime](architecture-and-runtime.md) — workspace ownership, CLI/bootstrap behavior, build metadata, placeholders, and generated/local state.
- [Operations](operations.md) — every repo-native validation and build command, tooling, CI coverage, and failure interpretation.
- [Template Adoption](template-adoption.md) — the ordered procedure for turning this template into a real repository.
- [Knowledge Maintenance](knowledge-maintenance.md) — OpenWiki routing, claim ownership, evidence/drift rules, the migrated documentation decision, and historical context.

## Repository Status And Boundaries

- `apps/` owns runnable products; `packages/` owns reusable packages shared by products. A Rust package under `packages/` is **not** a workspace member until root `Cargo.toml` deliberately includes it.
- `scripts/` owns repository-maintenance TypeScript programs. Root `package.json`, `package-lock.json`, `tsconfig.json`, `.oxfmtrc.json`, and `.oxlintrc.json` own their runtime and validation policy.
- Root `Cargo.toml` owns workspace membership, common package metadata, profiles, and dependency versions. Each app manifest owns package-specific metadata and dependency selection.
- `Makefile.toml` owns local validation tasks. `.github/workflows/release.yml` owns tag-based release and publishing orchestration; `.github/actions/` owns reusable repository actions. No tracked workflow validates pull requests, merge queues, or branch pushes.
- `openwiki/` is the sole maintained repository knowledge surface. Do not create a competing `docs/` or wiki root.

## Before Changing Anything

1. Read the page that owns the affected contract.
2. Verify exact behavior in the cited source/config; prefer source when prose conflicts.
3. Preserve ownership boundaries and replace template placeholders consistently.
4. Run the narrowest relevant checks, then `cargo make check` when the required external tools are available.
5. Update the owning OpenWiki page when behavior, commands, layout, status, or workflows change; record durable rationale or drift evidence when appropriate.

Use this page as the agent router and [Knowledge Maintenance](knowledge-maintenance.md) for the full update policy.
