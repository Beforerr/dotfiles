try
    using Revise
catch e
    @info "Revise not installed. Run `] add Revise` to install it."
end

if isinteractive()
    import BasicAutoloads
    BasicAutoloads.register_autoloads([
        ["@b", "@be"] => :(using Chairmarks),
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
