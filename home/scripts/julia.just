# Check julia and juliaup versions
default:
    -julia --version
    -juliaup --version

# Install Julia using Juliaup
install: install-juliaup install-pkgs
# Update Julia using Juliaup
update: update-julia install-pkgs

[private]
install-juliaup:
    #!/usr/bin/env sh
    if ! command -v juliaup; then
        echo "Installing Juliaup - Julia version manager..."
        curl -fsSL https://install.julialang.org | sh -s -- --yes
    fi

[private]
update-julia:
    -juliaup update

install-pkgs:
    -julia ~/.julia/config/packages.jl

pluto:
    #!/usr/bin/env julia
    import Pluto;
    Pluto.run()
