# Rust Style Guide

These rules apply only to Rust code in this repository.
All comments and messages must also follow the Global Language Rules in `AGENTS.md`.

## Rule Language and Precedence

- MUST indicates a strict requirement.
- SHOULD indicates a strong preference.
- MAY indicates an optional choice.
- rustfmt output is always the final authority for formatting.

## Normative Rules

### Indentation

- Indentation MUST use tabs (`\t`).

### Declaration Order

Each Rust file MUST follow this order for module-level items:

```
mod
use
macro_rules!
type
const
static
trait
enum
struct
impl
fn
```

Within each group, `pub` items MUST appear before non-`pub` items.

Expanded `#[cfg(test)] mod tests { ... }` blocks MUST appear at the end of the file, after all other items.
If `mod tests;` is used, it MUST appear after all other items as well.

### Imports and Headers

Allowed `use` section headers are:

- `// std`.
- `// crates.io`.
- `// self`.

Rules:

- You MUST preserve existing header groups.
- You MUST NOT invent new groups.
- You MUST NOT add headers above non-import definitions.
- Within each header group, you MUST order imports lexicographically by full path text (ASCII order, case-sensitive).

### Module Layout (No mod.rs)

You MUST use a flat structure:

```
src/foo.rs
src/foo/bar.rs
src/foo/baz.rs
```

You MUST NOT create or modify `mod.rs`.

### Structs, Enums, and Impl Blocks

For each type:

1. The first `impl` block MUST appear immediately after the type definition.
2. All `impl` blocks MUST be contiguous without blank lines between them.
3. `impl` order MUST be:
    1. Inherent `impl`.
    2. Standard library traits.
    3. Third-party traits.
    4. Project or self traits.

Inside `impl Type` blocks, you MUST use `Self` instead of the concrete type name when referring to the
implementing type in method signatures (parameters and return types), including references, slices,
and generic containers.

Examples (non-normative):

Allowed:

```rust
struct A;

impl A {
	fn new() -> Self {
		Self
	}

	fn from_owned(value: Self) -> Self {
		value
	}

	fn from_ref(value: &Self) -> &Self {
		value
	}

	fn collect_all(values: &[Self]) -> Vec<Self> {
		values.to_vec()
	}
}
```

Forbidden:

```rust
struct A;

impl A {
	fn new() -> A {
		A
	}

	fn from_owned(value: A) -> A {
		value
	}

	fn from_ref(value: &A) -> &A {
		value
	}

	fn collect_all(values: &[A]) -> Vec<A> {
		values.to_vec()
	}
}
```

### Generics and Trait Bounds

- All bounds MUST go in a `where` clause.
- Inline trait bounds MUST NOT be used.
- You MAY use `impl Trait`.

Allowed:

```rust
fn render<T>(value: T) -> String
where
	T: Display,
{
```

Forbidden:

```rust
fn render<T: Display>(value: T) -> String {
```

### Logging Rules

- Tracing macros MUST be fully qualified (for example, `tracing::info!`).
- Tracing macros MUST NOT be imported.
- Tracing calls MUST use structured fields for dynamic values such as identifiers, names, counts, statuses, sizes, durations, and errors.
- You MUST NOT encode those values only in the message string.

Examples (non-normative):

Allowed:

```rust
tracing::info!(user_id, org_id, "User logged in.");
```

Forbidden:

```rust
tracing::info!("User {user_id} logged in (org {org_id}).");
```

### Numeric Literals

- When using a numeric type suffix, you MUST separate the value and suffix with a single underscore.
- For decimal integer literals with more than three digits (ignoring the sign), you MUST insert an underscore every three digits from the right.

Allowed:

- `10_f64`.
- `1_u32`.
- `0_i64`.
- `1_000`.
- `10_000`.
- `1_000_000`.

Forbidden:

- `10f64`.
- `1u32`.
- `0i64`.
- `1000`.
- `10000`.
- `1000000`.

## Guidance (Non-Normative)

Guidance is non-normative. Follow it unless it conflicts with MUST rules, rustfmt output, or explicit requirements.

### Declaration Order

- Inside `#[cfg(test)] mod tests`, prefer `use super::*;` before any other `use` statements.

### Imports and Headers

- If `crate::prelude::*` is imported, avoid redundant imports.

### Logging Rules

- Use a short, action-oriented message alongside structured fields.
- Avoid creating temporary variables solely for logging.

### Error Wrapping

- Add contextual messages at crate or module boundaries and keep the original error as the source.
- Use `#[error(transparent)]` only for thin wrappers where this crate adds no context and the upstream message is already sufficient for developers.
- Prefer short, action-oriented messages that name the operation and include the source error.

Example (non-normative):

```rust
#[derive(Debug, thiserror::Error)]
pub enum Error {
	#[error(transparent)]
	Utf8(#[from] std::str::Utf8Error),

	#[error("Failed to serialize JetStream payload: {0}.")]
	Json(#[from] serde_json::Error),
}
```

### Borrowing and Ownership

- Prefer `&value` over `.as_ref()` or `.as_str()` where applicable.
- Avoid `.clone()` unless it is required by ownership or lifetimes.
- Use `into_iter()` when consuming collections intentionally.
- Do not use scope blocks solely to end a borrow.
- When an early release is required, use an explicit `drop`.
- When the value is a reference, prefer `let _ = value;` to end the borrow without triggering a drop warning.
- Avoid single-use `let` bindings that only forward a value; inline the expression unless it improves readability, error handling, or avoids repeated work.

### Vertical Spacing

Inside Rust functions:

- Do not insert blank lines within the same statement type.
- Insert one blank line between different statement types.
- Insert exactly one blank line before the final return or tail expression, unless the body is a single expression.

Treat statements as the same type when they share the same syntactic form or call target, such as:

- Multiple `let` statements.
- Multiple `if` or `if let` statements.
- Multiple `match` statements.
- Multiple loop statements (`for`, `while`, `loop`).
- Multiple macro calls (`println!`, `tracing::...`).
- Multiple `Type::function(...)` calls.
- Multiple `self.method(...)` calls.
- Multiple assignment statements like `a = b`.
  These examples are not exhaustive. Apply the same rule to any repeated statement shape.
