# Agent Rules and Preferences

- Prefer Jujutsu (`jj`) for version control instead of git
- Prefer conventional commit format (Do not create a new commit if it has been created)

## Style Guidelines

### Functions

- When writing functions, avoid overly restrict the argument types. In general, you should use the most general applicable abstract types for arguments, and when in doubt, omit the argument types. The most common reasons to declare argument types in Julia are, Dispatch, Correctness, and Clarity.

### Docstrings

- Clarity First: Write docstrings that are clear and easy to understand.
- Conciseness: Keep descriptions brief, avoid unnecessary verbosity and do not repeat yourself.
- Detail When Needed: Include additional explanations only when they provide meaningful context (e.g., complex logic, non-obvious behavior, side effects).
- Only provide an argument list when really necessary.
- Provide hints to related functions.
- Consistency: Follow the same style, tone, structure, and level of detail for the same project.

## Version Bumping

- Use patch version bumps unless breaking changes are introduced or explicitly requested
- Push version bumps directly to main after rebasing (avoid PRs for version bumps)
