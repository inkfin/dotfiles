---
name: chezmoi-migration
description: Apply destructive chezmoi updates from changelogs/ when the user says "更新一下", or when making/reviewing a breaking chezmoi change that needs a changelog entry (old dir/file deletion, local config migration, environment-dependent adjustment).
---

# Chezmoi Migration

Apply changelog-recorded destructive updates per-machine on request. See
`changelogs/README.md` for what qualifies (the residual test) and the entry
template.

## When to log

A change needs a changelog entry when it fails the **residual test**:
after `chezmoi apply`, an old machine still needs hand work — deleting/moving
old files, migrating local config, or adjusting per-environment paths. Pure
additive changes pass the test and need no entry. See
`changelogs/README.md` for the full test.

## Workflow: "更新一下"

When the user asks to update:

1. **Read.** List entries and open each in date order.
   ```
   ls -1 changelogs/ | grep -E '^[0-9]{4}-'
   ```

2. **Filter.** For each entry, check its completion condition on the current
   machine. Skip entries already applied or already satisfied; keep only
   pending ones.

3. **Apply.** Run each pending entry's migration steps exactly as written.
   For destructive steps, read the current files first and touch nothing
   unmanaged or unrelated.

4. **Verify.** Confirm each applied entry's completion condition now holds.

5. **Mark.** Set `Status: applied` in each applied entry's file.

6. **Report.** Which entries applied, which skipped (and why), and any manual
   steps left for the user (restart an app, re-login).

## Safety rules

- Read before you delete; back up first when unsure.
- Keep secrets, tokens, and private keys out of the source tree and changelog.
- Confirm scope when an entry touches more than the user asked about.
- Stop and report partial state if a step fails; do not force through.

## Final checks

```zsh
chezmoi diff
chezmoi apply --dry-run --verbose
git -C ~/.local/share/chezmoi status --short
```
