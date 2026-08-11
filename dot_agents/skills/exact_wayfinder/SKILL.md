---
name: wayfinder
description: Plan a huge chunk of work — more than one agent session can hold — as a shared map of decision tickets under plans/, and resolve them one at a time until the way to the destination is clear.
disable-model-invocation: true
---

A loose idea has arrived — too big for one agent session, and wrapped in fog: the way from here to the **destination** isn't visible yet. Wayfinding is about finding that way, not charging at the destination. This skill charts the way as a **shared map** under `plans/`, then works its **decision tickets** — questions whose resolution is a decision, not slices of a build to execute — one at a time until the route is clear.

The destination varies per effort, and naming it is the first act of charting — it shapes every ticket. It might be a spec to hand off and iterate on, a decision to lock before planning starts, or a change made in place like a data-structure migration. The map is domain-agnostic — engineering work, research, game systems, whatever fits the shape.

Work tracking is **local markdown** under `plans/`. If `docs/agents/work-tracking.md` is missing, run `/agent-repo-setup` once (or follow the layout below).

## Plan, don't do

Wayfinder is **planning** by default: each ticket resolves a decision, and the map is done when the way is clear — nothing left to decide before someone goes and does the thing. The pull to just do the work is usually the signal you've reached the edge of the map and it's time to hand off to `/to-spec` → `/to-tickets` → `/implement`. An effort can override this in its **Notes** — carrying execution into the map itself — but absent that, produce decisions, not deliverables.

## Refer by name

Every map and ticket has a **name** — its title. In everything the human reads — narration, the map's Decisions-so-far — refer to it by that name, never by a bare number or slug alone. A wall of `01, 02, 03` is illegible; names read at a glance. Paths ride _inside_ the name as links, never stand in for it.

## The Map

Canonical layout for one effort:

```
plans/<effort-slug>/map.md
plans/<effort-slug>/issues/<NN>-<slug>.md
```

The map is an **index**, not a store. A decision lives in exactly one place — its ticket file — so the map only gists it and links.

### The map body (`map.md`)

The whole map at low resolution, loaded once per session. Open tickets are **not** listed in the body — find them by scanning `issues/` for `Status:` that is not `done`.

```markdown
## Destination

<what reaching the end of this map looks like — one or two lines>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

- [<closed ticket title>](issues/NN-slug.md) — <one-line gist of the answer>

## Not yet specified

<!-- fog: in-scope but not sharp enough to ticket yet -->

## Out of scope

<!-- ruled beyond the destination; never graduates -->
```

### Tickets (`issues/<NN>-<slug>.md`)

Sized to one ~100K-token agent session. Number from `01` in rough dependency order; renumber only when needed for clarity.

```markdown
# <NN> — <Ticket title>

**Type:** grilling | research | prototype | task
**Status:** ready | claimed | done
**Blocked by:** None — can start immediately | `01 — Title`, `02 — Title`

## Question

<the decision or investigation this ticket resolves>
```

**Claim** a ticket by setting `Status: claimed` **before** any work, so concurrent sessions skip it. Unclaimed + unblocked = on the **frontier**.

**Blocking** is the `Blocked by:` line. A ticket is unblocked when every listed ticket is `Status: done`. The frontier is open (`ready`), unblocked, unclaimed — work blockers-first; for a linear chain that means ascending `NN`.

On resolution: append an `## Answer` section (or a short answer plus links to assets), set `Status: done`, and append a context pointer to the map's **Decisions so far**. Assets created while resolving live under `plans/<effort-slug>/` (or a linked path) — link them from the ticket, don't paste large blobs into the map.

## Ticket Types

Every ticket is either **HITL** (human in the loop) or **AFK** (agent alone). A HITL ticket only resolves through that live exchange; never answer your own grilling questions.

- **Research** (AFK): Surface a fact a decision waits on (docs, APIs, papers, local knowledge bases). Prefer the `/research` skill if installed; otherwise investigate and write a short findings file under `plans/<effort-slug>/`, linking it from the ticket.
- **Prototype** (HITL): Cheap concrete artifact to react to. Prefer `/prototype` if installed; otherwise build a minimal throwaway artifact and link it. Use when "how should it look/behave" is the question.
- **Grilling** (HITL): Conversation. The default. Always invoke `/grilling` and `/domain-modeling`.
- **Task** (HITL or AFK): Manual work that unblocks a *decision* — not a slice of the destination build. Provisioning access, moving data so its shape can be seen, etc. Agent alone where it can; otherwise a precise checklist for the human.

## Fog of war

Don't chart what you can't yet see. **Not yet specified** holds dim upcoming decisions — in scope, not sharp enough to ticket.

- **Ticket when** the question is already sharp (even if blocked).
- **Not yet specified when** you can't phrase it sharply yet. Don't pre-slice fog into fake tickets.

## Out of scope

Work beyond the destination goes in **Out of scope**, never in fog. If a live ticket turns out past the destination: set it `done` (or delete it), and leave one line in **Out of scope** with why — keep it out of **Decisions so far**.

## Invocation

Two modes. Either way, **never resolve more than one ticket per session** — except `research` tickets, which may run in parallel as subagents.

### Chart the map

User invokes with a loose idea.

1. **Name the destination.** Run `/grilling` and `/domain-modeling` to pin it down.
2. **Map the frontier.** Grill again, **breadth-first**: surface open decisions and first takeable steps. **If no fog** — the whole journey fits one session — stop and ask how to proceed (usually `/grill-with-docs` or straight `/to-spec`).
3. **Create** `plans/<effort-slug>/map.md`: Destination and Notes filled, Decisions-so-far empty, fog in **Not yet specified**.
4. **Create** ticket files you can specify now under `issues/`, then wire `Blocked by:` in a second pass. Unspecifiable work stays in fog.
5. **Fire research** for each `research` ticket (subagents / parallel), linking findings from the ticket.
6. Stop — charting resolves nothing by hand.

### Work through the map

User invokes with a map path (e.g. `plans/<effort>/map.md`) or effort slug. A ticket is optional — without one, pick the next frontier ticket.

1. Load **map.md** — low-res, not every ticket body.
2. Choose the ticket (user-named, or first frontier in `NN` order). **Claim** it (`Status: claimed`) before work.
3. Resolve — zoom related/closed tickets on demand; follow **Notes**; default to `/grilling` + `/domain-modeling`.
4. Record: write `## Answer`, set `Status: done`, append a gist+link to **Decisions so far**.
5. Add newly-surfaced tickets; graduate fog that is now sharp; rule out-of-scope what sits past the destination; update/delete invalidated tickets.

When the map is clear (no open tickets, fog empty or only out-of-scope remains), hand off — do **not** implement here. Collapse into `/to-spec` (then `/to-tickets` / `/implement`) unless the effort turned out genuinely small.
