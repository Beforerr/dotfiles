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
            GitHubActions(; extra_versions=["lts", "1", "pre"]),
            Codecov(),
            Documenter{GitHubActions}(),
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

[no-cd]
bump:
    julia --project -e 'using PkgBump, Pkg; project_file = Base.active_project(); project = Pkg.Types.read_project(project_file); PkgBump.updateversion!(project, project_file, :patch); new_version = project.version; run(`jj desc -m "build(release): 🔖 $new_version"`)'
    jj bookmark move main --to=@; jj git push; 
    .j julia register

[no-cd]
register:
    #!/bin/bash
    # Script to trigger Julia package registration by commenting on the current commit
    set -e

    # Get repository info
    REPO_INFO=$(gh repo view --json owner,name)
    OWNER=$(echo "$REPO_INFO" | jq -r '.owner.login')
    REPO_NAME=$(echo "$REPO_INFO" | jq -r '.name')

    # Get the current commit hash
    COMMIT_HASH=$(jj log -r main --no-graph --template 'commit_id.short()')

    # Comment on the commit to trigger registration
    echo "Commenting on commit $COMMIT_HASH in Repository: $OWNER/$REPO_NAME to trigger Julia package registration..."
    gh api "repos/$OWNER/$REPO_NAME/commits/$COMMIT_HASH/comments" \
        --method POST \
        --input - <<< '{"body":"@JuliaRegistrator register()"}' \
        --silent
    echo "✅ Registration comment posted successfully!"
    echo "Check the commit page: https://github.com/$OWNER/$REPO_NAME/commit/$COMMIT_HASH"

link:
    ln -s ~/src/IRBEM.jl ~/.julia/dev/IRBEM
    ln -s ~/src/GeoAACGM.jl ~/.julia/dev/GeoAACGM
    ln -s ~/src/GeoCotrans.jl ~/.julia/dev/GeoCotrans
    ln -s ~/src/Madrigal.jl ~/.julia/dev/Madrigal
    ln -s ~/src/TimeseriesUtilities.jl ~/.julia/dev/TimeseriesUtilities
    ln -s ~/src/SPEDAS.jl ~/.julia/dev/SPEDAS
    ln -s ~/src/SpaceDataModel.jl ~/.julia/dev/SpaceDataModel
    ln -s ~/src/SpacePhysicsMakie.jl ~/.julia/dev/SpacePhysicsMakie
    ln -s ~/src/PySPEDAS.jl ~/.julia/dev/PySPEDAS
    ln -s ~/src/SolarEnergeticParticle.jl ~/.julia/dev/SolarEnergeticParticle
    ln -s ~/src/Speasy.jl ~/.julia/dev/Speasy
    ln -s ~/src/CDFDatasets.jl ~/.julia/dev/CDFDatasets
    ln -s ~/src/CommonDataFormat.jl ~/.julia/dev/CommonDataFormat
    ln -s ~/src/CDAWeb.jl ~/.julia/dev/CDAWeb