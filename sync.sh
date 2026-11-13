#!/bin/bash

# Quick sync script to update dotfiles from current system configs

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/personal/dotfiles}"

cp ~/.zshrc $DOTFILES_DIR/zsh/.zshrc
cp ~/.config/starship.toml $DOTFILES_DIR/config/starship/ 2>/dev/null || true
cp ~/.gitconfig $DOTFILES_DIR/.gitconfig 2>/dev/null || true

echo "✓ Dotfiles synced from system to $DOTFILES_DIR/"
echo "Don't forget to commit and push:"
echo "  cd $DOTFILES_DIR && git add -A && git commit -m 'Update configs' && git push"
