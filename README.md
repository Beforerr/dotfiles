# macOS Setup

## Introducation

- Dotfiles are managed by [chezmoi](https://www.chezmoi.io/) and Nix;
- Use Nix for packages & command line tools;
- Use Homebrew exclusively for casks (applications);
- Sync application settings with [mackup](https://github.com/lra/mackup).
- Use [just](https://just.systems) for automation (see [Justfile](./home/justfile)).

## General setup

First we need to get command line tools, we can do that by installing `Homebrew`.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

One-line install:

```bash
curl https://raw.githubusercontent.com/Beforerr/dotfiles/main/install.sh | bash
```

Note we need to restart the terminal after the installation of `nix`, so the script will fail on the first run as expected.

## Apps

#### Zotero

Install beta version and login to sync.