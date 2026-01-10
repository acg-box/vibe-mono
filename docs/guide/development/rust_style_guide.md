# Rust Style Guide

These rules apply only to Rust code in this repository.
All comments and messages must also follow the Global Language Rules in `AGENTS.md`.

## Indentation

- Use tabs (`\t`) for all indentation.

## Declaration Order

Each Rust file must follow this order:

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

Within each group:

- `pub` items appear before non-`pub`.

Expanded `mod tests` blocks belong at the end of the file, after all other items.

Inside `mod tests`, prefer `use super::*;` before any other `use` statements.

## Imports and Headers

Allowed `use` section headers:

- `// std`
- `// crates.io`
- `// self`

Rules:

- Preserve existing header groups.
- Do not invent new groups.
- Do not add headers above non-import definitions.
- If `crate::prelude::*` is imported, avoid redundant imports.

## Module Layout (No mod.rs)

Use a flat structure:

```
src/foo.rs
src/foo/bar.rs
src/foo/baz.rs
```

Never create or modify `mod.rs`.

## Structs, Enums, and Impl Blocks

For each type:

1. The first `impl` block must appear immediately after the type definition.
2. All impls must be contiguous without blank lines between them.
3. Impl order:
   1. Inherent impl
   2. Std traits
   3. Third-party traits
   4. Project or self traits

Inside `impl Type` blocks, always use `Self` instead of the concrete type name when referring to
the implementing type in method signatures (parameters and return types), including references,
slices, and generic containers.

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

## Generics and Trait Bounds

- All bounds go in a `where` clause.
- Inline trait bounds are forbidden.
- Exception: `impl Trait` is always allowed.

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

## Logging Rules

- Never import tracing macros.
- Use fully-qualified macros (`tracing::info!`).
- Prefer named captures:

```rust
tracing::info!("User: {user_id}");
```

- Never create temporary variables solely for logging.


## Error Wrapping

- Add contextual messages at crate or module boundaries, and keep the original error as the source.
- Use `#[error(transparent)]` only for thin wrappers where this crate adds no context and the upstream
  message is already sufficient for developers.
- Prefer short, action-oriented messages that name the operation and include the source error.

Example:

```rust
#[derive(Debug, thiserror::Error)]
pub enum Error {
	#[error(transparent)]
	Utf8(#[from] std::str::Utf8Error),
	
	#[error("Failed to serialize JetStream payload: {0}.")]
	Json(#[from] serde_json::Error),
}
```

## Borrowing and Ownership

- Prefer `&value` over `.as_ref()` or `.as_str()` where applicable.
	- Avoid `.clone()` unless it is required by ownership or lifetimes.
	- Use `into_iter()` when consuming collections intentionally.
	- Do not use scope blocks solely to end a borrow.
	- When an early release is required, use an explicit drop.
	- When the value is a reference, prefer `let _ = value;` to end the borrow without triggering a
	  drop warning.
	- Avoid single-use `let` bindings that only forward a value; inline the expression unless it
	  improves readability, error handling, or avoids repeated work.

## Numeric Literals

- When using a numeric type suffix, always separate the value and suffix with a single underscore:
  - Allowed: `10_f64`, `1_u32`, `0_i64`
  - Forbidden: `10f64`, `1u32`, `0i64`

- For decimal integer literals with more than three digits (ignoring the sign), insert an
  underscore every three digits from the right:
  - Allowed: `1_000`, `10_000`, `1_000_000`
  - Forbidden: `1000`, `10000`, `1000000`

## Vertical Spacing

Inside Rust functions:

- Same-category statements: no blank lines.
- Different categories: one blank line.
- Before the final return or tail expression: exactly one blank line (unless single-expression
  body).
