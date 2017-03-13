zplug "zplug/zplug", hook-build:'zplug --self-manage'

zplug "~/.zsh",  \
    from:local,  \
    use:"*sh"

zplug "zsh-users/zsh-completions"

zplug "zsh-users/zsh-history-substring-search"

zplug "zsh-users/zsh-autosuggestions"

zplug "zsh-users/zsh-syntax-highlighting",  \
    defer:2
