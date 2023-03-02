# Shortcuts for common commands 
colorflag="-G"
alias l="ls -lF ${colorflag}"
alias la="ls -lAF ${colorflag}"
alias ll="ls -lAF ${colorflag}"
alias ls="ls -G"

if command -v cat; then
	alias cat="bat"
fi

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

# Sublime
alias s="subl"

# Homebrew
alias b="brew"
alias bb="brew bundle"

# Home manager
alias hm="home-manager"
alias hms="home-manager switch"
alias hme="home-manager edit"

# Chezmoi
alias cm="chezmoi"
alias cma="chezmoi apply"
alias cmr="chezmoi re-add"
alias cme="chezmoi edit"
alias cmcd="chezmoi cd"

# Micromamba
if command -v micromamba; then
	alias m="micromamba"
	alias mamba="micromamba"
	alias conda="micromamba"
fi