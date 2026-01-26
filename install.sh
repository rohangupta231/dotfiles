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

# Install WezTerm
if command_exists wezterm; then
    print_success "WezTerm already installed"
else
    print_info "Installing WezTerm..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
        sudo apt update
        sudo apt install -y wezterm
    else
        brew install --cask wezterm
    fi
    print_success "WezTerm installed"
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
[ -f ~/.config/wezterm/wezterm.lua ] && cp ~/.config/wezterm/wezterm.lua "$BACKUP_DIR/wezterm.lua"
[ -f ~/.config/starship.toml ] && cp ~/.config/starship.toml "$BACKUP_DIR/starship.toml"
[ -f ~/.gitconfig ] && cp ~/.gitconfig "$BACKUP_DIR/.gitconfig"

print_success "Backed up to $BACKUP_DIR"

# Copy config files
print_info "Installing config files..."

# Determine dotfiles directory
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/personal/dotfiles}"

cp $DOTFILES_DIR/zsh/.zshrc ~/.zshrc
print_success "Installed .zshrc"

mkdir -p ~/.config/wezterm
cp $DOTFILES_DIR/config/wezterm/wezterm.lua ~/.config/wezterm/
print_success "Installed wezterm.lua"

mkdir -p ~/.config
if [ -f $DOTFILES_DIR/config/starship/starship.toml ]; then
    cp $DOTFILES_DIR/config/starship/starship.toml ~/.config/
    print_success "Installed starship.toml"
fi

if [ -f $DOTFILES_DIR/.gitconfig ]; then
    cp $DOTFILES_DIR/.gitconfig ~/.gitconfig
    print_success "Installed .gitconfig"
fi

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
echo "  2. Open WezTerm for the new config"
echo "  3. Customize configs in ~/dotfiles/"
echo ""
print_warning "Note: You may need to log out and back in for shell changes to take effect"
