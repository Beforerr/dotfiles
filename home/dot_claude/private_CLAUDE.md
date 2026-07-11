# Agent Guidelines

言简意赅, Disagree when confident, no sycophancy

## Agent memory

Memory is distilled knowledge, not session log. Litmus test before saving:
"would a fresh agent reading current repository act differently knowing this?"
If doc, code or tests, or git history show, don't save.

## Preferences

- For replies (not deliverables): respond terse like smart caveman. No fluff. Drop articles (a/the), filler (just/really/actually/simply), pleasantries (sure/certainly/of course), hedging. Fragments OK.
- Minimize repetition across progress updates, tool uses, and final response. Do not restate command contents or patch text visible in context.
- `uv` for Python dependency management
- Jujutsu (`jj`) for version control
- Using subagent(s) for code review (fresh ones), explore unfamiliar large codebase, parallel editing of independent files

## Code Style

Optimize codes for your own throughput, context window, token usage, and future agent maintenance.

- Avoid comments on WHAT or HOW and narrating obvious code. Code shows what. Non-derivable WHY (hidden constraint, assumptions, invariants, tradeoffs) comments allowed.
- Dense, no scaffolding: section dividers, headers that restate tasks. Every line consumes next session's context

## Task automation (`just`)

Recipes are guidelines, not fixed rules — add or improve them as needed to fit task.

- User-level justfile: `~/justfile` (modules: `julia`, `rust`, `github` in `~/scripts/`). Use `--justfile ~/justfile` when calling from project directory.
- Discover recipes: `just --justfile ~/justfile --list`
- `--dry-run` available to preview commands before executing
- Common recipes: `julia fast-test [regex]`, `julia time-import`, `github push-and-pr`

## Julia development

- When writing functions, avoid restricting argument types (omit types when possible; declare for dispatch, correctness, or clarity);
- Prefer `Pkg.add` for new packages; `Pkg.resolve()` when `Project.toml` changes; use `io = devnull` keyword for suppressing output;
- To run focused tests for touched behavior in test environment:
    - `using TestRunner` with `@testset`: `runtest("test/runtests.jl", ["TestSetName", r"TestSetRegex"])`
    - `using TestItemRunner` with `@testitem`: `TestItemRunner.run_tests(pwd(); filter = ti -> ti.name == "TestItemName")`
- Prefer `Chairmarks.jl` (globally installed) for fast benchmarking. Examples: `@b rand(1000)`, `@b rand(100) sort`, `@b rand(1000) _.*5` (use `_` to refer to setup)
