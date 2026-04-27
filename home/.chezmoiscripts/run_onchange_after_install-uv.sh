#!/bin/bash
curl -LsSf https://astral.sh/uv/install.sh | sh

if command -v uv &>/dev/null; then
    # Python environment
    uv tool install pdfcropmargins
    uv tool install nbdev
    uv tool install pylatexenc
fi
