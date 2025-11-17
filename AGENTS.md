# Agent Workflow

## Overview

This document defines the tooling rules, execution model, design and implementation principles, coding conventions, and hard restrictions that apply to all automated agents interacting with this Rust repository. Its purpose is to ensure reproducibility, consistent formatting, predictable behavior, and safe automation across the workspace.

Agents must strictly follow every rule in this document when generating, modifying, or verifying source code or configuration.

---

# **1. Execution Principles**

## **1.1 Guiding Principle**

Agents must always use the curated `cargo make` tasks defined in `Makefile.toml` for all build, lint, format, test, and auxiliary operations.

Agents must **never** run raw `cargo` commands or manually invoke toolchains.

This guarantees:

- Correct toolchain selection
- Consistent feature flags
- Stable formatting and linting
- No divergence from expected project behavior

---

## **1.2 Toolchain Notes**

- The repository pins the stable Rust toolchain via `rust-toolchain.toml`.
- Certain tasks (e.g., formatting, some lint steps) require nightly, and the corresponding `cargo make` tasks already inject the correct version.
- Agents must not alter toolchain definitions or configuration files.

---

## **1.3 Common Tasks**

- `cargo make clippy` — Lints the entire workspace under the expected feature matrix.
- `cargo make fmt` — Formats the repository using the pinned nightly toolchain.
- `cargo make nextest` — Runs the full test suite via nextest.

Agents must prefer these tasks over any raw `cargo` invocation.

---

## **1.4 Adding New Automation**

When introducing any new automation:

1. Define a dedicated task inside `Makefile.toml`.
2. Document that task in this file so that all agents can use it.
3. Always invoke the task via `cargo make <task>`.

---

# **2. Design, Implementation, and Dependency Principles**

These principles define how agents should design, structure, and integrate changes so that implementations remain minimal, robust, and easy to evolve.

---

## **2.1 Minimal, Iterative, and Agile Delivery**

- Agents must prefer **minimal, end-to-end implementations** that fully satisfy the current, explicitly stated requirements without introducing speculative features.
- Each change set must solve a well-defined problem with the smallest reasonable surface area in terms of:
    - New types
    - New modules
    - New configuration knobs
- Minimal does **not** mean “quick-and-dirty” or “prototype-only.” A minimal solution must still be:
    - Robust under expected inputs and error conditions
    - Consistent with the rest of the codebase
    - Safe to build upon in future iterations

Agents must not introduce additional behavior, features, or configuration solely “because it might be useful later.” All scope expansion must be driven by explicit requirements.

---

## **2.2 Simple, Logical, and Well-Structured Code**

- Prefer straightforward, explicit control flow over clever, highly generic, or meta-programmed abstractions.
- Keep modules cohesive: each module should have a clear responsibility and avoid mixing unrelated concerns.
- Within a module, group related types and functions together so that the logical flow is easy to follow.
- Prefer clear, descriptive names for types, functions, and variables that reflect their domain meaning.
- Error handling must be structured and consistent:
    - Propagate errors with context where appropriate.
    - Avoid deeply nested control structures when a simpler decomposition is possible.

The target is **simple and logical**, not simplistic. Agents should prioritize readability and maintainability over micro-optimizations unless performance is an explicit requirement.

---

## **2.3 Robust Foundations for Future Iterations**

Even when implementing the minimal feature set, agents must ensure that the resulting code:

- Is **internally consistent** and free of obvious edge-case failures within the stated requirements.
- Has a clear extension path: later iterations should be able to add complexity without needing to discard or radically rewrite the initial implementation.
- Includes appropriate tests (unit, integration, or property-based) that:
    - Cover the main code paths
    - Lock in externally observable behavior
    - Reduce the risk of regressions when the feature is extended

Agents must design minimal implementations as **foundations**, not throwaway prototypes.

---

## **2.4 Design Before Implementation**

For any non-trivial change (e.g., new public API, non-trivial state machine, cross-crate integration), agents must:

1. Sketch a brief design before editing:
    - Key data structures and their relationships
    - Main control flow and error handling strategy
    - How the new pieces integrate with existing crates and modules
2. Ask explicitly whether the design aligns with:
    - Established industry best practices for the problem domain
    - Well-understood and production-proven patterns or algorithms
3. Prefer **known, validated patterns** over ad-hoc designs when multiple options are viable.

The design can be kept lightweight (short text, comments, or a high-level outline), but the design step must not be skipped for complex features.

---

## **2.5 Prefer Reuse Over Reinventing**

- Before introducing new utilities or abstractions, agents must:
    - Check whether equivalent functionality already exists in the workspace.
    - Prefer using the Rust standard library or well-known crates from the ecosystem where appropriate.
- Agents must avoid reimplementing generic functionality (e.g., parsing, serialization, retry logic, HTTP clients, collection utilities) when a **mature, well-maintained, and appropriately licensed** crate already solves the problem.
- New custom utilities or “wheel reinventions” are allowed only when:
    - Existing solutions do not meet functional, performance, or security requirements, or
    - The repository has an explicit policy or constraint that forbids the candidate dependency.

When introducing new abstractions instead of reusing existing ones, agents must be able to justify the decision based on explicit requirements or constraints.

---

## **2.6 Dependency Governance and Hygiene**

When adding or modifying dependencies, agents must follow strict dependency governance rules:

- **Assess maintenance and stability**
    - Prefer crates with active maintenance, recent releases, and evidence of real-world usage.
    - Avoid depending on experimental or abandoned crates for critical functionality.

- **Check license compatibility**
    - Ensure that the crate’s license is compatible with this repository’s licensing and distribution model.
    - If there is any ambiguity, agents must not introduce the dependency without an explicit requirement or prior approval.

- **Control dependency graph growth**
    - Avoid large, multi-purpose frameworks when a smaller, focused crate or the standard library can satisfy the requirement.
    - Prefer adding a single, well-scoped crate over introducing multiple overlapping dependencies.

- **Prefer existing capabilities**
    - When the functionality can be implemented using:
        - The Rust standard library,
        - Existing crates already in the dependency tree, or
        - Existing internal modules in this repository,
          agents must prioritize those options before adding a new dependency.

- **Minimize lock-in and duplication**
    - Avoid introducing multiple crates that solve the same generic problem (e.g., multiple JSON libraries, multiple HTTP clients) without a strong justification.
    - When replacing a dependency, ensure that:
        - The migration path is clear and documented.
        - Dead or obsolete code paths are removed as part of the change, within the explicit scope allowed by the user request.

---

# **3. Rust Coding Conventions**

These conventions apply to all crates and all directories (libraries, binaries, tests, examples, benches). They define the required structure and style of Rust source code.

Items that appear here do not appear again in the “Never Do” list to avoid duplication.

---

## **3.1 Module, Import, and Declaration Order**

Each file must follow the strict declaration order:

```rust
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

Within each group:

- `pub` items must appear before non-`pub` items.

Import section headers (e.g., `// std`, `// crates.io`, `// self`) must be preserved exactly and must not be removed.

---

## **3.2 Structs and Impl Blocks**

A struct’s `impl` must appear **immediately** after the struct definition with **no blank line** between them.

---

## **3.3 Generics, Bounds, and UFCS**

### Bound Placement

- All trait bounds must appear in a `where` clause.
- Inline trait bounds after the generic list are not allowed.
- Bounds must be ordered as:
  **(1) lifetimes → (2) standard library traits → (3) project traits**

### Generics

Whenever explicit generic type specification is required, agents must use turbofish syntax.

If turbofish cannot be used (e.g., `Into::into`), the explicit constructor form must be used instead.

### UFCS

Prefer UFCS (type-qualified paths) when referencing inherent items or specific trait implementations.

---

## **3.4 Borrowing Rules**

Prefer using plain references such as `&value` rather than `.as_ref()`, `.as_str()`, or similar adapters, unless the adapter is strictly required.

---

## **3.5 Macro, Formatting, and Logging Rules**

- Tracing macros must always be invoked with fully qualified paths (`tracing::info!`, etc.).
- When using `format!`, tracing, or logging macros, directly reference existing variables in the format string.
- Never introduce temporary variables solely for use inside a formatting expression.

---

# **4. Language Requirements**

These rules apply to:

- Comments
- Documentation comments (`///` and `//!`)
- Log messages

All such text must:

- Use standard, grammatically correct English.
- Begin with capital letters and end with proper punctuation.
- Avoid slang, localisms, and ambiguous abbreviations.
- Avoid non-English languages completely in code-facing text.

---

# **5. Never Do**

The following actions are **strictly prohibited**. These rules ensure workspace integrity, prevent unpredictable behavior, and restrict agents to safe operational boundaries.

---

## **5.1 Toolchain and System Prohibitions**

### **(A) Never modify toolchain management files.**

Agents must not edit:

- `rust-toolchain.toml`
- `.cargo/config.toml`
- `rustfmt.toml`

### **(B) Never install, upgrade, or manually switch Rust toolchains.**

Prohibited commands include:

```bash
rustup update
rustup install ...
rustup override ...
```

### **(C) Never execute system-level installation commands.**

Prohibited:

```bash
apt-get install ...
brew install ...
pip install ...
```

---

## **5.2 File Boundary Restrictions**

### **(D) Never modify files outside the repository root.**

Agents must not touch:

- Parent directories
- Home directories
- Global system paths
- External submodule files

### **(E) Never modify generated files.**

Including but not limited to:

- `OUT_DIR` outputs
- `build.rs` generated files
- `target/` directory
- Vendored third-party code
- Automatically generated assets or schemas

---

## **5.3 Patch and Diff Restrictions**

### **(F) Never produce non-unified diffs.**

Patch output must use standard unified diff format (`diff --git ...`).

### **(G) Never modify unrelated code in the same patch.**

Patches must be minimal and scoped exclusively to the user’s explicit request.

---

## **5.4 Style Restrictions**

### **(H) Never import tracing macros.**

Example of prohibited form:

```rust
use tracing::{info, warn};
```

Agents must always use:

```rust
tracing::info!();
```

### **(I) Never use inline trait bounds.**

(Prohibited under coding conventions; enforced again here as a hard rule.)

### **(J) Never place blank lines between a struct and its impl.**

### **(K) Never use `.as_ref()`, `.as_str()`, or similar adapters when `&value` suffices.**

---

## **5.5 Runtime and Async Restrictions**

### **(L) Never use `unwrap()` or `expect()` in non-test code.**

Unless the failure case is provably impossible (e.g., parsing a literal).

### **(M) Never block inside async contexts.**

Prohibited operations include:

```rust
std::thread::sleep(...)
blocking synchronous I/O
```

---

## **5.6 Documentation and Language Restrictions**

### **(N) Never mix languages in comments, docs, or logs.**

### **(O) Never introduce ambiguous abbreviations or informal slang.**

Examples of prohibited shorthand:

- `w/`
- `u`
- `tho`
- Nonstandard contractions

---

## **5.7 Behavioral Restrictions**

### **(P) Never infer missing requirements.**

Agents may not guess intent or expand tasks beyond what is explicitly stated.

### **(Q) Never apply optimizations or refactors unless explicitly asked.**

This includes:

- Code cleanup
- Performance changes
- Interface redesign
- Removal of unused code

---

# **6. Summary**

This document defines the complete execution workflow, design and implementation principles, dependency governance, Rust coding conventions, language standards, and prohibited actions for all automated agents operating within this Rust workspace. By adhering to these rules, agents ensure that generated code is consistent, predictable, maintainable, and safe to apply across the entire repository.
