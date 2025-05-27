#!/bin/bash
if command -v uv &>/dev/null; then
    # Python environment
    uv tool install pdfcropmargins
    uv tool install nbdev
    uv tool install pylatexenc
fi
