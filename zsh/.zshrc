function is_exists() {
    type "$1" >/dev/null 2>&1; return $?;
}
function has() {
    is_exists "$@"
}

# Check OS
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_linux() { [[ $OSTYPE == linux* ]]; }

# Aliases
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
alias mkdir="mkdir -p"
alias purge="sudo purge"
alias grep="grep --color"

# vim
alias vi="vim"

# disk
alias du="du -h"
alias df="df -h"

# memory
alias free="free -h"

alias ipython="ipython --no-confirm-exit --no-banner --quick --ext=autoreload --InteractiveShellApp.exec_lines=\"%autoreload 2\""

# git
alias g="git"
alias gst="git status"
alias gsth="git stash"
alias gsthu="git stash -u"
alias gad="git add"
alias gadp="git add -p"
alias gcino="git commit -a --allow-empty-message -m ''"
alias gci="git commit"
alias gcim="git commit -m"
alias gph="git push"
alias gpl="git pull"
alias gbr="git branch"
alias gbra="git branch -a"
alias gbrd="git branch -d"
alias gbrm="git branch -m"
alias gco="git checkout"
alias gcob="git checkout -b"
alias glg="git graph"
alias gdf="git diff"
alias gmrg="git merge"
alias grb="git rebase"
alias grbi="git rebase -i"
alias gsb="git submodule"
alias grmt="git remote"
alias grmtv="git remote -v"
alias gmv="git mv"
alias grm="git rm"
alias grst="git reset"
alias gfch="git fetch"

# .gitignore command
function gi() {
    curl -sL https://www.gitignore.io/api/$@;
}

# Completion
autoload -U compinit
compinit
_comp_options+=(globdots)
# Important
zstyle ':completion:*:default' menu select=2

# Completing Groping
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format '%F{white}Completing %B%d%b%f'
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

# Keybindings
bindkey -d
bindkey -v

bindkey -M viins '^F' forward-char
bindkey -M viins '^B' backward-char
bindkey -M viins '^P' up-line-or-history
bindkey -M viins '^N' down-line-or-history
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
# bindkey -M viins '^R' history-incremental-pattern-search-backward
# bindkey -M viins '\er' history-incremental-pattern-search-forward
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

# Setopt
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
# autoload -Uz url-quote-magic
# zle -N self-insert url-quote-magic
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

# Setup pyenv if it exists
if [[ -x "${HOME}/.pyenv/bin/pyenv" ]]; then
    # For git-cloned pyenv.
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
fi
if has 'pyenv'; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init - --no-rehash)"

    RPROMPT='%F{white}(py:$(pyenv version-name))%f'
fi

# Load zinit
[ -f ~/.zinit/bin/zinit.zsh ] && . ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load plugins
zinit light "zsh-users/zsh-completions"

zinit light "zsh-users/zsh-history-substring-search"

zinit light "zsh-users/zsh-autosuggestions"

zinit light "zsh-users/zsh-syntax-highlighting"

zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure

# Install fzf
zinit ice as'null' depth='1' atinit'export PATH="${PATH:+${PATH}:}$PWD/bin"' \
    atclone'./install' atpull'%atclone' multisrc'shell/*.zsh'
zinit light junegunn/fzf

# Keybindings for substring search
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
