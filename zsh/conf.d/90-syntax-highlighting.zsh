# Load after the plugin; be robust if it isn't there yet
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

# Ensure styles map exists even if plugin hasn’t created it yet
typeset -gA ZSH_HIGHLIGHT_STYLES

# Set a few nice defaults
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=160,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=33,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=39'
ZSH_HIGHLIGHT_STYLES[path]='fg=220'
