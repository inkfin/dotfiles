# Work tracking: local markdown

Plans, specs, and tickets for this repo live as markdown under `plans/`. No remote trackers.

## Layout

Two shapes share the same tree:

**Implementation track** (`/to-spec`, `/to-tickets`):

- One feature per directory: `plans/<feature-slug>/`
- Spec: `plans/<feature-slug>/spec.md`
- Tickets: `plans/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order — never a single combined file
- Status near the top: `Status: ready` | `claimed` | `done`

**Wayfinder track** (`/wayfinder`) — decision map, not a build plan:

- Effort directory: `plans/<effort-slug>/`
- Map: `plans/<effort-slug>/map.md`
- Decision tickets: same `issues/<NN>-<slug>.md` shape, plus `Type:` (`grilling` | `research` | `prototype` | `task`)
- When the map clears, hand off to `/to-spec` (often a new or sibling feature dir) — do not treat decision tickets as implementable build slices

Comments append under a `## Comments` heading at the bottom of a file. Resolution answers for wayfinder tickets go under `## Answer`.

## When a skill says "publish" / "write the spec or tickets"

Create or update files under `plans/<slug>/` (mkdir if needed).

- Spec → `spec.md`
- Wayfinder map → `map.md`
- Ticket → `issues/<NN>-<slug>.md`

## When a skill says "fetch the relevant ticket"

Read the path the user (or commit/message) pointed at. Prefer explicit paths under `plans/`.

## Frontier

A ticket can start when every file listed in its `Blocked by:` line is `Status: done` (or the line says none). Work blockers-first; for a linear chain that means ascending `NN`.

### Wayfinding operations

- **Map**: `plans/<effort>/map.md` — Destination / Notes / Decisions so far / Not yet specified / Out of scope
- **Child ticket**: `plans/<effort>/issues/NN-<slug>.md` with `Type:` and `Status:`
- **Blocking**: `Blocked by:` line listing `NN — Title` (or none)
- **Frontier**: scan `issues/` for `Status: ready`, unblocked, not `claimed`
- **Claim**: set `Status: claimed` before any work
- **Resolve**: write `## Answer`, set `Status: done`, append gist+link to the map's Decisions so far
