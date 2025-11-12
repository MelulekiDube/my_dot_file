#!/usr/bin/env bash
set -euo pipefail

PLUGINS_FILE="$HOME/.zsh_plugins.txt"
BUNDLE_FILE="$HOME/.zsh_plugins.zsh"

ensure_files() {
  [[ -f "$PLUGINS_FILE" ]] || : > "$PLUGINS_FILE"
}

plugin_exists() { grep -E -q "^$1(\s|$)" "$PLUGINS_FILE"; }

add_plugin() {
  local spec="${1:?repo required}"                 # e.g. zsh-users/zsh-autosuggestions or 'ohmyzsh/ohmyzsh path:plugins/mercurial'
  ensure_files
  if plugin_exists "$spec"; then
    echo "already present: $spec"; return 0
  fi
  # keep syntax-highlighting last
  if grep -q '^zsh-users/zsh-syntax-highlighting' "$PLUGINS_FILE"; then
    sed -i.bak '/^zsh-users\/zsh-syntax-highlighting$/d' "$PLUGINS_FILE"
    echo "$spec" >> "$PLUGINS_FILE"
    echo 'zsh-users/zsh-syntax-highlighting' >> "$PLUGINS_FILE"
  else
    echo "$spec" >> "$PLUGINS_FILE"
  fi
  echo "added: $spec"
}

remove_plugin() {
  local spec="${1:?repo required}"
  ensure_files
  if plugin_exists "$spec"; then
    sed -i.bak "/^${spec//\//\/}\$/d" "$PLUGINS_FILE"
    echo "removed: $spec"
  else
    echo "not found: $spec" >&2
  fi
}

list_plugins() { ensure_files; nl -ba "$PLUGINS_FILE"; }

rebuild_bundle() {
  # build with antidote from a subshell to avoid sourcing issues
  zsh -lc 'autoload -Uz antidote; antidote bundle < "$HOME/.zsh_plugins.txt" >| "$HOME/.zsh_plugins.zsh"' >/dev/null 2>&1 || true
  echo "bundle rebuilt: $BUNDLE_FILE"
}

preset() {
  case "${1:?name required}" in
    fzf)
      add_plugin junegunn/fzf
      add_plugin unixorn/fzf-zsh-plugin ;;
    git)
      add_plugin wfxr/forgit
      add_plugin tj/git-extras ;;
    k8s)
      add_plugin superbrothers/zsh-kubectl-prompt ;;
    devops)
      add_plugin zsh-users/zsh-completions
      add_plugin ajeetdsouza/zoxide
      add_plugin junegunn/fzf
      add_plugin unixorn/fzf-zsh-plugin ;;
    mercurial|hg)
      add_plugin 'ohmyzsh/ohmyzsh path:plugins/mercurial' ;;
    *)
      echo "unknown preset: $1"; exit 1 ;;
  esac
}

doctor() {
  [[ -f "$PLUGINS_FILE" ]] || { echo "missing $PLUGINS_FILE"; return 1; }
  grep -q '^zsh-users/zsh-syntax-highlighting' "$PLUGINS_FILE" || echo "tip: add zsh-users/zsh-syntax-highlighting (last)"
  command -v zsh >/dev/null || echo "warning: zsh not found in PATH"
}

usage() {
  cat <<USAGE
Usage: $(basename "$0") <command> [args]
Commands:
  add <repo> [path:subdir]   Add a plugin (idempotent)
  remove <repo>              Remove a plugin
  list                       List plugins
  upgrade                    Rebuild plugin bundle
  preset <name>              Add curated set (fzf|git|k8s|devops|mercurial)
  doctor                     Check for common issues
USAGE
}

cmd=${1:-}; shift || true
case "$cmd" in
  add)     add_plugin "${1:?repo required}" ;;
  remove)  remove_plugin "${1:?repo required}" ;;
  list)    list_plugins ;;
  upgrade) rebuild_bundle ;;
  preset)  preset "${1:?name required}" ;;
  doctor)  doctor ;;
  *)       usage; exit 1 ;;
esac
