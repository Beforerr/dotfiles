#!/bin/bash

function _setup_emacs() {
    echo "Setting up 'emacs'"
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install
}

function _setup_nvim() {
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    # remove template's git connection to set up your own later
    rm -rf ~/.config/nvim/.git
}