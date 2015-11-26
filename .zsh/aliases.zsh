# default command
alias ls="ls -aG"
alias rm="rm -iv"
alias mv="mv -iv"
alias cp="cp -iv"
alias purge="sudo purge"
alias grep="grep --color"

# git
alias gst="git status"
alias gad="git add --all"
alias gci="git commit -a --allow-empty-message -m ''"
alias gph="git push"
alias gpl="git pull"
alias gcim="git commit -m"
alias gbr="git branch"
alias gco="git checkout"
alias glg="git log --graph"

# tmux
alias tmux="tmux -u"

# matlab
alias matlab="/Applications/MATLAB_R2015a.app/bin/matlab -nosplash -nodisplay"

# update
alias brew-cask-upgrade="for c in \`brew cask list\`; do ! brew cask info \$c | grep -qF 'Not installed' || brew cask install \$c; done"
alias update-all="brew update && brew upgrade --all && brew cleanup && brew-cask-upgrade && brew-cask cleanup && softwareupdate -ia"
alias pip-update="pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U"
