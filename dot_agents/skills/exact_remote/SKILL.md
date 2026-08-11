---
name: remote
description: >-
  Run commands and transfer files on remote machines via the local `remote`
  SSH wrapper (run/get/put, BatchMode, Host aliases). Use when the user asks to
  check another host, pull logs, journalctl, scp/rsync-style file moves, SSH into
  a box for investigation, or do work on a machine that has no Herdr session.
  Prefer this over hand-rolled ssh/scp. Do not use for herdr --remote TUI attach.
---

# Remote

Drive other machines through the local `remote` CLI (`~/.local/scripts/remote`).
It wraps SSH/SCP with BatchMode, ControlMaster reuse, and safe quoting so agents
can run non-interactively.

```bash
remote --help
remote run --help
```

Host names are OpenSSH targets — prefer `Host` aliases from `~/.ssh/config`.

## When to use

- Inspect or operate on another machine (logs, services, disk, processes).
- Fetch or drop a file without opening an interactive SSH shell.
- A dispatched coding agent needs remote evidence but should write its report
  on **this** machine.

Do **not** use this skill for:

- Interactive TUI attach with clipboard/image bridge → `herdr --remote <host>`.
- Full coding-agent sessions on a remote checkout that already runs Herdr → SSH
  there (or a Herdr control path) and use agents-supervisor / `herdr` locally on
  that host. `herdr --remote` is attach-only and must not be used for automation.

## Commands

```bash
remote run <host> -- <cmd...>
remote run <host> --cwd <dir> -- <cmd...>
remote get <host> <remote-path>                 # stdout
remote get <host> <remote-path> -o <local-path>
remote put <host> <local-path> <remote-path>
```

Examples:

```bash
remote run workbox -- journalctl -u myapp -n 200 --no-pager
remote run workbox --cwd /srv/app -- ls -lt
remote get workbox /var/log/app/error.log
remote get workbox ~/notes.md -o /tmp/notes.md
remote put workbox ./fix.sh /tmp/fix.sh
```

`run` executes under remote `bash -lc` so login `PATH` matches an interactive
SSH session. Exit codes propagate from the remote command.

## Auth and failure modes

- Requires non-interactive SSH auth (`BatchMode=yes`). If a passphrase-protected
  key is needed, load it into `ssh-agent` first (`ssh-add`); do not expect a
  password prompt.
- If `ssh <host>` itself fails, fix plain SSH before debugging `remote`.
- Long-running `run` commands rely on SSH keepalives and ControlMaster under
  `~/.cache/remote-ssh`.

## Reporting

Capture command output or `remote get` results into whatever deliverable the
caller asked for (often `~/.cache/agents-supervisor/<date>/<name>.md` when a
supervisor dispatched you). Prefer summarizing on this machine; do not assume
remote home paths are readable locally without `get`.

## Prompting a sub-agent

If you dispatch another agent to do the remote work, the prompt must name the
SSH Host alias, the exact `remote` commands or investigation goal, constraints
(e.g. read-only), and where to write the report on **this** host.
