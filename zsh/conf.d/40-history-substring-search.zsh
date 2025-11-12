# ----- History substring search configuration -----
# Wait until plugin is loaded
autoload -Uz history-substring-search-up history-substring-search-down 2>/dev/null || true

if (( $+functions[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down

  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=green,bold'
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'

  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
    history-substring-search-up
    history-substring-search-down
  )
else
  echo "[warn] history-substring-search plugin not loaded yet"
fi
