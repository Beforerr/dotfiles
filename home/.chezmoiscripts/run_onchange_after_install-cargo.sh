#!/bin/bash

command -v rustup || rustup default stable
command -v cargo binstall || curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

if command -v cargo &>/dev/null; then
    cargo install garden-tools
fi

if command -v cargo binstall &>/dev/null; then
    cargo binstall --strategies crate-meta-data jj-cli
fi
