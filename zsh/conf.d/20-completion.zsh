# ----- Completion configuration -----

autoload -Uz compinit
compinit -d "$HOME/.zcompdump"

# Enable completion menu and selection
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' \
                                     'r:|[._-]=* r:|=*' \
                                     'l:|=* r:|=*'

# Fuzzy and case-insensitive matches
setopt AUTO_LIST
setopt COMPLETE_IN_WORD

# Add completions from plugins (zsh-completions)
fpath=("$HOME/.antidote/bundles/zsh-users/zsh-completions/src" $fpath)

# Cache completion data
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh_cache"
