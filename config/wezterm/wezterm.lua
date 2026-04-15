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

-- Helper function to get SSH session details from pane
local function get_ssh_info(pane)
  if not pane then return nil end

  -- Get foreground process info
  local process_name = pane:get_foreground_process_name()

  if not process_name then return nil end

  -- Check if the process is ssh
  if process_name:find('ssh') then
    -- Try to get full command line to extract destination
    local success, stdout = wezterm.run_child_process({
      'bash',
      '-c',
      'ps -p ' .. pane:pane_id() .. ' -o command= 2>/dev/null || ps aux | grep "ssh " | grep -v grep | tail -1'
    })

    if success and stdout then
      -- Try to extract ssh destination (user@host or just host)
      local destination = stdout:match('ssh%s+[^%s]*%s+([^%s@]+@[^%s]+)') or
                         stdout:match('ssh%s+([^%s@]+@[^%s]+)') or
                         stdout:match('ssh%s+[^%s]*%s+([^%s]+)') or
                         stdout:match('ssh%s+([^%s]+)')

      if destination then
        local user, host = destination:match('([^@]+)@(.+)')
        if not user then
          host = destination
          user = os.getenv('USER') or os.getenv('USERNAME')
        end

        return {
          user = user,
          hostname = host,
          destination = destination
        }
      end
    end
  end

  return nil
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

  -- Get kube context
  local kube_context = get_kube_context()

  -- Get docker health status
  local docker_containers = get_docker_health()

  -- Get SSH session info
  local ssh_info = get_ssh_info(pane)

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
        { Foreground = { Color = container.color } },
        { Text = icon .. ' ' .. container.name .. ' ' },
        { Foreground = { Color = '#565f89' } },
        { Text = '│ ' },
      })

    end
  end

  -- Kube context (if exists, clickable)
  if kube_context then
    table.insert(status_parts, {
      'ResetAttributes',
      { Foreground = { Color = '#bb9af7' } },
      { Text = '󰠳 ' .. kube_context.context },
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

  -- Left status: Show SSH if active, otherwise hostname
  local left_status = {}
  if ssh_info then
    left_status = {
      { Foreground = { Color = '#f7768e' } },
      { Text = ' ' .. ssh_info.destination .. ' ' },
      { Foreground = { Color = '#565f89' } }
    }
  else
    local hostname = wezterm.hostname()
    left_status = {
      { Foreground = { Color = '#cdd6f4' } },
      { Text = ' ' .. hostname .. ' ' },
      { Foreground = { Color = '#565f89' } }
    }
  end

  window:set_left_status(wezterm.format(left_status))
  window:set_right_status(wezterm.format(status))
end)

-- Tab title formatting
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local index = tab.tab_index + 1

  local bg = '#45475a'
  local fg = '#cdd6f4'

  local bg, fg, sep_bg
  if tab.is_active then
    bg, fg, sep_bg = '#7aa2f7', '#1a1b26', '#7aa2f7'
  elseif hover then
    bg, fg, sep_bg = '#414868', '#a9b1d6', '#414868'
  else
    bg, fg, sep_bg = '#24283b', '#565f89', '#24283b'
  end

  return {
    { Background = { Color = '#1a1b26' } },
    { Foreground = { Color = sep_bg } },
    { Text = '' },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
    { Text = ' ' .. index .. ' ' },
    { Background = { Color = '#1a1b26' } },
    { Foreground = { Color = sep_bg } },
    { Text = '' },
  }
end)

return {
  color_scheme = "Tokyo Night",
  font = wezterm.font_with_fallback({
    "JetBrains Mono",
    "Symbols Nerd Font",
  }),
  font_size = 15,
  line_height = 1.1,

  -- Tab bar and status bar at bottom (tmux-like)
  enable_tab_bar = true,
  use_fancy_tab_bar = true,
  tab_bar_at_bottom = true,
  hide_tab_bar_if_only_one_tab = false,
  show_tab_index_in_tab_bar = false,

  -- Tab bar and status colors
  colors = {
    background = '#1e1e2e',
    tab_bar = {
      background = '#1e1e2e',
      active_tab = {
        bg_color = '#7aa2f7',
        fg_color = '#1a1b26',
        intensity = 'Bold',
      },
      inactive_tab = {
        bg_color = '#24283b',
        fg_color = '#565f89',
      },
      inactive_tab_hover = {
        bg_color = '#414868',
        fg_color = '#a9b1d6',
      },
      new_tab = {
        bg_color = '#1e1e2e',
        fg_color = '#414868',
      },
      new_tab_hover = {
        bg_color = '#24283b',
        fg_color = '#7aa2f7',
      },
    },
  },

  tab_max_width = 40,

  initial_cols = 140,
  initial_rows = 35,
  window_decorations = "RESIZE",

  window_background_opacity = 1.0,

  window_padding = {
    left = 12,
    right = 12,
    top = 12,
    bottom = 10,
  },

  cursor_blink_rate = 800,
  default_cursor_style = "BlinkingBlock",
  scrollback_lines = 10000,
  inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7,
  },
  status_update_interval = 5000,  -- Update every 5 seconds

  window_frame = {
    font = wezterm.font_with_fallback({
      "JetBrains Mono",
      "Symbols Nerd Font",
    }),
    font_size = 16.0,
    active_titlebar_bg   = '#1e1e2e',
    inactive_titlebar_bg = '#1e1e2e',
    border_left_color    = '#404765',
    border_right_color   = '#404765',
    border_top_color     = '#404765',
    border_bottom_color  = '#404765',
    border_left_width    = '1px',
    border_right_width   = '1px',
    border_top_height    = '1px',
    border_bottom_height = '1px',
  },

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
