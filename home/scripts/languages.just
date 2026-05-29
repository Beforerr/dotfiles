mod? julia
mod? latex

[no-cd]
bump:
    #!/usr/bin/env sh
    if [ -f Project.toml ]; then
        just --justfile ~/justfile julia bump
    elif [ -f Cargo.toml ]; then
        just --justfile ~/justfile rust bump
    else
        echo "Unknown project language" && exit 1
    fi

[no-cd]
coverage:
    #!/usr/bin/env sh
    find . -name '*.cov' -delete
    if [ -f Project.toml ]; then
        julia --project=. --code-coverage=user test/runtests.jl
        julia --project=@temp -e 'using Pkg; Pkg.add("Coverage"; io=devnull); using Coverage; LCOV.writefile("lcov.info", process_folder("."))'
    else
        echo "No Project.toml found"
    fi
    genhtml lcov.info --output-directory coverage-html
    echo "Coverage report generated in coverage-html/index.html"
    find . -name '*.cov' -delete
    echo "Clean after: \`rm -rf lcov.info coverage-html\`"

[no-cd]
[private]
_bump-type:
    #!/usr/bin/env sh
    last_tag=$(git tag --sort=-version:refname | grep -E '^v[0-9]' | head -1)
    commits=$(git log "${last_tag:+${last_tag}..}HEAD" --format="%s%n%b")
    if echo "$commits" | grep -qE '^[a-z]+(\([^)]*\))?!:|^BREAKING CHANGE:'; then
        echo "minor"
    else
        echo "patch"
    fi

[no-cd]
check-bump:
    #!/usr/bin/env sh
    bump_type=$(just --justfile ~/justfile _bump-type)
    if [ "$bump_type" = "minor" ]; then
        last_tag=$(git tag --sort=-version:refname | grep -E '^v[0-9]' | head -1)
        git log "${last_tag:+${last_tag}..}HEAD" --format="%s%n%b" \
            | grep -E '^[a-z]+(\([^)]*\))?!:|^BREAKING CHANGE:' \
            | sed 's/^/  /; 1s/^  /minor: /'
    else
        echo "patch"
    fi
