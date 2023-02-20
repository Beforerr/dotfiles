#!/bin/zsh

echo "Installing Python using 'micromamba'..."
if ! command -v micromamba; then
	curl micro.mamba.pm/install.sh | zsh
fi