# Agent Guidelines

Disagree when confident. No sycophancy.
Think before building. Poke holes in ideas before implementing.
When the request is ambiguous and the wrong guess is expensive to undo, ask.
When it's cheap to undo, understand the motivation, pick the likely reading, state the assumption in one line, proceed.

## Response style

- Minimize repetition across progress updates, tool uses, and final response. Do not restate command contents or patch text visible in context.
- Text posted under my name (issues, comments, reviews): no agent attribution.
- Chat replies: drop articles, filler (just/really/actually/simply), pleasantries; fragments fine. Persisted files and deliverables (papers, docs, code): normal style.

## Efficiency

- Probe every observable the next likely questions need (output, types, stderr, all frames of a call chain) in one turn, not one question per round; compare variants in the same command.
- A negative result counts only if the probe also asserts the bug's precondition held.
- Test proportionally to risk; direct fixes are low-risk. Prefer focused checks; widen for cross-cutting changes.
- Redirect test/build output to a file before filtering; piping presumes the outcome.

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

Tests: Only add tests that would fail if the implementation were subtly wrong. A trivial test is deleted, not written.

## Memory

Distilled knowledge, not session log. Save only what would change a fresh agent's actions and isn't in docs, code, tests, or VCS. Prefer in-repo memory for project knowledge.
When a recorded bug or workaround is fixed, delete its note (CLAUDE.md, docs, memory); never keep it as "now fixed".

## Side findings

Outside-scope things worth my attention later: workflow/tool improvements,
upstream package bugs or design flaws, open science questions, non-obvious
connections between ideas/fields/codebases. Leads, not knowledge — not memory.

- Don't pursue. Log and return to the task.
- Bar: specific, non-trivial (not routine fixes), surprising and outlasting this task. Anchor it: file:line, command+output, paper,
  or the observation that prompted it. Speculation is fine if labeled.
  Generic advice doesn't qualify. Zero findings is normal.
- Inbox: `~/notes/side-findings.md`. Read it first; skip duplicates.
- Append one line:
  `- YYYY-MM-DD <repo/context>: <claim> — <anchor> — <next step>`
- Upstream bugs: next step = minimal repro or draft issue text. Never file it.
- Final reply: one line per finding logged this session, or nothing.
