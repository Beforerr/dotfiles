default:
    -just --list --justfile "{{ source_file() }}"
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

[no-cd]
add-docs:
    #!/usr/bin/env -S julia --threads=auto --project=. -i
    using DocumenterTools
    DocumenterTools.generate()

[no-cd]
servedocs:
    #!/usr/bin/env -S julia --threads=auto --project=docs/ -i
    using Pkg
    Pkg.resolve()
    using LiveServer;
    servedocs(include_dirs=["src/"])

[no-cd]
jet:
    #!/usr/bin/env -S julia --threads=auto --project=. -i
    using JET: report_package
    using Pkg: project
    report_package(project().name)

[no-cd]
snoop:
    #!/usr/bin/env -S julia --threads=auto --project=. --startup-file=no -i
    using SnoopCompileCore, TOML
    pkg_name = Symbol(TOML.parsefile("Project.toml")["name"])
    invs = @eval @snoop_invalidations using $pkg_name
    using SnoopCompile, AbstractTrees
    trees = invalidation_trees(invs)
    println("Total trees: ", length(trees))
    function countnodes(n::SnoopCompile.InstanceNode)
        total = 1; for c in n.children; total += countnodes(c); end; total
    end
    function count_tree(t)
        n = 0
        for be in t.backedges; n += countnodes(be); end
        for (sig, mb) in t.mt_backedges; n += countnodes(mb); end
        n
    end
    counts = [(count_tree(t), t) for t in trees]
    for (n, t) in counts
        println("[", lpad(n, 5), "] ", t.method)
    end
    println("Total: ", sum(first.(counts)))

[no-cd]
new-package name dir="~/.julia/dev":
    #!/usr/bin/env -S julia --threads=auto
    using PkgTemplates
    Template(; 
        dir="{{ dir }}",
        julia=v"1.10", 
        plugins=[
            Tests(; project=true, aqua=true),
            GitHubActions(; extra_versions=["lts", "1", "pre"]),
            Codecov(),
            Documenter{GitHubActions}(),
        ]
    )("{{ name }}")

[no-cd]
new-package-sph name dir="~/src":
    #!/usr/bin/env -S julia --threads=auto
    using PkgTemplates
    Template(; 
        user="JuliaSpacePhysics",
        dir="{{ dir }}",
        julia=v"1.10", 
        plugins=[
            Tests(; project=true, aqua=true),
            GitHubActions(; 
                file="/Users/zijin/src/juliaspacephysics.github.io/templates/github/workflows/CI.yml",
            ),
            Codecov(),
            Documenter{GitHubActions}(),
        ]
    )("{{ name }}")

[no-cd]
fast-test filter="" flags="":
    #!/usr/bin/env -S repld julia {{ flags }} --project=test --
    using TOML
    test_deps = get(TOML.parsefile(joinpath(pwd(), "test", "Project.toml")), "deps", Dict())
    filter_str = "{{ filter }}"
    if haskey(test_deps, "TestItems") || haskey(test_deps, "TestItemRunner")
        using TestItemRunner
        kw = isempty(filter_str) ? (;) : (; filter = ti -> occursin(filter_str, ti.name))
        TestItemRunner.run_tests(pwd(); kw...)
    else
        runtests = joinpath(pwd(), "test", "runtests.jl")
        @info filter_str
        if isempty(filter_str)
            include(runtests)
        else
            using TestRunner
            TestRunner.runtest(runtests, [Regex(filter_str)])
        end
    end

[no-cd]
time-import:
    #!/usr/bin/env sh
    name=$(julia --threads=auto --project=. --startup-file=no -e 'using Pkg; Pkg.resolve(); Pkg.instantiate(); print(Pkg.project().name)')
    julia --project=. --startup-file=no -e "@time Base.@time_imports using $name"

# Compare import time against another revision (default: parent `HEAD~1`).
[no-cd]
time-import-compare rev="HEAD~1" warmup="2" runs="5":
    #!/usr/bin/env sh
    set -e
    name=$(julia --threads=auto --project=. --startup-file=no -e 'using Pkg; Pkg.resolve(); Pkg.instantiate(); print(Pkg.project().name)')
    wt=$(mktemp -d -t jl-time-import-XXXXXX)
    trap 'git worktree remove --force "$wt" 2>/dev/null || true; rm -rf "$wt"' EXIT
    git worktree add --detach "$wt" {{ rev }}
    julia --threads=auto --project="$wt" --startup-file=no -e 'using Pkg; Pkg.resolve(); Pkg.instantiate()' >/dev/null
    hyperfine --warmup {{ warmup }} --runs {{ runs }} \
        -n "{{ rev }}" "julia --project='$wt' --startup-file=no -e 'using $name'" \
        -n "HEAD"      "julia --project=.    --startup-file=no -e 'using $name'"

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

[no-cd]
bump bump_type="":
    #!/usr/bin/env sh
    set -e
    bump_type="{{ bump_type }}"
    if [ -z "$bump_type" ]; then
        bump_type=$(just --justfile ~/justfile _bump-type)
    fi
    julia --startup-file=no -e 'using Pkg; !haskey(Pkg.project().dependencies, "PkgBump") && Pkg.add(url="https://github.com/AtelierArith/PkgBump.jl")'
    new_version=$(julia --project --startup-file=no -e "
        using PkgBump, Pkg
        project_file = Base.active_project()
        project = Pkg.Types.read_project(project_file)
        PkgBump.updateversion!(project, project_file, :$bump_type)
        print(project.version)
    ")
    echo "Bumped to v$new_version ($bump_type)"
    jj desc -m "build(release): 🔖 $new_version"
    jj bookmark move main --to=@
    jj git push
    if [ "$bump_type" = "patch" ]; then
        just --justfile ~/justfile julia register
    else
        REPO_INFO=$(gh repo view --json owner,name)
        OWNER=$(echo "$REPO_INFO" | jq -r '.owner.login')
        REPO_NAME=$(echo "$REPO_INFO" | jq -r '.name')
        COMMIT_HASH=$(jj log -r main --no-graph --template 'commit_id.short()')
        echo "⚠️  Breaking change detected — register manually:"
        echo "https://github.com/$OWNER/$REPO_NAME/commit/$COMMIT_HASH"
    fi

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
    ln -s ~/src/HAPIClient.jl ~/.julia/dev/HAPIClient
    ln -s ~/src/CDAWeb.jl ~/.julia/dev/CDAWeb
    ln -s ~/src/ELFINData.jl ~/.julia/dev/ELFINData
    ln -s ~/src/DMSPData.jl ~/.julia/dev/DMSPData
    ln -s ~/src/ERGData.jl ~/.julia/dev/ERGData
    ln -s ~/src/VelocityDistributionFunctions.jl ~/.julia/dev/VelocityDistributionFunctions
    ln -s ~/src/MinimumVarianceAnalysis.jl ~/.julia/dev/MinimumVarianceAnalysis
    ln -s ~/src/PlasmaWaves.jl ~/.julia/dev/PlasmaWaves
    ln -s ~/src/PlasmaBO.jl ~/.julia/dev/PlasmaBO
    ln -s ~/src/PlasmaFormulary.jl ~/.julia/dev/PlasmaFormulary
    ln -s ~/src/MultiSpacecraftAnalysis.jl ~/.julia/dev/MultiSpacecraftAnalysis
    ln -s ~/src/SpaceWeather.jl ~/.julia/dev/SpaceWeather
    ln -s ~/src/TsyganenkoModels.jl ~/.julia/dev/TsyganenkoModels
    ln -s ~/src/PlanetaryMagneticFields.jl ~/.julia/dev/PlanetaryMagneticFields
