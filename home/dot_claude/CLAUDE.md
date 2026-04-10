# Agent Rules

## Preferences

- `uv` for Python dependency management
- Jujutsu (`jj`) for version control
- conventional commit format
- Using subagent(s) for code review (fresh ones), explore unfamiliar large codebase, parallel editing of independent files

## Style Guidelines

- When writing functions, avoid restricting argument types (omit them when possible). Declare them only when necessary for dispatch, correctness, or clarity.
- Prefer clear, concise, consistent, and understandable docstrings over verbose ones. Only provide an argument list when really necessary. Include additional explanations for meaningful context (e.g., complex logic, non-obvious behavior, side effects).
