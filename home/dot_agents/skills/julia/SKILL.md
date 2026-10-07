---
name: julia
description: Load BEFORE any `julia` command, especially tests. Test invocation, Revise, package conventions.
---

- Global: `Revise`; `Chairmarks` (`@b rand(1000) sort`); `CodeTracking` (`@code_string f(x)`);
  `ReferenceRevision` (`head = open_process(rev = "HEAD"); head.func()`).
- `@run_package_tests` from `test/`; from the repo root it scans all sibling packages.
- Iterate via the `repld` skill, not repeated `julia -e`; go fresh only when session state could affect the result.
  Tests: `just --justfile ~/justfile julia fast-test [regex]` (repld-backed).
  One file / line range: `testrunner [--project=test --] test/foo.jl "testset name" L10:20 ':(@test f(x_) == y_)'` (`--json` for structured results).
  Load latency: `just --justfile ~/justfile julia time-import`.
- Don't over-narrow signatures; users bring their own types.

## Performance

- Profile line attribution inside inlined code misleads (both ways). Keep a change only if a fresh-process A/B shows it (`@b f($x) seconds=3`); revert the rest.
- `@b` on literal arguments constant-folds; interpolate non-constant values.
- Hot loops over tiny arrays (3×3, short tuples): generic `tr`, in-place broadcast (`S .*= c`), `argmax(f, tuple)` cost 2–6 ns fixed overhead each, comparable to the math itself. Use explicit `@inbounds` loops / comparisons there.
- `abs(::Complex)` is `hypot` (range-safe, slow); `sqrt(abs2(z))` when magnitudes are known bounded.
