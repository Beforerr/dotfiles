{ ... }:

{
  # Shared shell configuration
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = ".config/zsh";
    envExtra = ''
      export JULIA_MAX_NUM_PRECOMPILE_FILES=3
    '';
    initExtraFirst = "source $HOME/.zshrc";
    completionInit = "";   # ~/.zshrc runs the (cached) compinit; suppress home-manager's
    profileExtra = ''eval "$(/opt/homebrew/bin/brew shellenv)"'';
  };
}
