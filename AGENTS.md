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

## 1.2 Toolchain

The Rust toolchain is pinned.

Never:

- Modify `rust-toolchain.toml`, `.cargo/config.toml`, or `rustfmt.toml`.
- Install, update, or override toolchains.
- Invoke system package managers.

## 1.3 Model Context Protocol (MCP) Tools

Agents **should actively consider** using available MCP tools whenever they improve understanding of the codebase, reduce errors, or lead to better engineering outcomes, while still fully respecting scope and change-control rules in this document.

Use only the tools that are configured and enabled in the environment. If a tool is unavailable or fails, degrade gracefully and proceed without it.

High-level rules:

- MCP tools **do not** override scope limits. They are helpers, not a license to make broader changes.
- Do not attempt to modify MCP configuration, credentials, or endpoints.
- Prefer MCP tools over generic guessing when they can provide precise, authoritative information about code, documentation, or repository state.

### 1.3.1 context7

- **Endpoint:** `https://mcp.context7.com/mcp`
- **Tools:** `get-library-docs`, `resolve-library-id`

Usage guidance:

- Use `context7` to retrieve and resolve library documentation or identifiers when you need accurate information about external libraries, APIs, or dependencies.
- Prefer this over speculative assumptions about third-party crates or APIs.
- Do not use it to justify out-of-scope refactors; use it strictly to implement the requested change correctly.

### 1.3.2 deepwiki

- **Endpoint:** `https://mcp.devin.ai/mcp`
- **Tools:** `ask_question`, `read_wiki_contents`, `read_wiki_structure`

Usage guidance:

- Use `deepwiki` to understand higher-level concepts, architecture notes, or domain knowledge that may be documented in wiki-like systems.
- Prefer it when the user request depends on non-obvious domain context or design decisions that are likely documented elsewhere.
- Do not treat wiki content as a mandate to change unrelated parts of the codebase; it is context, not a new requirement.

### 1.3.3 github

- **Endpoint:** `https://api.githubcopilot.com/mcp`
- **Representative tools:**
    - Repository and code: `get_file_contents`, `search_code`, `list_branches`, `list_commits`
    - Issues and PRs: `list_issues`, `issue_read`, `issue_write`, `list_pull_requests`, `pull_request_read`, `pull_request_review_write`
    - Changes: `create_or_update_file`, `delete_file`, `push_files`, `create_branch`, `create_pull_request`, `update_pull_request`, `merge_pull_request`, `update_pull_request_branch`, `request_copilot_review`, `add_comment_to_pending_review`, `add_issue_comment`, `assign_copilot_to_issue`, `sub_issue_write`

Usage guidance:

- Use `github` to:
    - Inspect repository files, branches, and history when needed for the user’s request.
    - Cross-check behavior, prior decisions, or related work in issues and pull requests.

- Creation or modification actions (branches, files, pull requests, merges) must obey:
    - Scope rules in this file (no out-of-scope refactors or cleanup).
    - Any explicit user instructions about Git workflow.

- Do **not**:
    - Create or merge pull requests, or push changes, unless the user clearly asks for this workflow.
    - Delete files or repositories unless explicitly requested and clearly in scope.

### 1.3.4 memory

- **Command:** `npx -y @modelcontextprotocol/server-memory`
- **Tools:** `add_observations`, `create_entities`, `create_relations`, `delete_entities`, `delete_observations`, `delete_relations`, `open_nodes`, `read_graph`, `search_nodes`

Usage guidance:

- Use `memory` to capture and reuse long-lived, cross-task insights that improve consistency, such as:
    - Stable architectural decisions.
    - Important domain concepts and their relationships.
    - Persistent conventions or invariants that are not obvious from a single file.

- Do not store ephemeral or highly local details that are unlikely to be reused.
- Do not store sensitive information beyond what is necessary for development.

### 1.3.5 sequential-thinking

- **Command:** `npx -y @modelcontextprotocol/server-sequential-thinking`
- **Tools:** `sequentialthinking`

Usage guidance:

- Use `sequential-thinking` to structure reasoning for complex, multi-step tasks where explicit step tracking will reduce mistakes or help coordinate multiple edits.
- Prefer this when:
    - The requested change spans several modules or layers.
    - There are many interdependent steps that must be kept in a clear order.

- Even when using sequential thinking, you must still:
    - Respect scope limits and behavior-preservation rules.
    - Avoid introducing additional work beyond what the user requests.

---

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
- If unexpected file changes appear: **STOP** and ask the user.

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

## 6.3 Patch Scope

- Modify only what the explicit request requires.
- No opportunistic refactors.

## 6.4 Async & Runtime

- No `unwrap()` or `expect()` in non-test code.
- Never block inside async (`thread::sleep`, blocking I/O).

## 6.5 Behavioral

- Never infer missing requirements.
- Choose the smallest valid change.
- Ask questions only when truly blocked.

---

# 7. Rust Style Rules Reference

Rust formatting and style conventions live in `STYLE_RUST.md`.
These rules apply **only** when editing Rust code and do **not** override
the global behavior and language rules in this file.
