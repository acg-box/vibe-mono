# AGENTS.md

Authoritative Rules for Automated Agents in This Repository

This document defines the **execution model**, **coding conventions**, **design rules**, **dependency policies**, and **hard prohibitions** for all automated agents interacting with this Rust workspace.

Agents must treat every rule in this document as mandatory.
If any rule conflicts with “typical Rust style” or “common sense,” **this document takes precedence**.

---

## 0. Prime Directive

> Agents must only produce code, operations, and patches that comply with this document exactly.
> Do not guess, relax, or reinterpret these rules.

---

## 0.1 Available MCP / External Tools

When supported by the runtime, agents may use these tools to better satisfy the rules in this file:

- `memory` — Long-lived project context / state.
- `context7` — Rich contextualization and cross-file understanding.
- `deepwiki` — Deep, structured knowledge lookup.
- `sequential-thinking` — Multi-step, chain-of-thought style planning.
- `github` — Repository access, browsing, and metadata.

Use these tools **to follow AGENTS.md more faithfully**, never to bypass or reinterpret it.

---

## 1. Execution Model

### 1.1 Core Principle

Agents **must use only `cargo make` tasks** for all operations:

- Build / compile
- Test
- Format
- Lint
- Auxiliary automation

#### ❌ Bad

```bash
cargo test
cargo clippy
cargo fmt
```

#### ✔ Good

```bash
cargo make nextest
cargo make clippy
cargo make fmt
```

Raw `cargo` commands are forbidden unless the user explicitly asks for them **and** there is no corresponding `cargo make` task.

---

### 1.2 Toolchain

- The workspace is pinned via `rust-toolchain.toml`.
- Nightly usage (e.g., formatting) is handled via `cargo make` tasks.

Agents must not:

- Modify toolchain configuration.
- Install, update, or override toolchains.

(See hard prohibitions for details.)

---

### 1.3 Standard Tasks

Agents must prefer these tasks:

- `cargo make clippy` — Lint the workspace.
- `cargo make fmt` — Format the workspace.
- `cargo make nextest` — Run the test suite.

---

### 1.4 Adding New Automation

When introducing new automation:

1. Define a new task in `Makefile.toml`.
2. Document it in this file.
3. Invoke it strictly via `cargo make <task>`.

---

## 2. Design & Implementation Principles

### 2.1 Minimal, Complete, Iterative

- Implement **only** the explicitly requested scope.
- The implementation must be robust and production-ready within that scope.
- Do not add speculative features, knobs, or abstractions “for later.”

---

### 2.2 Simplicity, Structure, and Readability

- Prefer **simple, explicit, logically ordered** code.
- Keep modules cohesive: each module should have a focused responsibility.
- Use descriptive names that reflect domain meaning.
- Keep error handling structured and consistent.

#### ❌ Bad (overly dense and hard to parse)

```rust
fn collect_long_items(inputs: &[Option<String>]) -> Result<Vec<String>> {
    inputs
        .iter()
        .filter(|x| x.is_some() && x.as_ref().unwrap().len() > 3)
        .map(|x| process(x.as_ref().unwrap()))
        .collect::<Result<Vec<_>, _>>()
}
```

#### ✔ Good (clear logic with small steps and correct spacing)

```rust
fn collect_long_items(inputs: &[Option<String>]) -> Result<Vec<String>> {
    let mut results = Vec::new();

    for input in inputs {
        if let Some(value) = input {
            if value.len() <= 3 {
                continue;
            }

            let processed = process(value)?;
            results.push(processed);
        }
    }

    Ok(results)
}
```

- 多个 `let` 在一起（同类，无空行）。
- `for` 属于新类别，与 `let` 之间有一个空行。
- 循环内部：条件和计算/插入之间用一个空行分开类别。
- 返回表达式 `Ok(results)` 前有一个空行。

---

### 2.3 Functional / Pipeline Style

Agents should use **functional / pipeline-style chains** when they make the code:

- Simpler
- More logically structured
- Easy to read at a glance

But must avoid **clever, opaque chains** that hide control flow or error handling.

#### ✔ Good (simple, readable pipeline)

```rust
fn normalize_names(names: &[String]) -> Vec<String> {
    names
        .iter()
        .map(|name| name.trim())
        .filter(|name| !name.is_empty())
        .map(|name| name.to_lowercase())
        .collect()
}
```

#### ✔ Good (pipeline + helper functions)

```rust
fn is_valid(name: &str) -> bool {
    !name.is_empty() && name.len() <= 32
}

fn normalize(name: &str) -> String {
    name.trim().to_lowercase()
}

fn normalize_valid_names(names: &[String]) -> Vec<String> {
    names
        .iter()
        .map(|name| name.trim())
        .filter(|name| is_valid(name))
        .map(|name| normalize(name))
        .collect()
}
```

#### ❌ Bad (pipeline too clever and fragile)

```rust
fn normalize_names(names: &[String]) -> Vec<String> {
    names
        .iter()
        .map(|n| n.trim())
        .filter(|n| !n.is_empty() && n.len() <= 32 && !n.chars().any(|c| c.is_numeric()))
        .map(|n| format!("{}{}", &n[0..1].to_uppercase(), &n[1..].to_lowercase()))
        .collect()
}
```

**Rule of thumb:**

- Pipelines are good when each step is simple and clearly named.
- Switch to explicit loops or helper functions when pipelines become dense or tricky.

---

### 2.4 Extendable Foundations

Minimal implementations must still:

- Be internally consistent.
- Provide a clear growth path for future requirements.
- Include tests that cover main flows and lock in observable behavior.

---

### 2.5 Design Before Code

For non-trivial changes (new public APIs, complex state, cross-crate integration):

1. Sketch a short design: data structures, control flow, integration points, error handling.
2. Prefer well-known patterns and algorithms over ad-hoc inventions.

The design can be in comments or a short note, but **must exist**.

---

### 2.6 Reuse First

Before introducing anything new:

- Prefer the Rust standard library.
- Prefer existing internal utilities and modules.
- Prefer crates already in the dependency tree.

---

### 2.7 Dependency Governance

When adding or modifying dependencies:

- Prefer actively maintained crates with recent releases and real usage.
- Ensure license compatibility with this repository.
- Avoid large frameworks when a focused crate or stdlib suffices.
- Avoid overlapping crates that solve the same generic problem.
- Avoid adding functionality already available in existing dependencies.

---

## 3. Rust Coding Conventions

These conventions apply to **all** Rust code in this repository: libraries, binaries, tests, examples, and benches.

---

### 3.1 Declaration Order

Each file must follow this declaration order:

```text
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

Rules:

- `pub` items appear before non-`pub` items within each group.

#### ❌ Bad

```rust
use crate::foo;
use std::fmt;

mod bar;
```

#### ✔ Good

```rust
mod bar;

// std
use std::fmt;
// crates.io
use anyhow::Result;
// self
use crate::foo;
```

---

### 3.2 Imports and Section Headers

- Import sections may use the following headers in the `use` block:

    ```rust
    // std
    // crates.io
    // self
    ```

- Preserve these headers if they already exist.
- When creating a **new file**, you may introduce these exact three headers.
- **Do not invent or add any other artificial group headers** such as `// mod`, `// type`, `// fn`, `// trait`, etc.
- Do not insert headers above `mod`, `type`, `trait`, `enum`, `struct`, or `fn` items unless the file already uses that exact pattern and the user explicitly requests it.

---

### 3.3 Module Layout (No `mod.rs`)

Agents **must not** use the `mod.rs` pattern.

The workspace uses a **flat entry + directory** layout:

- Entry module: `foo.rs`
- Submodules: `foo/` directory

#### ❌ Bad

```text
src/foo/mod.rs
src/foo/bar.rs
```

#### ✔ Good

```text
src/foo.rs
src/foo/bar.rs
src/foo/baz.rs
```

Never create or edit `mod.rs` files.

---

### 3.4 Struct & Impl Placement and Ordering

For any type (`struct` or `enum`), its `impl` blocks must be:

1. **Contiguous** for that type:
    - The first `impl` for a type must appear **immediately after** the type definition with **no blank line**.
    - All additional `impl` blocks for that type must follow directly, also **with no blank lines between consecutive impl blocks**.

2. **Ordered** as follows (top to bottom):
    1. Inherent impl (`impl Type { ... }`)
    2. Impl of **standard library traits** (`std::...`)
    3. Impl of **third-party / crates.io traits**
    4. Impl of **project / self traits** (`crate::...`)

#### ❌ Bad (blank lines and wrong order)

```rust
pub struct Foo {}

impl crate::traits::MyTrait for Foo {}

impl Foo {}

impl std::fmt::Display for Foo {}
```

#### ❌ Bad (blank line between struct and impl)

```rust
pub struct Foo {}

impl Foo {}
impl std::fmt::Display for Foo {}
```

#### ✔ Good (no blank lines, correct order)

```rust
pub struct Foo {}
impl Foo {
    pub fn new() -> Self {
        Self {}
    }
}
impl std::fmt::Display for Foo {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Foo")
    }
}
impl serde::Serialize for Foo {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str("Foo")
    }
}
impl crate::traits::MyTrait for Foo {
    fn do_something(&self) {}
}
```

---

### 3.5 Generics, Bounds, and UFCS

#### 3.5.1 General Rule

All trait bounds must appear in a `where` clause, not inline on type parameters or after names.
Bounds must be ordered:

1. Lifetimes
2. Standard library traits
3. Project-specific traits

#### ❌ Bad (inline bound on generic)

```rust
fn run<T: std::fmt::Display>(value: T) -> String {
    value.to_string()
}
```

#### ✔ Good (bounds in `where`)

```rust
fn run<T>(value: T) -> String
where
    T: std::fmt::Display,
{
    value.to_string()
}
```

---

#### 3.5.2 `impl Trait` Exception

The `impl Trait` syntax in parameter or return position is allowed and does **not** need a `where` clause.

#### ✔ Allowed

```rust
fn handle(value: impl std::fmt::Display) -> String {
    value.to_string()
}

fn make_displayable() -> impl std::fmt::Display {
    "ok"
}
```

Do not rewrite these into generics solely to satisfy the `where` rule.

---

#### 3.5.3 Trait Declarations

Trait bounds must also be expressed via a `where` clause on `Self`.
Do **not** use the supertrait (`trait T: U {}`) syntax.

#### ❌ Bad

```rust
trait Printable: std::fmt::Display {
    fn print(&self);
}
```

#### ✔ Good

```rust
trait Printable
where
    Self: std::fmt::Display,
{
    fn print(&self);
}
```

---

#### 3.5.4 UFCS Preference

Prefer UFCS when referring to specific implementations or when clarity is improved.

#### ✔ Example

```rust
let value = String::from("data");
let length = <String as AsRef<str>>::as_ref(&value).len();
```

---

### 3.6 Borrowing

Prefer simple references like `&value` over `.as_ref()` or `.as_str()` unless the adapter is strictly required.

#### ❌ Bad

```rust
let s = value.as_str();
process(s);
```

#### ✔ Good

```rust
let s = &value;
process(s);
```

---

### 3.7 Logging and Macros

- Tracing macros must always be invoked with fully qualified paths.
- Do not import tracing macros.

#### ❌ Bad

```rust
use tracing::{info, warn};

info!("Started.");
```

#### ✔ Good

```rust
tracing::info!("Started.");
tracing::warn!("Something happened.");
```

When formatting messages:

- Use existing variables directly.
- Do not introduce temporary variables _solely_ for formatting.

---

### 3.8 Ownership and Iteration

- Avoid `.clone()` unless ownership must be duplicated or transferred.
- Use `.into_iter()` when a collection is consumed.
- Use borrowing iteration when the collection is reused later.

#### ❌ Bad

```rust
let items_clone = items.clone();
for item in items_clone {
    process(item);
}
```

#### ✔ Good (consume)

```rust
for item in items.into_iter() {
    process(item);
}
```

#### ✔ Good (borrow)

```rust
for item in &items {
    process(item);
}
```

---

### 3.9 Statement Grouping and Vertical Spacing

Within a function body:

1. **Same-category statements must be grouped together with no blank lines between them.**
   Examples of categories (not exhaustive):
    - Multiple `let` bindings
    - Multiple `if`, `if let`, or `match` conditions
    - Multiple method/function calls on similar receivers
    - Multiple macro invocations
    - Multiple early-return or guard checks

2. **Different categories must be separated by exactly one blank line.**

3. **Before the final return expression or tail expression, there must be exactly one blank line**,
   unless the entire function body is just that single expression.

4. Do not insert decorative or random blank lines; use vertical spacing **only** to separate logical blocks.

#### ✔ Good

```rust
fn example(items: &[Item]) -> Result<Vec<Id>> {
    let mut ids = Vec::new();
    let mut skipped = 0;

    for item in items {
        if !item.is_active() {
            skipped += 1;
            continue;
        }

        ids.push(item.id());
    }

    if skipped > 0 {
        tracing::info!("Skipped {} inactive items.", skipped);
    }

    Ok(ids)
}
```

#### ✔ Good (single-expression function)

```rust
fn count_active(items: &[Item]) -> usize {
    items.iter().filter(|item| item.is_active()).count()
}
```

#### ❌ Bad (mixed categories and noisy spacing)

```rust
fn example(items: &[Item]) -> Result<Vec<Id>> {

    let mut ids = Vec::new();

    let mut skipped = 0;
    for item in items {
        if !item.is_active() {
            skipped += 1;

            continue;
        }
        ids.push(item.id());
    }

    if skipped > 0 {
        tracing::info!("Skipped {} inactive items.", skipped);
    }
    Ok(ids)
}
```

---

## 4. Language Rules

These rules apply to:

- Comments
- Documentation comments (`///`, `//!`)
- Log messages

All such text must:

- Use standard, grammatically correct English.
- Begin with a capital letter and end with proper punctuation.
- Avoid slang, informal shorthand, or mixed languages.

---

## 5. Hard Prohibitions (“Never Do”)

Violating any rule in this section makes the agent output invalid.

---

### 5.1 Toolchain & System

Never modify:

- `rust-toolchain.toml`
- `.cargo/config.toml`
- `rustfmt.toml`

Never run:

- `rustup update`
- `rustup install`
- `rustup override`
- System install commands (`apt-get`, `brew`, `pip`, etc.)

---

### 5.2 File Boundaries

Agents must not:

- Modify files outside the repository root.
- Modify generated files, including but not limited to:
    - `target/`
    - `OUT_DIR` outputs
    - Vendored third-party code
    - Automatically generated schemas or assets

---

### 5.3 Patch Scope

- All patches must be standard **unified diffs**.
- Only modify code directly related to the user’s explicit request.

No opportunistic refactors.
No drive-by cleanups.
No behavioral changes outside the requested scope.

---

### 5.4 Style Prohibitions

- Never import tracing macros (`use tracing::{info, warn};` is forbidden).
- Never use inline trait bounds on generic parameters or trait declarations.
- Never place blank lines:
    - Between a type definition and its first impl, or
    - Between consecutive impl blocks for the same type.
- Never use `.as_ref()` or `.as_str()` when `&value` is sufficient.
- Never use `mod.rs` modules.
- Never invent new group headers such as `// mod`, `// type`, `// fn`, or similar.

---

### 5.5 Runtime & Async

- Never use `unwrap()` or `expect()` in non-test code.
- Never block inside async contexts:
    - No `std::thread::sleep`.
    - No blocking I/O (filesystem, network, etc.).

#### ❌ Bad

```rust
async fn run() {
    std::thread::sleep(std::time::Duration::from_secs(1));
}
```

#### ✔ Good

```rust
async fn run() {
    tokio::time::sleep(std::time::Duration::from_secs(1)).await;
}
```

---

### 5.6 Documentation

- Never mix languages in code-facing text.
- Never introduce ambiguous abbreviations or slang (e.g., `w/`, `u`, `tho`).

---

### 5.7 Behavioral

- Never infer missing requirements.
- Never expand the scope, refactor, or optimize unless explicitly requested.
- Never redesign public interfaces unless the user explicitly asks for it.

---

## 6. Canonical Examples (Authoritative Behavior Samples)

These examples resolve ambiguities.
When in doubt, agents must follow these patterns exactly.

---

### 6.1 Canonical File Skeleton (with multiple impl blocks)

```rust
mod utils;

// std
use std::fmt;
// crates.io
use anyhow::Result;
// self
use crate::core::Service;

type Id = u64;

const MAX_ITEMS: usize = 16;

trait Printable
where
    Self: std::fmt::Display,
{
    fn print(&self) -> String;
}

enum Status {
    Ready,
    Busy,
}

pub struct Foo {
    id: Id,
}
impl Foo {
    pub fn new(id: Id) -> Self {
        Self { id }
    }

    pub fn id(&self) -> Id {
        self.id
    }
}
impl std::fmt::Display for Foo {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Foo({})", self.id)
    }
}
impl serde::Serialize for Foo {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_u64(self.id)
    }
}
impl crate::traits::Trackable for Foo {
    fn track_id(&self) -> Id {
        self.id
    }
}

fn run(service: &Service, id: Id) -> Result<()> {
    tracing::info!("Running with id: {}", id);

    service.process(id)?;

    Ok(())
}
```

This skeleton demonstrates:

- Declaration order
- Clean `use` section with only the allowed headers
- Module layout (no `mod.rs`)
- Struct followed immediately by contiguous impls
- Impl ordering: inherent → std → third-party → self
- Trait bounds in a `where` clause on `Self`
- Fully qualified tracing macros
- Statement grouping and final return spacing

---

### 6.2 Generics & Bounds Examples

#### Function with generic parameters

```rust
fn render<T>(value: T) -> String
where
    T: std::fmt::Display,
{
    value.to_string()
}
```

#### Trait with bounds on `Self`

```rust
trait Renderable
where
    Self: std::fmt::Display,
{
    fn render(&self) -> String {
        self.to_string()
    }
}
```

#### `impl Trait` (allowed)

```rust
fn log_message(message: impl std::fmt::Display) {
    tracing::info!("Message: {}", message);
}
```

#### ❌ Forbidden inline bound

```rust
// Forbidden
fn render<T: std::fmt::Display>(value: T) -> String {
    value.to_string()
}
```

---

### 6.3 Module Layout Tree

```text
src/
  core.rs
  core/
    service.rs
    error.rs
  api.rs
  api/
    handlers.rs
    dto.rs
```

- `core.rs` and `api.rs` are entry modules.
- Their submodules live in corresponding directories.
- No `mod.rs` anywhere.

---

### 6.4 Logging and Borrowing

```rust
pub fn process(name: &str) {
    tracing::info!("Starting process for: {}", name);

    let label = name;
    tracing::debug!("Label is: {}", label);
}
```

---

### 6.5 Async Without Blocking

```rust
pub async fn handle_request() -> Result<()> {
    tracing::info!("Handling request.");

    tokio::time::sleep(std::time::Duration::from_millis(100)).await;

    Ok(())
}
```

---

### 6.6 Functional / Pipeline Style

```rust
fn active_ids(items: &[Item]) -> Vec<u64> {
    items
        .iter()
        .filter(|item| item.is_active())
        .map(|item| item.id())
        .collect()
}
```

When this pattern starts to require nested conditionals, multiple unwraps, or complex branching, switch to explicit loops and helper functions.

---

### 6.7 `cargo make` Usage

```text
# Formatting
cargo make fmt

# Linting
cargo make clippy

# Tests
cargo make nextest
```

These must be used instead of raw `cargo` equivalents.

---

## 7. System Prompt Snippet for Agents

This snippet can be used directly in a system message or tool description to enforce these rules:

```text
You are an automated agent operating on a Rust repository. You MUST obey the repository’s AGENTS.md rules exactly.

Execution:
- Use ONLY `cargo make` tasks (fmt, clippy, nextest, and any documented tasks). Do NOT run raw `cargo` or system package managers.
- Respect the pinned toolchain. Never modify rust-toolchain.toml, .cargo/config.toml, or rustfmt.toml.

Design:
- Implement only the explicitly requested scope, but with production-grade robustness.
- Prefer simple, logically ordered code. Use functional / pipeline-style chains when they make the flow clearer and still easy to read; avoid clever, dense chains.
- Reuse std, existing modules, and existing dependencies before adding new crates.

Rust style:
- File declaration order: mod → use → macro_rules → type → const → trait → enum → struct → fn. Public items come before non-public.
- In the use section, only use the three allowed headers: `// std`, `// crates.io`, `// self`. Preserve them if they already exist. Do NOT invent new headers like `// mod`, `// type`, `// fn`.
- Use flat module layout: foo.rs + foo/ submodules. NEVER use mod.rs.
- For any type, place all impl blocks contiguously right after the struct/enum, with NO blank lines between the type and its first impl or between impl blocks.
- Order impl blocks: first inherent `impl Type`, then impls of std traits, then third-party traits, then project/self traits.
- Put ALL trait bounds in where-clauses, ordered: lifetimes → std traits → project traits.
- Exception: `impl Trait` in parameter/return position is allowed. Do NOT rewrite it just to add where bounds.
- For traits, express bounds as `trait T where Self: Bound` instead of `trait T: Bound`.
- Prefer `&value` over `.as_ref()` / `.as_str()` unless strictly necessary.
- NEVER import tracing macros; always call them as `tracing::info!`, `tracing::warn!`, etc.
- Avoid `.clone()` unless you truly need another owned value. Use borrowing or into_iter() instead.
- Group same-category statements together with no blank lines (e.g., multiple let bindings, multiple conditionals, multiple macro calls). Separate different categories with exactly one blank line. Ensure there is exactly one blank line before the final return or tail expression, unless the function body is only that expression.

Behavior:
- NEVER use unwrap() or expect() in non-test code.
- NEVER block inside async code (no std::thread::sleep, no blocking I/O).
- NEVER modify generated files, files outside the repo root, or vendored code.
- Patches MUST be minimal unified diffs, touching only what the user requested. No drive-by refactors or optimizations.
- Comments, docs, and logs must be written in clear English, starting with capital letters and ending with punctuation. No slang or mixed languages.

When needed, you MAY use the following MCP tools to better follow these rules:
- memory (long-lived project state)
- context7 (deeper contextualization)
- deepwiki (structured knowledge)
- sequential-thinking (multi-step reasoning)
- github (repository access)

When in doubt, favor clarity, explicit control flow, and strict compliance with AGENTS.md over idiomatic but non-compliant Rust.
```

---

## 8. Summary

This document defines:

- The execution model (cargo-make–first)
- Toolchain handling
- Design and implementation principles
- Preference for clear, sometimes functional / pipeline-style code
- Dependency governance
- Rust coding conventions (including strict struct/impl spacing, impl ordering, imports,和语句分组)
- Language requirements
- Hard prohibitions
- Canonical examples
- A ready-to-use system prompt snippet

Agents must follow every rule exactly. When in doubt, prefer:

- `cargo make` over raw `cargo`
- `where` clauses over inline bounds (with the explicit `impl Trait` exception)
- `trait T where Self: Bound` over `trait T: Bound`
- Strict contiguous struct+impl layout with ordered impl blocks
- Grouping same-category statements and using minimal, meaningful blank lines
- `&value` over `.as_ref()` / `.as_str()`
- Fully qualified `tracing::...` macros
- Flat module layout without `mod.rs`
- Simple, logically structured, and, when appropriate, pipeline-style functional code that is easy to understand at a glance.
