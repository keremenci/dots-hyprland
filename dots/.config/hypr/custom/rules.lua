-- Overrides for hyprland/rules.lua

-- Blur behind terminals (default rules disable blur for every window)
hl.window_rule({match = {class = "^(kitty)$" }, no_blur = false })

-- Apps that live on their own special workspace (Super+F2 music, F3 slack, F4 beekeeper, F5 discord).
-- Slack autostarts at login, so it opens silently instead of popping its scratchpad open.
hl.window_rule({match = {class = "^([Ss]lack)$" },                workspace = "special:slack silent" })
hl.window_rule({match = {class = "^([Ww]eb[Cc]ord)$" },           workspace = "special:discord" })
hl.window_rule({match = {initial_class = "^([Ss]potify)$" },      workspace = "special:music" })
hl.window_rule({match = {class = "^(beekeeper-studio)$" },        workspace = "special:beekeeper" })

-- The general scratchpad (Super+F1 / Ctrl+Super+S) shows one window at a time
hl.workspace_rule({ workspace = "special:special", layout = "monocle" })
