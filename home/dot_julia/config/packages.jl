using Pkg
Pkg.add("Revise")
Pkg.add([
    "IJulia",
    "QuartoNotebookRunner",
    "Pluto"
])

Pkg.add([
    "LaTeXStrings",
    "CairoMakie",
    "GLMakie",
    "WGLMakie",
    "AlgebraOfGraphics"
])

Pkg.add([
    "DataFrames",
    "DataFramesMeta",
])