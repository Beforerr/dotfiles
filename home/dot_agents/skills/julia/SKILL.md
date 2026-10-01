---
name: julia
description: Load BEFORE any `julia` command (tests, Pkg, REPL, benchmarks). Test invocation, Revise, package conventions.
---

- Global: `Revise`; `Chairmarks` (`@b rand(1000) sort`); `CodeTracking` (`@code_string f(x)`);
  `ReferenceRevision` (`head = open_process(rev = "HEAD"); head.func()`).
- `@run_package_tests` from `test/`; from the repo root it scans all sibling packages.
- `just --justfile ~/justfile julia fast-test [regex]` / `julia time-import`.
- Add deps with `Pkg.add`, not by editing `Project.toml`. Don't over-narrow signatures; users bring their own types.
