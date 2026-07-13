# Knowledge Maintenance

## Purpose And Authority

OpenWiki is the repository's concise, checked-in retrieval layer for humans and future agents. Start at [Quickstart](quickstart.md), route to the smallest page that owns the question, and verify important claims against cited implementation/configuration before changing code or documentation.

This page retains the useful governance from the former strict OKF system without preserving its frontmatter and per-lane-index overhead. Source code, manifests, task definitions, and workflows remain authoritative for implemented behavior; accepted decision records own rationale; procedures own execution order; evidence owns only what it actually demonstrates.

## Routing And Claim Ownership

| Question | Owner |
| --- | --- |
| What is this repository and where do I start? | `openwiki/quickstart.md` |
| How are workspace/runtime boundaries implemented? | `openwiki/architecture-and-runtime.md` |
| Which command or CI/release sequence applies? | `openwiki/operations.md` |
| How is the template converted into a project? | `openwiki/template-adoption.md` |
| How should knowledge, rationale, research, and evidence be maintained? | This page |
| What is the public project pitch/setup? | `README.md`, once placeholders are replaced |
| What exact task runs? | `Makefile.toml` |

Rules:

- Keep one canonical owner per durable claim. Link rather than copy.
- Separate required behavior, current implementation, procedure, rationale, research, and evidence even when they share a page.
- Prefer stable subject names and shallow paths. Create a directory only for a real domain with enough material to sustain it.
- Do not create empty indexes, placeholder pages, or speculative domains.
- Mark unresolved proposals non-authoritative; do not let research silently become a contract.
- Keep evidence public-safe: no secrets, credentials, private user data, `.env` contents, or machine-local state.
- Keep `quickstart.md` as the canonical router. If a repository-level OpenWiki routing block is retained, keep it brief and aligned with this corpus; it must not define behavior or automation policy.

## Change Workflow

Before claiming a change ready, classify its documentation impact:

- `none`: no behavior, command, config, layout, status, workflow, or durable rationale changed.
- `update_required`: update the page owning the changed claim.
- `research_required`: capture options/evidence before promoting an unresolved choice.
- `drift_required`: add or refresh public-safe evidence because alignment itself is a maintained claim.

Then:

1. Read the owning OpenWiki page and its cited sources.
2. Inspect the changed implementation/config and relevant recent Git history.
3. Update the owning source first, then run `openwiki code --update --print` and review the generated diff against source authority. Direct page edits are reserved for explicit curation or correction.
4. Repair all links and routing affected by moves/renames; record routing, promotion, rename, or maintenance-policy changes in this page's historical context (or a focused successor history page if the record grows). Routine content corrections need no log entry.
5. Run source checks from [Operations](operations.md) and a focused wiki self-check.
6. Record a durable decision only when future maintainers would otherwise need to rediscover an accepted tradeoff.

A behavior change requires updating its contract. A procedure/command change requires updating operations. A layout/ownership change requires updating architecture. Changes crossing boundaries update each owner while preserving one canonical home per claim.

## OpenWiki Drift Check

Use a durable drift-audit section or focused page when alignment itself is a maintained claim. Record its status, authority (`evidence`), owner, and last verification date, then include:

- **Watched claims:** exact behavior, command, path, status, or workflow assertion.
- **Evidence anchors:** source/config paths and, when useful, targeted history.
- **Reverse checks:** commands or inspections that could falsify the claim.
- **Verdict:** pass/fail/partial with date and repository revision.
- **Required updates:** concrete next actions and owners.
- **Citations:** public-safe repository paths; never copied credentials or local private data.

A one-off review may use the same checks without becoming durable evidence. It must not be presented as a maintained audit unless the metadata and evidence are retained and refreshed.

For routine OpenWiki changes, verify at minimum:

- `openwiki/quickstart.md` links every major page.
- Every relative Markdown link resolves.
- Every cited repository path exists, or is explicitly historical.
- Commands match `Makefile.toml`/workflows exactly and distinguish mutation from checking.
- Runtime claims match app source and manifests.
- Template status/placeholders and untracked or unauthorized automation are not misrepresented as product decisions.
- `openwiki/_plan.md` is absent at the end of a generation/update run.

Do not treat a prose verdict as proof of command execution. Record checks actually run and disclose unavailable prerequisites.

## Accepted Documentation Decision And Migration Consequences

**Status:** accepted on 2026-06-25; the strict OKF implementation is superseded by the completed OpenWiki migration.

**Context and alternatives:** The repository accepted a checked-in knowledge system because a README alone could not reliably route agents, distinguish contracts from procedures and rationale, or support drift checks as the project grows. README-only guidance lacked ownership context; a separate external `wiki/` or `okf/` tree would split authority from repository docs. Strict docs-backed OKF added frontmatter/index maintenance but made ownership and validation checkable, so it was chosen over those alternatives.

**Decision and consequences:** Retain the accepted checked-in, agent-routable knowledge goal while replacing the strict lane/frontmatter machinery with five concise OpenWiki pages:

- `openwiki/quickstart.md` is the single knowledge entrypoint; subject sections replace mandatory lane directories and indexes.
- `docs/`, strict OKF frontmatter, the standalone log/evidence lanes, and `cargo make check-docs` were intentionally removed rather than left as a second authority.
- Readiness now requires focused manual checks of links, citations, current commands/configuration, and runtime claims. A failed or incomplete check is a documentation completion blocker even though no repo-native docs command enforces it.
- No recurring OpenWiki automation is authorized. An untracked/generated workflow or routing file does not establish policy or current automation.
- Generated repositories must replace template-specific OpenWiki claims when their real contracts diverge.

This migration supersedes the implementation mechanism, not the accepted rationale: checked-in routing, authority separation, public-safe evidence, and explicit promotion remain required. Replace or amend the decision if the repository approves a different knowledge root, restores machine-enforced documentation validation, authorizes recurring maintenance automation, or outgrows the five-page ownership model. Historical sources remain available in commits `7c80c51` and `69eb753`; current routing is owned by `openwiki/quickstart.md` and this corpus.

## Historical Context

- **2026-06-25:** commit `7c80c51` formalized the strict docs-backed OKF, added research/evidence lanes, a self-check, template-adoption runbook, and the accepted documentation decision. Commit `69eb753` later clarified structured frontmatter rules.
- **2026-07-02:** commit `4f91ab1` moved the CLI into `apps/name_placeholder/`, created `packages/`, split root/package Cargo authority, and updated docs/release paths for the workspace-first template.
- **Completed migration:** replaced the deleted `docs/` lanes, log, and Decodex gate with this five-page OpenWiki corpus and focused manual drift review; recurring OpenWiki automation remains unauthorized.
- The only accepted durable decision in the migrated corpus concerns the knowledge-system foundation. The workspace layout is implemented and logged but lacks a standalone rationale record; do not invent one.
- The legacy self-check reports `pass` with `last_verified: 2026-06-25`, predates the monorepo migration, and includes no command transcript/revision. Treat it as historical evidence, not current proof.

Sources: Git history at commits `7c80c51`, `69eb753`, and `4f91ab1`.

## Migration Drift Audit

**Status:** active evidence. **Owner:** maintainers. **Last verified:** 2026-07-11 at repository revision `ee6f87f` with the documented migration present as an uncommitted working-tree change.

- **Watched claims:** `openwiki/` is the only maintained knowledge root; all five pages are reachable from `quickstart.md`; task, runtime, workspace, CI/…762 tokens truncated…ip changes.
