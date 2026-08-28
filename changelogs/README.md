# Changelogs — Destructive Updates

Record breaking changes here so the `chezmoi-migration` skill can apply them
on each machine when you say "更新一下" / "apply 一下".

> Pure deletions (a leftover file/dir that should simply be gone) do **not**
> need an entry — use a `remove_` placeholder instead (see
> `AGENTS.md` → Deletions Do Not Propagate). This directory is only for
> migrations a `remove_` cannot express.

## When to log — the residual test

Log a change only if it fails the **residual test**: after `chezmoi apply`,
an old machine still has something left to do by hand —

- old directories/files on disk that should be deleted or moved
- local config that must be migrated (not re-rendered)
- per-environment paths or values that need adjusting on this machine

Additive changes (new config, new template, new app, new script) pass the
test — `apply` installs everything, nothing is left over — and are never
logged.

The test is observable: run `chezmoi apply --dry-run` and ask whether an
existing machine ends up clean. Clean means no entry.

## Rules

- One file per change: `YYYY-MM-DD-<slug>.md`.
- Record the date; entries never expire.
- Never deployed (see `.chezmoiignore`); read by the migration agent only.
- Every entry is idempotent: re-running it is a no-op, and it states a
  completion condition the agent checks before running it again.
- Changelogs are **shared across machines**; applied-ness is per-machine and
  must NOT be recorded in this directory (it would go stale). The completion
  condition, run on the current machine, is the only gate. After a verified
  apply the agent drops a machine-local marker — see "Applied markers".

## Applied markers

After an entry's completion condition verifies, the agent writes:

```
~/.local/state/chezmoi-migrations/<slug>
```

(content: the date). The marker lives in the machine's home dir — never in
git, so it cannot leak across machines or go stale in this repo. It is
bookkeeping for humans and agents (`ls ~/.local/state/chezmoi-migrations`
shows what this machine has migrated), **not** a gate: when in doubt, trust
the completion condition over the marker.

## Template

```markdown
# <Title>

Date: YYYY-MM-DD

## What changed

One paragraph: the change and the residual it leaves on old machines.

## Impact

- Which machines/setups are affected
- What breaks if the migration is skipped

## Migration steps

Numbered commands the agent runs. Must be idempotent and safe to re-run.

## Completion condition

How to check on a machine that the migration is done (a file no longer
exists, a config key present). If met, write the marker (see Applied
markers) and skip re-running.
```
