#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSH_DIR="$REPO_DIR/zsh"
PLUGINS_TXT="$ZSH_DIR/plugins.txt"
TARGET_ZSHRC="$HOME/.zshrc"
TARGET_LOCAL="$HOME/.zsh.local"
ANTIDOTE_DIR="$HOME/.antidote"

info() { printf "\033[1;34m[info]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
need() { command -v "$1" >/dev/null 2>&1; }

# ----- OS detection (macOS / Debian / RHEL-family) -----
OS="unknown"
[[ "$(uname -s)" == "Darwin" ]] && OS="mac"
if [[ -f /etc/os-release ]]; then
  if grep -qi 'ubuntu\|debian' /etc/os-release; then OS="debian"; fi
  if grep -qi 'rhel\|centos\|rocky\|almalinux' /etc/os-release; then OS="rhel"; fi
fi
info "Detected OS: $OS"

# ----- Ensure zsh only (you said Git is installed) -----
if ! need zsh; then
  case "$OS" in
    debian) sudo apt-get update && sudo apt-get install -y zsh ;;
    rhel)   if command -v dnf >/dev/null 2>&1; then sudo dnf install -y zsh; else sudo yum install -y zsh; fi ;;
    mac)    : ;;
    *)      warn "Unknown OS; install zsh manually and re-run." ;;
  esac
fi

# ----- Install antidote (plugin manager) -----
if [[ ! -d "$ANTIDOTE_DIR" ]]; then
  info "Installing antidote…"
  git clone --depth=1 https://github.com/mattmc3/antidote "$ANTIDOTE_DIR"
else
  info "Updating antidote…"
  git -C "$ANTIDOTE_DIR" pull --ff-only || true
fi

# ----- Optional fonts (skip on servers with --no-fonts) -----
INSTALL_FONTS=1
for arg in "$@"; do [[ "$arg" == "--no-fonts" ]] && INSTALL_FONTS=0; done
if (( INSTALL_FONTS )); then
  case "$OS" in
    mac)
      if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew tap homebrew/cask-fonts || true
      brew install --cask font-meslo-lg-nerd-font || true
      ;;
    debian)
      sudo apt-get update && sudo apt-get install -y fonts-powerline || true
      ;;
    rhel)
      if command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y powerline-fonts || true
      else
        sudo yum install -y powerline-fonts || true
      fi
      ;;
  esac
fi

# ----- Prepare directories & warn about OMZ -----
mkdir -p "$HOME" "$ZSH_DIR" "$ZSH_DIR/conf.d"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  warn "Detected ~/.oh-my-zsh. If you plan to use OMZ via ./setup.sh 2, that's fine."
  warn "If you prefer the minimal Antidote setup, you can keep OMZ or remove it later: rm -rf ~/.oh-my-zsh"
fi

# ----- Link files (backup old zshrc with timestamp) -----
if [[ -f "$TARGET_ZSHRC" && ! -L "$TARGET_ZSHRC" ]]; then
  backup_name="$HOME/zshrc.old_$(date +%Y%m%d_%H%M%S)_"
  mv "$TARGET_ZSHRC" "$backup_name"
  info "Moved existing .zshrc to: $backup_name"
fi

ln -sf "$ZSH_DIR/.zshrc" "$TARGET_ZSHRC"
ln -sf "$ZSH_DIR/local.example.zsh" "$TARGET_LOCAL" 2>/dev/null || true

# Ensure plugins list exists (link if present in repo, else create empty)
if [[ -f "$PLUGINS_TXT" ]]; then
  ln -sf "$PLUGINS_TXT" "$HOME/.zsh_plugins.txt"
else
  : > "$HOME/.zsh_plugins.txt"
fi

# Make plugin CLI executable if you added it
if [[ -f "$REPO_DIR/plugins.sh" ]]; then
  chmod +x "$REPO_DIR/plugins.sh"
  info "Plugin helper available: $REPO_DIR/plugins.sh (or use 'plugin' function if configured)"
fi

info "Install complete.
- Edit ~/.zsh_plugins.txt to add/remove plugins (Antidote-managed)
- Optional: run ./setup.sh to switch to Oh-My-Zsh/Prezto/YADR
- Reload shell with: exec zsh
- Pass --no-fonts to skip font install on servers"
