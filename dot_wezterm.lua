-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

local act = wezterm.action

------- Configuration -------

-- General appearance
config.front_end = 'WebGpu'
config.color_scheme = 'Tokyo Night'
config.window_background_opacity = 0.98

config.font_size = 14
config.font = wezterm.font_with_fallback {
  'Iosevka Term',
}

config.default_cursor_style = 'SteadyBar'
config.cursor_thickness = '200%'

config.enable_scroll_bar = true

-- Keybindings
local openPaneMods = 'SUPER|CTRL'

config.keys = {
  -- OPT-Left/Right and CMD-Left/Right to match macOS shortcuts
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = act.SendKey { key = 'b', mods = 'ALT' },
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = act.SendKey { key = 'f', mods = 'ALT' },
  },
  {
    key = 'LeftArrow',
    mods = 'SUPER',
    action = act.SendKey { key = 'a', mods = 'CTRL' },
  },
  {
    key = 'RightArrow',
    mods = 'SUPER',
    action = act.SendKey { key = 'e', mods = 'CTRL' },
  },

  -- Opening panes
  {
    key = 'LeftArrow',
    mods = openPaneMods,
    action = act.SplitPane { direction = 'Left' },
  },
  {
    key = 'RightArrow',
    mods = openPaneMods,
    action = act.SplitPane { direction = 'Right' },
  },
  {
    key = 'UpArrow',
    mods = openPaneMods,
    action = act.SplitPane { direction = 'Up' },
  },
  {
    key = 'DownArrow',
    mods = openPaneMods,
    action = act.SplitPane { direction = 'Down' },
  },
  -- Changing panes
  {
    key = '[',
    mods = openPaneMods,
    action = act.ActivatePaneDirection 'Prev',
  },
  {
    key = ']',
    mods = openPaneMods,
    action = act.ActivatePaneDirection 'Next',
  },
  -- Closing tabs/panes
  {
    key = 'w',
    mods = 'SUPER',
    action = act.CloseCurrentPane { confirm = true },
  },
  {
    key = 'w',
    mods = 'SUPER|SHIFT',
    action = act.CloseCurrentTab { confirm = true },
  },
  -- Jumping to prompts
  {
    key = 'UpArrow',
    mods = 'SUPER',
    action = act.ScrollToPrompt(-1),
  },
  {
    key = 'DownArrow',
    mods = 'SUPER',
    action = act.ScrollToPrompt(1),
  },
}

-- Tab bar config
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

-- Miscellaneous config
config.skip_close_confirmation_for_processes_named = {} -- always ask for confirm

-----------------------------

return config

