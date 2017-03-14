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
