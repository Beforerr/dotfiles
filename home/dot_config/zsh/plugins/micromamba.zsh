# >>> mamba initialize >>>
# # !! Contents within this block are managed by 'mamba init' !!
# export MAMBA_EXE="/Users/zijin/.nix-profile/bin/micromamba";
export MAMBA_ROOT_PREFIX="/Users/zijin/conda";
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    if [ -f "/Users/zijin/conda/etc/profile.d/micromamba.sh" ]; then
        . "/Users/zijin/conda/etc/profile.d/micromamba.sh"
    else
        export  PATH="/Users/zijin/conda/bin:$PATH"  # extra space after export prevents interference from conda init
    fi
fi
unset __mamba_setup
# <<< mamba initialize <<<
