---
name: julia
description: Load BEFORE any `julia` command, especially tests. Test invocation, Revise, package conventions, performance tuning.
---

- Global: `Revise`; `Chairmarks` (`display(@b rand(1000) sort)`); `CodeTracking` (`@code_string f(x)`);
  `ReferenceRevision` (`head = open_process(rev = "HEAD"); head.func()`); `JET`;
  `DispatchDoctor` (inference loss: `@stable default_mode="warn" begin … end` around suspects, call once).
- Fresh checkouts (clone, worktree, jj workspace...) have no Manifest: `Pkg.instantiate()` before `using`.
- Minimize rounds. Use `repld` when calls reuse state: slow setup, or exploration where each query builds on the last. Fresh process (julia --project=… script.jl or repld --fresh) when the check needs one.
- Tests: `just -g julia fast-test [regex]` (repld-backed; regex matches `@testitem`/`@testset` names; prints only the summary and capped failure blocks; full output goes to the log path printed last). Ad-hoc: `TestItemRunner.run_tests(pkgdir)`; `@run_package_tests` scans `..` of the calling file.
  `@testset` files only — one file / line range: `testrunner [--project=test --] test/foo.jl "testset name" L10:20 ':(@test f(x_) == y_)'` (`--json` for structured results).
  Load latency: `just -g julia time-import` (`time-import-compare [rev]` vs a revision); invalidations: `just -g julia snoop`; JET: `just -g julia jet`.
- Structural search/rewrite: `sg-jl -p '@views $E' [paths] [--json] [-r 'repl' [-U]]` (`ast-grep run` flags, Julia preset; `-r` previews a diff, `-U` writes); prefer over regex for multi-line or nested refactors.
- Don't over-narrow signatures; users bring their own types.

## Performance

- One call's hot spots: `[repld] julia --project=… ~/scripts/profile.jl '<setup>' '<expr>'` prints `@b`, per-frame inclusive/self %, and JET runtime-dispatch sites.
- Profile line attribution inside inlined code misleads (both ways): A/B-benchmark speedups that cost readability before keeping them.
- `@b` on literal arguments constant-folds; interpolate non-constant values.
- Generic Base calls (broadcast, reductions, `tr`, folds over tuples) carry a few ns of fixed overhead; on tiny arrays in hot loops that rivals the math, so write explicit loops there.
- `abs(::Complex)` is `hypot` (range-safe, slow); `sqrt(abs2(z))` when magnitudes are known bounded.

## repld

!`cat ~/.agents/skills/repld/SKILL.md ~/.agents/skills/repld/references/julia.md`
