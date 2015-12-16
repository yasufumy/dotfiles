fpath=(/usr/local/share/zsh/site-functions(N-/) $fpath)

# autoload
autoload -U  run-help
autoload -Uz add-zsh-hook
autoload -Uz cdr
autoload -Uz colors; colors
autoload -Uz compinit; compinit -u
autoload -Uz is-at-least
autoload -Uz history-search-end
autoload -Uz modify-current-argument
autoload -Uz smart-insert-last-word
autoload -Uz terminfo
autoload -Uz vcs_info
autoload -Uz zcalc
autoload -Uz zmv
autoload     run-help-git
autoload     run-help-svk
autoload     run-help-svn

antigen=~/.antigen
antigen_plugins=(
    "bobthecow/git-flow-completion"
    "zsh-users/zsh-completions"
    "zsh-users/zsh-history-substring-search"
    "zsh-users/zsh-syntax-highlighting"
)
### initialize ###
# is_exists returns true if executable $1 exists in $PATH
function is_exists() {
    type "$1" >/dev/null 2>&1; return $?;
}
# has is wrapper function
function has() {
    is_exists "$@"
}

function is_osx() { [[ $OSTYPE == darwin* ]]; }

function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }

function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }

function shell_has_started_interactively() { [ ! -z "$PS1" ]; }

function is_ssh_running() { [ ! -z "$SSH_CONECTION" ]; }

function tmux_automatically_attach_session()
{
    if is_screen_or_tmux_running; then
        ! is_exists 'tmux' && return 1
    else
        if shell_has_started_interactively && ! is_ssh_running; then
            if ! is_exists 'tmux'; then
                echo 'Error: tmux command not found' 2>&1
                return 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && is_exists 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}
setup_bundles() {
    echo -e "$fg[blue]Starting $SHELL....$reset_color\n"

    modules() {
        local -a modules_path
        modules_path=(
            ~/.zsh/*.(sh|zsh)
        )

        local f
        for f ($modules_path) source "$f" && echo "loading $f"
    }

    # has_plugin returns true if $1 plugin are installed and available
    has_plugin() {
        (( ${antigen_plugins[(I)${${(M)1:#*/*}:-"*"/${1#*/}}|${1#*/}]} ))
        return $status
    }

    # bundle_install installs antigen and runs bundles command
    bundle_install() {
        git clone https://github.com/zsh-users/antigen $antigen
        bundles
    }

    # bundles checks if antigen plugins are valid and available
    bundles() {
        if [[ -f $antigen/antigen.zsh ]]; then
            source $antigen/antigen.zsh

            # check plugins installed by antigen
            local p
            for p in ${antigen_plugins[@]}
            do
                echo "checking... $p"
                antigen-bundle "$p"
            done

            # apply antigen
            antigen-apply
        else
            echo "$fg[red]To make your shell strong, run 'bundle_install'.$reset_color"
        fi
    }

    bundles; echo
    modules; echo
}

zsh_startup() {
    # tmux
    tmux_automatically_attach_session
    # setup_bundles return true if antigen plugins and some modules are valid
    setup_bundles || return 1
}

if zsh_startup; then
    # Important
    zstyle ':completion:*:default' menu select=2

    # Completing Groping
    zstyle ':completion:*:options' description 'yes'
    zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'
    zstyle ':completion:*' group-name ''

    # Completing misc
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
    zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'
    zstyle ':completion:*' use-cache true
    zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

    # Directory
    zstyle ':completion:*:cd:*' ignore-parents parent pwd
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

    # default:
    zstyle ':completion:*' list-separator '-->'
    zstyle ':completion:*:manuals' separate-sections true

    ### alias ###
    # default command
    alias ls="ls -G"
    alias rm="rm -iv"
    alias mv="mv -iv"
    alias cp="cp -iv"
    alias purge="sudo purge"
    alias grep="grep --color"

    # git
    alias gst="git status"
    alias gad="git add"
    alias gci="git commit -a --allow-empty-message -m ''"
    alias gph="git push"
    alias gpl="git pull"
    alias gcim="git commit -m"
    alias gbr="git branch"
    alias gco="git checkout"
    alias glg="git log --graph"

    # matlab
    alias matlab="/Applications/MATLAB_R2015a.app/bin/matlab -nosplash -nodisplay"

    # update
    alias brew-cask-upgrade="for c in \`brew cask list\`; do ! brew cask info \$c | grep -qF 'Not installed' || brew cask install \$c; done"
    alias update-all="brew update && brew upgrade --all && brew cleanup && brew cask update && brew cask cleanup && softwareupdate -ia"
    alias pip-update="pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U"
    ### PROMPT ###
    #
    terminfo_down_sc=$terminfo[cud1]$terminfo[cuu1]$terminfo[sc]$terminfo[cud1]
    left_down_prompt_preexec() {
        print -rn -- $terminfo[el]
    }
    add-zsh-hook preexec left_down_prompt_preexec
    function zle-keymap-select zle-line-init zle-line-finish {
        case $KEYMAP in
            main|viins)
                PROMPT_2="$fg[black]-- INSERT --$reset_color"
                ;;
            vicmd)
                PROMPT_2="$fg[white]-- NORMAL --$reset_color"
                ;;
            vivis|vivli)
                PROMPT_2="$fg[yellow]-- VISUAL --$reset_color"
                ;;
            virep)
                PROMPT_2="$fg[red]-- REPLACE --$reset_color"
                ;;
        esac
        PROMPT="%{$terminfo_down_sc$PROMPT_2$terminfo[rc]%}[%(?.%{${fg[green]}%}.%{${fg[red]}%})${HOST}%{${reset_color}%}]%# "
        zle reset-prompt
    }

    zle -N zle-line-init
    zle -N zle-line-finish
    zle -N zle-keymap-select
    zle -N edit-command-line

    PROMPT="%{$terminfo_down_sc$PROMPT_2$terminfo[rc]%}[%(?.%{${fg[green]}%}.%{${fg[red]}%})${HOST}%{${reset_color}%}]%# "

    # Right PROMPT
    #
    setopt prompt_subst
    # Automatically hidden rprompt
    # however,
    setopt transient_rprompt

    r-prompt() {
        # pyenv
        if ! [ -z $VIRTUAL_ENV ]; then
            env='('`echo $(basename $VIRTUAL_ENV)`')'
        else
            env=''
        fi
        # git
        if has '__git_ps1'; then
            export GIT_PS1_SHOWDIRTYSTATE=1
            export GIT_PS1_SHOWSTASHSTATE=1
            export GIT_PS1_SHOWUNTRACKEDFILES=1
            export GIT_PS1_SHOWUPSTREAM="auto"
            export GIT_PS1_DESCRIBE_STYLE="branch"
            export GIT_PS1_SHOWCOLORHINTS=0
            RPROMPT='%{'${fg[red]}'%}'`echo $(__git_ps1 "(%s)")|sed -e s/%/%%/|sed -e s/%%%/%%/|sed -e 's/\\$/\\\\$/'`'%{'${reset_color}'%}'
            RPROMPT+=$' [%{${fg[blue]}%}%~$env%{${reset_color}%}]'
            RPROMPT+='${p_buffer_stack}'
        else
            RPROMPT='[%{$fg[blue]%}%~$env%{$reset_color%}]'
        fi
    }
    add-zsh-hook precmd r-prompt

    # Other PROMPT
    #
    SPROMPT="%{${fg[red]}%}Did you mean?: %R -> %r [nyae]? %{${reset_color}%}"
fi
