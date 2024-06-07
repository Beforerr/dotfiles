#!/bin/bash

echo "Installing 'brew' package manager..."
if ! command -v brew; then
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | NONINTERACTIVE=1 bash
fi

echo "Installing packages with 'brew'..."
if command -v brew; then
    brew bundle --file="$HOME/Brewfile"
else
    echo "Brew is not installed. Please install it first."
fi

echo "Setting up 'yabai'"
chmod +x $HOME/.config/yabai/yabairc
