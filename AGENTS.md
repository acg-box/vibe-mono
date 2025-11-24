# AGENTS.md

Unified Rules for Automated Agents in This Repository

This document defines the **execution model**, **coding conventions**, **design rules**, and **hard prohibitions** for all agents operating on this Rust workspace.
Agents must treat this file as authoritative.

---

# 1. Execution Model

## 1.1 Core Principle

Agents **must use only `cargo make` tasks** for all builds, lints, tests, formatting, or auxiliary operations.
Never invoke raw `cargo` or toolchain commands manually.

## 1.2 Toolchain

- The workspace is pinned via `rust-toolchain.toml`.
- Some tasks require nightly; `cargo make` handles this automatically.
- Agents must not modify or override toolchain configuration.

## 1.3 Standard Tasks

- `cargo make clippy`
- `cargo make fmt`
- `cargo make nextest`

## 1.4 Adding New Automation

1. Define a new task in `Makefile.toml`.
2. Document it here.
3. Always invoke via `cargo make <task>`.

---

# 2. Design & Implementation Principles

## 2.1 Minimal, Complete, Iterative

Implement **only the explicitly required scope**, but with production-level robustness.
Avoid speculative features or abstractions.

## 2.2 Simplicity & Structure

- Prefer simple, explicit logic over clever or generic designs.
- Keep modules cohesive and responsibilities clear.
- Use descriptive names, consistent error handling, and shallow control flow.

## 2.3 Extendable Foundations

Even minimal implementations must provide:

- Internal consistency
- Clear growth paths
- Tests covering main behavior and preventing regressions

## 2.4 Design Before Code

For non-trivial changes:

- Draft a brief design (data structures, control flow, integration points)
- Prefer proven patterns over ad-hoc solutions

## 2.5 Reuse First

Before creating new utilities:

- Prefer stdlib or existing workspace modules
- Add external dependencies only when truly required

## 2.6 Dependency Governance

- Favor actively maintained crates with compatible licenses
- Avoid duplicates or multi-purpose frameworks when smaller crates suffice
- Never add functionality already available in existing dependencies

---

# 3. Rust Coding Conventions

## 3.1 Declaration Order

Each file must follow:

```
mod
use
macro_rules
type
const
trait
enum
struct
fn
```

- `pub` items appear before non-`pub`.
- Import section headers (`// std`, `// crates.io`, `// self`) must stay.

## 3.2 Structs & Impls

A struct’s `impl` appears **immediately after the struct** with **no blank line**.

## 3.3 Generics, Bounds, UFCS

- All bounds go in a `where` clause (never inline).
- Bound order: lifetimes → std traits → project traits.
- Use turbofish when specifying generics.
- Prefer UFCS for inherent or trait-specific method calls.

## 3.4 Borrowing

Use `&value` instead of `.as_ref()` or `.as_str()` unless strictly required.

## 3.5 Macros & Logging

- Always fully qualify tracing macros: `tracing::info!`.
- Use existing variables directly; do not create temporaries solely for formatting.

## 3.6 Ownership & Iteration

- Avoid `.clone()` unless ownership must be duplicated.
- Use `.into_iter()` when the collection will not be reused.

---

# 4. Language Rules

All comments, docs, and log messages must:

- Use correct English
- Start with capital letters and end with punctuation
- Avoid slang or mixed languages

---

# 5. Hard Prohibitions (“Never Do”)

## 5.1 Toolchain & System

**Never modify:**

- `rust-toolchain.toml`
- `.cargo/config.toml`
- `rustfmt.toml`

**Never run:**

- `rustup update/install/override`
- System install commands (`apt-get`, `brew`, `pip`, etc.)

## 5.2 File Boundaries

- Do not modify files outside the repository root
- Do not touch generated files (`target/`, `OUT_DIR`, vendored code, schema outputs)

## 5.3 Patch Scope

- Patches must be unified diffs
- Only modify code explicitly requested—no opportunistic refactors

## 5.4 Style

- Never import tracing macros (use fully qualified calls)
- Never use inline trait bounds
- Never place blank lines between a struct and its impl
- Never use `.as_ref()`, `.as_str()` when `&value` works

## 5.5 Runtime & Async

- Never use `unwrap()` or `expect()` in non-test code
- Never block inside async (no `thread::sleep`, no blocking IO)

## 5.6 Documentation

- No mixed languages
- No ambiguous abbreviations or informal shorthand

## 5.7 Behavior

- Do not infer requirements
- Do not refactor, optimize, or redesign unless explicitly requested

---

# 6. Summary

This document defines all required conventions for execution, design, coding style, dependency hygiene, and prohibited operations.
Agents must follow these rules exactly to maintain consistency, safety, and predictability across the workspace.
