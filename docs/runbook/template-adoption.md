---
type: Runbook
title: Template Adoption Runbook
description: Defines the sequence for deriving a real repository from this template while preserving docs and OKF integrity.
status: active
authority: procedural
owner: maintainers
last_verified: 2026-06-25
tags:
  - template
  - adoption
  - okf
  - llm-wiki
source_refs: []
code_refs:
  - README.md
  - Cargo.toml
  - src/main.rs
  - src/cli.rs
related:
  - ../policy.md
  - ../spec/cli.md
  - ../reference/workspace-layout.md
  - ../decisions/docs-okf-template-foundation.md
drift_watch:
  - README.md
  - Cargo.toml
  - src/main.rs
  - src/cli.rs
  - docs/**
---

# Template Adoption Runbook

Goal: Convert this template into a project-specific repository without losing
the docs-backed OKF/LLM Wiki foundation.

Read this when: You are starting a new repository from this template or checking
whether a generated repository still carries template placeholders.

Preconditions: A new repository has been created from this template and the
project name, description, runtime shape, and owner are known.

Depends on: `docs/policy.md`; `docs/spec/cli.md`;
`docs/reference/workspace-layout.md`

Verification: Placeholders are replaced, owner concepts match the generated
project, and `cargo make check-docs` passes.

## 1. Replace Public Identity

Replace `name_placeholder` and `description_placeholder` in:

- `README.md`
- `Cargo.toml`
- `Cargo.lock`
- `src/main.rs`
- `src/cli.rs`
- `.github/workflows/*.yml`
- docs concepts that describe the package, binary, repository, or app data path

Keep replacement names consistent across package metadata, binary paths, badges,
release artifacts, app data directories, and CLI examples.

## 2. Reclassify The CLI Contract

Read `docs/spec/cli.md` and decide whether the generated repository still uses
the template CLI.

- If the CLI is still the placeholder CLI, keep the spec and update only names.
- If the CLI adds commands, flags, config, logging changes, or startup behavior,
  replace the spec with the real contract.
- If the project has no CLI, replace the spec with the owning runtime contract
  and update `docs/spec/index.md`.

## 3. Update The Layout Reference

Read `docs/reference/workspace-layout.md` after the first real project files are
created.

- Add new top-level owners such as `crates/`, `apps/`, `packages/`, `scripts/`,
  or generated artifact directories only when they exist.
- Keep local-only paths separate from tracked source paths.
- Keep one layout owner; do not repeat the same map in README and docs.

## 4. Preserve The LLM Wiki Shape

Keep these files unless the generated repository intentionally replaces the docs
profile:

- `docs/index.md`
- `docs/policy.md`
- `docs/log.md`
- every lane `index.md`
- at least one drift audit under `docs/evidence/`

Add new concepts only for real owners. Do not create placeholder concepts to
make the tree look complete.

## 5. Record Durable Choices

Add a decision record under `docs/decisions/` when repository setup accepts a
tradeoff that future agents should not rediscover from scratch.

Examples:

- choosing a package layout
- adopting a runtime boundary
- selecting a release strategy
- replacing the template CLI with another interface

Do not use decisions for transient task notes or unresolved research.

## 6. Validate

Run:

```sh
cargo make check-docs
```

For a full local validation pass, run:

```sh
cargo make check
```

If docs check fails, repair the owning concept, index, or log before claiming the
generated repository is ready.
