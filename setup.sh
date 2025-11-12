#!/usr/bin/env bash
set -euo pipefail

die(){ echo "error: $*" >&2; exit 1; }
have(){ command -v "$1" >/dev/null 2>&1; }

# ----- Helpers: inject our custom files into OMZ -----
inject_omz_custom() {
  local omz_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$omz_custom"

  # plugin wrapper (works with Antidote + ~/.zsh_plugins.txt)
  cat > "$omz_custom/05-plugin-cli.zsh" <<'EOF'
plugin() {
  "$HOME/.dotfiles/plugins.sh" "$@" || return $?
  case "$1" in
    add|remove|preset)
      autoload -Uz antidote 2>/dev/null || true
      antidote bundle < "$HOME/.zsh_plugins.txt" >| "$HOME/.zsh_plugins.zsh" 2>/dev/null || true
      source "$HOME/.zsh_plugins.zsh" 2>/dev/null || true
      ;;
  esac
}
EOF

  # right-side timer + clock
  cat > "$omz_custom/80-rprompt-timing.zsh" <<'EOF'
setopt PROMPT_SUBST
integer __CMD_START=0 __CMD_ELAPSED=0
preexec(){ __CMD_START=$EPOCHSECONDS }
precmd(){
  if (( __CMD_START > 0 )); then __CMD_ELAPSED=$(( EPOCHSECONDS-__CMD_START )); __CMD_START=0; fi
  local d=""; (( __CMD_ELAPSED>0 )) && d="⏱ ${__CMD_ELAPSED}s "
  RPROMPT="${d}🕒 $(date +%H:%M:%S)"
}
EOF
}

set_omz_theme_and_plugins() {
  # theme → agnoster; plugins → git + our essentials
  sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' "$HOME/.zshrc" || true
  # Replace plugins=(...) with our set (safe even if already set)
  if grep -q '^plugins=' "$HOME/.zshrc"; then
    perl -0777 -pe 's/^plugins=\([^)]*\)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting history-substring-search z)/m' -i "$HOME/.zshrc"
  else
    printf '\nplugins=(git zsh-autosuggestions zsh-syntax-highlighting history-substring-search z)\n' >> "$HOME/.zshrc"
  fi
}

ensure_omz_plugins_cloned() {
  local omz_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$omz_custom/plugins"
  git -C "$omz_custom/plugins" clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions 2>/dev/null || true
  git -C "$omz_custom/plugins" clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting 2>/dev/null || true
  git -C "$omz_custom/plugins" clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search zsh-history-substring-search 2>/dev/null || true
}

ensure_antidote_bundle() {
  # Rebuild Antidote bundle so our plugin wrapper can hot-reload
  autoload -Uz antidote 2>/dev/null || true
  if typeset -f antidote >/dev/null; then
    antidote bundle < "$HOME/.zsh_plugins.txt" >| "$HOME/.zsh_plugins.zsh" || true
  fi
}

install_omz() {
  # Install OMZ if absent (non-interactive)
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  # If OMZ template prompt appears, we still overwrite theme/plugins right after.
}

# ----- Modes -----
mode="${1:-}"

if [[ -z "$mode" ]]; then
  cat <<'MENU'
Choose setup mode:
  1) Minimal (Antidote + plugins.txt)  [recommended]
  2) Oh My Zsh (install/refresh + agnoster + our plugin wrapper + timer)
  3) Prezto (powerlevel10k)
  4) YADR (full dotfiles suite)
Enter number:
MENU
  read -r mode
fi

case "$mode" in
  1)
    echo "[ok] Minimal mode selected. Edit ~/.zsh_plugins.txt, then: exec zsh"
    ;;

  2)
    echo "[*] Installing or refreshing Oh My Zsh…"
    install_omz
    echo "[*] Injecting our plugin CLI and timer into OMZ custom…"
    inject_omz_custom
    echo "[*] Ensuring theme/plugins in ~/.zshrc…"
    set_omz_theme_and_plugins
    echo "[*] Cloning OMZ plugins (autosuggestions, syntax-highlighting, substring-search)…"
    ensure_omz_plugins_cloned
    echo "[*] Rebuilding Antidote bundle (for plugin CLI)…"
    ensure_antidote_bundle
    echo "[ok] Oh My Zsh configured. Run: exec zsh"
    ;;

  3)
    echo "[*] Installing Prezto…"
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" 2>/dev/null || true
    for rc in zlogin zlogout zprofile zshenv zshrc zpreztorc; do
      ln -sf "${ZDOTDIR:-$HOME}/.zprezto/runcoms/$rc" "${ZDOTDIR:-$HOME}/.$rc"
    done
    perl -0777 -pe 's/^prompt=.*/prompt="powerlevel10k"/m' -i "$HOME/.zpreztorc" || echo 'prompt="powerlevel10k"' >> "$HOME/.zpreztorc"
    echo "[ok] Prezto installed. Run: exec zsh"
    ;;

  4)
    echo "[*] Installing YADR…"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/skwp/dotfiles/master/install.sh)"
    echo "[ok] YADR installed. It manages its own files."
    ;;

  *)
    die "Unknown choice: $mode"
    ;;
esac
