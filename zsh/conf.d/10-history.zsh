# ----- History configuration -----

# Where to store history
HISTFILE="$HOME/.zsh_history"

# Huge history sizes (effectively infinite)
HISTSIZE=1000000
SAVEHIST=1000000

# Append history as you go, share across terminals
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Remove duplicates, keep clean entries
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# Extended history adds timestamps to entries
setopt EXTENDED_HISTORY
