local home_dir = os.getenv("HOME")

-- Wayland
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Applications
-- Prepend the flatpak/system data dirs without duplicates: this file runs again on every config
-- reload inside the same process, so plain prepending grew XDG_DATA_DIRS by 4 entries per reload
-- (which made fuzzel and other apps that scan it noticeably slow).
local function prepend_unique(dirs, existing)
    local seen, out = {}, {}
    for _, d in ipairs(dirs) do
        if d ~= "" and not seen[d] then seen[d] = true; out[#out + 1] = d end
    end
    for d in string.gmatch(existing or "", "[^:]+") do
        if not seen[d] then seen[d] = true; out[#out + 1] = d end
    end
    return table.concat(out, ":")
end
hl.env("XDG_DATA_DIRS", prepend_unique({
    home_dir .. "/.local/share/flatpak/exports/share",
    "/var/lib/flatpak/exports/share",
    "/usr/local/share",
    "/usr/share",
}, os.getenv("XDG_DATA_DIRS")))

-- Themes
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")

-- Virtual environment
hl.env("ILLOGICAL_IMPULSE_VIRTUAL_ENV", home_dir .. "/.local/state/quickshell/.venv")
