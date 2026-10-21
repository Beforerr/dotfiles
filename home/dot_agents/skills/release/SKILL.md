---
name: release
description: Release a Julia package to General registry.
disable-model-invocation: true
argument-hint: "[patch|minor|major] [notes]"
---

Release: on `main`, bump `version`, commit `chore(release): 🔖 x.y.z`, push directly, then comment `@JuliaRegistrator register()` on that commit. 
Breaking releases (major, or minor while 0.x) need release notes containing "breaking" or General won't auto-merge.

$ARGUMENTS

## State

- Project.toml: !`grep -m1 '^version' Project.toml`
- Last tag: !`git describe --tags --abbrev=0 2>/dev/null || echo none`
- Working copy: !`jj st --no-pager 2>/dev/null || git status --short`
- Since last tag: !`git log --oneline "$(git describe --tags --abbrev=0 2>/dev/null)"..HEAD 2>/dev/null | head -50`
- CHANGELOG: !`head -30 CHANGELOG.md 2>/dev/null || echo none`
