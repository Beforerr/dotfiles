# Focused test runner. Usage: julia [--project=test] focused_test.jl [filter]
# Filters @testitem/@testset by name across files; empty filter runs full suite.
using TOML

filter_str = get(ARGS, 1, "")
root = pwd()
proj = joinpath(root, "test", "Project.toml")
deps = isfile(proj) ? get(TOML.parsefile(proj), "deps", Dict()) : Dict()

if haskey(deps, "TestItems") || haskey(deps, "TestItemRunner")
    using TestItemRunner
    kw = isempty(filter_str) ? (;) : (; filter = ti -> occursin(Regex(filter_str, "i"), ti.name))
    TestItemRunner.run_tests(root; kw...)
else
    entry = joinpath(root, "test", "runtests.jl")
    if isempty(filter_str)
        include(entry)
    else
        using TestRunner
        dir = dirname(entry)
        scan = [joinpath(r, f) for (r, _, fs) in walkdir(dir) for f in fs if endswith(f, ".jl")]
        files = unique(abspath.([entry; scan]))
        TestRunner.runtests(entry, [f => [Regex(filter_str, "i")] for f in files])
    end
end
