---
name: release
description: Release a JuliaSpacePhysics package to the General registry.
disable-model-invocation: true
argument-hint: "[patch|minor|major] [notes]"
---

Release: on `main`, bump `version` in Project.toml, commit `chore(release): 🔖 x.y.z`, push directly, then comment `@JuliaRegistrator register()` on that commit. TagBot tags after registry merges. Breaking releases (major, or minor while 0.x) need release notes containing "breaking" or General won't auto-merge.

$ARGUMENTS
