# Agent Rules and Preferences

## Style Guidelines

### Docstrings

-   Clarity First: Write docstrings that are clear and easy to understand.
-   Conciseness: Keep descriptions brief, avoid unnecessary verbosity and do not repeat yourself.
-   Detail When Needed: Include additional explanations only when they provide meaningful context (e.g., complex logic, non-obvious behavior, side effects).
-   Only provide an argument list when really necessary.
-   Provide hints to related functions.
-   Consistency: Follow the same style, tone, structure, and level of detail for the same project.

## Version Control

-   Use Jujutsu (`jj`) for version control instead of git
-   Use `jj new` to create separate commits for different purposes when needed (e.g., do not create new, empty change if working copy is clean or contains changes for the same purpose)
-   When triggering Julia package registration, comment on the commit page with `@JuliaRegistrator register()`

## Version Bumping

-   Use patch version bumps unless breaking changes are introduced or explicitly requested
-   Push version bumps directly to main after rebasing (avoid PRs for version bumps)

### Version Bumping Workflow

1. Edit version in Project.toml
2. Create commit: `jj commit -m "build(release): 🔖 X.Y.Z"`
3. Move main bookmark: `jj bookmark set main -r @-`
4. Push to main: `jj git push --bookmark main`

## Pull Request Workflow

-   Use `jj git push -c @` to push current commit (this creates a temporary bookmark)

1. Use command like `gh pr create --head "$BRANCH_NAME" ...` to create a pull request since we are working on detached heads;
2. Check PR status and wait for all checks to pass before merging
3. Merge PRs when all checks are successful (prefer `squash and merge`)
4. Delete the branch after merging.
5. Fetch from github `jj git fetch` and rebase new commits to main.

## Commit Messages

-   Follow conventional commit format

-   Do not create a new commit if it has been created.
