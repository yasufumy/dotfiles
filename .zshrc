typeset -gx -U fpath
fpath=( \
    ~/.zsh/completion(N-/) \
    /usr/local/share/zsh/site-functions(N-/) \
    $fpath \
    )

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
bindkey -v
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
function is_linux() { [[ $OSTYPE == linux* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }

function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }

function shell_has_started_interactively() { [ ! -z "$PS1" ]; }

function is_ssh_running() { [ ! -z "$SSH_CONNECTION" ]; }

function tmux_automatically_attach_session() {
    is_ssh_running && return

    if is_screen_or_tmux_running; then
        if is_tmux_runnning; then
            export DISPLAY="$TMUX"
        elif is_screen_running; then
            # For GNU screen
        fi
    else
        #if shell_has_started_interactively && ! is_ssh_running; then
        if ! is_ssh_running; then
            if ! has "tmux"; then
                echo "tmux not found" 1>&2
                exit 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions | perl -pe 's/(^.*?):/\033[31m$1:\033[m/'
                echo -n "Tmux: attach? (y/N num/session-name) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        exit
                    fi
                elif tmux list-sessions | grep -q "^$REPLY:"; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        exit
                    fi
                fi
            fi

            tmux new-session && echo "tmux created new session"
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
    if is_linux; then
        alias ls="ls --color -F"
    elif is_osx; then
        alias ls="ls -GF"
    fi
    alias ll="ls -lF"
    alias la="ls -aF"
    alias lla="ls -alF"
    alias rm="rm -iv"
    alias mv="mv -iv"
    alias cp="cp -iv"
    alias purge="sudo purge"
    alias grep="grep --color"

    # vim
    alias vi="vim"

    # git
    alias gst="git status"
    alias gsth="git stash"
    alias gad="git add"
    alias gcino="git commit -a --allow-empty-message -m ''"
    alias gci="git commit"
    alias gcim="git commit -m"
    alias gph="git push"
    alias gpl="git pull"
    alias gbr="git branch"
    alias gco="git checkout"
    alias glg="git graph"
    alias gfl="git-flow"
    alias gdf="git diff"
    alias gmrg="git merge"
    alias grb="git rebase"

    # labnet
    alias labnet="ssh -N -f -L localhost:8088:sara:80 yasufumi@peter.pi.titech.ac.jp"

    # update
    alias brew-cask-upgrade="for c in \`brew cask list\`; do ! brew cask info \$c | grep -qF 'Not installed' || brew cask install \$c; done"
    alias update-all="brew update && brew upgrade --all && brew cleanup && brew cask update && brew-cask-upgrade && brew cask cleanup && softwareupdate -ia"
    alias pip-update="pip install --upgrade pip; pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U"
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
                PROMPT_2="$fg[cyan]-- INSERT --$reset_color"
                ;;
            vicmd)
                PROMPT_2="$fg[green]-- NORMAL --$reset_color"
                ;;
        esac
        if is_ssh_running; then
            PROMPT="%{$terminfo_down_sc$PROMPT_2$terminfo[rc]%}%(?.%{${fg[green]}%}.%{${fg[red]}%})${HOST}%{${reset_color}%} %# "
        else
            PROMPT="%{$terminfo_down_sc$PROMPT_2$terminfo[rc]%}%# "
        fi
        zle reset-prompt
    }

    zle -N zle-line-init
    zle -N zle-line-finish
    zle -N zle-keymap-select
    zle -N edit-command-line

    if is_ssh_running; then
        PROMPT="%{$terminfo_down_sc$PROMPT_2$terminfo[rc]%}%(?.%{${fg[green]}%}.%{${fg[red]}%})${HOST}%{${reset_color}%} %# "
    else
        PROMPT="%{$terminfo_down_sc$PROMPT_2$terminfo[rc]%}%# "
    fi

    # Right PROMPT
    #
    setopt prompt_subst
    # Automatically hidden rprompt
    # however,
    setopt transient_rprompt

    r-prompt() {
        # pyenv
        if ! [ -z $VIRTUAL_ENV ]; then
            env='|'`echo $(basename $VIRTUAL_ENV)`
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

    # setup pyenv
    if [[ -x "${HOME}/.pyenv/bin/pyenv" ]]; then
        # For git-cloned pyenv.
        export PYENV_ROOT="${HOME}/.pyenv"
        path=(${PYENV_ROOT}/bin(N-/^W) ${path})
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
    elif (( $+commands[pyenv] )); then
        # For Homebrew installed pyenv.
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
    fi
fi
