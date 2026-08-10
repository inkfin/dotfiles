---
name: agents-supervisor
description: Supervise and dispatch other coding agents through Herdr — start a new agent for a task, check on running agents, surface blocked ones, and collect their results. Also covers first-time setup, installing Herdr and its per-agent integration hooks. Use when the user asks to spin up, delegate to, monitor, or coordinate another agent, or mentions Herdr, agent spaces, tabs, or worktrees. Do not use merely because a task could be parallelised.
---

# Agents Supervisor

Delegate work to other coding agents running inside [Herdr](https://herdr.dev), then monitor them and report back.

This file holds **policy** — the topology, naming, permission, and reporting rules to follow.
It deliberately does not restate CLI syntax. Before issuing any control command, read the
authoritative instructions shipped with the installed binary:

```bash
herdr --skill
```

Use `herdr --help` and `herdr <group>` (e.g. `herdr agent`, `herdr worktree`) for exact flags.
When this file and the binary disagree: **strategy from here, syntax from the binary.**

## Where this skill applies

| Activity | Requires being inside Herdr |
|---|---|
| Setup: install Herdr, install integrations, edit config | No |
| Dispatch: create tabs/worktrees, start agents, prompt, read | Yes — `HERDR_ENV=1` |

For dispatch, verify first:

```bash
test "${HERDR_ENV:-}" = 1
```

If it fails, say so and stop. Never drive a Herdr session from outside it — the focused pane
belongs to someone else.

## Setup

Linux and macOS only. On Windows, point the user at https://herdr.dev instead of running anything.

1. **Herdr present?** `command -v herdr`. If missing:
   `curl -fsSL https://herdr.dev/install.sh | sh`. If present and outdated, `herdr update`.
2. **Healthy?** `herdr status` — client and server versions must be protocol-compatible.
3. **Integrations.** Integration hooks let Herdr read an agent's real lifecycle state instead of
   guessing from the screen. Install one **only for agent CLIs that actually exist on this
   machine**: check `command -v <cli>` before `herdr integration install <target>`. Compare
   against `herdr integration status` and reinstall anything not `current`. Do not install hooks
   for agents that are not installed. When the user later installs a new agent CLI, they will ask
   for its integration to be added.
4. **Config.** See below.
5. **Verify.** `herdr config check`.

### Changing Herdr config

The config is managed by chezmoi. Never edit `~/.config/herdr/config.toml` directly — it gets
overwritten. Edit the source, then apply:

```bash
chezmoi edit ~/.config/herdr/config.toml   # or edit dot_config/herdr/config.toml.tmpl
chezmoi diff
chezmoi apply
herdr server reload-config
herdr config check
```

Git worktrees are collected under `~/.agents/worktrees` via `[worktrees].directory`, so worktree
paths are managed by Herdr and never passed explicitly.

## Topology rules

**Never split panes.** Splits produce unusable narrow columns and hide agents from the sidebar.

- **Another agent on the same checkout** → new **tab** in that workspace (space).
- **Work that needs an isolated branch** → new **worktree**, which opens as its own **space**;
  put the agent in a tab there.
- **Target repo has no space yet** → match `herdr workspace list` against each entry's
  `worktree.checkout_path`. On a miss, create a plain workspace with `--cwd <repo>`. Do not create
  a worktree for a checkout that already exists — worktrees are for new branches only.

Everything runs with `--no-focus`. The user stays where they are; only focus a tab or agent when
they ask to be taken there. Consequence: background work settles as `done` rather than `idle`.
Treat both as finished.

Creating a worktree:

- `--branch` is the task slug (`fix-auth`, not `feat/fix-auth`).
- `--base` defaults to the repo's current HEAD. Never silently base off `main`.
- `--label` is the same slug; the space takes that name.
- If the branch already exists, open the worktree instead of creating it.

Multiple agents sharing one checkout can overwrite each other's edits. That is the user's call to
make, not a reason to refuse — mention the risk once when it comes up.

## Starting an agent

Default kind is `cursor`. If the user names another kind, confirm its CLI exists locally before
attempting to start it; if it does not, say so rather than letting the start time out.

Name the agent after its job — a slug matching `[a-z][a-z0-9_-]{0,31}`, unique among live agents,
suffixed `-2` on collision. Give the tab the same job name. Never name an agent after its kind.

Pass permission flags after `--`:

| Role | Flags |
|---|---|
| Writing code | `-- --yolo --trust --approve-mcps` |
| Read-only (review, research, analysis) | `-- --mode plan --trust` |

`--trust` and `--approve-mcps` matter because a fresh worktree directory otherwise stops at a
workspace-trust or MCP-approval prompt, which registers as `blocked`.

Start a new agent rather than reusing an idle one — a fresh session keeps context clean. Reuse
only when continuing a task with an agent started earlier in this same conversation, or when the
user points at a specific one.

## Assigning work

A dispatched agent knows nothing about the current conversation. Every prompt must stand alone
and state all four:

1. **Goal** — what to accomplish, concretely.
2. **Location** — repository path and branch it is working on.
3. **Constraints** — e.g. read-only, do not commit, do not push, do not touch unrelated files.
4. **Deliverable** — write the full result as Markdown to
   `~/.cache/agents-supervisor/<YYYYMMDD>/<agent-name>.md`, creating the directory if needed, and
   reply with only that path.

The report file exists because agent TUIs run on the terminal's alternate screen, where long
responses scroll out of reach of `agent read`. Keeping reports outside the repository also avoids
polluting a worktree with untracked files.

Submit with `agent prompt ... --wait` and a timeout sized to the task. On return, read the report
file and summarise for the user.

## Reporting back

Summarise; do not paste transcripts. Per agent: name, state, what it did, and the key conclusion
or the question it is stuck on. Quote raw output only when the user asks for it or when something
failed and the exact text is the evidence.

When a wait returns `blocked`, inspect with `agent get` and `agent read`, then **bring the
question to the user**. Never approve an action, accept a plan, or answer a permission prompt on
their behalf.

### Checking on everything

When asked how things are going, run `herdr agent list` and group by `agent_status`:

- `blocked` first — include the actual question, read from the pane.
- `done` next — with the conclusion from each report file.
- `working` — name and workspace only; do not interrupt.
- `unknown` — state plainly that Herdr cannot classify it. It is not evidence of completion.

Sweeps are read-only. Do not send keys or prompts while surveying.

## Cleanup

Nothing is cleaned up automatically. Only close a tab, space, or worktree that was created in this
conversation, and ask the user first. `worktree remove` can discard uncommitted work — always
confirm. Never close the user's own tabs or spaces, and never run `herdr server stop`.
