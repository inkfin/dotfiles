---
name: agents-supervisor
description: Supervise and dispatch other coding agents through Herdr — start a new agent for a task, check on running agents, surface blocked ones, and collect their results. Works both from inside a Herdr pane and from outside it (OpenClaw, cron, a plain shell), with stricter targeting rules when outside. Also covers first-time setup, installing Herdr and its per-agent integration hooks. Use when the user asks to spin up, delegate to, monitor, or coordinate another agent, or mentions Herdr, agent spaces, tabs, or worktrees. Do not use merely because a task could be parallelised.
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

One known conflict: `herdr --skill` tells you to stop unless `HERDR_ENV=1`. That is a strategy
statement, so this file wins — see the two host modes below. Its command syntax still applies.

## Two host modes

Every `herdr` subcommand goes over the socket API, so dispatch works from outside a Herdr pane
too — from OpenClaw, a cron job, or a plain shell. What changes is not the capability but the
targeting discipline.

```bash
test "${HERDR_ENV:-}" = 1
```

**Inside Herdr (`HERDR_ENV=1`).** The caller's own pane context is injected as
`HERDR_WORKSPACE_ID`, `HERDR_TAB_ID`, `HERDR_PANE_ID`. `--current` is available and is the correct
way to mean "my own pane".

**Outside Herdr (the check fails).** There is no calling pane, and — this is the trap — no session
either. Inside a pane, `HERDR_SESSION` and `HERDR_SOCKET_PATH` are injected; outside, commands fall
back to the **default** session, which may not be the one that is running. Resolve it explicitly
before anything else:

```bash
herdr session list
```

Pick the entry whose status is `running` and pass `--session <name>` on **every** command (or
export `HERDR_SESSION=<name>` once for the whole run). Without it you will get:

```
server_not_running: no herdr server is running at ~/.config/herdr/herdr.sock; run `herdr` to start or attach it
```

**Do not follow that suggestion.** Running bare `herdr` launches or attaches a TUI and can create a
second, empty session — after which every survey truthfully reports no agents while the user's real
work sits in the other one. If no session is `running`, say so and stop. If more than one is
running, ask which; do not guess.

`--session <name>` is documented as "use **or create**", so a typo in the name silently creates an
empty session instead of failing. Copy the name from `session list` output; never type it from
memory. Exporting `HERDR_SESSION` once is the safer habit — it removes the chance of getting the
flag right nine times and wrong on the tenth.

Then follow these rules, all of which exist because the focused pane belongs to whoever is sitting
at the terminal:

- **Never `--current`.** There is no caller pane to resolve it against.
- **Never omit a target.** Every pane and agent command takes an explicit pane ID or agent name,
  parsed out of a previous JSON response. Omitting a target may act on the user's focused pane.
- **Never take focus.** No `tab focus`, `agent focus`, or `agent attach`; always pass `--no-focus`
  on creation. An external caller yanking the view is worse than useless — the user may not even
  be at the machine.
- **Never `pane split`.** Already forbidden by the topology rules below, and there is no caller
  pane to split.
- **Do not read `HERDR_*` variables.** They are unset; discover topology with `workspace list`,
  `tab list`, and `agent list`, matching on each entry's `worktree.checkout_path`.

### Interacting with an agent in a running session

Everything is reachable from outside — the surface is the same, only targeting and consent change.
Resolve the session first, then work from `agent list` output.

```bash
export HERDR_SESSION=dev          # copied from `session list`
herdr agent list
```

Each entry carries `name`, `agent_status`, `pane_id`, `cwd`, and `focused`. Target agents by
**name**; fall back to `pane_id` only for an agent that has none. Names are not stable identity --
a name follows the current pane occupant and clears when that agent exits, so re-read `agent list`
rather than caching a name across a long run.

**Reading is always safe.** These are pure observation and, unlike focusing, do not mark a tab as
seen — so they will not flip a `done` agent's bookkeeping:

```bash
herdr agent get <name>
herdr agent read <name> --source recent-unwrapped --lines 120
```

Prefer `recent-unwrapped` for transcripts. If a long response will not come back no matter how
high `--lines` goes, the agent is drawing on the alternate screen and those rows are unrecoverable
from scrollback — this is exactly why dispatched agents are told to write a report file.

**Writing needs consent.** `agent prompt` and `agent send-keys` inject keystrokes into a live
terminal that the user may be watching:

```bash
herdr agent prompt <name> "<self-contained prompt>" --wait --timeout 120000
herdr agent wait <name> --until blocked --timeout 120000
```

Two failure modes worth knowing before you send anything. A prompt from a non-working state must
produce a lifecycle change within five seconds or Herdr returns `agent_prompt_stalled` instead of
hanging. And `--wait` tracks lifecycle state, not one turn: prompting an agent that is already
`working` can return the moment its **current** turn ends, which is not your answer. Check
`agent_status` first and prefer prompting agents that are `idle` or `done`.

**Identify the user's own pane before writing to anything.** The entry with `focused: true` is
where the user is sitting, and an unnamed focused agent whose `cwd` is the supervisor's own repo is
very likely the session driving this conversation. Prompting it means talking to yourself through
the terminal and stealing the user's input line. Never send keys to a focused agent from outside;
if that is genuinely the target, say so and let the user act.

`send-keys` is for interactive UI controls (`esc`, `ctrl+c`) — that is, interrupting or dismissing.
From outside it is the sharpest tool available and cancels work the user may still want. Treat it
as a last resort, name the agent explicitly, and ask first.

One judgement rule on top of the mechanics: **do not start write-mode agents from a channel where
the user cannot review a diff.** An IM message or a cron job is a fine place to survey state,
collect reports, or run a read-only investigation. It is not a place to approve a code change or a
platform action whose cost is measured in hours. When such a task arrives through a narrow
channel, prepare it and hand the decision back to a channel that can show the work.

Setup — installing Herdr, installing integrations, editing config — never requires being inside a
session at all.

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

Everything after `--` goes to the agent CLI — permission flags and the model. The table below is
for `cursor`; other kinds have their own flags, so check that CLI before assuming these carry over.

| Role | Flags | Model |
|---|---|---|
| Writing code | `--yolo --trust --approve-mcps` | `auto-smart[optimize_for=balanced]` |
| Read-only judgement (review, research, investigation) | `--mode plan --yolo --trust` | `auto-smart[optimize_for=balanced]` |
| Read-only mechanical work (surveys, digests, status collection) | `--mode plan --yolo --trust` | `auto-smart[optimize_for=cost]` |
| Architecture, cross-module refactors, hard bugs | `--yolo --trust --approve-mcps` | name a model — `gpt-5.6-sol-high` |

`--trust` and `--approve-mcps` matter because a fresh worktree directory otherwise stops at a
workspace-trust or MCP-approval prompt, which registers as `blocked`.

`--yolo` is needed for the read-only role too. `--trust` only settles workspace trust; the shell
command allowlist is separate, so without `--yolo` a read-only agent stops for approval on its
first `git log` and registers as `blocked`. Read-only is then enforced by `--mode plan`, which
locks the file-editing tools, plus the prompt itself — not by the shell layer. So state the
read-only constraint explicitly in the prompt, and do not use this role for a task whose obvious
next step is a mutating command.

### Choosing a model

This is about the agents you dispatch. Whatever model the supervising session itself runs on is the
user's own configuration — do not reason about it or try to change it.

**Never omit `--model`.** Without it the agent inherits whatever the user last selected in the CLI,
which for anyone who works on hard problems interactively is a frontier model at high reasoning
effort. Dispatched agents are numerous and mostly do legwork; paying interactive-session rates for
all of them is the single largest avoidable cost in this workflow.

`auto-smart` is Cursor's Auto router. `optimize_for` takes `cost` or `balanced` — `frontier` is not
a valid value. Quote the whole argument (`--model 'auto-smart[optimize_for=cost]'`) or the shell
expands the brackets as a glob. Check any other id against `cursor-agent --list-models`; an
unrecognised one aborts the start.

Pick the tier by asking what a wrong answer costs. Work you will read and verify yourself anyway — a
commit sweep, a log summary, a state survey — goes to the cost tier, because you are the check on
it. Work whose conclusion you will act on without re-deriving it goes to `balanced` or higher.

Escalate rather than argue: when a cost-tier report comes back shallow or wrong, re-dispatch the
same task one tier up instead of spending several prompts correcting it. Escalate once, not
repeatedly.

When naming a model instead of letting Auto route, follow the owner's standing preference: the GPT
and Grok families first — `gpt-5.6-sol-*` for hard reasoning, `gpt-5.6-terra-*` or
`cursor-grok-4.5-*` for mid-weight work — and `claude-opus-5-thinking-*` when a task genuinely calls
for it rather than as the default top pick. Each family has effort suffixes (`-low`, `-medium`,
`-high`, `-xhigh`) plus a `-fast` variant; `--list-models` shows which combinations exist. This is a
preference, not a benchmark claim, so do not optimise it away.

When the user names a model, pass it through verbatim and do not substitute.

Start a new agent rather than reusing an idle one — a fresh session keeps context clean. Reuse
only when continuing a task with an agent started earlier in this same conversation, or when the
user points at a specific one.

Remote investigation on a box **without** a Herdr session (logs, `journalctl`, fetch a file) belongs
to the `remote` skill — use `remote run` / `remote get` / `remote put`, and keep reports on this
machine. Do not use `herdr --remote` for automation; it is TUI attach only. Reach for Herdr on the
remote host only when the work needs a full coding-agent session on that checkout.

## Assigning work

A dispatched agent knows nothing about the current conversation. Every prompt must stand alone
and state all four:

1. **Goal** — what to accomplish, concretely.
2. **Location** — repository path and branch it is working on. For a remote box without Herdr,
   name the SSH Host alias and remote paths, and point the agent at the `remote` skill.
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

When asked how things are going, this skill surveys **only agents visible in running Herdr sessions**. Resolve each running session explicitly, run `herdr agent list`, then group by `agent_status`:

- `blocked` first — include the actual question, read from the pane.
- `done` and `idle` next — retrieve their conclusion from the declared report file or pane output when available; both can mean finished.
- `working` — name and workspace only; do not interrupt.
- `unknown` — state plainly that Herdr cannot classify it. It is not evidence of completion.

Sweeps are read-only. Do not send keys or prompts while surveying. A stopped session or agent absent from `agent list` is **outside Herdr observation scope**, not evidence of no result. In WorkNotes, hand off that recovery to `chief-of-staff/workflows/sweep.md`, which scans cached reports, archived reports, and repository progress.

## Cleanup

Nothing is cleaned up automatically. Only close a tab, space, or worktree that was created in this
conversation, and ask the user first. `worktree remove` can discard uncommitted work — always
confirm. Never close the user's own tabs or spaces, and never run `herdr server stop`.
