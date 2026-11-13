# Tools Reference

Quick reference for all configured tools and aliases.

## Kubectl Aliases

### Basic Commands
```bash
k                      # kubectl
kgp                    # kubectl get pods
kgd                    # kubectl get deployments
kgs                    # kubectl get svc
kgn                    # kubectl get nodes
```

### Describe
```bash
kdp <pod>              # kubectl describe pod
kdd <deployment>       # kubectl describe deployment
kds <service>          # kubectl describe svc
```

### Context Management
```bash
kctx                   # Show current context
kcgc                   # Get all contexts
kcuc <context>         # Use context
```

### Apply/Delete
```bash
kaf <file>             # kubectl apply -f
kdf <file>             # kubectl delete -f
```

### Advanced
```bash
kex <pod> -- sh        # kubectl exec -it (shell into pod)
kpf <svc> 8080:8080    # kubectl port-forward
```

## Stern (Log Tailing)

```bash
klogs <pattern>        # Tail logs (50 lines, 5min, colored)
klf <pattern>          # Same as klogs
kl <pattern>           # Basic stern
klall                  # Tail ALL pods in all namespaces

# Examples
klogs api              # All pods with "api" in name
klogs ^frontend        # Pods starting with "frontend"
kl api --since 15m     # Custom time range
kl api -l app=backend  # Filter by label
```

## Ripgrep Aliases

### Basic
```bash
rg <pattern>           # Basic search
rgi <pattern>          # Case insensitive
rgw <pattern>          # Whole word only
rgl <pattern>          # List files with matches
rgc <pattern>          # Count matches per file
rgg <pattern>          # Search hidden/ignored files
```

### Logic Operations
```bash
# AND (all must match)
rgand error 500        # Lines with both "error" AND "500"
rgand3 a b c           # Lines with all three patterns

# OR (any can match)
rgor error -e warning -e fail    # Any of these
rg 'error|warning|fail'          # Alternative syntax

# NOT (exclude)
rgnot test             # All lines EXCEPT with "test"
rg error | rgnot debug # error but not debug
```

### Examples
```bash
# Find errors excluding test files
rg error --glob '!*test*'

# Case insensitive multi-pattern
rgi 'error|warning|critical'

# Search in specific file types
rg pattern -t js       # JavaScript files only
rg pattern -t py       # Python files only

# Complex: has user and login, but not admin
rgand user login | rgnot admin
```

## Directory Navigation

```bash
z <dir>                # Jump to frequently used directory
z proj                 # Fuzzy match "project"
cd -                   # Go to previous directory
dirs -v                # Show directory stack
d                      # Show directory stack (if aliased)
```

## File Operations

```bash
ls                     # eza with icons
cat <file>             # batcat with syntax highlighting
grep                   # Actually uses ripgrep
```

## Git Shortcuts

```bash
# (Add your common git aliases here)
```

## FZF (Fuzzy Finder)

```bash
Ctrl+R                 # Fuzzy search command history
Ctrl+T                 # Fuzzy find files
Alt+C                  # Fuzzy cd into directory
**<TAB>                # Trigger fuzzy completion
```

## Zsh Editing

```bash
Ctrl+Left              # Move word backward
Ctrl+Right             # Move word forward
Ctrl+Backspace         # Delete word backward
Ctrl+Delete            # Delete word forward
Up/Down                # History search (context-aware)
```

## kitty Shortcuts

### Panes
```bash
Ctrl+Shift+O           # Split pane down
Ctrl+Shift+E           # Split pane right
Ctrl+Shift+Arrow       # Navigate between panes
Ctrl+Shift+W           # Close pane (with confirmation)
```

### Utility
```bash
Ctrl+Shift+K           # Clear scrollback
Ctrl+Shift+F           # Search scrollback (fzf)
Ctrl+Shift+Z           # Zoom current pane (toggle)
Ctrl+Shift+T           # New tab in current directory
Ctrl+Shift+F5          # Reload kitty config
```

## Kubernetes Quick Tips

### Get logs from pods
```bash
klogs api              # Much easier than kubectl logs -f
```

### Switch contexts quickly
```bash
kcgc                   # List contexts
kcuc context-name      # Switch context
```

### Exec into pod
```bash
kgp                    # See pod names
kex pod-name -- sh     # Shell into it
```

### Port forwarding
```bash
kpf svc/api 8080:8080  # Forward service port
kpf pod/name 3000:3000 # Forward pod port
```

## Common Workflows

### Debug Application
```bash
1. klogs myapp              # Watch logs
2. kgp | grep myapp         # Find pod name
3. kex myapp-xxx -- sh      # Shell into pod
4. kdp myapp-xxx            # Describe pod for details
```

### Switch Environments
```bash
1. kcgc                     # List contexts
2. kcuc new-context         # Switch
3. kctx                     # Verify
4. kgp                      # Check resources
```

### Search Logs
```bash
klogs api | rgi error       # Case insensitive error search
klogs api | rgand error 500 # Multiple patterns
klall | rg 'error|fail'     # All pods, any pattern
```

## Pro Tips

1. **Use stern instead of kubectl logs -f** - Auto-follows all matching pods
2. **Use ripgrep instead of grep** - Much faster, better defaults
3. **Use z instead of cd** - Learns your frequently used dirs
4. **Use fzf (Ctrl+R)** - Never remember full commands again
5. **Right-click kube context** - Fastest way to switch clusters
6. **Tab completion works everywhere** - k get po<TAB> works!
