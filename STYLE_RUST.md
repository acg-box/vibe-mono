# STYLE_RUST.md — Rust Style Rules

These rules apply **only** to Rust code in this repository.
All comments and messages must also follow the Global Language Rules in `AGENTS.md`.

---

# 1. Indentation

- Use **tabs** (`\t`) for all indentation.

---

# 2. Declaration Order

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

---

# 3. Imports and Headers

Allowed `use` section headers:

- `// std`
- `// crates.io`
- `// self`

Rules:

- Preserve existing header groups.
- Do not invent new groups.
- Do not add headers above non-import definitions.
- If `crate::prelude::*` is imported, avoid redundant imports.

---

# 4. Module Layout (No mod.rs)

Use a flat structure:

```
src/foo.rs
src/foo/bar.rs
src/foo/baz.rs
```

Never create or modify `mod.rs`.

---

# 5. Structs, Enums, and Impl Blocks

For each type:

1. The first `impl` block must appear **immediately after** the type definition.
2. All impls must be **contiguous** without blank lines between them.
3. Impl order:
    1. Inherent impl
    2. Std traits
    3. Third-party traits
    4. Project/self traits

4. Inside `impl Type` blocks, always use `Self` instead of the concrete type name when referring to the implementing type in method signatures (parameters and return types), including references, slices, and generic containers.

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

---

# 6. Generics & Trait Bounds

- All bounds go in a `where` clause.
- Inline trait bounds **forbidden**.
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

---

# 7. Logging Rules

- Never import tracing macros.
- Use fully-qualified macros (`tracing::info!`).
- Prefer named captures:

```rust
tracing::info!("User: {user_id}");
```

- Never create temporary variables solely for logging.

---

# 8. Borrowing & Ownership

- Prefer `&value` over `.as_ref()` or `.as_str()` where applicable.
- Avoid unnecessary `.clone()`.
- Use `into_iter()` when consuming collections intentionally.

---

# 9. Numeric Literals

- When using a numeric type suffix, always separate the value and suffix with a single underscore:
    - Allowed: `10_f64`, `1_u32`, `0_i64`
    - Forbidden: `10f64`, `1u32`, `0i64`

- For decimal integer literals with more than three digits (ignoring the sign), insert an underscore every three digits from the right:
    - Allowed: `1_000`, `10_000`, `1_000_000`
    - Forbidden: `1000`, `10000`, `1000000`

---

# 10. Vertical Spacing

Inside Rust functions:

- Same-category statements: **no blank lines**.
- Different categories: **one blank line**.
- Before final return/tail expression: **exactly one** blank line (unless single-expression body).

---

# 11. Comments & Documentation

- Must follow Global Language Rules.
- Clear English, proper punctuation.
- No slang, abbreviations, or mixed-language text.

---

# 12. Forbidden Style

Never:

- Use spaces for indentation.
- Use inline trait bounds.
- Add blank lines between a type and its first impl.
- Add blank lines between impl blocks.
- Use `mod.rs`.
- Import tracing macros.

---

# 13. Closure Parameters

- In short-lived closures where the meaning is obvious and the bindings are not reused elsewhere, prefer single-letter names (e.g., `k`, `v`, `e`).
- Use descriptive names when a closure spans multiple lines, when the role is not immediately clear, or when the bindings are referenced outside the closure.
