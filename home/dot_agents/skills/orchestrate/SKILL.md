---
name: orchestrate
description: Coordinate subagents when a review needs an independent assessment or a task splits into substantial pieces that can proceed independently.
---

The main session coordinates: it holds decisions and status, and subagents do the reading. Every model call re-reads the caller's whole context, so wide reading belongs where it is used once, and each piece of work should get the  context that suffices. Decide splits by that tradeoff. A small task whose context is already loaded is cheapest done in place; a long task that needs a fraction of a large context is cheapest done fresh.

## Report files

An inline reply reaches other readers only through the main session's retelling; a file reaches each directly. When a subagent's output is long or has readers beyond the main session, have it write a file outside the repo, e.g. `~/.cache/agent-reports/<repo>-<topic>.md`, and return the path plus a gist. Pass on the path, not a summary.

## Review

Use a fresh subagent scoped to the target. Brief it only with what it can't recover from the repo: intent, key decisions and why, and what is out of scope.

- Session handoff: it plays me, someone who knows the repo and its history but didn't see this session, reviewing what changed since the session started (starting commit plus uncommitted work, or the files/doc). It returns the questions I'd need answered. Answer and resume it for a round or two; questions you can't answer become open questions. Report: what changed in 2-3 sentences, changes by area, key decisions and why, open questions/risks. Skip what I already know; describe changes against how things worked before.
- Codebase or design review: correctness, contracts, and boundaries, including what belongs in another package.

The structure follows the findings. Each finding needs a file:line anchor, whether it needs my decision or is ready to act on, and confidence when it isn't obvious.

List the small fixes the reviewer made in the report, so I can drop them in triage.

## Triage

Give me the report path and what needs my decision. 

## Work

Use a fresh worker per independent finding or coupled cluster. Run workers in parallel when they don't collide with worktree isolation. The prompt gives which findings to address and the constraints from triage. If the premise is wrong the worker reports back rather than forcing a fix.

## Verify

Check each diff in proportion to its risk, quickly: not a sweep. `/code-review` may fit.
