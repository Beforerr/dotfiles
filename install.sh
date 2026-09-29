#!/bin/sh

set -e

echo "Installing chezmoi..."
if ! command -v chezmoi >/dev/null; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply Beforerr
fi
echo "Done."
echo "Running post-installation scripts..."