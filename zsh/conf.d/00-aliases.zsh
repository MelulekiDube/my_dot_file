# ----- Persistent aliases (not in the repo) -----

# Load a file if it exists
_z_load_if() { [[ -r "$1" ]] && source "$1"; }

# Main personal aliases
_z_load_if "$HOME/.zsh_aliases"

# Optional: per-OS
case "$OSTYPE" in
  darwin*)  _z_load_if "$HOME/.zsh_aliases.d/macos.zsh" ;;
  linux*)   _z_load_if "$HOME/.zsh_aliases.d/linux.zsh" ;;
esac

# Optional: per-host
_z_load_if "$HOME/.zsh_aliases.d/$(hostname -s).zsh"

# Optional: load everything in the folder
for f in "$HOME/.zsh_aliases.d/"*.zsh(N); do _z_load_if "$f"; done
unset -f _z_load_if
