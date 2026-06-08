#!/usr/bin/env bash
#
# Bootstrap a fresh macOS machine with my dotfiles.
#
# Run locally:    ./init.sh
# Run remotely:   curl -fsSL https://raw.githubusercontent.com/DavidConnack/dotfiles/main/init.sh | bash
#
set -euo pipefail

REPO_URL="https://github.com/DavidConnack/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Documents/Repos/dotfiles}"

# Homebrew (also installs Xcode Command Line Tools, which gives us git)
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Clone repo if not already present, otherwise fast-forward to latest
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$REPO_URL" "$DOTFILES_DIR"
else
  git -C "$DOTFILES_DIR" pull --ff-only --quiet || \
    echo "⚠️  Could not fast-forward $DOTFILES_DIR — using current local state"
fi
cd "$DOTFILES_DIR"

# Apps + fonts (idempotent; keeps going if individual entries fail)
brew bundle install --file="$DOTFILES_DIR/Brewfile" || \
  echo "⚠️  Some Brewfile entries failed. Continuing — re-run init.sh to retry."

# oh-my-zsh (unattended: skips chsh and skips launching zsh)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Config dirs + symlinks
mkdir -p ~/.config/zed ~/.config/ghostty

ln -sf "$DOTFILES_DIR/zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/tmux" ~/.tmux
ln -sf "$DOTFILES_DIR/tmux.conf" ~/.tmux.conf
ln -sf "$DOTFILES_DIR/zed.json" ~/.config/zed/settings.json
ln -sf "$DOTFILES_DIR/ghostty.config" ~/.config/ghostty/config

# Touch ID for sudo (incl. tmux). Render with this machine's brew prefix and
# install only if changed, so re-runs don't trigger a needless sudo prompt.
if [ -f "$DOTFILES_DIR/pam/sudo_local" ]; then
  rendered="$(sed "s#/opt/homebrew/lib/pam/pam_reattach.so#$(brew --prefix)/lib/pam/pam_reattach.so#" "$DOTFILES_DIR/pam/sudo_local")"
  if ! diff -q <(printf '%s\n' "$rendered") /etc/pam.d/sudo_local >/dev/null 2>&1; then
    echo "→ Installing /etc/pam.d/sudo_local (Touch ID for sudo). You may be prompted for your password."
    printf '%s\n' "$rendered" | sudo tee /etc/pam.d/sudo_local >/dev/null
    sudo chmod 444 /etc/pam.d/sudo_local
    sudo chown root:wheel /etc/pam.d/sudo_local
  fi
fi

echo
echo "✓ Done. Restart your shell, or run: source ~/.zshrc"
echo "  Note: remote is HTTPS. To push, switch to SSH:"
echo "    git -C \"$DOTFILES_DIR\" remote set-url origin git@github.com:DavidConnack/dotfiles.git"
