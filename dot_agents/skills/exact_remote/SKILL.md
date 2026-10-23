---
name: remote
description: >-
  Work on remote machines using available MCP tools or SSH: inspect and edit
  files, run scripts and builds, collect logs, and transfer files. Use when the
  user asks to operate on another host, including win-workstation from devcloud.
  Do not use for herdr --remote TUI attach.
---

# Remote

Choose tools for the target host; SSH is not required when a suitable remote
MCP is callable. Local file and shell tools still operate on this machine:
they do not become remote tools just because an MCP is configured.

- **Windows workstation:** prefer the `windows` MCP for file development,
  searches, scripts, and command-line builds. Use native SSH/SFTP as a fallback
  or for file transfers between machines.
- **Other hosts:** use a suitable MCP if available; otherwise use the local
  `remote` CLI (`~/.local/scripts/remote`) for hosts with `bash`.
- **Windows client/editor/GPU work:** also read `windows-joint-debug` when that
  skill is available.

Confirm an MCP's target before operating on it. A config entry alone does not
make its tools available in the current session. Discover tools when supported;
if they are unavailable, use the appropriate SSH fallback.

## When to use

- Inspect or operate on another machine (logs, services, disk, processes).
- Fetch or drop a file without opening an interactive SSH shell.
- A dispatched coding agent needs remote evidence but should write its report
  on **this** machine.

Do **not** use this skill for:

- Interactive TUI attach with clipboard/image bridge → `herdr --remote <host>`
  (Windows: `wsl herdr --remote <host>`; native `herdr.exe` rejects remote mode).
- Full coding-agent sessions on a remote checkout that already runs Herdr → SSH
  there (or a Herdr control path) and use agents-supervisor / `herdr` locally on
  that host. `herdr --remote` is attach-only and must not be used for automation.

## Windows MCP

The machine-local MCP named `windows` connects devcloud to `win-workstation`.
Client tool names may have a server prefix; use the actual exposed schemas.
Start with `get_config` to check `systemInfo`, the shell, and allowed directories.
Use `start_process` with `hostname` if the target identity is unclear.

| Task | Tools |
|---|---|
| Inspect files | `list_directory`, `read_file`, `read_multiple_files`, `get_file_info` |
| Edit files | `write_file`, `edit_block`, `create_directory`, `move_file` |
| Search | `start_search`, `get_more_search_results`, `stop_search` |
| Run scripts/builds | `start_process`, `read_process_output` |
| Process interaction | `interact_with_process`, `list_sessions`, `force_terminate` |

Use absolute Windows paths, such as `D:\Code\project`; in JSON they become
`"D:\\Code\\project"`. Select the user-named project rather than assuming a game
or engine root. `start_process` has no `cwd` argument: set the working directory
inside the command. The installed default shell is non-interactive PowerShell 7.

```json
{
  "command": "Set-Location 'D:\\Code\\project' -ErrorAction Stop; python .\\scripts\\check.py; exit $LASTEXITCODE",
  "timeout_ms": 1000
}
```

A process call can return before completion. Keep its PID and poll
`read_process_output` until completion and exit status; one output chunk is
not proof of completion. Save long build logs on Windows. Sessions are held
by the MCP server and are not guaranteed to survive a disconnect or client
restart. After uncertain completion, inspect processes, logs, and artifacts
before retrying a build or another mutating operation.

Commands run with the SSH user's Windows permissions in Session 0, not the
interactive desktop session. GUI launch, screenshots, and input require a
desktop-session runner; MCP process execution alone does not provide that.
Directory allowlists are guardrails, not a sandbox for shell commands.

Connection settings are machine-local. The devcloud clients share
`~/.local/scripts/windows-agent-mcp`; the Windows launcher is
`~/.config/windows-agent/start-mcp.cmd`, with settings in
`~/.claude-server-commander/config.json` and maintenance notes in
`~/.config/windows-agent/README.md`. Do not install or reconfigure an MCP merely
to perform an unrelated remote task.

## SSH Fallback

The `remote` CLI wraps SSH/SCP with BatchMode, ControlMaster reuse, and safe
quoting. Host names are OpenSSH targets; prefer aliases from `~/.ssh/config`.

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
SSH session. Exit codes propagate from the remote command. Do not use
`remote run` or stdout-mode `remote get` on native Windows: both assume Unix
commands. Windows OpenSSH on `win-workstation` defaults to `cmd.exe`; use
native SSH with explicit PowerShell, and SCP/SFTP for transfers.

```bash
ssh -T -o BatchMode=yes -o ConnectTimeout=10 win-workstation hostname
ssh -T -o BatchMode=yes win-workstation powershell -NoProfile -NonInteractive -Command "Get-ChildItem 'D:\Code'"
scp -o BatchMode=yes win-workstation:C:/path/to/log.txt /tmp/log.txt
```

## Auth and failure modes

- Requires non-interactive SSH auth (`BatchMode=yes`). If a passphrase-protected
  key is needed, load it into `ssh-agent` first (`ssh-add`); do not expect a
  password prompt.
- If `ssh <host>` itself fails, fix plain SSH before debugging `remote`.
- Long-running `run` commands rely on SSH keepalives and ControlMaster under
  `~/.cache/remote-ssh`.

## Reporting

Capture MCP results, command output, or fetched files into the requested
deliverable (often `~/.cache/agents-supervisor/<date>/<name>.md` when a supervisor
dispatched you). Prefer summarizing on this machine; remote paths are not local
paths. Fetch artifacts when the deliverable requires local files.

## Prompting a sub-agent

If you dispatch another agent, name the target MCP server or SSH alias, the
remote paths, the investigation goal, constraints (e.g. read-only), and where to
write the report on **this** host. For MCP work, confirm the subagent can access
those tools rather than assuming inheritance.
