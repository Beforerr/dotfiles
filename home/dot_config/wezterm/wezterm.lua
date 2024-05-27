-- config: https://wezfurlong.org/wezterm/config/files.html
local wezterm = require 'wezterm'

local config = {
  -- default_prog = { '/Users/zijin/.nix-profile/bin/nu', '-l' },

  font_size = 18.0,
  color_scheme = "Catppuccin Mocha",   -- or Macchiato, Frappe, Latte

  -- enable_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,

  window_decorations = "RESIZE",
  window_background_opacity = 0.618,
  window_close_confirmation = "NeverPrompt",

  keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    { key = "LeftArrow", mods = "OPT",       action = wezterm.action { SendString = "\x1bb" } },
    -- Make Option-Right equivalent to Alt-f; forward-word
    { key = "RightArrow", mods = "OPT",      action = wezterm.action { SendString = "\x1bf" } },
    { key = 'k',        mods = 'CMD', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' },
  }
}

return config
