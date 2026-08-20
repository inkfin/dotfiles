---
name: agents-supervisor
description: >-
  Herdr dispatch: start, prompt, and sweep other coding agents; collect report
  files; surface blocked. Use when the user asks to spin up, delegate, monitor,
  or coordinate an agent, or names Herdr, spaces, tabs, or worktrees. Covers
  host modes, session pin, and first-time setup. Not for “this could be parallel”
  alone.
---

# Agents Supervisor

**Policy** for dispatching coding agents through [Herdr](https://herdr.dev) (0.8.2):
topology, naming, permissions, reports. CLI syntax lives in the binary — before any
control command:

```bash
herdr --skill
herdr --help
herdr <group>    # agent | pane | terminal | workspace | tab | worktree | session | …
```

Strategy from this file; syntax from the binary. Exception: `herdr --skill` says stop
unless `HERDR_ENV=1` — this file wins; outside dispatch is allowed under **Session pin**.

The bundled skill (`herdr --skill`) is the canonical reference for this binary; when in
doubt about any command or lifecycle behavior, diff against it or the manpage.

## Host mode

```bash
test "${HERDR_ENV:-}" = 1
```

| Mode | Meaning |
|---|---|
| **Inside** (`HERDR_ENV=1`) | Pane context injected; `--current` means this pane. |
| **Outside** | No pane, no injected session. **Pin** before any other Herdr call. |

### Session pin (outside)

Done when `HERDR_SESSION` is set to one name copied from `herdr session list`, and every
later create/prompt/read/wait in this conversation uses that pin until the user switches.

```bash
herdr session list
```

1. User named a session → pin it (must appear in the list; prefer `running`).
2. Else exactly one `running` → pin it.
3. Else several `running` → ask which.
4. Else none → stop and say so. Leave sessions stopped; a wrong `--session` **creates** an empty one.

```bash
export HERDR_SESSION=<pinned-from-list>
```

**Switch** only when the user names another session: re-pin, export, and say the new pin in
reports. One session holds a whole team (tabs/spaces); extra sessions are separate contexts.

Bare `herdr` attaches a TUI and can spawn a second empty session — resolve with `session list`
and the pin instead.

### Outside targeting

Done when every mutating call names an explicit agent or pane_id from a prior JSON response,
creations use `--no-focus`, and layout follows **Topology**.

- Target by agent **name**; use `pane_id` only when the agent has no name. Re-read `agent list`
  before reuse — names follow the pane occupant and clear on exit.
- Discover layout with `workspace list` / `tab list` / `agent list` (match
  `worktree.checkout_path`). Ambient `HERDR_*` is unset outside; do not invent IDs.
- Pass `--no-focus` on create. Focus a tab/agent only when the user asks to be taken there.
- Prefer new **tabs** over pane splits (see Topology).

## Topology

| Need | Action |
|---|---|
| Another agent, same checkout | New **tab** in that space |
| Isolated branch | New **worktree** → its own space; agent in a tab there |
| Repo with no space yet | Match `workspace list` on `checkout_path`; else `workspace create --cwd <repo>` |

Worktrees are for **new branches** only — never for a checkout that already exists.

Worktree create: `--branch` / `--label` = task slug (`fix-auth`); `--base` defaults to the
repo's current HEAD (do not silently retarget `main`). Branch already exists → open that
worktree.

Background finish lands as `done` (unseen) or `idle` (seen) — treat both as finished.
Shared-checkout overwrite risk: mention once; user’s call.

## Start

Default kind: `cursor`. Other kinds: confirm `command -v <cli>` first (`herdr agent
start --help` lists the installed kinds).

- Agent name = job slug `[a-z][a-z0-9_-]{0,31}`, unique among live agents (`-2` on collision).
  Tab name = same slug (job, not kind).
- `agent start` needs an **existing** shell pane at its interactive prompt (create via
  `pane split --current --direction right --cwd "$PWD" --no-focus` — keep caller focus); it
  never splits or moves layout. It returns only when the agent is detected and ready; a
  blocked startup returns `agent_not_ready` early but keeps the name for `read`/`send-keys`.
  `--timeout` defaults to 30s.
- Always pass `--model` after `--` (with permission flags). Omitted model inherits the user’s
  last interactive choice — the largest avoidable cost on fleets.
- Fresh agent per task; reuse only to continue one started in this conversation, or when the
  user points at it.
- Box without Herdr (logs, files) → `remote` skill. `herdr --remote` is TUI attach only
  (works from Windows clients too).

Cursor flag presets (other kinds: check that CLI):

| Role | Flags | Model |
|---|---|---|
| Write code | `--yolo --trust --approve-mcps` | `auto-smart[optimize_for=balanced]` |
| Read-only judgement | `--mode plan --yolo --trust` | `auto-smart[optimize_for=balanced]` |
| Read-only mechanical | `--mode plan --yolo --trust` | `auto-smart[optimize_for=cost]` |
| Hard architecture / bugs | `--yolo --trust --approve-mcps` | named — e.g. `gpt-5.6-sol-high` |

`--yolo` covers shell allowlist (needed even in plan mode); `--mode plan` locks edits — also
state read-only in the prompt. Quote models with brackets:
`--model 'auto-smart[optimize_for=cost]'`. Unknown ids → `cursor-agent --list-models`.

**Tier:** cost when you will re-check the answer; `balanced`+ when you will act on it.
Shallow cost result → escalate **once** one tier, then stop thrashing. Owner preference when
naming models: GPT/Grok first (`gpt-5.6-sol-*`, `gpt-5.6-terra-*`, `cursor-grok-4.5-*`);
`claude-opus-5-thinking-*` when the task needs it. User-named model → pass through verbatim.

Narrow channel (IM/cron) without diff review → survey / read-only / prepare only; hand write
work back to a reviewable channel.

## Assign

Every spawn prompt is self-contained — four fields, then submit:

1. **Goal** — concrete outcome.
2. **Location** — repo path and branch (or SSH Host + paths + `remote` skill).
3. **Constraints** — e.g. read-only, no commit/push, scope.
4. **Deliverable** — full Markdown at
   `~/.cache/agents-supervisor/<YYYYMMDD>/<agent-name>.md` (mkdir if needed); reply with
   **only that path**.

Reports live outside the repo because alternate-screen TUIs drop long answers from
`agent read`.

```bash
herdr agent prompt <name> "<self-contained prompt>" --wait --timeout <ms>
```

`agent prompt` rejects an agent already waiting at an approval/question dialog with
`agent_blocked` before sending anything — inspect the UI and bring it to the user, do not
answer for them. From a non-working state, `--wait` first requires an observed lifecycle
change within 5s or it returns `agent_prompt_stalled` (a shorter `--timeout` returns
`timeout`); it then settles on `idle`/`done`/`blocked` unless you pass `--until` for a
specific state. It tracks lifecycle state, not turns — if the agent was already `working`,
your ask returning may satisfy it. Use `--until blocked` to wait for an already-running
agent to request input.

On return: read the report file; summarise for the user (see **Report**).

### Peer mailbox

Default spawn prompts omit mailbox. Inject only for user-asked team/peer work, or ≥2 agents that
must share findings mid-flight:

1. Create `~/.cache/agents-supervisor/<YYYYMMDD>/teams/<team-slug>/` + `TEAM.md` (goal, roster,
   constraints).
2. Follow `~/.agents/skills/agent-mailbox/SKILL.md`.
3. Each peer prompt also gets: team root, their roster name, and “read agent-mailbox”.
   Lead-facing deliverable stays the per-agent report file.

## Monitor

```bash
herdr agent list
herdr agent get <name>
herdr agent read <name> --source recent-unwrapped --lines 120
herdr agent explain <name> --json   # why Herdr classified a pane a given way
```

**Read** is always safe (does not mark tabs seen). Prefer `recent-unwrapped`. Read sources:
`visible` (rendered viewport), `recent`, `recent-unwrapped` (logs/transcripts), `detection`
(bottom-buffer snapshot used for agent detection). Add `--format ansi` when color/styling is
evidence. `--lines` only reaches Herdr host scrollback, not a TUI's alternate screen — empty
long output usually means alternate screen → use the report file.

**Write** (`prompt`, `send-keys`) needs care: the user may be watching that terminal.

- Prompt agents in `idle` or `done`. Already `working` + `--wait` can return when the *current*
  turn ends, not when your ask finishes. Non-working prompt with no lifecycle change in ~5s →
  `agent_prompt_stalled`.
- Skip the `focused: true` pane from outside (often the user’s own line). If that is the real
  target, say so and let the user act. In `idle` vs `done`: `done` is the same busy-idle state
  after unseen background work; `blocked` means an approval/question UI; `unknown` is a
  present-but-unclassifiable agent — none prove completion on their own.
- `send-keys` (`esc`, `ctrl+c`) only as last resort, named agent, ask first; Herdr validates
  keys before writing.

`blocked` → `agent get` / `agent read`, then **bring the question to the user**. Do not approve,
accept a plan, or answer a permission prompt for them.

## Sweep

**Dispatch** (start / prompt / wait / one-team follow-up) → **pinned** session only.

**Full sweep** (“how is everyone”) → every `running` session: `agent list` each, group by
**session** then `agent_status`, then restore `HERDR_SESSION` to the pin.

Per group, in order: `blocked` (quote the question) → `done`/`idle` (report or pane) →
`working` (name + workspace only) → `unknown` (unclear, not done). Sweeps are read-only.

Stopped session or missing from `agent list` → outside Herdr scope, not “no result”. WorkNotes
recovery: `chief-of-staff/workflows/sweep.md`.

## Report

Per agent: name, pin/session, state, what changed, conclusion or blocker. Summarise; paste
transcripts only on request or as failure evidence.

## Cleanup

Close only tabs/spaces/worktrees created in this conversation, and ask first.
`worktree remove` can drop uncommitted work. Leave the user’s own layout and the Herdr server
running.

## Setup

Herdr missing, unhealthy, integrations stale, or config change → read [`SETUP.md`](SETUP.md).
