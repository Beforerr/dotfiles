#!/bin/bash

echo "Installing 'brew' package manager..."
if ! command -v brew; then
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | NONINTERACTIVE=1 bash
fi
