#!/bin/bash

# Native installer rather than the brew cask: it self-updates, the cask lags releases.
if ! command -v claude &>/dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
fi
