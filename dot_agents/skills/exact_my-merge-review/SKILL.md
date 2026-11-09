---
name: my-merge-review
description: Review changes against repository merge standards, checking implementation completeness, boundaries, stale code and docs, and effects on tests and CI. Use for merge-readiness reviews.
---

# Merge review

Review only; do not fix code or publish review comments unless requested.

Write the review report in Chinese. Preserve code identifiers, commands, and file paths as written.

Establish the review scope from the user's request: base/head, PR, or working-tree changes. DO NOT write plain sha256 ids or abbreviations, use human readable short names actually explaining the changes. State the baseline and include untracked files when relevant. If scope is ambiguous, inspect repository state and state a reasonable assumption; ask only when competing scopes materially change the review.

Read applicable AGENTS.md files, contribution rules, requirements, and relevant test/build/CI configuration. Follow affected callers and consumers beyond the diff, keeping the review focused on this change and its consequences rather than a repository-wide cleanup.

Check:
- Requirements are implemented end to end, including normal, failure, and boundary paths; flag missing requirements or unclear acceptance criteria.
- Responsibilities and interfaces are clear, errors and resource lifecycles are handled, and complexity is justified.
- The change leaves no dead code, obsolete configuration, or documentation inconsistent with behavior.
- Existing interfaces, test scripts, build commands, and pipeline contracts remain compatible; migrations and deployment steps are complete where needed.
- Repository conventions and required merge checks are satisfied.

Run necessary, feasible checks using repository conventions. Distinguish observed results from static reasoning and checks that could not run. Preserve the checkout and branch state; use an isolated temporary copy if baseline comparison requires another revision.

Report actionable, evidenced findings ordered by severity, with file/line, trigger, impact, and a concrete recommendation. Separate merge blockers from optional improvements. Do not invent issues to fill a checklist or treat missing evidence as a passing check. Identify pre-existing issues separately from regressions.

End with a clear, easy-to-understand table and bullet-point checklist:
- Compare behavior before and after the reviewed change, including relevant compatibility and workflow effects. “After” means the actual reviewed implementation; label proposed fixes separately.
- Include necessary metric comparisons when relevant, such as test results, runtime, memory, or artifact size. State measurement method and baseline; use comparable conditions. Mark unavailable values as unmeasured and explain the gap; do not invent numbers or run irrelevant benchmarks.
- List merge blockers, optional follow-ups, checks completed, and remaining verification gaps in concise bullets. State whether the evidence supports merging, requires changes, or is insufficient to decide. “No findings” does not mean “verified passing.”
