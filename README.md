# 🚀 Dotfiles

Personal development environment configuration for quick setup on any Linux machine.

## 📦 What's Included

- **WezTerm** - Modern terminal emulator with custom status bar
- **Zsh** - Shell configuration with plugins and aliases
- **Starship** - Cross-shell prompt
- **Git** - Git configuration
- **Ripgrep** - Fast grep alternative configs
- **FZF** - Fuzzy finder integration
- **Stern** - Kubernetes log tailing
- **kubectl** - Kubernetes CLI aliases
- **SDKMAN** - Java/Groovy/Gradle/Maven version manager
- **fnm** - Node.js version manager
- **Zoxide** - Smart directory jumping

## ✨ Features

### WezTerm Status Bar
- Hostname & Time (left)
- Git branch (right)
- Kubernetes context & namespace with right-click switcher (right)
- Docker container health status (right)
- Terminator-style pane splitting

### Zsh Enhancements
- **zsh-autosuggestions** - Fish-like suggestions
- **zsh-syntax-highlighting** - Real-time validation
- **fzf** - Fuzzy search (Ctrl+R for history)
- **zoxide** - Smart directory jumping
- **kubectl** aliases and completion
- **stern** aliases for log tailing
- **ripgrep** aliases for advanced searching

### Kubernetes Aliases
- `k` → kubectl
- `kgp` → get pods
- `kgd` → get deployments
- `klogs` → stern with smart defaults
- `kctx` → current context
- Many more...

### Ripgrep Aliases
- `rgi` → case insensitive
- `rgand` → AND logic
- `rgor` → OR logic
- `rgnot` → NOT logic
- `rgg` → search hidden files

## 🛠️ Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dev/personal/dotfiles
cd ~/dev/personal/dotfiles
chmod +x install.sh
./install.sh
```

## 📋 Manual Install

If you prefer manual installation:

### 1. Install Tools

```bash
# Essential tools
sudo apt update
sudo apt install -y zsh git curl wget fzf ripgrep eza bat

# Starship prompt
curl -sS https://starship.rs/install.sh | sh

# WezTerm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt update
sudo apt install -y wezterm

# Stern (Kubernetes log tailing)
wget https://github.com/stern/stern/releases/download/v1.30.0/stern_1.30.0_linux_amd64.tar.gz -O /tmp/stern.tar.gz
tar -xzf /tmp/stern.tar.gz -C /tmp
sudo mv /tmp/stern /usr/local/bin/
sudo chmod +x /usr/local/bin/stern

# Zoxide (smart cd)
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# fnm (Node version manager)
curl -fsSL https://fnm.vercel.app/install | bash

# SDKMAN (Java/Groovy/Gradle/Maven/Kotlin manager)
curl -s "https://get.sdkman.io" | bash
```

### 2. Install Zsh Plugins

```bash
mkdir -p ~/.zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
```

### 3. Copy Configs

```bash
# Zsh
cp ~/dotfiles/zsh/.zshrc ~/.zshrc

# WezTerm
mkdir -p ~/.config/wezterm
cp ~/dotfiles/config/wezterm/wezterm.lua ~/.config/wezterm/

# Starship
mkdir -p ~/.config
cp ~/dotfiles/config/starship/starship.toml ~/.config/

# Git
cp ~/dotfiles/.gitconfig ~/.gitconfig

# Set Zsh as default shell
chsh -s $(which zsh)
```

### 4. Reload

```bash
source ~/.zshrc
# Or restart terminal
```

## 🎨 Customization

### WezTerm
Edit `config/wezterm/wezterm.lua` to customize:
- Colors and fonts
- Status bar items
- Keyboard shortcuts
- Window appearance

### Zsh Aliases
Edit `zsh/.zshrc` to add your own aliases in the Aliases section.

### Starship Prompt
Edit `config/starship/starship.toml` to customize prompt appearance.

## 🔧 Tools Reference

### Kubectl Shortcuts
```bash
k get pods              # List pods
kgp -o wide            # Detailed pod view
klogs api              # Tail logs for "api" pods
kex pod-name -- sh     # Exec into pod
kctx                   # Show current context
```

### Ripgrep Examples
```bash
rg pattern             # Basic search
rgi pattern            # Case insensitive
rgand error 500        # Lines with both
rgor error -e warning  # Lines with either
rgnot test            # Exclude pattern
```

### Directory Navigation
```bash
z project             # Jump to frequently used dir
cd -                  # Previous directory
dirs -v               # Show directory stack
```

## 📝 Maintenance

### Update Dotfiles
```bash
cd ~/dotfiles
git pull
./install.sh  # Re-run to update symlinks
```

### Sync Changes
```bash
cd ~/dotfiles
cp ~/.zshrc zsh/.zshrc
cp ~/.config/wezterm/wezterm.lua config/wezterm/
cp ~/.config/starship.toml config/starship/
git add -A
git commit -m "Update configs"
git push
```

## 🐛 Troubleshooting

### Zsh plugins not working
```bash
# Reinstall plugins
rm -rf ~/.zsh
mkdir -p ~/.zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
source ~/.zshrc
```

### WezTerm status bar not showing
- Ensure kubectl is installed if using kube context
- Check docker is running if using container health
- Verify git is installed for branch display

### Permission issues
```bash
chmod +x ~/dotfiles/install.sh
chmod 644 ~/.zshrc
```

## 📄 License

MIT

## 🤝 Contributing

Feel free to fork and customize for your own needs!
