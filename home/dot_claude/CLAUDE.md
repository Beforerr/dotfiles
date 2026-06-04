# Agent Rules

## Preferences

- For replies (not deliverables): respond terse like smart caveman. No fluff. Drop articles (a/the), filler (just/really/actually/simply), pleasantries (sure/certainly/of course), hedging. Fragments OK.
- Minimize repetition across progress updates, tool output, and final response. Do not restate command output or patch text visible in context.
- `uv` for Python dependency management
- Jujutsu (`jj`) for version control
- conventional commit format
- Using subagent(s) for code review (fresh ones), explore unfamiliar large codebase, parallel editing of independent files

## Code Style

Optimize code for your own throughput and future agent maintenance.

- Comments say non-derivable WHY (hidden constraint, assumptions, invariants, tradeoffs), not WHAT or HOW. Code shows what.
- Docstrings: clear, concise, consistent. No narrating obvious code.
- Dense, no scaffolding: section dividers, headers that restate tasks. Every line eats next session's context
- Mark dead ends: "tried X, broke Y, skip."

## Task automation (`just`)

Recipes are guidelines, not fixed rules — add or improve them as needed to fit task.

- User-level justfile: `~/justfile` (modules: `julia`, `rust`, `github` in `~/scripts/`). Use `--justfile ~/justfile` when calling from project directory.
- Discover recipes: `just --justfile ~/justfile --list`
- `--dry-run` available to preview commands before executing
- Common recipes: `julia fast-test [regex]`, `julia time-import`, `github push-and-pr`

## Julia development

- When writing functions, avoid restricting argument types (omit types when possible; declare for dispatch, correctness, or clarity);
- Prefer `Pkg.add` for new packages; when `Project.toml` changes, run `Pkg.resolve()` first to update `Manifest.toml`; use `io = devnull` keyword for suppressing output;
- Run focused tests for touched behavior, and optional full test suite before handoff:
    - `using TestRunner` with `@testset`: `runtest("test/runtests.jl", ["TestSetName", r"TestSetRegex"])`
    - `using TestItemRunner` with `@testitem`: `TestItemRunner.run_tests(pwd(); filter = ti -> ti.name == "TestItemName")`
- Prefer `Chairmarks.jl` for fast benchmarking. Examples: `@b rand(1000)`, `@b rand(100) sort`, `@b rand(1000) _.*5` (use `_` to refer to setup)

@RTK.md
