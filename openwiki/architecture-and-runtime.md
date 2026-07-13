# Architecture And Runtime

## Workspace Model

The repository is intentionally a small monorepo template with lanes for later growth:

| Path | Ownership |
| --- | --- |
| `apps/` | Runnable applications, services, sites, and binaries |
| `apps/name_placeholder/` | Current Rust binary package and all package-specific metadata |
| `packages/` | Reusable, language-neutral shared packages; currently only `.gitkeep` |
| `Cargo.toml` | Rust workspace membership (`apps/*`), resolver 3, shared package metadata, `final-release`, and shared dependency versions |
| `Cargo.lock` | Locked dependency graph used by release commands with `--locked` |
| `Makefile.toml` | Repository-native validation task contracts |
| `.github/` | CI, release, and dependency automation; no CodeQL workflow is currently retained |
| `openwiki/` | Maintained repository knowledge and agent routing |

The root is a virtual Cargo workspace, not a package. `apps/name_placeholder/Cargo.toml` inherits common metadata, declares the build script, selects dependencies, and names the package. The accepted workspace-first layout was introduced in commit `4f91ab1`, moving the prior root CLI without changing its runtime behavior and reserving `packages/` for future reuse.

**Ownership invariant:** put runnable surfaces in `apps/` and genuinely reusable code in `packages/`. Add a Rust package lane to workspace membership deliberately; the current `apps/*` pattern does not include `packages/*`, and non-Rust packages never belong in Cargo membership.

Sources: `Cargo.toml`, `apps/name_placeholder/Cargo.toml`, `packages/.gitkeep`, `Makefile.toml`; historical evidence: commit `4f91ab1`.

## CLI Contract

The workspace builds one binary with no subcommands. `apps/name_placeholder/src/cli.rs` derives `clap::Parser` and defines:

- `--placeholder` / `-p`, parsed as a `String` despite its displayed `value_name = "NUM"`.
- Default value `Welcome to use name_placeholder!`.
- A generated `--version` string formed as `<package-version>-<git-sha>-<target-triple>`.
- Styled help headings/usage in bold red, literals in bold blue, and placeholders in green.
- `Cli::run`, which emits one structured info log containing the parsed CLI and returns success; it produces no terminal output of its own.

The unit test checks only the default placeholder string. It does not cover parsing aliases, version metadata, logging, startup errors, or panic behavior.

Sources: `apps/name_placeholder/src/cli.rs`, `apps/name_placeholder/Cargo.toml`.

## Startup And Runtime

`apps/name_placeholder/src/main.rs` executes this sequence:

1. Install `color-eyre`; installation failure returns an error.
2. Resolve platform application data via `ProjectDirs::from("", "hack.ink", "name_placeholder")`; inability to resolve directories returns `Failed to resolve project directories.`
3. Build a non-blocking file appender in that data directory. Logs rotate weekly, use the suffix `log`, and retain at most three files. Appender construction errors abort startup through `?`.
4. Read the tracing filter from the default environment (`RUST_LOG`); an absent **or invalid** value falls back to `info`.
5. Initialize non-ANSI tracing to the file writer. The guard remains alive through CLI execution so buffered logs can flush.
6. Replace the panic hook: invoke the default hook, then abort instead of unwinding.
7. Parse arguments and run the CLI.

Changing the organization/application identifiers changes the platform data path and therefore is part of template adoption, not a cosmetic rename. Changing flags, commands, version text, logging, startup errors, or panic semantics requires updating this page and relevant tests.

Sources: `apps/name_placeholder/src/main.rs`, `apps/name_placeholder/src/cli.rs`.

## Build Metadata

`apps/name_placeholder/build.rs` uses `vergen-gitcl` to expose the target triple and Git SHA at compile time. If adding the Git instructions fails—for example in a crates.io package without usable Git metadata—the script sets `VERGEN_GIT_SHA=crates.io`. Failure to add target-triple instructions or to perform final emission still fails the build.

The release profile `final-release` inherits `release` and enables LTO. The release workflow builds each target with `--locked --profile final-release`.

Sources: `apps/name_placeholder/build.rs`, `Cargo.toml`, `.github/workflows/release.yml`.

## Placeholder And Replacement Surface

Adoption must replace or deliberately remove all coupled identity values:

- `name_placeholder` and `description_placeholder` in README files, manifests, lockfile, Rust source, workflow package/artifact names, badges, repository/homepage URLs, and OpenWiki claims.
- The app directory/package/binary name and all Cargo `-p` selectors.
- `ProjectDirs` organization/application identifiers and the resulting data location.
- CLI default text, crate-level docs, release archive names, and crates.io publication target.
- README TODOs and fake installation dependencies; these are incomplete template guidance, not valid product instructions.

Use [Template Adoption](template-adoption.md) for sequencing.

## Generated And Local-Only Paths

These are not tracked source owners:

- `target/`: Cargo build output, final-release binaries, bundles, and local artifacts.
- `.worktrees/` and `.workspaces/`: local Git/workspace lanes.
- `.agent/` and `.codex/`: local agent/runtime state.
- `tmp/`: scratch data.
- Other ignored language/tool output in `.gitignore`, including `build`, `dist`, `coverage`, and `node_modules`.
- Platform application data created by the CLI, including rotating logs.

Never infer repository state from these paths or commit them as source. `.taplo.toml` also excludes generated, local, and tool-owned trees from formatting.

Sources: `.gitignore`, `.taplo.toml`, `apps/name_placeholder/src/main.rs`.

## Change Guide

- Workspace/package move: update both manifests, package paths, workflows, README commands, OpenWiki ownership, and lockfile; run all checks.
- CLI/runtime change: start in `apps/name_placeholder/src/cli.rs` or `apps/name_placeholder/src/main.rs`; add behavior tests and update this page.
- Shared package addition: establish its language-specific manifest first, then update only the appropriate workspace/tooling membership.
- Release identity/profile change: update manifest metadata and `.github/workflows/release.yml` together; verify archive paths on all target OSes.
