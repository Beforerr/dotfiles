# Agent Rules and Preferences

## Version Control
- Use Jujutsu (`jj`) for version control instead of git
- Use `jj new` to create separate commits for different purposes when needed (e.g., do not create new, empty change if working copy is clean or contains changes for the same purpose)
- When triggering Julia package registration, comment on the commit page with `@JuliaRegistrator register()`

## Version Bumping
- Use patch version bumps unless breaking changes are introduced or explicitly requested
- Push version bumps directly to main after rebasing (avoid PRs for version bumps)

## Pull Request Workflow
1. Use command like `gh pr create --head "$BRANCH_NAME" ...` to create a pull request since we are working on detached heads;
2. Check PR status and wait for all checks to pass before merging
3. Merge PRs when all checks are successful (prefer `squash and merge`)
4. Delete the branch after merging.
5. Fetch from github `jj git fetch` and rebase new commits to main.

## Commit Messages
- Follow conventional commit format

- Do not create a new commit if it has been created, and you can use `jj git push -c @` to push current commit