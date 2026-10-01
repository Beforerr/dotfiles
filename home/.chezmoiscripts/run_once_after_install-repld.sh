#!/bin/bash
command -v repld &>/dev/null || [ -x "$HOME/.local/bin/repld" ] || curl -fsSL https://raw.githubusercontent.com/Beforerr/repld/main/install.sh | bash
