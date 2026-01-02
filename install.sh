#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR"

# ---- sanity checks ----
if ! command -v pacman &>/dev/null; then
  echo "pacman not found. This script is for Arch Linux."
  exit 1
fi

# ---- install pacman packages ----
if [[ -f "$DOTFILES_DIR/packages/pacman.txt" ]]; then
  echo "==> Installing pacman packages"
  sudo pacman -S --needed --noconfirm \
    $(grep -vE '^\s*#|^\s*$' "$DOTFILES_DIR/packages/pacman.txt")
fi

# ---- install yay if needed ----
if [[ -f "$DOTFILES_DIR/packages/aur.txt" ]]; then
  if ! command -v yay &>/dev/null; then
    echo "==> Installing yay"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
  fi

  echo "==> Installing AUR packages"
  yay -S --needed --noconfirm \
    $(grep -vE '^\s*#|^\s*$' "$DOTFILES_DIR/packages/aur.txt")
fi

# ---- symlink configs ----
echo "==> Linking config files"

mkdir -p "$HOME/.config"

for dir in "$DOTFILES_DIR/config/"*; do
  name="$(basename "$dir")"
  target="$HOME/.config/$name"

  if [[ -e "$target" || -L "$target" ]]; then
    echo "    Skipping $name (already exists)"
  else
    ln -s "$dir" "$target"
    echo "    Linked $name"
  fi
done

echo "==> Done"
