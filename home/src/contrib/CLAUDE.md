# Contributing to external repos

- Upstream conventions win over my global style.
- Setup confined to my side needs no confirmation: fork (`gh repo fork --remote --remote-name fork`), branch, commit, push to `fork`.
- Never act upstream (PRs, issues, comments, pushes to `origin`). Give me `gh pr create ...` command and PR body.
- PR body: problem, root cause, fix, how verified. No agent attribution.
- Large projects (compilers, runtimes): no full builds by default. Verify against a prebuilt: hot-patch the changed functions, run only the affected test file.
