# 🚀 Dotfiles

Personal development environment configuration for quick setup on any Linux machine.

## 📦 What's Included

- **kitty** - GPU-accelerated terminal (Tokyo Night, Terminator-style splits)
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

### kitty Terminal
- Tokyo Night colors, FiraCode Nerd Font
- Tab bar at the bottom
- Terminator-style pane splitting (`Ctrl+Shift+O` / `Ctrl+Shift+E`)
- Scrollback search with fzf (`Ctrl+Shift+F`)

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

## 🎨 Themes

One command switches the whole terminal look — kitty, the starship prompt and
the Claude Code status line (ccstatusline):

```bash
theme                 # list themes (* = current)
theme tokyo-night     # switch; open kitty windows update instantly
theme <TAB>           # tab-completes theme names
```

| Theme | Name |
|---|---|
| GitHub Dark (default) | `github-dark` |
| Tokyo Night | `tokyo-night` |
| Ayu Dark | `ayu-dark` |

**How it works:** each theme is a kitty color file in `themes/<name>.conf`.
`theme` points `~/.config/kitty/current-theme.conf` at it and reloads kitty.
Starship and ccstatusline use ANSI color names (`blue`, `green`, …) instead of
hex codes, so they pick up the new palette automatically.

**Add a theme:** copy one of the files in `themes/`, change the colors, save it
as `themes/<new-name>.conf` — it shows up in `theme` right away.

## 🛠️ Quick Install

```bash
git clone https://github.com/rohangupta231/dotfiles.git ~/dev/personal/dotfiles
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

# kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

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

# kitty
mkdir -p ~/.config/kitty
cp ~/dotfiles/config/kitty/kitty.conf ~/.config/kitty/

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

### kitty
Edit `config/kitty/kitty.conf` to customize colors, fonts, keyboard shortcuts
and window appearance. Reload a running kitty with `Ctrl+Shift+F5`.

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

### kitty icons show as boxes
- Make sure FiraCode Nerd Font is installed: `fc-list | grep -i "FiraCode Nerd"`
- List fonts kitty can see: `kitty +list-fonts`

### Permission issues
```bash
chmod +x ~/dotfiles/install.sh
chmod 644 ~/.zshrc
```

## 📄 License

MIT

## 🤝 Contributing

Feel free to fork and customize for your own needs!
