#!/bin/bash
if command -v uv &>/dev/null; then
    # Python environment
    uv tool install pdfcropmargins
fi
