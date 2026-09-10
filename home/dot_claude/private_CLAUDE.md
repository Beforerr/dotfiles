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

- Same fact in two places is the signal to consolidate and leave a pointer.
- Source files document the system as it is, not the change that made it.
  Update in place; never append "NEW:" or "(updated)". History lives in VCS.

## Tools

Install with `brew`/`uv` as needed. Python deps: `uv`. VCS: Jujutsu (`jj`) + Git.

- `just --justfile ~/justfile`: `julia fast-test [regex]`, `julia time-import`, `push-and-pr`, … (`--list`; modules hide behind `julia ...`).
- `~/scripts/zotero.py <citekey|DOI|title>...` prints metadata + PDF path; `add <DOI|arXiv|url>... -c Collection` imports. Needs Zotero running. `research.bib` in paper repos is an auto-export of the whole library.
- PDF: `pdftotext -layout in.pdf out.txt` for text; `uvx --from marker-pdf marker_single in.pdf --output_dir out --output_format markdown` for equations/tables/figures → `out/<stem>/<stem>.md`, ~30 s.

## Dotfiles

- chezmoi-managed, incl. `~/.agents` and `~/.claude*` (`chezmoi managed <path>` to check). Edit in place, then `chezmoi re-add <path>` (auto-commits + pushes) or next `apply` reverts.
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
- Cut: section dividers, headers restating the task, docstrings that restate signatures.
- A contradicting comment is a bug. Fix or delete it — never route around it.

Tests: Only add tests that would fail if the implementation were subtly wrong. A trivial test is deleted, not written.

## Julia

- Global: `Revise`; `Chairmarks` (`@b rand(1000) sort`); `CodeTracking` (`@code_string f(x)`); `ReferenceRevision` (`head = open_process(rev = "HEAD"); head.func()`).
- `@run_package_tests` from `test/`; from the repo root it scans all sibling packages.
- Add deps with `Pkg.add`, not by editing `Project.toml`. Don't over-narrow signatures; users bring their own types.

## Memory

Distilled knowledge, not session log. Save only what would change a fresh agent's actions and isn't in docs, code, tests, or VCS. Prefer in-repo memory for project knowledge.
