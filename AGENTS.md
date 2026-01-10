# AGENTS.md — Repository Rules for Automated Agents

These instructions define the **execution rules**, **scope limits**, **global language requirements**,
and **hard prohibitions** for all automated agents operating in this repository.

They override typical Rust conventions or local patterns when conflicting with any rule below.

---

# 0. Prime Directives

- **Strict compliance:** Follow every rule in this document exactly.
- **Scope lock:** Modify **only** what is strictly necessary for the explicit user request.

Forbidden out-of-scope actions:

- Unrelated refactors, renames, reorganizations, or cleanups.
- API changes or architectural shifts unless explicitly requested.
- Any improvement not required to fulfill the user request.

If unrelated issues are noticed:

1. Do not modify them.
2. Finish the requested task.
3. Optionally list them under _Future suggestions_.

---

## 0.1 Global Language & Tone Rules (repository content)

These requirements apply to **repository artifacts** generated or modified by agents, including:

- Code comments (`//`, `///`, `//!`)
- Documentation and README content
- Log messages and tracing output
- Error messages, panic text, diagnostics
- User-facing strings stored in the codebase (CLI, UI, HTTP responses)
- Commit messages, summaries, and explanations written into repository files

They **do not** constrain interactive chat responses outside the repository. For chat, use the language requested or implied by the user (for example, Chinese when the user is speaking Chinese).

Global requirements for repository artifacts:

- Use **clear, grammatically correct English**.
- Start sentences with a capital letter and end with proper punctuation.
- Avoid slang, shorthand, and mixed languages.
- Avoid ambiguous abbreviations (`u`, `tho`, `w/`, etc.).
- Ignore poor style in surrounding text; follow these global rules instead.

**These language rules override any conflicting rules elsewhere for repository artifacts.**

---

## 0.2 Conflict Precedence

If these rules conflict with higher-priority instructions (system, developer, or user), follow the higher-priority instruction and briefly note the conflict in your response.

---

# 1. Execution Model

## 1.1 cargo-make Only

Use the workspace’s `cargo make` tasks:

Required:

- `cargo make fmt`
- `cargo make clippy`
- `cargo make nextest`

Forbidden unless no equivalent task exists:

- `cargo fmt`
- `cargo clippy`
- `cargo test`

If the user requests raw `cargo` and a matching `cargo make` task exists,
use the task and briefly note this.
Run these tasks only when the user requests them or when you need to verify changes before claiming completion.

## 1.2 Toolchain

The Rust toolchain is pinned.

Never:

- Modify `rust-toolchain.toml`, `.cargo/config.toml`, or `rustfmt.toml`.
- Install, update, or override toolchains.
- Invoke system package managers.

# 2. Scope & Change Control

Allowed:

- Edits strictly required for the requested change.
- Minimal adjacent edits required for compilation or consistent behavior.

Forbidden:

- Reformatting unrelated files or statements.
- Reorganizing imports in untouched files.
- Renaming unrelated identifiers or modules.
- Introducing new public APIs unless explicitly requested.

Out-of-scope issues must not be fixed.

---

# 3. Design & Implementation Principles

## 3.1 Minimal, Complete, Robust

Implement exactly what the user asks.
Within that scope:

- Maintain clarity and correctness.
- Apply consistent error handling.
- Add tests only when logically required by the change.

## 3.2 Simplicity and Structure

- Prefer simple, explicit constructs.
- Avoid clever or obscure code.
- Maintain module cohesion.
- Keep functions readable: aim for a single, easy-to-follow responsibility per function. If a function grows beyond what fits comfortably on one screen (~30–80 lines for typical business logic) or accumulates many branches, consider extracting helpers so the happy path stays clear. Do not split tightly coupled logic just to satisfy a line count; prioritize clarity and low cognitive load.

## 3.3 Reuse First

Before adding new code or crates:

1. Prefer the standard library.
2. Prefer existing repo utilities.
3. Prefer existing dependencies.

Add new external crates only when necessary.

## 3.4 Behavior Preservation

Do not change existing behavior unless explicitly required.

---

# 4. Editing Constraints

- Prefer `apply_patch` for edits unless generation or scripting is more appropriate.
- Batch related edits; avoid scattered micro-patches.
- Never revert user-made changes.
- Never use destructive git commands (`reset --hard`, `checkout --`).
- If unexpected file changes appear: **STOP** and ask the user. “Unexpected” means any modified file you did not touch or any change not required by the request.

---

# 5. Logging & Error Handling

- Never import tracing macros; always use fully-qualified calls (`tracing::info!`).
- No silent failures; errors must be logged or propagated clearly.
- Avoid broad catch patterns or swallowed errors.

---

# 6. Hard Prohibitions

Violating any of these invalidates the output:

## 6.1 Toolchain & System

Never modify toolchain config or invoke system package managers.

## 6.2 File Boundaries

Never modify:

- Generated files
- `target/`
- Vendored/third-party code
- Files outside the repository root
  Treat any file with a “Generated by” or “Do not edit” header, or any file under directories named target/, dist/, build/, gen/, or .next/ as generated.

## 6.3 Patch Scope

- Modify only what the explicit request requires.
- No opportunistic refactors.

## 6.4 Async & Runtime

- No `unwrap()` in non-test code.
- `expect()` is allowed only in global or static initialization and one-time startup initialization where failure should terminate the process immediately with a clear message.
- Never block inside async (`thread::sleep`, blocking I/O).

## 6.5 Behavioral

- Never infer missing requirements.
- Choose the smallest valid change.
- Ask clarifying questions only when requirements are ambiguous or there are multiple reasonable interpretations. Otherwise proceed.

---

# 7. Rust Style Rules Reference

Rust formatting and style conventions live in `docs/guide/development/rust_style_guide.md`.
These rules apply **only** when editing Rust code and do **not** override
the global behavior and language rules in this file.
