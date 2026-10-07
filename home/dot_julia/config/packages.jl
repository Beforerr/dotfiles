using Pkg
Pkg.add([
    "Revise",

    "SnoopCompileCore",
    "SnoopCompile",
    "AbstractTrees",

    # Development
    # "About",
    "Aqua",
    "LiveServer",
    "JET",
    "BenchmarkTools",
    "Chairmarks",
    "RegressionTests",
    # "PkgCacheInspector",
    # "MethodAnalysis",
    "PackageCompiler",
    "PrecompileAfterUpdate",
    "TestItems",
    "TestItemRunner",
    "TestEnv",
    # "InteractiveErrors",
    # "Infiltrator",

    # Interactive
    "BasicAutoloads",
])

# `release` branch vendors deps with rewritten UUIDs, so it never conflicts with project envs.
testrunner = (; url="https://github.com/aviatesk/TestRunner.jl", rev="release")
Pkg.add(; testrunner...)
Pkg.Apps.add(; testrunner...)

Pkg.activate("runic"; shared=true)
Pkg.add("Runic")
