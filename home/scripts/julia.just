# Check julia and juliaup versions
default:
    -julia --version
    -juliaup --version

# Install Julia using Juliaup
install: install-juliaup install-pkgs

# Update Julia using Juliaup
update: update-julia install-pkgs
    #!/usr/bin/env julia --threads=auto
    using PrecompileAfterUpdate
    PrecompileAfterUpdate.precompile()

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
    -julia --project=@runic -e 'using Pkg; Pkg.add("Runic")'

pluto:
    #!/usr/bin/env julia --threads=auto
    import Pluto;
    Pluto.run()

[no-cd]
add-docs:
    #!/usr/bin/env -S julia --threads=auto --project=. -i
    using DocumenterTools
    DocumenterTools.generate()

[no-cd]
servedocs:
    #!/usr/bin/env -S julia --threads=auto --project=docs/ -i
    using Pkg
    Pkg.develop(PackageSpec(path=pwd()))
    using LiveServer;
    servedocs(include_dirs=["src/"])

[no-cd]
jet:
    #!/usr/bin/env -S julia --threads=auto --project=. -i
    using JET: report_package
    using Pkg: project
    report_package(project().name)

[no-cd]
new-package name dir="~/.julia/dev":
    #!/usr/bin/env -S julia --threads=auto
    using PkgTemplates
    Template(; 
        dir="{{dir}}",
        julia=v"1.10", 
        plugins=[
            Tests(; project=true),
            GitHubActions(; extra_versions=["1.10", "1.11", "pre"])
        ]
    )("{{name}}")

[no-cd]
test:
    julia --threads=auto --project=. -e 'using Pkg; Pkg.test()'

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
    # ~/Library/Caches/quarto/julia/Project.toml

link:
    ln -s ~/src/IRBEM.jl ~/.julia/dev/IRBEM
