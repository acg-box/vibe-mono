# Workspace Layout Reference

Purpose: Explain the current template repository layout, which files own which concerns, and which
paths are tracked source versus generated or local runtime state.

Read this when: You are deciding where a change belongs, checking whether the current layout still
matches the implementation, or routing a docs/code question to the right file.

Sources: `Cargo.toml`; `Makefile.toml`; `README.md`; `src/main.rs`; `src/cli.rs`

Depends on: `docs/spec/cli.md`

Covers: The tracked workspace layout, ownership boundaries, and the local directories that should
not be treated as repository source.

## Current top-level layout

| Path | Role |
| --- | --- |
| `src/main.rs` | Binary entrypoint, runtime bootstrap, logging setup, and panic-hook behavior |
| `src/cli.rs` | CLI argument surface and command execution |
| `build.rs` | Build-time metadata emission through `vergen-gitcl` |
| `Cargo.toml` | Package metadata and Rust dependency graph |
| `Makefile.toml` | Repo-native lint, test, and formatting entrypoints |
| `docs/` | Agent-facing docs split into `spec`, `runbook`, `reference`, and `decisions` |
| `.github/` | Repository automation such as Dependabot and workflows |

## Documentation placement

- `README.md`: public project overview and setup guidance
- `docs/spec/`: normative contracts for current behavior
- `docs/runbook/`: repeatable execution and validation steps
- `docs/reference/`: current layout and implementation notes
- `docs/decisions/`: durable rationale for accepted tradeoffs

## Local-only and generated directories

These paths are intentionally not part of the tracked source layout:

- `target/`: Rust build outputs and local artifacts
- `.worktrees/`: local git worktree lanes
- `.workspaces/`: local clone-backed workspace lanes from older workflows
- `.codex/`: local agent/runtime state

## Structure assessment

The current template layout is intentionally shallow:

- source lives under `src/`
- automation entrypoints live in `Makefile.toml`
- durable docs live under `docs/`
- build metadata lives in `build.rs`

This is a reasonable starting shape for generated projects because it keeps routing simple and
leaves room for later subfolders only when the codebase actually grows into them.
