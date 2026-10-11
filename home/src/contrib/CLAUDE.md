# Contributing to external repos

- Upstream conventions win over my global style.
- Never push, open PRs or comment upstream. Give me `gh pr create ...` command and PR body.
- PR body: problem, root cause, fix, how verified. No agent attribution.
- Large projects (compilers, runtimes): no full builds by default. Verify against a prebuilt: hot-patch the changed functions, run only the affected test file.
