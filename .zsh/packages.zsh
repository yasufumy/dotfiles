has_plugin() {
    (( $+functions[zplug] )) || return 1
    zplug check "${1:?too few arguments}"
    return $status
}

zplug "zplug/zplug"

zplug "~/.zsh",  \
    from:local,  \
    nice:1,  \
    use:"*.sh"

zplug "zsh-users/zsh-completions"

zplug "zsh-users/zsh-history-substring-search"

zplug "zsh-users/zsh-syntax-highlighting",  \
    nice:19
