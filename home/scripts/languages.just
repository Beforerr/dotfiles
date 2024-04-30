import? 'julia.just'
# mod? julia

install language:
  just install-{{ language }}

install-rust:
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

install-R:
  command -v R || brew install --cask r

# check programming language versions (ignoring errors)
check-versions:
  -python3 --version
  -node --version
  -julia --version

install-spack:
  #!/usr/bin/env sh
  echo "Installing 'spack' package manager..."
  if ! command -v spack; then
    git clone -c feature.manyFiles=true https://github.com/spack/spack.git
    . spack/share/spack/setup-env.sh
  fi

install-zoxide:
  #!/usr/bin/env sh
  command -v zoxide || curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
