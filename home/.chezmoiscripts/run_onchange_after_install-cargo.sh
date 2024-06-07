#!/bin/bash

command -v rustup || rustup default stable

if command -v cargo &> /dev/null; then
    cargo install garden-tools
fi