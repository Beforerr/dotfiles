#!/bin/bash

# mackup
pipx install mackup

# Python environment
pipx install nbqa
pipx install black
pipx install isort
pipx inject nbqa isort
pipx inject nbqa black

pipx install thefuck
