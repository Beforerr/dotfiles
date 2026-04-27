# Agent Rules

## Preferences

- `uv` for Python dependency management
- Jujutsu (`jj`) for version control
- conventional commit format
- Using subagent(s) for code review (fresh ones), explore unfamiliar large codebase, parallel editing of independent files

## Style Guidelines

- Prefer clear, concise, consistent, and understandable docstrings over verbose ones. Only provide argument list when really necessary. Include additional explanations for meaningful context (e.g., complex logic, non-obvious behavior, side effects).

## Julia development

- When writing functions, avoid restricting argument types (omit types when possible; declare for dispatch, correctness, or clarity).
- Never edit Project.toml directly (use `Pkg` commands)
- Activate the test environment with `Pkg.activate("test")`
- Run selective tests with [`TestRunner`](https://github.com/aviatesk/TestRunner.jl): `using TestRunner; runtest("test/runtests.jl", ["TestSetName", r"TestSetRegex"])`
