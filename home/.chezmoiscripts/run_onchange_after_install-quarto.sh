#!/bin/bash
export PATH="/opt/homebrew/bin:$PATH"
if command -v quarto; then
    quarto install tinytex
fi
