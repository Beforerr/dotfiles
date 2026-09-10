---
name: julia
description: Julia conventions and global tools — benchmarking, inspecting methods, comparing revisions, running package tests, adding deps. Use when editing or testing Julia code or packages.
---

- Global: `Revise`; `Chairmarks` (`@b rand(1000) sort`); `CodeTracking` (`@code_string f(x)`);
  `ReferenceRevision` (`head = open_process(rev = "HEAD"); head.func()`).
- `@run_package_tests` from `test/`; from the repo root it scans all sibling packages.
- `just --justfile ~/justfile julia fast-test [regex]` / `julia time-import`.
- Add deps with `Pkg.add`, not by editing `Project.toml`. Don't over-narrow signatures; users bring their own types.
