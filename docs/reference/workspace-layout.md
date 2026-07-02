---
type: Reference
title: Workspace Layout Reference
description: Maps the template repository layout, tracked owners, generated outputs, and local-only directories.
status: active
authority: current_state
owner: maintainers
last_verified: 2026-07-02
tags:
  - layout
  - template
  - rust
source_refs: []
code_refs:
  - Cargo.toml
  - apps/name_placeholder/Cargo.toml
  - Makefile.toml
  - README.md
  - apps/name_placeholder/src/main.rs
  - apps/name_placeholder/src/cli.rs
related:
  - ../spec/cli.md
  - ../runbook/template-adoption.md
drift_watch:
  - Cargo.toml
  - apps/**
  - packages/**
  - Makefile.toml
  - README.md
  - .github/**
---

# Workspace Layout Reference

Purpose: Explain the current template repository layout, which files own which
concerns, and which paths are tracked source versus generated or local runtime
state.

Read this when: You are deciding where a change belongs, checking whether the
current layout still matches the implementation, or routing a docs/code question
to the right file.

Sources: `Cargo.toml`; `apps/name_placeholder/Cargo.toml`;
`Makefile.toml`; `README.md`; `apps/name_placeholder/src/main.rs`;
`apps/name_placeholder/src/cli.rs`

Depends on: `docs/spec/cli.md`; `docs/policy.md`

Covers: The tracked workspace layout, ownership boundaries, template
placeholders, generated outputs, and local directories that should not be
treated as repository source.

## Current Top-Level Layout

| Path | Role |
| --- | --- |
| `apps/` | Application workspace lane for deployable binaries, services, sites, and apps |
| `apps/name_placeholder/` | Default Rust CLI application package |
| `apps/name_placeholder/src/main.rs` | Binary entrypoint, runtime bootstrap, logging setup, and panic-hook behavior |
| `apps/name_placeholder/src/cli.rs` | CLI argument surface and command execution |
| `apps/name_placeholder/build.rs` | Build-time metadata emission through `vergen-gitcl` |
| `packages/` | Shared package lane for reusable libraries across languages |
| `Cargo.toml` | Rust workspace membership, shared package metadata, and shared Rust dependencies |
| `apps/name_placeholder/Cargo.toml` | Rust package metadata and app-specific dependency ownership |
| `Cargo.lock` | Locked Rust dependency graph for reproducible local and CI checks |
| `Makefile.toml` | Repo-native docs, lint, test, and formatting entrypoints |
| `docs/` | Repository LLM Wiki and strict Markdown OKF bundle |
| `.github/` | Repository automation such as Dependabot and workflows |

## Workspace Lanes

- `apps/` contains runnable surfaces. The default Rust CLI app lives at
  `apps/name_placeholder/`.
- `packages/` is intentionally language-neutral. Add reusable Rust crates,
  TypeScript packages, Python packages, Swift packages, or other shared
  libraries here when they are consumed by more than one app.
- The root `Cargo.toml` includes `apps/*` as Rust workspace members. Add Rust
  package lanes deliberately when a future `packages/*` directory contains a
  `Cargo.toml`; do not force non-Rust package directories into the Cargo
  workspace.

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
- workspace package metadata in root `Cargo.toml`
- app package metadata in `apps/name_placeholder/Cargo.toml`
- app package README in `apps/name_placeholder/README.md`
- CLI default text in `apps/name_placeholder/src/cli.rs`
- app data path ownership in `apps/name_placeholder/src/main.rs`
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

The current template layout is intentionally workspace-first:

- runnable application source lives under `apps/name_placeholder/src/`
- future reusable package source belongs under `packages/<package-name>/`
- automation entrypoints live in `Makefile.toml`
- durable docs live under `docs/`
- build metadata lives in `apps/name_placeholder/build.rs`

This shape keeps the first generated project small while preserving clear lanes
for monorepos that later mix Rust, Node, Python, Swift, or other language
toolchains.
