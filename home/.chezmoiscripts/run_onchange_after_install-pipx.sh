#!/bin/bash

pipx install mackup


echo "Syncing applications with 'mackup'..."
if command -v mackup; then
    mackup restore
else
    echo "Mackup is not installed. Please install it first."
fi