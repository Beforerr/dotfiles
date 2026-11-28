try
    using Revise
catch e
    @info "Revise not installed. Run `] add Revise` to install it."
end

using InteractiveUtils
import Pkg
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true

macro autoinfiltrate(cond = true)
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
            "Could not load Infiltrator."
        )
    end

    return Expr(
        :macrocall,
        Expr(:., i, QuoteNode(Symbol("@infiltrate"))),
        lnn,
        esc(cond)
    )
end

if isinteractive()
    try
        using Autoloads
    catch e
        @info "Autoloads not installed. Run `~/.julia/config/packages.jl` to install it."
    end
end
