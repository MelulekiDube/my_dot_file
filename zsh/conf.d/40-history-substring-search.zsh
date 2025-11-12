# ----- History substring search configuration -----

# Bind keys for substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# Optional: make results visually distinct
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=green,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'

# Ensure autosuggestions don't conflict
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)
