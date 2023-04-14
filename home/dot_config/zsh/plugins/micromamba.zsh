init_conda() {
    # >>> mamba initialize >>>
    # !! Contents within this block are managed by 'mamba init' !!
    export MAMBA_EXE="/Users/zijin/.nix-profile/bin/micromamba";
    export MAMBA_ROOT_PREFIX="/Users/zijin/micromamba";
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__mamba_setup"
    else
        if [ -f "/Users/zijin/micromamba/etc/profile.d/micromamba.sh" ]; then
            . "/Users/zijin/micromamba/etc/profile.d/micromamba.sh"
        else
            export  PATH="/Users/zijin/micromamba/bin:$PATH"  # extra space after export prevents interference from conda init
        fi
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<
}

init_conda_x86() {
    alias iconda='/Users/zijin/mambaforge_x86/bin/conda' 
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/Users/zijin/mambaforge_x86/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/Users/zijin/mambaforge_x86/etc/profile.d/conda.sh" ]; then
            . "/Users/zijin/mambaforge_x86/etc/profile.d/conda.sh"
        else
            export PATH="/Users/zijin/mambaforge_x86/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
}


# init conda based on arch
if [[ $(uname -m) == 'x86_64' ]]; then
    init_conda_x86
    echo "conda x86_64 is activated"
else
    init_conda
    echo "conda m1 is activated"
fi