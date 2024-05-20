#!/usr/bin/env zsh -i

if command -v conda &> /dev/null; then
    conda env create --file .conda/base.yml
fi