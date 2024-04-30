#!/bin/bash

if ! command -v micromamba; then
	echo "Installing 'micromamba' package manager..."
	"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
fi

# Notes: With the release of Miniforge3-22.3.1-0, that incorporated the changes in #277, the packages and configuration of Mambaforge and Miniforge3 are now identical. 
function _install_conda() {
	echo "Installing 'conda' package manager..."
	curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
	bash Miniforge3-$(uname)-$(uname -m).sh -b
	rm Miniforge3-$(uname)-$(uname -m).sh
}

if [[ $INSTALL_CONDA ]]; then
	command -v conda || install_conda
fi
