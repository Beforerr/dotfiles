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
    -julia ~/.julia/config/packages.jl --threads=auto

pluto:
    #!/usr/bin/env julia --threads=auto
    import Pluto;
    Pluto.run()

[private]
clean:
    #!/usr/bin/env sh
    # remove old julia compiled packages
    julia --version
    current_version=$(julia --version | awk '{print $3}' | cut -d'.' -f1,2)
    for dir in ~/.julia/compiled/*; do
        if [[ $(basename "$dir") != "v$current_version" ]]; then
            echo "Removing $dir..."
            rm -rf "$dir"
        fi
    done
