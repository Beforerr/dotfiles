function alias_helper() {
    if command -v $2 >/dev/null; then
        alias $1=$2
    fi
}

# Shortcuts for common commands
if command -v eza >/dev/null; then
    alias ls=eza
    alias la="eza -a"
    alias ll="eza -l"
    alias lla="eza -la"
    alias lt="eza --tree"
else
    colorflag="-G"
    alias l="ls -lF ${colorflag}"
    alias la="ls -lAF ${colorflag}"
    alias ll="ls -lAF ${colorflag}"
    alias ls="ls -G"
fi

# alias_helper cat bat

# Easier navigation
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Directories
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias p="cd ~/projects"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Editors
alias_helper s subl
alias_helper v nvim

# Homebrew
alias b="brew"
alias bb="brew bundle"

# yazi, cd to its last dir on exit
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Chezmoi
alias cm="chezmoi"
alias cma="chezmoi apply"
alias cmr="chezmoi re-add"
alias cme="chezmoi edit"

alias j="just"
alias .j='just --justfile ~/justfile --working-directory .'

alias jl="julia --threads=auto --project"

alias jgf="jj git fetch"
alias jgp="jj git push"
alias jgpc="jj git push -c @"
alias jgpr="jj git push -c @; .j create-pr"
alias js="jj status"
alias jjs="jj squash"

# Claude
# Claude Code only reads .claude/settings.json at the project root; pass the nearest ancestor's (below $HOME) too.
claude() {
  local d=${PWD:h}
  while [[ $d == $HOME/?* ]]; do
    [[ -f $d/.claude/settings.json ]] && { command claude --settings $d/.claude/settings.json "$@"; return }
    d=${d:h}
  done
  command claude "$@"
}
alias c="claude --dangerously-skip-permissions"
alias cc="claude --dangerously-skip-permissions -c"
alias csy="CLAUDE_CONFIG_DIR=~/.claude-wsy claude --dangerously-skip-permissions"
alias cwk="CLAUDE_CONFIG_DIR=~/.claude-zwk claude --dangerously-skip-permissions"
