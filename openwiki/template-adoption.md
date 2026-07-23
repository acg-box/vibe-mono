---
type: "Reference"
title: "Template Adoption"
openwiki_generated: true
---

# Template Adoption

## Goal And Preconditions

Use this procedure when deriving a real repository from the template. Before editing, know the project name and description, repository/homepage, maintainers, runtime/interface shape, application-data owner, release targets, and whether the workspace remains a monorepo.

Success means no unintended template identity remains, ownership and runtime docs describe the real project, release/package paths agree, and relevant validation passes. A blind global replacement is insufficient because some placeholders require design decisions or path moves.

Sources: `README.md`, `Cargo.toml`, `Cargo.lock`, `package.json`, `package-lock.json`, `scripts/list-template-markers.ts`, `apps/name_placeholder/Cargo.toml`, `apps/name_placeholder/README.md`, `apps/name_placeholder/src/main.rs`, `apps/name_placeholder/src/cli.rs`, `.github/workflows/language.yml`, `.github/workflows/release.yml`; migration rationale and history are retained in [Knowledge Maintenance](knowledge-maintenance.md).

## 1. Establish Identity And Inventory

Install the exact TypeScript tool graph and inventory the configured markers in tracked source:

```sh
npm ci --ignore-scripts
cargo make list-template-markers
```

The helper scans all tracked files through `git grep`, forwards `path:line:text` records, and does not read untracked or ignored secret-bearing files. Before Node/npm is available, use this scoped bootstrap fallback:

```sh
rg -n 'name_placeholder|name-placeholder-workspace|description_placeholder|hack-ink/name_placeholder|Welcome to use' \
  README.md Cargo.toml Cargo.lock package.json package-lock.json apps scripts .github openwiki
```

Decide the canonical Cargo package/binary name, private npm tool-package name, app directory name, repository URLs, package description, owners, and platform data identity before replacing anything.

Replacement surface includes:

- Root and app README files, badges, links, install/build commands, and TODO sections.
- Root private npm tool-package identity and `package-lock.json`; regenerate the lock with the pinned npm version rather than editing it by hand.
- Root workspace metadata, app package metadata, `Cargo.lock`, crate docs, and tests.
- App directory name, Cargo package selectors, binary paths, and optional bundle paths.
- `ProjectDirs` organization/application identifiers, CLI default text, and version/help expectations.
- All GitHub workflows that refer to package names, release assets, repository identity, or path filters.
- OpenWiki architecture, operations, adoption, and routing claims.

Keep `scripts/list-template-markers.ts` after adoption. Its configured markers intentionally retain the original template identity so a fully adopted repository produces no marker records and later regressions remain visible.

## 2. Define The Real Runtime Contract

Read [Architecture and Runtime](architecture-and-runtime.md) and choose deliberately:

- If the placeholder CLI remains structurally valid, rename it and document its real arguments and effects.
- If commands, flags, configuration, startup, logging, errors, or panic behavior change, implement tests and replace the corresponding contract rather than preserving template prose.
- If there is no CLI, remove/replace the app and make the true runtime surface the architecture owner.
- If application-data identity changes, decide migration/compatibility expectations for existing local data; renaming `ProjectDirs` silently points at a different directory.
- Keep the TypeScript marker inventory read-only and scoped to tracked files. If adoption changes its marker set, output, or exit semantics, update its integration test and the operations contract together.

Do not describe placeholder behavior as product behavior after the implementation diverges.

## 3. Preserve Ownership Boundaries Deliberately

Default boundaries are useful but not immutable:

- Keep deployable/runnable products under `apps/`.
- Put a library under `packages/` only when it is reused or intentionally public; avoid speculative packages.
- Add real Rust package paths to root workspace membership. Never include non-Rust package directories in Cargo merely to mirror the filesystem.
- Keep shared versions/profiles/metadata at the root and package-specific declarations in package manifests.
- Add new top-level owners such as `scripts/` or `artifacts/` only when they exist and have a durable boundary.
- Keep repository-maintenance TypeScript in `scripts/`; do not move it into Cargo membership or a speculative reusable package.
- Keep generated output and machine-local state out of tracked source and out of documentation evidence.

If the project rejects this workspace model, record why in [Knowledge Maintenance](knowledge-maintenance.md#durable-decisions) or a focused decision page before future agents have to reconstruct the tradeoff.

## 4. Reconcile Build And Release

Update together:

- `apps/<app>/build.rs` fallback/version behavior.
- Root `final-release` profile if release needs differ.
- Root private npm tool-package identity and its generated lockfile.
- `.github/workflows/release.yml` package selectors, target matrix, executable names, archive names, paths, and publication target.
- README download/install instructions and docs.rs/repository badges.
- `Cargo.lock` after package identity/dependency changes.

Check whether GitHub Release publication and registry publication should remain independent. The template runs crates.io publication without `needs: [build]`; changing that dependency is a release-policy decision, not just YAML cleanup.

## 5. Migrate Knowledge Ownership

`openwiki/` is the maintained knowledge surface. For every changed behavior or boundary:

- Update the source/configuration that owns the claim, run `openwiki code --update --print`, and review the generated owning-page diff; use direct page edits only for explicit curation or correction.
- Keep one canonical page per claim and link from other pages instead of copying it.
- Preserve the accepted reason for a checked-in, agent-routable knowledge system, but use OpenWiki pages rather than recreating the legacy strict OKF lane tree.
- Convert unresolved options into explicitly non-authoritative research notes only when there is active research.
- Add public-safe drift evidence when a critical code/config/status alignment needs proof.
- Keep `quickstart.md` links and any repository-level OpenWiki routing block aligned when page names or the documentation workflow changes.

Do not recreate `docs/` or another knowledge root as a second authority.

## 6. Validate

Run narrow checks while iterating, then the full available gate:

```sh
cargo make fmt
cargo make check
```

Also verify:

```sh
cargo make list-template-markers
cargo run -p <real-package> -- --help
cargo build -p <real-package> --profile final-release --locked
```

`list-template-markers` must produce no marker records after adoption. Cargo-make can still print task status. If Node/npm is not available, use the scoped `rg` fallback from step 1.

Independently validate OpenWiki links, cited paths, routing from `quickstart.md`, and alignment with source. Any unresolved mismatch blocks adoption readiness; there is intentionally no `check-docs` command to substitute for this review.

## Replacement Triggers

Revisit this runbook when any of these occurs:

- The repository is no longer a template.
- The workspace changes from `apps/*`, gains shared packages, or changes the TypeScript scripts toolchain.
- The CLI/runtime, app-data location, package identity, or release destinations change.
- OpenWiki gains an authorized validation command or maintenance automation.
- Repository automation changes what constitutes a required pre-merge or release gate.
