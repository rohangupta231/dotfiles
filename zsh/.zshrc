# =========================
# PATH & terminal
# =========================
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export TERM="xterm-256color"
export COLORTERM="truecolor"
export PAGER="batcat --style=plain"
export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
export EDITOR="code --wait"

# =========================
# History configuration
# =========================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt APPEND_HISTORY         # Append to history file
setopt INC_APPEND_HISTORY     # Write immediately, not on exit
setopt HIST_REDUCE_BLANKS     # Remove extra blanks from commands
setopt HIST_VERIFY            # Show command before executing from history

# =========================
# General options
# =========================
setopt AUTO_CD                # cd by typing directory name
setopt AUTO_PUSHD             # Push directories onto stack
setopt PUSHD_IGNORE_DUPS      # Don't push duplicates
setopt PUSHD_SILENT           # Don't print directory stack
setopt CORRECT                # Suggest corrections for commands
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shell
setopt NO_BEEP                # Disable beep on errors
setopt EXTENDED_GLOB          # Extended globbing patterns

# =========================
# Key bindings (word navigation)
# =========================
bindkey -e                          # Emacs key bindings
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^H' backward-kill-word     # Ctrl+Backspace
bindkey '^[[3;5~' kill-word         # Ctrl+Delete
bindkey '^[[A' history-search-backward  # Up arrow: search history
bindkey '^[[B' history-search-forward   # Down arrow: search history
bindkey '^R' history-incremental-search-backward  # Ctrl+R: reverse search

# =========================
# Zsh completion system
# =========================
# Speed up compinit by checking once per day
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh+24) ]]; then
  compinit
else
  compinit -C
fi

# Case-sensitive completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
# Completion menu with selection
zstyle ':completion:*' menu select
# Colorized completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Group completions by type
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
# Cache completions for speed
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# =========================
# Starship prompt
# =========================
eval "$(starship init zsh)"

# =========================
# fzf (fuzzy finder)
# =========================
if command -v fzf >/dev/null 2>&1; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi


# =========================
# kubectl
# =========================
kubectl() {
  if ! type __start_kubectl >/dev/null 2>&1; then
    source <(command kubectl completion zsh)
  fi
  command kubectl "$@"
}

export KUBECONFIG=$(echo ~/kube/kubeconfigs/* | tr ' ' ':')

# =========================
# fnm (Node version manager)
# =========================
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env)"
fi

# =========================
# Aliases
# =========================
alias cat='batcat'
alias zshconfig='nvim ~/.zshrc'
alias reloadzsh='source ~/.zshrc'
alias ls="eza --all --icons=always"

# Ripgrep aliases
alias grep='rg'
alias rgi='rg -i'                                    # Case insensitive
alias rgw='rg -w'                                    # Whole word
alias rgl='rg -l'                                    # List files with matches
alias rgc='rg -c'                                    # Count matches per file
alias rgn='rg -n'                                    # Show line numbers (default)
alias rgg='rg --hidden --no-ignore'                  # Search hidden/ignored files
# AND: Use function for cleaner syntax
rgand() { rg "$1" | rg "$2"; }                       # rgand pattern1 pattern2
rgand3() { rg "$1" | rg "$2" | rg "$3"; }           # rgand3 pattern1 pattern2 pattern3
# OR: Built-in with pipe operator
alias rgor='rg -e'                                   # rgor pattern1 -e pattern2 -e pattern3
# NOT: Invert match
alias rgnot='rg -v'                                  # rgnot pattern (exclude pattern)

# Kubectl aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe svc'
alias kcuc='kubectl config use-context'
alias kcgc='kubectl config get-contexts'
alias kctx='kubectl config current-context'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kex='kubectl exec -it'
alias kpf='kubectl port-forward'

# Stern (log tailing) aliases
alias klogs='stern --tail 50 --since 5m'
alias klf='stern --tail 50 --since 5m'
alias kl='stern'
alias klall='stern . --all-namespaces'

# Initialize zoxide (better cd)
eval "$(zoxide init zsh)"

# Activate syntax highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Activate autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
