#!/bin/bash
if command -v pipx &> /dev/null; then
    # mackup
    pipx install mackup

    # Python environment
    pipx install nbdev
    pipx install nbqa
    pipx install black isort
    pipx inject nbqa isort
    pipx inject nbqa black

    pipx install thefuck

    pipx install segno # generate qr code
fi