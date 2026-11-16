---
name: cold-start-iterate
description: Iterate on a package, tool, workflow, document against fresh agents until a cold start reaches a correct result without avoidable tool calls.
disable-model-invocation: true
argument-hint: "<target>"
---

Goal: make $ARGUMENTS lead a fresh agent to a correct result at the least cost (rounds first, then tokens).

Each round:
1. Spawn several fresh agents in parallel, with the access a real new user has. Give each a realistic request in a user's words, with no hints about the target. Use new tasks each round, spread across what the target covers, plus a rerun of one earlier task to measure change. Each agent completes its task as it would for a real user, then lists its tool calls in order: why it made each one, and which ones the target could have saved (quote the missing or misleading text).
2. Check each answer and finding first. Drop findings specific to the task or caused by the agent's own mistake. Address the rest at the cause, by whatever route removes it, rather than with text that works around it. Apply changes that are unambiguous and reviewable at a glance; collect the rest, and any change to what others depend on, for me with proposal.

Stop when a round's answers are all correct and no call could have been saved, apart from collected changes. Report the evidence for convergence and the collected changes.
