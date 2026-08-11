# Work tracking: local markdown

Specs and tickets for this repo live as markdown under `plans/`. No remote trackers.

## Layout

- One feature per directory: `plans/<feature-slug>/`
- Spec: `plans/<feature-slug>/spec.md`
- Tickets: one file each at `plans/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first) — never a single combined tickets file
- Optional status near the top: `Status: ready` | `claimed` | `done`
- Comments append under a `## Comments` heading at the bottom of the file

## When a skill says "publish" / "write the spec or tickets"

Create or update files under `plans/<feature-slug>/` (mkdir if needed).

- Spec → `spec.md`
- Ticket → `issues/<NN>-<slug>.md`

## When a skill says "fetch the relevant ticket"

Read the path the user (or commit/message) pointed at. Prefer explicit paths under `plans/`.

## Frontier

A ticket can start when every file listed in its `Blocked by:` line is `Status: done` (or the line says none). Work blockers-first; for a linear chain that means ascending `NN`.
