install-spack:
    #!/usr/bin/env sh
    echo "Installing 'spack' package manager..."
    if ! command -v spack; then
        git clone -c feature.manyFiles=true https://github.com/spack/spack.git
        . spack/share/spack/setup-env.sh
    fi
