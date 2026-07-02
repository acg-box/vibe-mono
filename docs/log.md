# Documentation Log

Purpose: Record routing, promotion, rename, and maintenance changes that affect
the repository LLM Wiki and OKF bundle.

## 2026-07-02

- Reworked the template into a workspace-first monorepo layout with
  `apps/name_placeholder/` owning the default Rust CLI package and `packages/`
  reserved for reusable shared libraries.
- Split root Cargo authority from app package authority: root `Cargo.toml`
  owns workspace metadata, profiles, membership, and shared dependencies while
  `apps/name_placeholder/Cargo.toml` owns package-specific metadata.
- Updated layout, CLI, adoption, README, and release workflow references so
  generated repositories no longer assume a root-level single-package `src/`
  layout.

## 2026-06-25

- Promoted the existing docs tree into a strict Markdown OKF bundle with
  `docs/policy.md` as the profile owner.
- Added required `research` and `evidence` lane indexes.
- Added `docs/evidence/docs-self-check.md` as the drift audit anchoring the docs
  self-check loop.
- Added `docs/runbook/template-adoption.md` so generated repositories can inherit
  the docs structure and replace template-specific contracts deliberately.
- Added `docs/decisions/docs-okf-template-foundation.md` to record why the
  template uses a docs-backed OKF/LLM Wiki profile.
- Clarified checker-enforced `status` and `authority` frontmatter values in
  `docs/policy.md`.
- Clarified checker-enforced structured frontmatter rules for source, code,
  related, promotion, tag, and drift-watch fields in `docs/policy.md`.
