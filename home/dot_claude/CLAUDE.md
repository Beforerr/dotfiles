# Agent Rules

## Preferences

- `uv` for Python dependency management
- Jujutsu (`jj`) for version control
- conventional commit format
- Using subagent(s) for code review (fresh ones), explore unfamiliar large codebase, parallel editing of independent files

## Style Guidelines

- Prefer clear, concise, consistent, and understandable docstrings over verbose ones. Only provide argument list when really necessary. Include additional explanations for meaningful context (e.g., complex logic, non-obvious behavior, side effects).

## Julia development

- When writing functions, avoid restricting argument types (omit types when possible; declare for dispatch, correctness, or clarity);
- Prefer `Pkg.add` for new packages; when dependency changes, run `Pkg.resolve()` first to update manifest; add keyword `io = devnull` to suppress output when needed;
- Activate test environment with `Pkg.activate("test")`;
- Run focused tests for touched behavior, and optional full test suite before handoff:
    - `using TestRunner` with `@testset`: `runtest("test/runtests.jl", ["TestSetName", r"TestSetRegex"])`
    - `using TestItemRunner` with `@testitem`: `TestItemRunner.run_tests(pwd(); filter = ti -> ti.name == "TestItemName")`
- Prefer `Chairmarks.jl` for fast benchmarking. Examples: `@b rand(1000)`, `@b rand(100) sort`, `@b rand(1000) _.*5` (use `_` to refer to setup)
