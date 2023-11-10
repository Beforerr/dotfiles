#!/bin/bash

# mackup
pipx install mackup

echo "Syncing applications with 'mackup'..."
if command -v mackup; then
    mackup restore
else
    echo "Mackup is not installed. Please install it first."
fi

# Python environment
pipx install black
pipx install isort
pipx install nbqa
pipx inject nbqa isort

pipx install thefuck
