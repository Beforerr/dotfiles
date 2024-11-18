using Pkg
Pkg.add([
    "Revise",
    "DrWatson",
    "PkgTemplates",

    # Development
    "LiveServer",
    "BenchmarkTools",
    "PkgCacheInspector",
    "MethodAnalysis",

    # Interactive
    "IJulia",
    "QuartoNotebookRunner",
    "Pluto",
    "BasicAutoloads",
])
