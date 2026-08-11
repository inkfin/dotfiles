---
name: agent-repo-setup
description: Configure a repo for agent skills — local file tracking under plans/ and domain doc layout. Run once per repo before to-spec / to-tickets.
disable-model-invocation: true
---

# Agent repo setup

Scaffold the per-repo files these skills assume:

- **Work tracking** — specs and tickets as markdown under `plans/`
- **Domain docs** — where `CONTEXT.md` and ADRs live, and how other skills should read them

No GitHub/GitLab/Linear. No download step — skills themselves live in chezmoi; this only writes repo-local conventions.

## Process

### 1. Explore

- `AGENTS.md` / `CLAUDE.md` — does either exist? Is there already an `## Agent skills` section?
- `CONTEXT.md` / `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any nested `*/docs/adr/`
- `docs/agents/` — prior run of this skill?
- `plans/` — already in use?
- Monorepo signals (`pnpm-workspace.yaml`, `package.json` workspaces, multiple `packages/*/src`)

### 2. Confirm defaults (ask only when it branches)

**Tracking** — always local files. Tell the user, don't ask:

> Specs and tickets live under `plans/<feature-slug>/`. No remote trackers.

**Domain docs** — default **single-context** (`CONTEXT.md` + `docs/adr/` at repo root). Write without asking.

Offer **multi-context** (`CONTEXT-MAP.md` + per-context `CONTEXT.md`) only when exploration found real monorepo signals — then confirm.

### 3. Draft and write

Show a short draft, then write:

1. `docs/agents/work-tracking.md` — from [work-tracking.md](./work-tracking.md)
2. `docs/agents/domain.md` — from [domain.md](./domain.md), adjusted if multi-context
3. `## Agent skills` in existing `CLAUDE.md` or `AGENTS.md` (edit whichever exists; if neither, ask which to create):

```markdown
## Agent skills

### Work tracking

Local markdown under `plans/<feature>/`. See `docs/agents/work-tracking.md`.

### Domain docs

[single-context | multi-context]. See `docs/agents/domain.md`.
```

If `## Agent skills` already exists, update in place — don't duplicate.

### 4. Done

Tell the user setup is complete. Later edits: change `docs/agents/*.md` directly. Re-run this skill only to switch layout or rebuild from scratch.

`/grill-with-docs` does **not** run this skill. It runs `/domain-modeling`, which lazily creates `CONTEXT.md` / ADRs when terms crystallise. This skill only records *where* those docs live for other skills to read.
