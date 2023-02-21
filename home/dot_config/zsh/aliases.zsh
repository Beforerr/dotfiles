# Shortcuts for common commands 
colorflag="-G"
alias l="ls -lF ${colorflag}"
alias la="ls -lAF ${colorflag}"
alias ll="ls -lAF ${colorflag}"
alias ls="ls -G"

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

# Home manager
alias hm="home-manager"
alias hms="home-manager switch"
alias hme="home-manager edit"

# Chezmoi
alias cm="chezmoi"
alias cma="chezmoi apply"
alias cmr="chezmoi re-add"
alias cme="chezmoi edit"
