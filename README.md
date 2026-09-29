# macOS Setup

## Introducation

- Dotfiles are managed by [chezmoi](https://www.chezmoi.io/);
- Use `Homebrew` for CLI tools and apps via [Brewfile](./home/packages/Brewfile); unlisted formulae are removed on apply, unlisted casks are kept;
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

## Apps

### Karabiner-Elements

Customize keyboard mappings.

[](~/.config/)

### Zotero

Install beta version and login to sync.

#### Extensions

- [windingwind/zotero-actions-tags](https://github.com/windingwind/zotero-actions-tags) - Customize your Zotero workflow.
  - [[Share] Copy Zotero link · Discussion #115](https://github.com/windingwind/zotero-actions-tags/discussions/115)
    - [discussioncomment](https://github.com/windingwind/zotero-actions-tags/discussions/115#discussioncomment-8731031)

### Browser

#### Extensions

- Surfingkeys settings - [gistfile](https://gist.githubusercontent.com/Beforerr/6a618d442ca37ec061c9cf012784a643/raw/e28248821f255370d8383e456c179aa18026cf89/gistfile.txt)

## Atuin

> ✨ Magical shell history

[Setting up Sync](https://docs.atuin.sh/guide/sync/)

```bash
atuin register -u Beforerr -e zzj956959688@gmail.com
atuin key
atuin login -u Beforerr
```
## Languages

- [Julia](https://julialang.org/) (via `juliaup`)
- [Python](https://www.python.org/) (via `uv` / `pixi`)
- [Rust](https://www.rust-lang.org/) (via `rustup`)

## Notes

- [zsh - What should/shouldn't go in .zshenv, .zshrc, .zlogin, .zprofile, .zlogout? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout)
