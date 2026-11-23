-- Overrides for hyprland/rules.lua

-- Blur behind terminals (default rules disable blur for every window)
hl.window_rule({match = {class = "^(kitty)$" }, no_blur = false })
