# Check rustc and cargo versions
default:
    -rustc --version
    -cargo --version

install:
    command -v rustup || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rustup default stable
