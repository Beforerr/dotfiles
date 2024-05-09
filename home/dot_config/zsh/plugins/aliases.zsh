function alias_helper() {
	# Safely Create an alias for a command
	# Usage: alias_helper <alias_name> <command>
	# Example: alias_helper c code
	if command -v $2 >/dev/null; then
		alias $1=$2
	fi
}

# Shortcuts for common commands 
if command -v exa >/dev/null; then
else
	colorflag="-G"
	alias l="ls -lF ${colorflag}"
	alias la="ls -lAF ${colorflag}"
	alias ll="ls -lAF ${colorflag}"
	alias ls="ls -G"
fi


alias_helper cat bat

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
alias c="code"
alias s="subl"
alias v="nvim"

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

# Micromamba
alias m="micromamba"
alias_helper conda micromamba
alias_helper mamba micromamba

alias j="just"