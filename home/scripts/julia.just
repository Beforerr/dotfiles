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
        curl -fsSL https://install.julialang.org | sh -s -- --yes --add-to-path no
    fi

[private]
update-julia:
    -juliaup update

install-pkgs:
    -julia --threads=auto ~/.julia/config/packages.jl

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
new-package-sph name dir="~/src/JuliaSpacePhysics":
    #!/usr/bin/env -S julia --threads=auto
    using PkgTemplates
    Template(; 
        user="JuliaSpacePhysics",
        dir="{{ dir }}",
        julia=v"1.10", 
        plugins=[
            Tests(; project=true, aqua=true),
            GitHubActions(; 
                file="/Users/zijin/src/JuliaSpacePhysics/juliaspacephysics.github.io/templates/github/workflows/CI.yml",
            ),
            Codecov(),
            Documenter{GitHubActions}(),
        ]
    )("{{ name }}")

# Focused tests, plain julia (cold start). Filters @testitem/@testset by name.
[no-cd]
test filter="" flags="":
    julia {{ flags }} --project=test ~/scripts/focused_test.jl "{{ filter }}"

# Focused tests via repld (persistent session — fast re-runs). Same script, layered.
[no-cd]
fast-test filter="" flags="":
    repld julia {{ flags }} --project=test -- ~/scripts/focused_test.jl "{{ filter }}"

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
    # The version bump lands in @ (which may carry release edits, e.g. changelog), so @ must stay
    # the same change, a child of the CI-checked commit on main's line.
    parent=$(jj log -r @- --no-graph -T commit_id)
    release=$(jj log -r @ --no-graph -T change_id)
    check_wc() {
        [ -n "$(jj log -r "$parent & main::" --no-graph -T commit_id)" ] || { echo "❌ @- is not main or a descendant of it"; exit 1; }
        [ "$(jj log -r @ --no-graph -T change_id)" = "$release" ] || { echo "❌ @ switched away from the release change"; exit 1; }
        [ "$(jj log -r @- --no-graph -T commit_id)" = "$parent" ] || { echo "❌ @- changed while waiting for CI"; exit 1; }
    }
    check_wc
    repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
    ci=$(gh run list -R "$repo" -c "$parent" --json databaseId,workflowName,status,conclusion \
        -q '[.[] | select(.workflowName == "CI")][0]')
    if [ -z "$ci" ]; then
        echo "⚠️  No CI run for $(echo "$parent" | cut -c1-8); releasing unchecked"
    else
        id=$(echo "$ci" | jq -r .databaseId)
        [ "$(echo "$ci" | jq -r .status)" = completed ] || gh run watch -R "$repo" "$id" --exit-status >/dev/null || true
        conclusion=$(gh run view -R "$repo" "$id" --json conclusion -q .conclusion)
        if [ "$conclusion" != success ]; then
            echo "❌ CI $conclusion on release base: https://github.com/$repo/actions/runs/$id"
            exit 1
        fi
    fi
    check_wc
    version=$(sed -n 's/^version = "\(.*\)"$/\1/p' Project.toml)
    IFS=. ; set -- ${version%%[-+]*}; unset IFS
    major=$1 minor=$2 patch=$3
    case "$bump_type" in
        major) new_version="$((major + 1)).0.0" ;;
        minor) new_version="$major.$((minor + 1)).0" ;;
        patch) new_version="$major.$minor.$((patch + 1))" ;;
        *) echo "unknown bump type: $bump_type"; exit 1 ;;
    esac
    sed -i "s/^version = \"$version\"$/version = \"$new_version\"/" Project.toml
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
