# >>> dotfiles-zsh-setup: core <<<

# Base directories
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
export ZSH_DIR="$DOTFILES_DIR/zsh"
export ZSH_CONF_DIR="$ZSH_DIR/conf.d"

# ----- Plugin manager: Antidote -----
fpath=("$HOME/.antidote/functions" $fpath)
autoload -Uz antidote

if typeset -f antidote >/dev/null; then
  # Regenerate plugin bundle if missing or outdated
  if [[ ! -f "$HOME/.zsh_plugins.zsh" || "$HOME/.zsh_plugins.txt" -nt "$HOME/.zsh_plugins.zsh" ]]; then
    antidote bundle < "$HOME/.zsh_plugins.txt" >| "$HOME/.zsh_plugins.zsh"
  fi
  source "$HOME/.zsh_plugins.zsh"
fi

# ----- Source modular configs -----
for f in "$ZSH_CONF_DIR"/*.zsh; do
  [[ -r "$f" ]] && source "$f"
done

# ----- Theme -----
# Using agnoster (you can replace later with powerlevel10k)
if [[ -f "$ZSH_DIR/agnoster.zsh-theme" ]]; then
  source "$ZSH_DIR/agnoster.zsh-theme"
else
  PROMPT='%n@%m %1~ %# '
fi

# ----- Local overrides -----
[[ -r "$HOME/.zsh.local" ]] && source "$HOME/.zsh.local"

# >>> dotfiles-zsh-setup: core <<<
