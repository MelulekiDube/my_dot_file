#!/usr/bin/env bash
set -euo pipefail

choice=${1:-}
if [[ -z "$choice" ]]; then
  cat <<'MENU'
Choose setup mode:
  1) Minimal (Antidote + plugins.txt)  [recommended]
  2) Oh My Zsh (agnoster theme + plugins)
  3) Prezto (powerlevel10k theme)
  4) YADR (full dotfiles suite)
Enter number:
MENU
  read -r choice
fi

case "$choice" in
  1)
    echo "Keeping minimal Antidote mode."
    echo "Edit ~/.zsh_plugins.txt to manage plugins, then: exec zsh"
    ;;

  2)
    echo "Installing Oh My Zsh…"
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Theme and plugins
    sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' "$HOME/.zshrc"
    perl -0777 -pe 's/^plugins=\([^)]*\)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting history-substring-search z)/m' -i "$HOME/.zshrc"

    # Ensure plugin clones
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || true
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true
    git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search" || true

    echo "Oh My Zsh ready. Run: exec zsh"
    ;;

  3)
    echo "Installing Prezto…"
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" || true
    for rc in zlogin zlogout zprofile zshenv zshrc zpreztorc; do
      ln -sf "${ZDOTDIR:-$HOME}/.zprezto/runcoms/$rc" "${ZDOTDIR:-$HOME}/.$rc"
    done
    perl -0777 -pe 's/^prompt=.*/prompt="powerlevel10k"/m' -i "$HOME/.zpreztorc" || echo 'prompt="powerlevel10k"' >> "$HOME/.zpreztorc"
    echo "Prezto installed with powerlevel10k. Run: exec zsh"
    ;;

  4)
    echo "Installing YADR…"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/skwp/dotfiles/master/install.sh)"
    echo "YADR installed. It will manage its own files."
    ;;

  *)
    echo "Unknown choice. Exiting."
    exit 1
    ;;
esac
