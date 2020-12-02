limit coredumpsize 0
bindkey -d

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
            tmux_login_shell=$(which zsh)
            tmux_config=$(cat ~/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l' $tmux_login_shell'"'))
            tmux_config+='\nbind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"'
            tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
        else
            tmux new-session && echo "tmux created new session"
        fi
    fi
}

tmux_automatically_attach_session

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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
