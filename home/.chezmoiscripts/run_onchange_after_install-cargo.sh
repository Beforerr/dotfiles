#!/bin/bash

export PATH="$HOME/.cargo/bin:$PATH"

command -v rustup >/dev/null || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
command -v cargo-binstall >/dev/null || curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

cargo binstall --no-confirm --strategies crate-meta-data jj-cli
