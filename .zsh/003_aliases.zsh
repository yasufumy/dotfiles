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

# python
# py() {
#     test -z "$1" && ipython --no-confirm-exit --ext=autoreload --quick \
#                             --InteractiveShellApp.exec_lines="['%autoreload 2']" \
#                             --no-banner|| command python "$@"
#     #ipython -h >/dev/null 2>&1
#     #if [[ $# -eq 0 && $? -eq 0 ]]; then
#     #    command ipython
#     #else
#     #    command python "$@"
#     #fi
# }
# alias python="py"
alias ipy="ipython --no-confirm-exit --no-banner --quick --ext=autoreload --InteractiveShellApp.exec_lines=\"['%autoreload 2']\""

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

# labnet
# alias socks="scselect -n socks"
# alias tunnel="ssh -N -f -D 1080 lab"
# alias labnet="tunnel; socks"
# alias homenet="kill $(ps aux | grep 1080 | grep ssh | awk '{print $2}') 2>/dev/null; scselect -n default"
alias labnet="ssh lab; sudo networksetup -setsocksfirewallproxystate wi-fi off"

# update
alias brew-cask-upgrade="for c in \`brew cask list\`; do ! brew cask info \$c | grep -qF 'Not installed' || brew cask install \$c; done"
alias update-all="brew update; brew upgrade; brew cleanup; brew-cask-upgrade; brew cask cleanup; zplug update; zplug clear; vim +PlugUpdate +PlugUpgrade +qall; softwareupdate -ia"
alias pip-update="pip install --upgrade pip; pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U"
