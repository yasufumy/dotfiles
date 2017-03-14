limit coredumpsize 0
bindkey -d

if [[ -f ~/.zplug/init.zsh ]]; then
    export ZPLUG_LOADFILE="$HOME/.zsh/zplug.zsh"
    source ~/.zplug/init.zsh

    #if ! zplug check --verbose; then
    #    printf "Install? [y/N]: "
    #    if read -q; then
    #        echo; zplug install
    #    else
    #        echo
    #    fi
    #fi
    zplug load
fi
