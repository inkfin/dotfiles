---
name: diagnosing-bugs
description: Investigate software failures with an unclear cause, especially intermittent bugs, cross-component failures, and performance regressions. Use when the user requests this workflow or diagnosis needs a reproduction or targeted evidence. Handle straightforward errors directly.
---

# Diagnosing Bugs

## Find a signal for the reported symptom

Identify the expected and observed behavior, the affected environment, and any known good baseline. Reuse the quickest reliable check that reaches the reported behavior. A failing test, fixture replay, or comparison with a known good version can work. Reduce inputs or dependencies when that makes the check faster without losing the symptom.

- For intermittent failures, record the number of failures and attempts under comparable conditions. Use repeated runs or controlled timing to make the failure easier to observe.
- For performance regressions, measure the affected metric under the same workload and environment before comparing versions or profiling a suspect path.
- If direct reproduction is impractical, proceed with available logs, traces, metrics, or matched comparisons. State what they establish and what remains uncertain. Request a specific missing artifact or access only if it would materially advance the investigation.

If only a person can perform a UI step, give them the shortest useful sequence and say what to observe. Use [the interactive script template](scripts/hitl-loop.template.sh) if a guided terminal sequence helps. Redact credentials and sensitive values before sharing commands, logs, or artifacts.

## Distinguish plausible causes

Use the observed evidence and relevant code to identify plausible causes. For each cause worth testing, predict what would confirm or rule it out. Pick the probe that best distinguishes the remaining explanations. Change one relevant variable at a time where practical. If adding temporary logs, tag them for easy removal.

## Verify any fix

If a fix is in scope, add a regression test when a stable interface can exercise the actual failure and existing coverage would miss it. Confirm that the check can catch the failure, then rerun the original scenario or compare the same signal under matched conditions. For intermittent failures, report the observed failure rate and sample size. Remove temporary instrumentation and report the cause, the evidence supporting it, and any limits on verification.
