# macOS Setup

## Introducation

- Dotfiles are managed by [chezmoi](https://www.chezmoi.io/) and Nix;
- Use `Nix` for packages & command line tools;
- Use `Homebrew` exclusively for casks (applications);
- Use [just](https://just.systems) for automation (see [Justfile](./home/justfile)).
- Sync application settings with [mackup](https://github.com/lra/mackup) (see [mackup.cfg](./home/private_dot_mackup.cfg)).
  - Note:
    - `mackup` is not used for syncing dotfiles, mostly for private application settings (such as `rclone`, `espanso` and so on).
    - It is better to specify the application settings in the `.mackup.cfg` file (whitelist instead of blacklist).
- Use [`Garden`](https://garden-rs.gitlab.io/index.html) for managing repositories

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

### Karabiner-Elements

Customize keyboard mappings.

[](~/.config/)

### Zotero

Install beta version and login to sync.

## Languages

- [Julia](https://julialang.org/) (via `juliaup`)
- [Python](https://www.python.org/) (via `mamba`)
- [R](https://www.r-project.org/) (via `brew`)
- [Rust](https://www.rust-lang.org/) (via `rustup`)

## Notes

- [zsh - What should/shouldn't go in .zshenv, .zshrc, .zlogin, .zprofile, .zlogout? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout)
