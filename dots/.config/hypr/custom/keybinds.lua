hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )

-- Keybinds carried over from ML4W. Where they clash with defaults in hyprland/keybinds.lua,
-- the default is unbound first and, if worth keeping, moved to a free key.

local function rebind(keys, dispatcher, opts)
    hl.unbind(keys)
    hl.bind(keys, dispatcher, opts)
end

--# Shell
-- A Super press on its own does nothing: no search on tap, no workspace numbers while held
for _, keys in ipairs({ "SUPER + SUPER_L", "SUPER + SUPER_R", "SUPER_L", "SUPER_R" }) do
    hl.unbind(keys)
end
rebind("SUPER + D", hl.dsp.global("quickshell:searchToggle"), { description = "Shell: Toggle search" })
rebind("SUPER + B", hl.dsp.exec_cmd(browser), { description = "App: Browser" })
hl.bind("SUPER + CTRL + Q", hl.dsp.global("quickshell:sessionToggle"), { description = "Shell: Toggle session menu" })
rebind("SUPER + L", hl.dsp.global("quickshell:sessionToggle"))
hl.bind("SUPER + CTRL + L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Session: Lock" })
hl.bind("SUPER + CTRL + E", hl.dsp.global("quickshell:overviewEmojiToggle"))
hl.bind("SUPER + CTRL + C", hl.dsp.global("quickshell:searchToggle"))
hl.bind("SUPER + CTRL + K", hl.dsp.global("quickshell:cheatsheetToggle"))
hl.bind("SUPER + CTRL + B", hl.dsp.global("quickshell:barToggle"), { description = "Shell: Toggle bar" })
hl.bind("SUPER + CTRL + W", hl.dsp.global("quickshell:wallpaperSelectorToggle"), { description = "Shell: Wallpaper selector" })
hl.bind("SUPER + SHIFT + W", hl.dsp.global("quickshell:wallpaperSelectorRandom"), { description = "Shell: Random wallpaper" })
rebind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Hyprland: Reload config" })
hl.bind("SUPER + Z", hl.dsp.exec_cmd("missioncenter"), { description = "App: Mission Center" })

-- Defaults displaced by the binds below
hl.bind("SUPER + ALT + K", hl.dsp.global("quickshell:oskToggle"), { description = "Shell: Toggle on-screen keyboard" })
hl.bind("SUPER + ALT + G", hl.dsp.global("quickshell:overlayToggle"), { description = "Shell: Toggle widget overlay" })
hl.bind("SUPER + ALT + Tab", hl.dsp.global("quickshell:overviewWorkspacesToggle"), { description = "Shell: Toggle overview" })
hl.bind("SUPER + ALT + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Window: Maximize" })

--# Screenshots
rebind("Print", hl.dsp.global("quickshell:regionScreenshot"), { description = "Utilities: Screen snip" })
hl.bind("SUPER + Print", hl.dsp.exec_cmd("grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\" - | wl-copy"),
    { description = "Utilities: Screenshot monitor to clipboard" })

--# Window
rebind("SUPER + T", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Float/Tile" })
rebind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Window: Toggle split" })
rebind("SUPER + K", hl.dsp.layout("swapsplit"), { description = "Window: Swap split" })
for i = 1, 4 do
    local arrowkey = { "Left", "Right", "Up", "Down" }
    local dir = { "l", "r", "u", "d" }
    local delta = { { -100, 0 }, { 100, 0 }, { 0, -100 }, { 0, 100 } }
    rebind("SUPER + SHIFT + " .. arrowkey[i], hl.dsp.window.resize({ x = delta[i][1], y = delta[i][2], relative = true }), { repeating = true })
    hl.bind("SUPER + ALT + " .. arrowkey[i], hl.dsp.window.move({ direction = dir[i] }))
end

--# Groups
rebind("SUPER + G", hl.dsp.group.toggle(), { description = "Group: Toggle" })
-- Super+Tab cycles stacked windows: the monocle scratchpad's windows when in it, group tabs elsewhere
local function in_monocle_scratchpad()
    local w = hl.get_active_window()
    return w ~= nil and w.workspace ~= nil and w.workspace.name == "special:special"
end
rebind("SUPER + Tab", function()
    hl.dispatch(in_monocle_scratchpad() and hl.dsp.layout("cyclenext") or hl.dsp.group.next())
end, { description = "Window: Next stacked (group tab / scratchpad)" })
rebind("SUPER + SHIFT + Tab", function()
    hl.dispatch(in_monocle_scratchpad() and hl.dsp.layout("cycleprev") or hl.dsp.group.prev())
end, { description = "Window: Previous stacked (group tab / scratchpad)" })
rebind("SUPER + Next", hl.dsp.group.next())
rebind("SUPER + Prior", hl.dsp.group.prev())
rebind("SUPER + mouse:276", hl.dsp.group.next())
rebind("SUPER + mouse:275", hl.dsp.group.prev())

--# Workspaces
for i = 1, 10 do
    hl.bind("SUPER + SHIFT + " .. (i % 10), function()
        hl.dispatch(hl.dsp.window.move({ workspace = workspace_in_group(i) }))
    end, { description = "Window: Move to workspace " .. i })
end
hl.bind("ALT + Tab", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("ALT + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }))
rebind("SUPER + CTRL + Down", hl.dsp.focus({ workspace = "empty" }), { description = "Workspace: Next empty" })

--# Scratchpads
local scratchpads = { "F1", "F2", "F3", "F4", "F5" }
local scratchnames = { "special", "music", "slack", "beekeeper", "discord" }
for i = 1, #scratchpads do
    hl.bind("SUPER + " .. scratchpads[i], hl.dsp.workspace.toggle_special(scratchnames[i]))
    hl.bind("SUPER + SHIFT + " .. scratchpads[i],
        hl.dsp.window.move({ workspace = "special:" .. scratchnames[i], follow = false }))
end

--# TOTP codes from Ente Auth (synced into the keyring, see custom/scripts/totp)
hl.bind("SUPER + SHIFT + O", hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/totp pick"), { description = "Utilities: Copy a TOTP code" })
