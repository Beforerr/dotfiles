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
    zplug = {
      enable = true;
      plugins = [
        { name = "plugins/aliases"; tags = ["from:oh-my-zsh"];}
        { name = "plugins/brew"; tags = ["from:oh-my-zsh"];} # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/brew
        { name = "plugins/git"; tags = ["from:oh-my-zsh"];}
        { name = "hlissner/zsh-autopair"; tags = ["defer:2"];}
        { name = "~/.config/zsh/plugins"; tags = ["from:local"];}
      ];
      };
    };
}
