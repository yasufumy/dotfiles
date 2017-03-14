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
