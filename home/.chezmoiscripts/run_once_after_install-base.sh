#!/bin/bash

# Notes: With the release of Miniforge3-22.3.1-0, that incorporated the changes in #277, the packages and configuration of Mambaforge and Miniforge3 are now identical. 
echo "Installing 'miniforge' package manager..."
if ! command -v conda; then
	curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
	bash Miniforge3-$(uname)-$(uname -m).sh -b
fi

# Notes
echo "Installing 'micromamba' package manager..."
if ! command -v micromamba; then
	"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
fi