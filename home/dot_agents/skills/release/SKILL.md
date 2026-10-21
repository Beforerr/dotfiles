---
name: release
description: Release a Julia package to General registry.
disable-model-invocation: true
argument-hint: "[patch|minor|major] [notes]"
---

Release: bump `version`, commit `chore(release): 🔖 x.y.z`, push directly, then comment `@JuliaRegistrator register()` on GitHub. 
Breaking releases (major, or minor while 0.x) need release notes containing "breaking" or General won't auto-merge.

$ARGUMENTS

## State

!`release-state`
