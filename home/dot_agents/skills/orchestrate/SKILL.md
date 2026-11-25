---
name: orchestrate
description: Coordinate subagents for an independent second opinion or for substantial tasks that can proceed in parallel.
---

Weigh the time saved or the value of independently checking a consequential assumption against the effort of briefing another agent, repeating earlier work, and reconciling the results.

## Report files

Keep findings inline when the main session is their only reader. When findings need to be handed off or revisited, write a report outside the repo, for example `~/.cache/agent-reports/<repo>-<topic>.md`. Pass the path to later readers.

## Review

Give a fresh reviewer the target, the intention, and any constraints it can't infer from the repo.

- **Session handoff to me.** The reviewer independently examines the changes and returns its questions to the coordinator. The coordinator investigates and brings answers back to the reviewer until each material question is resolved or has a specific blocker. Brief me as someone who knows the repo but missed the session. Explain what changed and why, identifying any missing evidence or decisions I need to make.
- Codebase or design review: correctness, contracts, and boundaries, including what belongs in another package.

The structure follows the findings. Anchor each finding to the evidence that supports it. Flag decisions I need to make and explain uncertainty where it matters.

List the small fixes the reviewer made in the report, so I can drop them in triage.

## Triage

Surface decisions that need my input and link the report if one exists.

## Work

When findings warrant separate workers, group coupled changes together. Run independent work in parallel, using separate worktrees where needed. The prompt gives which findings to address and the constraints from triage. If the premise is wrong the worker reports back rather than forcing a fix.

## Verify

Check each diff in proportion to its risk, quickly: not a sweep. `/code-review` may fit.
