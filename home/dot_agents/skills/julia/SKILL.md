---
name: julia
description: Load BEFORE any `julia` command, especially tests. Test invocation, Revise, package conventions, performance tuning.
---

- Global: `Revise`; `Chairmarks` (`display(@b rand(1000) sort)`); `CodeTracking` (`@code_string f(x)`);
  `ReferenceRevision` (`head = open_process(rev = "HEAD"); head.func()`); `JET`;
  `DispatchDoctor` (inference loss: `@stable default_mode="warn" begin … end` around suspects, call once).
- `@run_package_tests` from `test/`; from the repo root it scans all sibling packages.
- Iterate via the `repld` skill, not repeated `julia -e`; go fresh only when session state could affect the result.
  Tests: `just --justfile ~/justfile julia fast-test [regex]` (repld-backed; regex matches `@testitem`/`@testset` names).
  `@testset` files only — one file / line range: `testrunner [--project=test --] test/foo.jl "testset name" L10:20 ':(@test f(x_) == y_)'` (`--json` for structured results).
  Load latency: `just --justfile ~/justfile julia time-import`.
- Don't over-narrow signatures; users bring their own types.

## Performance

- Profile line attribution inside inlined code misleads (both ways): A/B-benchmark speedups that cost readability before keeping them.
- `@b` on literal arguments constant-folds; interpolate non-constant values.
- Trace a call chain in one probe (all frames' types/values at once), not one frame per round.
- Generic Base calls (broadcast, reductions, `tr`, folds over tuples) carry a few ns of fixed overhead; on tiny arrays in hot loops that rivals the math, so write explicit loops there.
- `abs(::Complex)` is `hypot` (range-safe, slow); `sqrt(abs2(z))` when magnitudes are known bounded.
