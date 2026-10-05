---
name: julia
description: Load BEFORE any `julia` command, especially tests. Test invocation, Revise, package conventions.
---

- Global: `Revise`; `Chairmarks` (`@b rand(1000) sort`); `CodeTracking` (`@code_string f(x)`);
  `ReferenceRevision` (`head = open_process(rev = "HEAD"); head.func()`).
- `@run_package_tests` from `test/`; from the repo root it scans all sibling packages.
- Iterate via the `repld` skill, not repeated `julia -e`; go fresh only when session state could affect the result.
  Tests: `just --justfile ~/justfile julia fast-test [regex]` (repld-backed).
  Load latency: `just --justfile ~/justfile julia time-import`.
- Benchmarks: interpolate every argument, `@b f($x, $v)`. A bare global dispatches dynamically; a literal
  constant-folds (`count(isequal(0.5), $x)` hides the 5x cost of a runtime `v`). Compare versions in one process
  on the same inputs (`ReferenceRevision` for HEAD).
- Don't over-narrow signatures; users bring their own types.
