# AGENTS.md

Authoritative Rules for Automated Agents in This Repository

This document defines the **execution model**, **scope rules**, **coding conventions**, and **hard prohibitions** for all automated agents interacting with this Rust workspace.

If any rule conflicts with “typical Rust style” or “common sense,” **this document wins**.

---

## 0. Prime Directives

1. **Compliance:** All code, operations, and patches **must** follow this document exactly. Do not guess, relax, or reinterpret rules.
2. **Scope Lock (very important):**
    - Only modify code that is **strictly necessary** to achieve the **explicit user goal**.
    - Do **not**:
        - “Clean up” unrelated code.
        - “Optimize” or “refactor” outside the requested scope.
        - Redesign public APIs or architecture unless explicitly asked.
    - If you notice issues outside the scope, **do not touch them**. Instead:
        - Finish the requested work first.
        - Mention the issues briefly in your **final summary** as suggestions for future work.

---

## 0.1 Allowed External / MCP Tools

When available, agents may use these tools **only to follow AGENTS.md more faithfully**, never to bypass it:

- `memory` — Long-lived project context / state.
- `context7` — Cross-file understanding.
- `deepwiki` — Structured knowledge lookup.
- `sequential-thinking` — Multi-step planning.
- `github` — Repository access and browsing.

---

## 1. Execution Model

### 1.1 `cargo make` Only

All automation must go through `cargo make` tasks:

- Build / compile
- Test
- Format
- Lint
- Any other automation

#### ✔ Required

```bash
cargo make fmt
cargo make clippy
cargo make nextest
```

#### ❌ Forbidden (unless explicitly requested _and_ no task exists)

```bash
cargo fmt
cargo clippy
cargo test
```

If a user explicitly asks for a raw `cargo` command and an equivalent `cargo make` task exists, **use the task instead** and note this briefly in your explanation.

---

### 1.2 Toolchain

- The workspace is pinned via `rust-toolchain.toml`.
- Nightly usage (e.g., formatting) is handled via `cargo make` tasks.

Agents must **never**:

- Modify toolchain configuration.
- Install, update, or override toolchains.
- Run system package managers.

Details are in **5. Hard Prohibitions**.

---

## 2. Scope & Change Control (Scope Lock)

This section is **critical**. Violating it makes your output invalid.

### 2.1 In-Scope Changes

You may change:

- Files and lines **directly involved** in the requested feature, fix, or refactor.
- Minimal supporting code required to keep compilation, tests, or clear behavior (e.g., updating a matching trait implementation or a closely coupled module).

### 2.2 Out-of-Scope Changes (Forbidden)

You must **not**:

- Reformat unrelated files or blocks.
- Rename unrelated functions, types, or modules.
- Reorganize imports in unrelated files.
- “Drive-by” optimize, deduplicate, or “clean up” code outside the requested flow.
- Introduce new public APIs or change existing ones unless the user explicitly requests it.

### 2.3 Reporting Out-of-Scope Issues

If you see problems outside the requested scope (e.g., obvious bugs, missing tests, poor naming):

1. **Do not modify them.**
2. Finish the requested work.
3. In your **final summary**, add a short “Future suggestions” section (if needed) listing:
    - The issue.
    - The file / symbol name.
    - A one-line suggestion.

Never turn these suggestions into code unless they are explicitly requested.

---

## 3. Design & Implementation Principles

### 3.1 Minimal, Complete, Robust

- Implement **only** what the user explicitly asks.
- Within that scope, aim for **production-grade robustness**:
    - Clear control flow.
    - Consistent error handling.
    - Reasonable tests.

No speculative features, toggles, or abstractions “just in case.”

---

### 3.2 Simplicity and Structure

- Prefer **simple, explicit, logically ordered** code.
- Keep modules cohesive: one clear responsibility per module.
- Use descriptive names reflecting the domain.
- Avoid cleverness that makes code harder to read or debug.

---

### 3.3 Functional / Pipeline Style

Use functional / pipeline style **when it is clearly readable**:

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

Switch to explicit loops or helper functions when:

- There are multiple branches or nested conditions.
- Error handling becomes non-obvious.
- The chain becomes hard to understand at a glance.

---

### 3.4 Reuse First

Before adding new code or crates:

1. Prefer the Rust standard library.
2. Prefer existing internal utilities and modules.
3. Prefer crates already in the dependency tree.

Only add new dependencies when truly necessary, and follow **dependency governance**:

- Prefer actively maintained crates with recent releases.
- Ensure license compatibility.
- Avoid overlapping crates that solve the same problem.
- Avoid large frameworks if a small focused crate or stdlib is enough.

---

### 3.5 Design Before Code (for non-trivial changes)

For new public APIs, complex state, or cross-crate integration:

1. Sketch a short design (can be comments or a short note):
    - Data structures
    - Control flow
    - Integration points
    - Error handling
2. Then implement.

---

## 4. Rust Style Rules

These rules apply to **all** Rust code: libraries, binaries, tests, examples, benches.

### 4.1 Indentation

- **All indentation must use tabs** (`\t`), never spaces.
- This applies to every block level in Rust code.

---

### 4.2 Declaration Order (Per File)

Each file must follow this order:

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

Within each group:

- `pub` items come before non-`pub` items.

Example:

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
```

---

### 4.3 Imports and Headers

- Allowed headers in the `use` section:
    - `// std`
    - `// crates.io`
    - `// self`
- Preserve existing headers.
- Do **not** invent new headers (e.g., `// mod`, `// fn`, `// type`).
- Do **not** add headers above `mod`, `type`, `trait`, `enum`, `struct`, or `fn`.

Before adding new `use` imports:

- Check if the file already imports `crate::prelude::*` or `crate::_prelude::*` (including grouped forms like `use crate::{prelude::*, ...};`).
- If the item is available via the prelude, **do not add a redundant direct import**.

---

### 4.4 Module Layout (No `mod.rs`)

Use flat entry + directory layout:

- Entry module: `foo.rs`
- Submodules: `foo/` directory

```text
src/foo.rs
src/foo/bar.rs
src/foo/baz.rs
```

Never create or edit `mod.rs` files.

---

### 4.5 Structs and Impl Blocks

For each `struct` or `enum`:

1. The first `impl` block must appear **immediately after** the type with **no blank line**.
2. All impl blocks for that type must be **contiguous**, with **no blank lines** between them.
3. Impl block order for a given type:
    1. Inherent impl: `impl Type { ... }`
    2. Std traits: `impl std::... for Type`
    3. Third-party traits (crates.io)
    4. Project/self traits: `impl crate::... for Type`

✔ Example:

```rust
pub struct Foo {
	id: u64,
}
impl Foo {
	pub fn new(id: u64) -> Self {
		Self { id }
	}

	pub fn id(&self) -> u64 {
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
	fn track_id(&self) -> u64 {
		self.id
	}
}
```

---

### 4.6 Generics and Trait Bounds

All trait bounds must be in a `where` clause, never inline on type parameters or trait declarations.

✔ Allowed:

```rust
fn render<T>(value: T) -> String
where
	T: std::fmt::Display,
{
	value.to_string()
}
```

❌ Forbidden:

```rust
fn render<T: std::fmt::Display>(value: T) -> String {
	value.to_string()
}
```

For traits:

✔ Allowed:

```rust
trait Printable
where
	Self: std::fmt::Display,
{
	fn print(&self);
}
```

❌ Forbidden:

```rust
trait Printable: std::fmt::Display {
	fn print(&self);
}
```

**Exception:** `impl Trait` in parameter or return position is allowed and does not need a `where` clause. Do not rewrite these just to add bounds.

```rust
fn handle(message: impl std::fmt::Display) {
	tracing::info!("Message: {message}");
}
```

---

### 4.7 Logging, Formatting, and Macros

- Never import tracing macros. Use fully qualified calls:
    - `tracing::info!(...)`
    - `tracing::warn!(...)`
    - `tracing::debug!(...)`, etc.

When logging or formatting **existing variables**, use named capture:

✔ Good:

```rust
tracing::info!("User id: {user_id}");
```

Do **not** create temporary `let` bindings only for logging:

❌ Bad:

```rust
let label = name;
tracing::debug!("Label is: {}", label);
```

✔ Good:

```rust
tracing::debug!("Label is: {name}");
```

If you log an expression that is not bound and not reused, pass it directly as an argument:

```rust
tracing::info!("User id: {}", user.id());
```

Do not build strings via `format!` only to immediately pass them into tracing macros; log directly instead:

✔ Good:

```rust
tracing::info!("Processed {count}");
```

---

### 4.8 Borrowing and Ownership

- Prefer `&value` over `.as_ref()` or `.as_str()` when a simple reference is enough.
- Avoid `.clone()` unless you really need another owned value.

✔ Consume when you are done:

```rust
for item in items.into_iter() {
	process(item);
}
```

✔ Borrow when you keep using the collection:

```rust
for item in &items {
	process(item);
}
```

---

### 4.9 Statement Grouping and Vertical Spacing

Inside a function:

1. Same-category statements are grouped with **no blank lines** between them:
    - Multiple `let` bindings.
    - Multiple conditionals (`if`, `if let`, `match`).
    - Multiple macro calls.
    - Multiple early returns.
2. Different categories are separated by **exactly one blank line**.
3. There must be **exactly one blank line before the final return or tail expression**, unless the function body is a single expression.

✔ Example:

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
		tracing::info!("Skipped {skipped} inactive items.");
	}

	Ok(ids)
}
```

---

## 5. Language Rules

These rules apply to:

- Comments
- Documentation comments (`///`, `//!`)
- Log messages

All such text must:

- Use clear, grammatically correct English.
- Start with a capital letter and end with proper punctuation.
- Avoid slang, shorthand, or mixed languages.

---

## 6. Hard Prohibitions

Violating any rule here makes the output invalid.

### 6.1 Toolchain & System

Never modify:

- `rust-toolchain.toml`
- `.cargo/config.toml`
- `rustfmt.toml`

Never run:

- `rustup update`, `rustup install`, `rustup override`
- System package managers: `apt-get`, `yum`, `brew`, `pip`, etc.
- Any command that installs or upgrades system-level tools.

---

### 6.2 File Boundaries

Agents must **not**:

- Modify files outside the repository root.
- Modify generated files:
    - `target/`
    - `OUT_DIR` outputs
    - Vendored third-party code
    - Automatically generated schemas or assets

---

### 6.3 Patch Scope

- Patches must be **standard unified diffs**.
- Only modify code that is necessary to satisfy the **explicit user request**, per the **Scope Lock** rules.
- No opportunistic refactors.
- No behavior changes outside the requested scope.

---

### 6.4 Style Prohibitions

- Never import tracing macros.
- Never use inline trait bounds on generic parameters or trait declarations.
- Never place blank lines:
    - Between a type definition and its first impl.
    - Between consecutive impl blocks for the same type.
- Never use `.as_ref()` or `.as_str()` when `&value` is enough.
- Never use `mod.rs`.
- Never invent new group headers in `use` sections.
- Never use spaces for indentation in Rust code.

---

### 6.5 Runtime & Async

- Never use `unwrap()` or `expect()` in non-test code.
- Never block inside async code:
    - No `std::thread::sleep`.
    - No blocking I/O (filesystem, network, etc.) in async contexts.

✔ Good async pattern:

```rust
pub async fn handle_request() -> Result<()> {
	tracing::info!("Handling request.");

	tokio::time::sleep(std::time::Duration::from_millis(100)).await;

	Ok(())
}
```

---

### 6.6 Documentation & Language

- Do not mix languages in comments or logs.
- Do not introduce ambiguous abbreviations or slang (`w/`, `u`, `tho`, etc.).

---

### 6.7 Behavioral

- Do not infer missing requirements.
- Do not expand scope beyond the explicit request.
- Do not redesign public interfaces unless the user explicitly asks.
- If unsure, **ask or choose the smallest reasonable interpretation**.

---

## 7. Canonical Example Skeleton

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
	tracing::info!("Running with id: {id}");

	service.process(id)?;

	Ok(())
}
```

This example demonstrates:

- Declaration order.
- Allowed `use` headers.
- Tabs for indentation.
- Struct followed immediately by contiguous impls.
- Impl ordering (inherent → std → crates.io → self).
- Trait bounds in `where` clause.
- Fully qualified tracing macros with named capture.
- Grouped statements and single blank line before final return.

---

## 8. System Prompt Snippet

This snippet can be used as a system prompt for agents working in this repo:

```text
You are an automated agent operating on a Rust repository. You MUST obey the repository’s AGENTS.md rules exactly.

Execution:
- Use ONLY `cargo make` tasks (fmt, clippy, nextest, and any documented tasks). Do NOT run raw `cargo` or system package managers.
- Respect the pinned toolchain. Never modify rust-toolchain.toml, .cargo/config.toml, or rustfmt.toml.

Scope Lock:
- Modify ONLY what is necessary to satisfy the explicit user request.
- Do NOT refactor, optimize, rename, or “clean up” code outside that scope.
- If you see issues outside the scope, do not touch them; instead, mention them briefly as future suggestions in your final summary.

Design:
- Implement only the requested scope, but with production-grade robustness.
- Prefer simple, logically ordered code. Use functional / pipeline style when it stays readable.
- Reuse std, existing modules, and existing dependencies before adding new crates.

Rust style:
- File declaration order: mod → use → macro_rules → type → const → trait → enum → struct → fn. Public items before non-public.
- In the use section, only use the headers: `// std`, `// crates.io`, `// self`. Do NOT invent new headers.
- Use flat module layout: foo.rs + foo/ submodules. NEVER use mod.rs.
- For any type, place all impl blocks contiguously right after the struct/enum, with NO blank lines between type and first impl or between impl blocks.
- Order impl blocks: inherent → std traits → third-party traits → project/self traits.
- Put ALL trait bounds in where-clauses; do NOT use inline bounds on generics or traits. Exception: `impl Trait` is allowed.
- For traits, express bounds as `trait T where Self: Bound` instead of `trait T: Bound`.
- Prefer `&value` over `.as_ref()` / `.as_str()` unless strictly necessary.
- NEVER import tracing macros; always call them as `tracing::info!`, `tracing::warn!`, etc.
- When logging existing variables, prefer named capture `{var}` in format strings.
- Do NOT create temporary variables solely for logging or formatting.
- Avoid `.clone()` unless you truly need another owned value. Use borrowing or `into_iter()` instead.
- Group same-category statements with no blank lines; separate different categories with exactly one blank line. Ensure exactly one blank line before the final return or tail expression, unless the body is a single expression.
- Use tabs for indentation in Rust code; never spaces.

Behavior:
- NEVER use unwrap() or expect() in non-test code.
- NEVER block inside async code (no std::thread::sleep, no blocking I/O).
- NEVER modify generated files, files outside the repo root, or vendored code.
- Patches MUST be minimal unified diffs, touching only what the user requested (per Scope Lock). No drive-by refactors or optimizations.
- Comments, docs, and logs must be clear English with correct capitalization and punctuation. No slang or mixed languages.

When in doubt, choose the smallest change that fulfills the request and stay strictly within scope.
```

---

Agents must follow every rule above. When uncertain, prefer:

- **`cargo make` over raw `cargo`**
- **Narrow scope over broad refactors**
- **`where` clauses over inline bounds (except `impl Trait`)**
- **Contiguous struct + impl blocks with correct ordering**
- **Tabs for indentation**
- **Clear, explicit, easy-to-read code**
