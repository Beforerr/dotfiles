#!/bin/bash

echo "Installing 'micromamba' package manager..."
if ! command -v micromamba; then
	"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
fi