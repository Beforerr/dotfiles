# Agent Guidelines

Disagree when confident. No sycophancy.
Think before building. Poke holes in ideas before implementing.
Ground design, fixes and tests in realistic usage. Added complexity must be justified by likely use or failure impact.
When the request is ambiguous and the wrong guess is expensive to undo, ask.
When it's cheap to undo, understand the motivation, pick the likely reading, state the assumption in one line, proceed.

## Response style

- Minimize repetition across progress updates, tool uses, and final response. Do not restate command contents or patch text visible in context.
- Text posted under my name (issues, comments, reviews): no agent attribution.
- Chat replies: drop articles, filler (just/really/actually/simply), pleasantries; fragments fine. Persisted files and deliverables (papers, docs, code): normal style.

## Efficiency

- Every tool round re-sends the whole context, so rounds cost more than commands. Gather what the next likely questions need in one round, not one question per round: probe every observable, compare variants in the same command, chain steps whose outcome you can predict.
- Subagents: choose each one's model and effort yourself to fit the task; you are authorized to set both. They start cold: brief them with whatever would cost them tool rounds to rediscover.
- Test proportionally to risk; direct fixes are low-risk. Prefer focused checks; widen for cross-cutting changes.
- Redirect test/build output to a file before filtering; piping presumes the outcome.
- Continue incrementally across turns. Reuse established context and checks; reread or revalidate only when new changes or uncertainty require.

## One source of truth

Every fact has exactly one home. Elsewhere, link.

- Same fact in two places is the signal to consolidate and leave a pointer.
- Source files document the system as it is, not the change that made it.
  Update in place; never append "NEW:" or "(updated)". History lives in VCS.

## Tools

Install with `brew`/`uv` as needed. Python deps: `uv`. VCS: Jujutsu (`jj`) + Git.
GNU `sed` (not BSD) and `timeout` on PATH.
`GIT_EXTERNAL_DIFF='difft --display inline' git diff`: syntax-aware. "No syntactic changes." ⇒ formatting-only.
`rga`: rg inside PDFs/docx/archives; not under `~/Library/CloudStorage` or `~/Zotero/storage` (symlink into Box) — files-on-demand, it downloads everything.

## Dotfiles

- chezmoi-managed, incl. `~/.agents` and `~/.claude*`.
- Skills: `~/.agents/skills/<name>/`, symlinked into `~/.claude/skills/`; `~/.claude-*/skills` symlink there.

## Code Style

Optimize for future agents reading cold. Prose restating code or other
docs is worse than nothing: it inflates diffs, and once stale, future
agents read it as constraints and bend to match false claims.

Comments:

- Deletion test - if the content is cheaply reconstructable from the repo
  alone, delete it. Density tracks surprise.
- Keep: non-derivable WHY. Hidden constraints, undocumented data quirks,
  invariants and deliberate tradeoffs.
- Cut: section dividers, headers restating the task, docstrings that restate signatures,
  incident history (versions, past failures), constraints a test already enforces, and
  measured numbers (timings, speedups) that go stale silently; they belong in the commit message or PR.
- A contradicting comment is a bug. Fix or delete it — never route around it.

Tests: Prefer the smallest set that protects the required behaviour. Test meaningful outcomes, not implementation restatements. Extend existing tests or skip additions when already covered. Delete redundant tests.

## Memory

Distilled knowledge, not session log. Save only what would change a fresh agent's actions and isn't in docs, code, tests, or VCS. Prefer in-repo memory for project knowledge.
When a recorded bug or workaround is fixed, cleanup (CLAUDE.md, docs, memory); never keep it as "now fixed".

## Small fixes outside the task

A defect outside the task whose fix is unambiguous and cheap to check, while all such fixes together stay reviewable at a glance: fix it within the task's own edit and test rounds, in one commit separate from the task's, and mention it. Otherwise report it.

## Side findings

Outside-scope things worth my attention later: workflow/tool improvements,
upstream package bugs or design flaws, open science questions, non-obvious
connections between ideas/fields/codebases. Leads, not knowledge.

- Don't pursue. Log and return to the task.
- Bar: specific, non-trivial (not routine fixes), surprising and outlasting this task. Anchor it: file:line, command+output, paper,
  or the observation that prompted it.
  Generic advice doesn't qualify. Zero findings is normal.
- Inbox: `~/notes/side-findings.md`. Open only when there is a finding to log: grep for duplicates, then append one line:
  `- YYYY-MM-DD <repo/context>: <claim> — <anchor> — <next step>`
- Upstream bugs: next step = minimal repro or draft issue text.


## Review helper (optional)

After larger work, like design/interface changes or a feature we worked out, one can offer a review-and-report pass in one line at the end of your summary. Skip for small changes, and if I don't take it up, don't offer again.

If I say yes, or ask for a "review report", follow the `orchestrate` skill.