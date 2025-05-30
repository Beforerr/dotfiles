try
    using Revise
catch e
    @info "Revise not installed. Run `] add Revise` to install it."
end

import Pkg
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true

macro autoinfiltrate(cond=true)
    pkgid = Base.PkgId(Base.UUID("5903a43b-9cc3-4c30-8d17-598619ec4e9b"), "Infiltrator")
    if !haskey(Base.loaded_modules, pkgid)
        try
            Base.eval(Main, :(using Infiltrator))
        catch err
            @error "Cannot load Infiltrator.jl. Make sure it is included in your environment stack."
        end
    end
    i = get(Base.loaded_modules, pkgid, nothing)
    lnn = LineNumberNode(__source__.line, __source__.file)

    if i === nothing
        return Expr(
            :macrocall,
            Symbol("@warn"),
            lnn,
            "Could not load Infiltrator.")
    end

    return Expr(
        :macrocall,
        Expr(:., i, QuoteNode(Symbol("@infiltrate"))),
        lnn,
        esc(cond)
    )
end

if isinteractive()
    import BasicAutoloads
    BasicAutoloads.register_autoloads([
        ["@b", "@be"] => :(using Chairmarks),
        ["@track"] => :(using RegressionTests),
        ["@benchmark", "@btime"] => :(using BenchmarkTools),
        ["@test", "@testset", "@test_broken", "@test_deprecated", "@test_logs",
            "@test_nowarn", "@test_skip", "@test_throws", "@test_warn", "@inferred"] =>
            :(using Test),
        ["@testitem"] => :(using TestItems),
        ["@report_opt", "@report_call"] => :(using JET),
        ["@descend"] => :(using Cthulhu),
        ["@about"] => :(using About;
        macro about(x)
            Expr(:call, About.about, x)
        end),
    ])

    using Pkg: Pkg
    atreplinit() do repl
        try
            @eval using OhMyREPL
        catch e
            @warn "error while importing OhMyREPL" e
        end
    end
end
