export PATH="$PATH:/Users/zijin/.local/bin"

if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

eval $(thefuck --alias)

if [ -f "$HOME/spack/share/spack/setup-env.sh" ]; then
    . $HOME/spack/share/spack/setup-env.sh
fi

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE='/Users/zijin/.local/bin/micromamba';
export MAMBA_ROOT_PREFIX='/Users/zijin/micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/zijin/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/zijin/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/zijin/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/zijin/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/Users/zijin/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<
