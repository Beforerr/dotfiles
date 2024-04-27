-- config: https://wezfurlong.org/wezterm/config/files.html
local wezterm = require 'wezterm'
local config = {
    font_size = 18.0,
    color_scheme = "Catppuccin Mocha", -- or Macchiato, Frappe, Latte
    
    -- enable_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,

    window_decorations = "RESIZE",
    window_background_opacity = 0.5,
}

return config