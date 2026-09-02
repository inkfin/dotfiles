# Cursor User Rules — Agent Orchestration Protocol

> 部署方式：把分隔线以下的正文粘贴到 Cursor IDE → Settings → Rules → User Rules（一次性，全局生效，CLI 同样收到）。
> 本文件是 canonical 副本，改动从这里出。**Cursor 不读这个文件**——改完必须重新粘贴才生效。

---

## Specialist lanes

Delegate by lane; never do a lane's work inline when it is mechanical.

Cursor does not expose `~/.cursor/agents/*.md` as a `subagent_type` — dispatching one errors on the
enum. Each lane therefore runs on a built-in type, with the agent file supplying the contract:

| Lane | Contract | Dispatch |
|---|---|---|
| Recon | `~/.cursor/agents/explorer.md` | `explore` |
| Docs | `~/.cursor/agents/librarian.md` | `generalPurpose` · `composer-2.5-fast` |
| Execute | `~/.cursor/agents/fixer.md` | `generalPurpose` · `cursor-grok-4.6-high` |
| Judgment | `~/.cursor/agents/oracle.md` | `generalPurpose` · `claude-opus-5-thinking-high` |
| Second opinion | `~/.cursor/agents/oracle-sol.md` | `generalPurpose` · `gpt-5.6-sol-high` |
| Ops | `~/.cursor/agents/operator.md` | `shell` |
| UI | `~/.cursor/agents/designer.md` | `generalPurpose` · `composer-2.5-fast` |

**Dispatch recipe.** Read the lane's contract file, put its body at the top of the Task prompt, then
the task itself. The listed models are a standing user instruction — pass them as `model` rather
than defaulting to `inherit`; `explore` and `shell` take the task prompt only.

**Read-only lanes** (Recon, Docs, Judgment, Second opinion) must be told "read-only: no file edits,
no state-changing commands" in the prompt. The contract file's `readonly` frontmatter governs only
the native path, which is not the one in use.

When `subagent_type: explorer` stops erroring, Cursor has wired custom subagents natively: dispatch
the agent names directly and drop the contract-paste step.

## Dispatch discipline

1. **Recon before plan.** For any non-trivial task, dispatch Recon for the lay of the land before writing a plan. Do not plan from guesses.
2. **Background by default.** Dispatch specialists with `run_in_background: true` and continue coordinating; wait on results at the point their output is needed, not earlier.
3. **Reconcile before proceed.** When specialist reports come back, reconcile them against each other and the plan before acting. Conflicting reports get resolved (re-dispatch or judge), never averaged away.
4. **Dual-oracle rule.** For hard-to-reverse decisions (architecture, migrations, data models), dispatch Judgment and Second opinion together, then synthesize. If they disagree, surface the disagreement explicitly — do not silently pick one.
5. **Plan → execute split.** Write the concrete plan yourself; hand Execute bounded instructions. Never send an open-ended task to a cheap lane.
6. **Verification closes the loop.** After execution, verification runs (tests, lint, or Ops for CI) before declaring done.

## Status vocabulary

Report progress in these terms: *recon in flight*, *plan ready*, *dispatched (N lanes)*, *reconciled*, *verified*.
