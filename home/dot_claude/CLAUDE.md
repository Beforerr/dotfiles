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
- Prefer `Pkg.add` to add new packages;
- Activate test environment with `Pkg.activate("test")`;
- For selective tests:
    - `using TestRunner` with `@testset`: `runtest("test/runtests.jl", ["TestSetName", r"TestSetRegex"])`
    - `using TestItemRunner` with `@testitem`: `TestItemRunner.run_tests(pwd(); filter = ti -> ti.name == "TestItemName")`
