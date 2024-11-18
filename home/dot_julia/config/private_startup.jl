try
    using Revise
catch e
    @info "Revise not installed. Run `] add Revise` to install it."
end

if isinteractive()
    import BasicAutoloads
    BasicAutoloads.register_autoloads([
        ["@b", "@be"] => :(using Chairmarks),
        ["@benchmark"] => :(using BenchmarkTools),
        ["@test", "@testset", "@test_broken", "@test_deprecated", "@test_logs",
            "@test_nowarn", "@test_skip", "@test_throws", "@test_warn", "@inferred"] =>
            :(using Test),
        ["@about"] => :(using About; macro about(x)
            Expr(:call, About.about, x)
        end),
    ])
end