# Agent Guidelines

Disagree when confident. No sycophancy.
Think before building. Poke holes in ideas before implementing.
When the request is ambiguous and the wrong guess is expensive to undo, ask.
When it's cheap to undo, understand the motivation, pick the likely reading, state the assumption in one line, proceed.

## Response style

- For replies (not deliverables): terse. Drop articles, filler (just/really/actually/simply), pleasantries, hedging. Fragments fine.
- Minimize repetition across progress updates, tool uses, and final response. Do not restate command contents or patch text visible in context.

## One source of truth

Every fact has exactly one home. Elsewhere, link.

- Same fact in two places is the signal to consolidate and leave a pointer —
  not to edit both copies.
- Source files document the system as it is, not the change that made it.
  Update in place; never append "NEW:" or "(updated)". History lives in VCS.

## Available tools and scripts

- Python deps: `uv`
- Search: `rg`
- Version control: Jujutsu (`jj`) + Git
- Task automation: `just`
- User-level justfile at `~/justfile`
  - Use `--justfile ~/justfile` when calling from project directory
  - Some recipes: `julia fast-test [regex]`, `julia time-import`, `github push-and-pr`
- References management: `zotero`
  - `~/scripts/zotero.py [CitationKey] [DOI]` to queue paper(s) metadata.
  - `~/scripts/zotero.py add [DOI]` to add paper(s) to Zotero

## Code Style

Optimize for future agents reading cold. Prose restating code or other
docs is worse than nothing: it inflates diffs, and once stale, future
agents read it as constraints and bend to match false claims.

Comments:

- Deletion test - if the content is cheaply reconstructable from the repo
  alone, delete it. Density tracks surprise.
- Keep: non-derivable WHY. Hidden constraints, undocumented data quirks,
  invariants and deliberate tradeoffs.
- Cut: section dividers, headers restating the task, docstrings that restate signatures.
- A contradicting comment is a bug. Fix or delete it — never route around it.

Tests: each one should fail if the implementation were subtly wrong. A trivial test is deleted, not written.

## Julia development

- Available global tools: `Revise`
  - `Chairmarks` for fast benchmarking: `@b rand(1000)`, `@b rand(100) sort`, `@b rand(1000) _.*5`.
  - `ReferenceRevision` for checking out code at different revisions: `head = open_process(rev = "HEAD"); head.func()`
- When writing functions, avoid over-narrow signatures blocking user types
- Prefer `Pkg.add` for new packages; `Pkg.resolve()` when `Project.toml` changes; use `io = devnull` keyword for suppressing output;

## Memory

Memory is distilled knowledge, not session log. Litmus test before saving:
"would a fresh agent reading current repository act differently knowing this?"
If doc, code or tests, or VCS history show, don't save. Prefer in-repo memory for project knowledge.
