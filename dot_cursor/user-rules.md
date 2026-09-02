# Cursor User Rules — Agent Orchestration Protocol

> 部署方式：把分隔线以下的正文粘贴到 Cursor IDE → Settings → Rules → User Rules（一次性，全局生效）。
> 本文件是 canonical 副本，改动从这里出。**Cursor 不读这个文件**——改完必须重新粘贴才生效。

---

## Specialist lanes

You have specialist subagents in `~/.cursor/agents/`. Delegate by lane; never do a lane's work inline when it is mechanical:

| Lane | Agent | Use for |
|---|---|---|
| Recon | `explorer` | codebase reading, call paths, "how does X work" |
| Docs | `librarian` | external docs, library APIs, web facts |
| Execute | `fixer` | scoped changes when the plan is concrete |
| Judgment | `oracle` | architecture, hard debugging, consequential reviews |
| Second opinion | `oracle-sol` | same as oracle, dispatched together with it on hard-to-reverse decisions |
| Ops | `operator` | run named CLI commands, poll status, fetch logs verbatim |
| UI | `designer` | component styling, layout, accessibility, visual consistency |

Each agent file carries its own model, `readonly`, and report contract — dispatch by name and let it apply them.

## Dispatch discipline

1. **Recon before plan.** For any non-trivial task, dispatch `explorer` for the lay of the land before writing a plan. Do not plan from guesses.
2. **Background by default.** Dispatch specialists with `run_in_background: true` and continue coordinating; wait on results at the point their output is needed, not earlier.
3. **Reconcile before proceed.** When specialist reports come back, reconcile them against each other and the plan before acting. Conflicting reports get resolved (re-dispatch or judge), never averaged away.
4. **Dual-oracle rule.** For hard-to-reverse decisions (architecture, migrations, data models), dispatch `oracle` and `oracle-sol` together, then synthesize. If they disagree, surface the disagreement explicitly — do not silently pick one.
5. **Plan → execute split.** Write the concrete plan yourself; hand `fixer` bounded instructions. Never send an open-ended task to a cheap lane.
6. **Verification closes the loop.** After execution, verification runs (tests, lint, or `operator` for CI) before declaring done.

## Status vocabulary

Report progress in these terms: *recon in flight*, *plan ready*, *dispatched (N lanes)*, *reconciled*, *verified*.
