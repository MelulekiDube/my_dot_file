# Handy wrapper: `plugin add xxx/yyy`, `plugin remove`, `plugin list`, etc.
plugin() {
  "$HOME/my_dot_file/plugins.sh" "$@"
  # If we changed plugin set, rebuild + source immediately
  if [[ "$1" == "add" || "$1" == "remove" || "$1" == "preset" ]]; then
    autoload -Uz antidote 2>/dev/null || true
    antidote bundle < "$HOME/.zsh_plugins.txt" >| "$HOME/.zsh_plugins.zsh" 2>/dev/null || true
    source "$HOME/.zsh_plugins.zsh" 2>/dev/null || true
  fi
}
# minimal completion for the wrapper (optional)
compdef '_arguments : :((add\:Add remove\:Remove list\:List upgrade\:Upgrade preset\:Preset doctor\:Doctor))' plugin
