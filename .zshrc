limit coredumpsize 0
bindkey -d

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
            :
        fi
    else
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

            if is_osx && has "reattach-to-user-namespace"; then
                tmux_login_shell=`which zsh`
                tmux_config=$(cat ~/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l' $tmux_login_shell'"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}

zsh_keybind() {
    ## Key bind
    bindkey -v

    # Add emacs-like keybind to viins mode
    bindkey -M viins '^F' forward-char
    bindkey -M viins '^B' backward-char
    bindkey -M viins '^P' up-line-or-history
    bindkey -M viins '^N' down-line-or-history
    bindkey -M viins '^A' beginning-of-line
    bindkey -M viins '^E' end-of-line
    bindkey -M viins '^K' kill-line
    bindkey -M viins '^R' history-incremental-pattern-search-backward
    bindkey -M viins '\er' history-incremental-pattern-search-forward
    bindkey -M viins '^Y' yank
    bindkey -M viins '^W' backward-kill-word
    bindkey -M viins '^U' backward-kill-line
    bindkey -M viins '^H' backward-delete-char
    bindkey -M viins '^?' backward-delete-char
    bindkey -M viins '^G' send-break
    bindkey -M viins '^D' delete-char-or-list

    bindkey -M vicmd '^A' beginning-of-line
    bindkey -M vicmd '^E' end-of-line
    bindkey -M vicmd '^K' kill-line
    bindkey -M vicmd '^P' up-line-or-history
    bindkey -M vicmd '^N' down-line-or-history
    bindkey -M vicmd '^Y' yank
    bindkey -M vicmd '^W' backward-kill-word
    bindkey -M vicmd '^U' backward-kill-line
    bindkey -M vicmd '/'  vi-history-search-forward
    bindkey -M vicmd '?'  vi-history-search-backward

    has 'history-substring-search-up' &&
        bindkey -M emacs '^P' history-substring-search-up
    has 'history-substring-search-down' &&
        bindkey -M emacs '^N' history-substring-search-down

    has 'history-substring-search-up' &&
        bindkey -M vicmd 'k' history-substring-search-up
    has 'history-substring-search-down' &&
        bindkey -M vicmd 'j' history-substring-search-down

    has 'history-substring-search-up' &&
        bindkey  '^P' history-substring-search-up
    has 'history-substring-search-down' &&
        bindkey  '^N' history-substring-search-down
}

zsh_alias() {
    if is_linux; then
        alias ls="ls --color -F"
    elif is_osx; then
        alias ls="ls -GF"
    fi
    alias ll="ls -lFh"
    alias la="ls -aF"
    alias lla="ls -alFh"
    alias rm="rm -iv"
    alias mv="mv -iv"
    alias cp="cp -iv"
    alias purge="sudo purge"
    alias grep="grep --color"

    # vim
    alias vi="vim"

    # disk
    alias du="du -h"
    alias df="df -h"

    # memory
    alias free="free -h"

    # python
    py() {
        test -z "$1" && ipython --no-confirm-exit --ext=autoreload --quick --no-banner|| command python "$@"
        #ipython -h >/dev/null 2>&1
        #if [[ $# -eq 0 && $? -eq 0 ]]; then
        #    command ipython
        #else
        #    command python "$@"
        #fi
    }
    alias python="py"

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
    alias gbrs="git branch -a"
    alias gco="git checkout"
    alias glg="git graph"
    alias gdf="git diff"
    alias gmrg="git merge"
    alias grb="git rebase"
    alias gsb="git submodule"
    alias grt="git remote"
    alias grm="git rm"
    alias grs="git reset"

    # labnet
    alias socks="scselect -n socks"
    alias tunnel="ssh -N -f -D 1080 lab"
    alias labnet="tunnel; socks"
    alias homenet="kill $(ps aux | grep 1080 | grep ssh | awk '{print $2}') 2>/dev/null; scselect -n default"

    # update
    alias brew-cask-upgrade="for c in \`brew cask list\`; do ! brew cask info \$c | grep -qF 'Not installed' || brew cask install \$c; done"
    alias update-all="brew update && brew upgrade&& brew cleanup && brew-cask-upgrade && brew cask cleanup && softwareupdate -ia"
    alias pip-update="pip install --upgrade pip; pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U"
}

zsh_prompt() {
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
        if ! [ -z $VIRTUAL_ENV ]; then
            env='(%{'${fg[yellow]}'%}'`echo $(basename $VIRTUAL_ENV)`'%{'${reset_color}'%})'
        else
            env=''
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
}

pyenv_setup() {
    # setup pyenv
    if [[ -x "${HOME}/.pyenv/bin/pyenv" ]]; then
        # For git-cloned pyenv.
        export PYENV_ROOT="${HOME}/.pyenv"
        path=(${PYENV_ROOT}/bin(N-/^W) ${path})
        eval "$(pyenv init - --no-rehash)"
        if [[ -x "${HOME}/.pyenv/plugins/pyenv-virtualenv/bin/pyenv-virtualenv" ]]; then
            eval "$(pyenv virtualenv-init - --no-rehash)"
        fi
    elif (( $+commands[pyenv] )); then
        # For Homebrew installed pyenv.
        eval "$(pyenv init - --no-rehash)"
        eval "$(pyenv virtualenv-init - --no-rehash)"
    fi
}

zsh_setopt() {
    # % Unknown command treat as arguments of cd
    setopt auto_cd
    setopt auto_pushd
    # Replace 'cd -' with 'cd +'
    setopt pushd_minus
    # Ignore duplicates to add to pushd
    setopt pushd_ignore_dups
    # pushd no arg == pushd $HOME
    setopt pushd_to_home
    # Check spell command
    setopt correct
    # Check spell all
    setopt correct_all
    # Automatically delete slash complemented by supplemented by inserting a space.
    setopt auto_remove_slash

    # Deploy {a-c} -> a b c
    setopt brace_ccl
    # Change
    #~$ echo 'hoge' \' 'fuga'
    # to
    #~$ echo 'hoge '' fuga'
    setopt rc_quotes
    # Automatically delete slash complemented by supplemented by inserting a space.
    setopt auto_remove_slash
    # Show exit status if it's except zero.
    #setopt print_exit_value
    # No Beep
    setopt no_beep
    setopt no_list_beep
    setopt no_hist_beep
    # Let me know immediately when terminating job
    setopt notify
    # Show process ID
    setopt long_list_jobs
    # Resume when executing the same name command as suspended process name
    setopt auto_resume
    # If the path is directory, add '/' to path tail when generating path by glob
    setopt mark_dirs
    # Automatically escape URL when copy and paste
    autoload -Uz url-quote-magic
    zle -N self-insert url-quote-magic
    # Show complition small
    setopt list_packed

    # Do not record an event that was just recorded again.
    setopt hist_ignore_dups
    # Delete an old recorded event if a new event is a duplicate.
    setopt hist_ignore_all_dups
    setopt hist_save_nodups
    # Expire a duplicate event first when trimming history.
    setopt hist_expire_dups_first
    # Do not display a previously found event.
    setopt hist_find_no_dups
    # Shere history
    setopt share_history
    # Pack extra blank
    setopt hist_reduce_blanks
    # Write to the history file immediately, not when the shell exits.
    setopt inc_append_history
    # Remove comannd of 'hostory' or 'fc -l' from history list
    setopt hist_no_store
    # Remove functions from history list
    setopt hist_no_functions
    # Record start and end time to history file
    setopt extended_history
    # Ignore the beginning space command to history file
    setopt hist_ignore_space
    # Append to history file
    setopt append_history
    # Edit history file during call history before executing
    setopt hist_verify
    # Enable history system like a Bash
    setopt bang_hist
}

zsh_misc() {
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

    # Menu select
    zmodload -i zsh/complist
    bindkey -M menuselect '^h' vi-backward-char
    bindkey -M menuselect '^j' vi-down-line-or-history
    bindkey -M menuselect '^k' vi-up-line-or-history
    bindkey -M menuselect '^l' vi-forward-char

    #autoload -Uz cdr
    autoload -Uz history-search-end
    autoload -Uz modify-current-argument
    autoload -Uz smart-insert-last-word
    autoload -Uz terminfo
    #autoload -Uz vcs_info
    #autoload -Uz zcalc
    autoload -Uz run-help-git
    autoload -Uz run-help-svk
    autoload -Uz run-help-svn
}

## start zsh

# attach tmux
tmux_automatically_attach_session

zsh_setopt

if [[ -f ~/.zplug/init.zsh ]]; then
    export ZPLUG_LOADFILE="$HOME/.zsh/packages.zsh"
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

# setup
zsh_keybind
zsh_alias
zsh_prompt
zsh_misc
pyenv_setup
