# macOS Setup

## Introducation

- Dotfiles are managed by [chezmoi](https://www.chezmoi.io/) and Nix;
- Use Nix for packages & command line tools;
- Use Homebrew exclusively for casks (applications);
- Sync application settings with [mackup](https://github.com/lra/mackup).

## Installation

First we need to get command line tools, we can do that by installing `Homebrew`.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

One-line install:

```bash
curl https://raw.githubusercontent.com/Beforerr/dotfiles/main/install.sh | bash
```