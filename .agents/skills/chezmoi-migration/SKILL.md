---
name: chezmoi-migration
description: Apply destructive chezmoi migrations from changelogs/ when the user says "更新一下"/"update config" or "apply 一下"/"apply", or when making/reviewing a breaking chezmoi change that fails the residual test (local config migration, environment-dependent adjustment) and needs a changelog entry.
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

2. **Filter.** For each entry, run its completion condition on the current
   machine — that condition is the only gate. Entries carry no applied
   state: the same changelog file is shared by every machine, so nothing in
   it can tell you whether *this* machine is done. The machine-local marker
   `~/.local/state/chezmoi-migrations/<slug>` is bookkeeping only; trust the
   condition over the marker when they disagree.

3. **Apply.** Run each pending entry's migration steps exactly as written.
   For destructive steps, read the current files first and touch nothing
   unmanaged or unrelated. Every entry is idempotent — re-running a
   satisfied entry is a no-op.

4. **Verify.** Confirm each applied entry's completion condition now holds.

5. **Mark.** Write the machine-local marker (never record applied-ness in
    the repo — it would go stale):
    ```
    mkdir -p ~/.local/state/chezmoi-migrations && date > ~/.local/state/chezmoi-migrations/<slug>
    ```

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
