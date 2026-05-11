mod? julia
mod? rust
mod? R

install language:
    just {{ language }} install

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
