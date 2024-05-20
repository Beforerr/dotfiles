using Pkg
Pkg.add("IJulia")
Pkg.add("Revise")
Pkg.add("Pluto")

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