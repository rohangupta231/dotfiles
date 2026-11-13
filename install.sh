#!/bin/bash

# Dotfiles Installation Script
# Automates setup of development environment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}➜${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "========================================="
echo "       Dotfiles Installation"
echo "========================================="
echo ""

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    print_info "Detected Linux"
    PKG_MANAGER="apt"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    print_info "Detected macOS"
    PKG_MANAGER="brew"
else
    print_error "Unsupported OS: $OSTYPE"
    exit 1
fi

# Update package manager
print_info "Updating package manager..."
if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt update
else
    brew update
fi
print_success "Package manager updated"

# Install essential tools
print_info "Installing essential tools..."

TOOLS=(git curl wget zsh fzf)
for tool in "${TOOLS[@]}"; do
    if command_exists "$tool"; then
        print_success "$tool already installed"
    else
        print_info "Installing $tool..."
        if [ "$PKG_MANAGER" = "apt" ]; then
            sudo apt install -y "$tool"
        else
            brew install "$tool"
        fi
        print_success "$tool installed"
    fi
done

# Install modern CLI tools
print_info "Installing modern CLI tools..."

if command_exists rg; then
    print_success "ripgrep already installed"
else
    print_info "Installing ripgrep..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt install -y ripgrep
    else
        brew install ripgrep
    fi
    print_success "ripgrep installed"
fi

if command_exists eza; then
    print_success "eza already installed"
else
    print_info "Installing eza..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt install -y eza
    else
        brew install eza
    fi
    print_success "eza installed"
fi

if command_exists batcat || command_exists bat; then
    print_success "bat already installed"
else
    print_info "Installing bat..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt install -y bat
    else
        brew install bat
    fi
    print_success "bat installed"
fi

# Install Starship
if command_exists starship; then
    print_success "Starship already installed"
else
    print_info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    print_success "Starship installed"
fi

# Install kitty (official installer, no sudo needed)
if command_exists kitty || [ -x ~/.local/kitty.app/bin/kitty ]; then
    print_success "kitty already installed"
else
    print_info "Installing kitty..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
    else
        brew install --cask kitty
    fi
    print_success "kitty installed"
fi
if [ "$PKG_MANAGER" = "apt" ] && [ -d ~/.local/kitty.app ]; then
    # Put kitty on PATH and in the app launcher
    mkdir -p ~/.local/bin ~/.local/share/applications
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g; s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty.desktop
fi

# Install FiraCode Nerd Font (used by kitty and starship icons)
if fc-list | grep -qi "FiraCode Nerd Font"; then
    print_success "FiraCode Nerd Font already installed"
elif [ "$PKG_MANAGER" = "apt" ]; then
    print_info "Installing FiraCode Nerd Font..."
    mkdir -p ~/.local/share/fonts
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz | tar -xJ -C ~/.local/share/fonts --wildcards '*.ttf'
    fc-cache -f >/dev/null
    print_success "FiraCode Nerd Font installed"
else
    brew install --cask font-fira-code-nerd-font
fi

# Install Stern (Kubernetes log tailing)
if command_exists stern; then
    print_success "stern already installed"
else
    print_info "Installing stern..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        wget https://github.com/stern/stern/releases/download/v1.30.0/stern_1.30.0_linux_amd64.tar.gz -O /tmp/stern.tar.gz
        tar -xzf /tmp/stern.tar.gz -C /tmp
        sudo mv /tmp/stern /usr/local/bin/
        sudo chmod +x /usr/local/bin/stern
        rm /tmp/stern.tar.gz
    else
        brew install stern
    fi
    print_success "stern installed"
fi

# Install zoxide
if command_exists zoxide; then
    print_success "zoxide already installed"
else
    print_info "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    print_success "zoxide installed"
fi

# Install fnm (Node version manager)
if command_exists fnm; then
    print_success "fnm already installed"
else
    print_info "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash
    print_success "fnm installed"
fi

# Install Node LTS (via fnm) and ccstatusline (Claude Code status line)
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"
if ! fnm ls | grep -q default; then
    print_info "Installing Node LTS..."
    fnm install --lts
    fnm default "$(fnm current)"
fi
if command_exists ccstatusline; then
    print_success "ccstatusline already installed"
else
    print_info "Installing ccstatusline..."
    npm install -g ccstatusline
    print_success "ccstatusline installed"
fi

# Install SDKMAN (Java/Groovy/Gradle/Maven manager)
if [ -d "$HOME/.sdkman" ]; then
    print_success "SDKMAN already installed"
else
    print_info "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    print_success "SDKMAN installed"
fi

# Install Zsh plugins
print_info "Installing Zsh plugins..."
mkdir -p ~/.zsh

if [ -d ~/.zsh/zsh-syntax-highlighting ]; then
    print_success "zsh-syntax-highlighting already installed"
else
    print_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting installed"
fi

if [ -d ~/.zsh/zsh-autosuggestions ]; then
    print_success "zsh-autosuggestions already installed"
else
    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    print_success "zsh-autosuggestions installed"
fi

# Backup existing configs
print_info "Backing up existing configs..."
BACKUP_DIR=~/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

[ -f ~/.zshrc ] && cp ~/.zshrc "$BACKUP_DIR/.zshrc"
[ -f ~/.config/kitty/kitty.conf ] && [ ! -L ~/.config/kitty/kitty.conf ] && cp ~/.config/kitty/kitty.conf "$BACKUP_DIR/kitty.conf"
[ -f ~/.config/starship.toml ] && cp ~/.config/starship.toml "$BACKUP_DIR/starship.toml"
[ -f ~/.gitconfig ] && cp ~/.gitconfig "$BACKUP_DIR/.gitconfig"

print_success "Backed up to $BACKUP_DIR"

# Copy config files
print_info "Installing config files..."

# Determine dotfiles directory
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/personal/dotfiles}"

cp $DOTFILES_DIR/zsh/.zshrc ~/.zshrc
print_success "Installed .zshrc"

mkdir -p ~/.config/kitty
ln -sfn $DOTFILES_DIR/config/kitty/kitty.conf ~/.config/kitty/kitty.conf
print_success "Linked kitty.conf"

mkdir -p ~/.config
if [ -f $DOTFILES_DIR/config/starship/starship.toml ]; then
    cp $DOTFILES_DIR/config/starship/starship.toml ~/.config/
    print_success "Installed starship.toml"
fi

if [ -f $DOTFILES_DIR/.gitconfig ]; then
    cp $DOTFILES_DIR/.gitconfig ~/.gitconfig
    print_success "Installed .gitconfig"
fi

# ccstatusline + Claude Code settings (symlinked so edits land in the repo)
mkdir -p ~/.config/ccstatusline ~/.claude
for pair in "config/ccstatusline/settings.json:$HOME/.config/ccstatusline/settings.json" \
            "config/claude/settings.json:$HOME/.claude/settings.json"; do
    src="$DOTFILES_DIR/${pair%%:*}"; dst="${pair#*:}"
    [ -e "$dst" ] && [ ! -L "$dst" ] && cp "$dst" "$BACKUP_DIR/$(basename "$(dirname "$dst")")-settings.json"
    ln -sfn "$src" "$dst"
    print_success "Linked $dst"
done

# Theme switcher (`theme <name>`), default theme on first install
mkdir -p ~/.local/bin
ln -sfn "$DOTFILES_DIR/bin/theme" ~/.local/bin/theme
if [ ! -L ~/.config/kitty/current-theme.conf ]; then
    DOTFILES_DIR="$DOTFILES_DIR" "$DOTFILES_DIR/bin/theme" github-dark
fi
print_success "Installed theme switcher (current: $(DOTFILES_DIR="$DOTFILES_DIR" "$DOTFILES_DIR/bin/theme" --current))"

# Set Zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    print_info "Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
    print_success "Zsh set as default shell"
else
    print_success "Zsh already default shell"
fi

echo ""
echo "========================================="
print_success "Installation complete!"
echo "========================================="
echo ""
print_info "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Open kitty for the new config"
echo "  3. Customize configs in ~/dotfiles/"
echo ""
print_warning "Note: You may need to log out and back in for shell changes to take effect"
