terminfo_down_sc=$terminfo[cud1]$terminfo[cuu1]$terminfo[sc]$terminfo[cud1]
left_down_prompt_preexec() {
    print -rn -- $terminfo[el]
}
add-zsh-hook preexec left_down_prompt_preexec
function zle-keymap-select zle-line-init zle-line-finish {
    case $KEYMAP in
        main|viins)
            PROMPT_2="$fg[cyan]-- INSERT --$reset_color"
            ;;
        vicmd)
            PROMPT_2="$fg[green]-- NORMAL --$reset_color"
            ;;
    esac
    PROMPT="%{$terminfo_down_sc$PROMPT_2$terminfo[rc]%}%(?.%{${fg[green]}%}.%{${fg[red]}%})${HOST}%{${reset_color}%} %# "
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select
zle -N edit-command-line

PROMPT="%{$terminfo_down_sc$PROMPT_2$terminfo[rc]%}%(?.%{${fg[green]}%}.%{${fg[red]}%})${HOST}%{${reset_color}%} %# "

# Right PROMPT
#
setopt prompt_subst
# Automatically hidden rprompt
# however,
setopt transient_rprompt

r-prompt() {
    # pyenv
    env=''
    if has "pyenv"; then
        env='(%{'${fg[yellow]}'%}'`pyenv version-name`'%{'${reset_color}'%})'
    fi
    # git
    if [ `__git_ps1 $?` ]; then
        export GIT_PS1_SHOWDIRTYSTATE=1
        export GIT_PS1_SHOWSTASHSTATE=1
        export GIT_PS1_SHOWUNTRACKEDFILES=1
        export GIT_PS1_SHOWUPSTREAM="auto"
        export GIT_PS1_DESCRIBE_STYLE="branch"
        export GIT_PS1_SHOWCOLORHINTS=0
        RPROMPT='$env '
        RPROMPT+='(%{'${fg[red]}'%}'`echo $(__git_ps1 "%s")|sed -e s/%/%%/|sed -e s/%%%/%%/|sed -e 's/\\$/\\\\$/'`'%{'${reset_color}'%})'
        RPROMPT+=$' [%{${fg[blue]}%}%~%{${reset_color}%}]'
        RPROMPT+='${p_buffer_stack}'
    else
        RPROMPT='$env [%{$fg[blue]%}%~%{$reset_color%}]'
    fi
}
add-zsh-hook precmd r-prompt

# Other PROMPT
#
SPROMPT="%{${fg[red]}%}Did you mean?: %R -> %r [nyae]? %{${reset_color}%}"
