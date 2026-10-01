---
name: julia
description: Load BEFORE any `julia` command, especially tests. Test invocation, Revise, package conventions.
---

- Global: `Revise`; `Chairmarks` (`@b rand(1000) sort`); `CodeTracking` (`@code_string f(x)`);
  `ReferenceRevision` (`head = open_process(rev = "HEAD"); head.func()`).
- `@run_package_tests` from `test/`; from the repo root it scans all sibling packages.
- Each process pays load + compile, so iterate in one warm session: `repld julia --project` with Revise
  (edits apply without restart); tests via `just --justfile ~/justfile julia fast-test [regex]` (same mechanism).
  Restart (`repld --fresh`) only when Revise can't follow (struct/const changes) or clean state matters
  (final full run, load/precompile behavior). `julia time-import` for load latency.
- Don't over-narrow signatures; users bring their own types.
