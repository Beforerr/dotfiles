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
- Don't over-narrow signatures; users bring their own types.
- Multi-step checks (anything loading Makie, before/after comparisons): one `repld` session, not
  repeated `julia -e`; each cold start re-pays precompile. Old-vs-new output: `ReferenceRevision`.
