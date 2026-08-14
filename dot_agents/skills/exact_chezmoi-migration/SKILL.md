---
name: chezmoi-migration
description: Check and apply destructive chezmoi updates recorded in changelogs/. Use when the user says "更新一下" / "update", when making or reviewing a breaking change to chezmoi dotfiles (old dir/file deletion, local config migration, environment-dependent adjustments), or when asked whether a recorded migration still needs to run on this machine.
---

# Chezmoi Migration

Track destructive updates in `changelogs/` and apply them per-machine on
request. Use when the user says "更新一下" — check the changelog and apply
whatever is pending on this machine — or when introducing a breaking change
that needs a changelog entry.

## When to log

Add an entry to `changelogs/YYYY-MM-DD-<slug>.md` whenever a change is
destructive and could leave an old machine in a broken or half-migrated state:

- old directories or files that should be deleted or moved
- local config that must be migrated (not just re-rendered by `chezmoi apply`)
- environment-dependent adjustments (per-OS, per-profile, per-machine paths)

Pure additive changes (new config, new template, new app) do **not** need an
entry.

## The changelog

- Location: `changelogs/` at the repo root. Never deployed (see
  `.chezmoiignore`); it is documentation for the migration agent.
- One file per change, named by date: `YYYY-MM-DD-<slug>.md`.
- Fields per entry (see `changelogs/README.md` for the template):
  - `Date` and `Status: pending | applied`
  - What changed and why it is destructive
  - Impact (which machines, what breaks if skipped)
  - Migration steps (numbered, idempotent)
  - Completion condition — how to tell on a machine that the migration is done

Keep entries idempotent: running them twice is a no-op, and each states its
completion condition.

## Workflow: "更新一下"

When the user asks to update:

1. **Read the changelog.**
   ```
   ls -1 changelogs/ | grep -E '^[0-9]{4}-'   # pending entries
   ```
   Open each entry in date order.

2. **Filter by completion condition.** For each entry, check on the current
   machine whether its completion condition is already met. Skip applied or
   already-satisfied entries. Keep only pending ones.

3. **Apply each pending entry.** Run its migration steps exactly as written.
   For destructive steps (deletes, moves), read the current files first and
   never touch unmanaged or unrelated data.

4. **Verify.** Confirm each entry's completion condition now holds.

5. **Update status.** Set `Status: applied` in each applied entry's file.

6. **Report.** Summarize which entries were applied, which were skipped (and
   why), and any manual steps the user must do (e.g. restart an app, re-login).

## Safety rules

- Read before you delete. Back up anything destructive first if unsure.
- Never copy secrets, tokens, or private keys into the source tree or the
  changelog.
- Never migrate a config the user did not ask about; confirm scope when an
  entry touches more than stated.
- If a migration step fails partway, stop and report the partial state rather
  than forcing through.

## Final checks

```zsh
chezmoi diff
chezmoi apply --dry-run --verbose
git -C ~/.local/share/chezmoi status --short
```

Report: which entries applied, which skipped, completion conditions verified,
and any user action still required.
