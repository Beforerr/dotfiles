{ ... }:

{
  # Shared shell configuration
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = ".config/zsh";
    initExtraFirst = "source $HOME/.zshrc";
    completionInit = "";   # ~/.zshrc runs the (cached) compinit; suppress home-manager's
  };
}
