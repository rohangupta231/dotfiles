local wezterm = require 'wezterm'
local act = wezterm.action

-- Helper function to get current kube context directly from kubectl
local function get_kube_context()
  local home = os.getenv('HOME')
  local success, stdout = wezterm.run_child_process({
    'bash',
    '-c',
    'export KUBECONFIG=$(echo ' .. home .. '/kube/kubeconfigs/* | tr " " ":") && CTX=$(kubectl config current-context 2>/dev/null) && NS=$(kubectl config view --minify --output "jsonpath={..namespace}" 2>/dev/null); NS=${NS:-default}; [[ -n "$CTX" ]] && echo "${CTX}|${NS}"'
  })
  
  if success and stdout and stdout ~= '' then
    local output = stdout:gsub('%s+', ''):match('^%s*(.-)%s*$')
    local ctx, ns = output:match('([^|]+)|([^|]+)')
    if ctx and ns then
      return { context = ctx, namespace = ns }
    end
  end
  return nil
end

-- Helper function to get all available kube contexts
local function get_all_kube_contexts()
  -- Build KUBECONFIG from all files in kubeconfigs directory
  local home = os.getenv('HOME')
  local success, stdout, stderr = wezterm.run_child_process({
    'bash',
    '-c',
    'export KUBECONFIG=$(echo ' .. home .. '/kube/kubeconfigs/* | tr " " ":") && kubectl config get-contexts -o name'
  })
  
  if success and stdout and stdout ~= '' then
    local contexts = {}
    for context in stdout:gmatch('[^\r\n]+') do
      if context ~= '' then
        table.insert(contexts, { 
          label = '•'  .. ' ' .. context, 
          id = context 
        })
      end
    end
    return contexts
  end
  return {}
end

-- Helper function to get git branch
local function get_git_branch(cwd)
  if not cwd then return '' end
  
  local success, stdout, stderr = wezterm.run_child_process({
    'git',
    '-C',
    cwd,
    'branch',
    '--show-current'
  })
  
  if success and stdout then
    local branch = stdout:gsub('%s+', '')
    return branch ~= '' and ' ' .. branch or ''
  end
  return ''
end

-- Helper function to get docker container health status
local function get_docker_health()
  local success, stdout = wezterm.run_child_process({
    'bash',
    '-c',
    'docker ps --format "{{.Names}}|{{.Status}}" 2>/dev/null | grep -i "health"'
  })
  
  if success and stdout and stdout ~= '' then
    local containers = {}
    for line in stdout:gmatch('[^\r\n]+') do
      local name, status = line:match('([^|]+)|(.+)')
      if name and status then
        local health = 'unknown'
        local color = '#7f849c'  -- gray
        
        if status:match('%(healthy%)') then
          health = 'healthy'
          color = '#9ece6a'  -- green
        elseif status:match('%(unhealthy%)') then
          health = 'unhealthy'
          color = '#f7768e'  -- red
        elseif status:match('%(starting%)') or status:match('%(health: starting%)') then
          health = 'starting'
          color = '#e0af68'  -- yellow
        end
        
        table.insert(containers, { name = name, health = health, color = color })
      end
    end
    return containers
  end
  return nil
end

-- Status bar update
wezterm.on('update-status', function(window, pane)
  -- Get current working directory
  local cwd_uri = pane:get_current_working_dir()
  local cwd = ''
  if cwd_uri then
    cwd = cwd_uri.file_path:gsub(wezterm.home_dir, '~')
  end
  
  -- Get git branch
  local git_branch = ''
  if cwd_uri then
    git_branch = get_git_branch(cwd_uri.file_path)
  end
  
  -- Get kube context
  local kube_context = get_kube_context()
  
  -- Get docker health status
  local docker_containers = get_docker_health()
  
  -- Build right status
  local status_parts = {}
  
  -- Docker health status (if any containers with health checks)
  if docker_containers and #docker_containers > 0 then
    for _, container in ipairs(docker_containers) do
      local icon = ''
      if container.health == 'healthy' then
        icon = ''
      elseif container.health == 'unhealthy' then
        icon = ''
      elseif container.health == 'starting' then
        icon = ''
      end
      
      table.insert(status_parts, {
        { Foreground = { Color = '#565f89' } },
        { Text = '│ ' },
        { Foreground = { Color = container.color } },
        { Text = icon .. ' ' .. container.name .. ' ' },
      })
    end
  end
  
  -- Git branch (if exists)
  if git_branch ~= '' then
    table.insert(status_parts, {
      { Foreground = { Color = '#565f89' } },
      { Text = '│ ' },
      { Foreground = { Color = '#9ece6a' } },
      { Text = '' .. git_branch .. ' ' },
    })
  end
  
  -- Kube context (if exists, clickable)
  if kube_context then
    table.insert(status_parts, {
      { Foreground = { Color = '#565f89' } },
      { Text = '│ ' },
      'ResetAttributes',
      { Foreground = { Color = '#bb9af7' } },
      { Text = '󰠳  ' .. kube_context.context },
      'ResetAttributes',
      { Foreground = { Color = '#7aa2f7' } },
      { Text = ':' .. kube_context.namespace .. ' ' },
    })
  end
  
  -- Flatten the status parts
  local status = {}
  for _, part in ipairs(status_parts) do
    for _, item in ipairs(part) do
      table.insert(status, item)
    end
  end

  local hostname = wezterm.hostname()
  
  window:set_left_status(wezterm.format({
    { Foreground = { Color = '#7aa2f7' } },
    { Text = ' ' .. hostname .. ' ' },
    { Foreground = { Color = '#565f89' } },
    { Text = '│ ' }
  }))
  window:set_right_status(wezterm.format(status))
end)

-- Tab title formatting
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local index = tab.tab_index + 1
  
  local bg = '#45475a'
  local fg = '#cdd6f4'
  
  if tab.is_active then
    bg = '#74c7ec'
    fg = '#11111b'
  elseif hover then
    bg = '#5d87a3'
    fg = '#1c1b19'
  end
  
  return {
    { Background = { Color = 'rgba(0, 0, 0, 0.4)' } },
    { Foreground = { Color = bg } },
    { Text = '' },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = '   ' .. index .. '   ' },
    { Background = { Color = 'rgba(0, 0, 0, 0.4)' } },
    { Foreground = { Color = bg } },
    { Text = '' },
  }
end)

return {
  color_scheme = "Tokyo Night",
  font = wezterm.font_with_fallback({
    "JetBrains Mono",
    "Symbols Nerd Font",
  }),
  font_size = 12.5,
  line_height = 1.1,

  -- Tab bar and status bar at bottom (tmux-like)
  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  tab_bar_at_bottom = true,  -- Status bar at bottom like tmux
  hide_tab_bar_if_only_one_tab = false,
  show_tab_index_in_tab_bar = true,
  
  -- Tab bar and status colors
  colors = {
    tab_bar = {
      background = 'rgba(0, 0, 0, 0.4)',
    },
  },

  initial_cols = 140,
  initial_rows = 40,
  window_decorations = "RESIZE",

  window_background_opacity = 0.95,

  window_padding = {
    left = 10,
    right = 10,
    top = 20,
    bottom = 0,
  },

  cursor_blink_rate = 800,
  default_cursor_style = "BlinkingBlock",
  scrollback_lines = 10000,
  inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8,
  },
  status_update_interval = 5000,  -- Update every 5 seconds

  hyperlink_rules = wezterm.default_hyperlink_rules(),
  
  -- Mouse bindings for status bar
  mouse_bindings = {
    -- Right-click on status bar to show kube context menu
    {
      event = { Up = { streak = 1, button = 'Right' } },
      mods = 'NONE',
      action = wezterm.action_callback(function(window, pane)
        local contexts = get_all_kube_contexts()
        
        if #contexts == 0 then
          window:toast_notification('WezTerm', 'No kubectl contexts found', nil, 4000)
          return
        end
        
        window:perform_action(
          act.InputSelector {
            action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
              if not id and not label then
                return
              end
              
              -- Switch context directly with kubectl using the id (actual context name)
              local home = os.getenv('HOME')
              local success, stdout, stderr = wezterm.run_child_process({
                'bash',
                '-c',
                'export KUBECONFIG=$(echo ' .. home .. '/kube/kubeconfigs/* | tr " " ":") && kubectl config use-context "' .. id .. '"'
              })
              
              if not success then
                inner_window:toast_notification('WezTerm', 'Failed to switch context', nil, 3000)
              end
            end),
            title = '󰠳 Select Kubernetes Context',
            choices = contexts,
            fuzzy = true,
            alphabet = '123456789',
          },
          pane
        )
      end),
    },
  },

  keys = {
    { key = 'k', mods = 'CTRL|SHIFT', action = act.ClearScrollback 'ScrollbackAndViewport' },
    { key = 'f', mods = 'CTRL|SHIFT', action = act.Search 'CurrentSelectionOrEmptyString' },
    
    -- Pane splitting (Terminator-style)
    { key = 'o', mods = 'CTRL|SHIFT', action = act.SplitPane { direction = 'Down', size = { Percent = 50 } } },
    { key = 'e', mods = 'CTRL|SHIFT', action = act.SplitPane { direction = 'Right', size = { Percent = 50 } } },
    
    -- Pane navigation
    { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
    { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },
    { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up' },
    { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down' },
    
    -- Close pane
    { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = true } },
  }
}
