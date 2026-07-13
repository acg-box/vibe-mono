# Repository Quickstart

## What This Repository Is

This is a Rust 2024, workspace-first monorepo **template**, not an adopted product. Its runnable example is still named `name_placeholder`, public metadata still says `description_placeholder`, and the README contains unfinished product, dependency, configuration, and platform sections. Treat those values as replacement markers, not product facts.

The root workspace currently includes every Cargo package under `apps/*`. The only package is the placeholder CLI in `apps/name_placeholder/`; `packages/` is reserved for reusable libraries but contains no package yet. The source of truth is the implementation and configuration, with this OpenWiki as its retrieval and maintenance layer.

Sources: `README.md`, `Cargo.toml`, `apps/name_placeholder/Cargo.toml`, `apps/name_placeholder/README.md`.

## Start Here

Prerequisites for the common local path:

- Rust via `rust-toolchain.toml` (stable, minimal profile, with Cargo, Clippy, rustfmt, rust-analyzer, and rust-src).
- `cargo-make` to invoke repository-native tasks.
- Nightly rustfmt, Taplo, `cargo-vstyle`, and `cargo-nextest` for the complete gate.

Build and run the template CLI:

```sh
cargo build -p name_placeholder
cargo run -p name_placeholder -- --help
cargo run -p name_placeholder -- --placeholder example
```

Run the complete repository-defined source-validation aggregate:

```sh
cargo make check
```

The gate covers Rust compilation, Rust/TOML formatting, Clippy and vstyle, and tests. `Makefile.toml` declares these as composite dependencies but does not itself document their runtime ordering; use the explicit diagnostic sequence in [Operations](operations.md) when order matters. OpenWiki is reviewed with the focused drift checks in [Knowledge Maintenance](knowledge-maintenance.md#openwiki-drift-check).

## Wiki Map

- [Architecture and Runtime](architecture-and-runtime.md) — workspace ownership, CLI/bootstrap behavior, build metadata, placeholders, and generated/local state.
- [Operations](operations.md) — every repo-native validation and build command, tooling, CI coverage, and failure interpretation.
- [Template Adoption](template-adoption.md) — the ordered procedure for turning this template into a real repository.
- [Knowledge Maintenance](knowledge-maintenance.md) — OpenWiki routing, claim ownership, evidence/drift rules, the migrated documentation decision, and historical context.

## Repository Status And Boundaries

- `apps/` owns runnable products; `packages/` owns reusable packages shared by products. A Rust package under `packages/` is **not** a workspace member until root `Cargo.toml` deliberately includes it.
- Root `Cargo.toml` owns workspace membership, common package metadata, profiles, and dependency versions. Each app manifest owns package-specific metadata and dependency selection.
- `Makefile.toml` owns local task names. `.github/workflows/language.yml` and `.github/workflows/release.yml` own current CI and release orchestration.
- `openwiki/` is the sole maintained repository knowledge surface. Do not create a competing `docs/` or wiki root.

## Before Changing Anything

1. Read the page that owns the affected contract.
2. Verify exact behavior in the cited source/config; prefer source when prose conflicts.
3. Preserve ownership boundaries and replace template placeholders consistently.
4. Run the narrowest relevant checks, then `cargo make check` when the required external tools are available.
5. Update the owning OpenWiki page when behavior, commands, layout, status, or workflows change; record durable rationale or drift evidence when appropriate.

Use this page as the agent router and [Knowledge Maintenance](knowledge-maintenance.md) for the full update policy.
