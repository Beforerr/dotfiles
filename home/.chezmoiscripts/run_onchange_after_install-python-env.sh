#!/bin/bash
# env.yml hash: {{ include "env.yml" | sha256sum }}
micromamba create -f $(chezmoi source-path)/env.yml -y