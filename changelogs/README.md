# Changelogs — Destructive Updates

This directory records breaking changes that affect existing machines: old
directories/files that must be deleted, local config migrations, and anything
that needs per-environment adjustment. The `chezmoi-migration` skill reads
these when you say "更新一下" to decide what to apply on the current machine.

## Rules

- One file per change, named `YYYY-MM-DD-<slug>.md` (or `<commit>.md`).
- Record only the date in the filename/frontmatter; no auto-expiry.
- Files here are never deployed by chezmoi (see `.chezmoiignore`), they are
  documentation for the migration agent.
- Each entry must be **idempotent**: running it twice is a no-op, and the
  entry states its completion condition so the agent can check whether it
  still needs to run on a given machine.

## Template

```markdown
# <Title>

Date: YYYY-MM-DD
Status: pending | applied   <!-- pending until it's been applied on this machine -->

## What changed

One paragraph: the breaking change in the chezmoi source, and why it is
destructive (deletes/moves files, rewrites local config, env-dependent).

## Impact

- Which machines/setups are affected
- What breaks if the migration is skipped

## Migration steps

Numbered commands the agent runs. Must be idempotent and safe to re-run.

## Completion condition

How to check on a machine whether this migration is done (e.g. a file no
longer exists, a config key present). If met, mark Status: applied.
```
