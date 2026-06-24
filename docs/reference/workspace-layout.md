---
type: Reference
title: Workspace Layout Reference
description: Maps the template repository layout, tracked owners, generated outputs, and local-only directories.
status: active
authority: current_state
owner: maintainers
last_verified: 2026-06-25
tags:
  - layout
  - template
  - rust
source_refs: []
code_refs:
  - Cargo.toml
  - Makefile.toml
  - README.md
  - src/main.rs
  - src/cli.rs
related:
  - ../spec/cli.md
  - ../runbook/template-adoption.md
drift_watch:
  - Cargo.toml
  - Makefile.toml
  - README.md
  - src/**
  - .github/**
---

# Workspace Layout Reference

Purpose: Explain the current template repository layout, which files own which
concerns, and which paths are tracked source versus generated or local runtime
state.

Read this when: You are deciding where a change belongs, checking whether the
current layout still matches the implementation, or routing a docs/code question
to the right file.

Sources: `Cargo.toml`; `Makefile.toml`; `README.md`; `src/main.rs`; `src/cli.rs`

Depends on: `docs/spec/cli.md`; `docs/policy.md`

Covers: The tracked workspace layout, ownership boundaries, template
placeholders, generated outputs, and local directories that should not be
treated as repository source.

## Current Top-Level Layout

| Path | Role |
| --- | --- |
| `src/main.rs` | Binary entrypoint, runtime bootstrap, logging setup, and panic-hook behavior |
| `src/cli.rs` | CLI argument surface and command execution |
| `build.rs` | Build-time metadata emission through `vergen-gitcl` |
| `Cargo.toml` | Package metadata and Rust dependency graph |
| `Cargo.lock` | Locked Rust dependency graph for reproducible local and CI checks |
| `Makefile.toml` | Repo-native docs, lint, test, and formatting entrypoints |
| `docs/` | Repository LLM Wiki and strict Markdown OKF bundle |
| `.github/` | Repository automation such as Dependabot and workflows |

## Documentation Layout

| Path | Role |
| --- | --- |
| `README.md` | Public project overview, badges, setup guidance, and template placeholder surface |
| `docs/index.md` | LLM Wiki router for the smallest owning document set |
| `docs/policy.md` | OKF concept rules, lane ownership, update workflow, and docs gate |
| `docs/log.md` | Maintenance log for routing, promotion, rename, and docs-policy changes |
| `docs/spec/` | Normative contracts for current behavior |
| `docs/runbook/` | Repeatable execution and validation steps |
| `docs/reference/` | Current layout and implementation notes |
| `docs/decisions/` | Durable rationale for accepted tradeoffs |
| `docs/research/` | Non-authoritative research contracts and latent proposals |
| `docs/evidence/` | Drift audits and public-safe proof |

## Template Placeholder Surface

The current template intentionally includes placeholders that a generated
repository must replace:

- `name_placeholder`
- `description_placeholder`
- GitHub badge and release URLs under `hack-ink/name_placeholder`
- package metadata in `Cargo.toml`
- CLI default text in `src/cli.rs`
- app data path ownership in `src/main.rs`
- release artifact names in `.github/workflows/release.yml`

Use `docs/runbook/template-adoption.md` for the replacement sequence.

## Local-Only And Generated Directories

These paths are intentionally not part of the tracked source layout:

- `target/`: Rust build outputs and local artifacts
- `.worktrees/`: local git worktree lanes
- `.workspaces/`: local clone-backed workspace lanes from older workflows
- `.agent/`: local agent state
- `.codex/`: local agent/runtime state
- `tmp/`: local scratch files

## Structure Assessment

The current template layout is intentionally shallow:

- source lives under `src/`
- automation entrypoints live in `Makefile.toml`
- durable docs live under `docs/`
- build metadata lives in `build.rs`

This is a reasonable starting shape for generated projects because it keeps
routing simple and leaves room for later subfolders only when the codebase
actually grows into them.
