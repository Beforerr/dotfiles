#!/bin/sh

set -e # -e: exit on error

echo "Installing chezmoi..."
if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$bin_dir" init --apply "Beforerr"
  else
    echo "To install chezmoi, you must have curl installed." >&2
    exit 1
  fi
fi
echo "Done."
echo "Running post-installation scripts..."