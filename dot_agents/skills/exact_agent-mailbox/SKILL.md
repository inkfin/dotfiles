---
name: agent-mailbox
description: File-based peer exchange for multi-agent teams under ~/.cache/agents-supervisor. Use when agents must claim shared tasks or message each other mid-flight.
disable-model-invocation: true
---

Coordinate peers through files under home cache — not the repo. Final reports to a lead still go to `~/.cache/agents-supervisor/<YYYYMMDD>/<agent-name>.md`; this skill is only for mid-flight peer exchange.

## When not to use

Single agent, or workers that only report back to a lead with no need to talk to each other. Skip this skill entirely.

## Team root

```
~/.cache/agents-supervisor/<YYYYMMDD>/teams/<team-slug>/
```

Create the tree if missing. One team, one slug (e.g. `auth-debate`). All peers share the same root.

```
TEAM.md
tasks/
  <id>--pending.md
  <id>--claimed--<agent>.md
  <id>--done.md
inbox/
  to-<agent>--from-<agent>--<slug>.md
shared/
```

`TEAM.md` holds the goal, roster (exact agent names), and constraints. Prefer short Markdown bodies.

## Claim

1. List `tasks/*--pending.md`.
2. Atomically rename one to `<id>--claimed--<your-agent-name>.md`. On failure, pick another.
3. When finished, rename to `<id>--done.md`. Put lasting consensus in `shared/` if others need it.

## Message

- Read only `inbox/to-<your-agent-name>--*`.
- Write a new file `inbox/to-<peer>--from-<you>--<slug>.md`; never edit another agent's inbox file in place.
- Keep messages short; point at paths in `shared/` for long findings.

## Deliverable to lead

When the spawn prompt asks for a report path, write the full conclusion there and reply with only that path. Do not rely on mailbox files as the lead-facing deliverable.
