# ----- Autosuggestions configuration -----

# Use async mode for speed
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Fetch suggestions from both history and completion
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Color for suggestion text (dim gray)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Accept suggestion with → or Ctrl+F
bindkey '^f' autosuggest-accept
