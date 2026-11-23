-- Overrides for hyprland/general.lua

hl.config({
    input = {
        kb_layout = "tr",
    },
    -- Blur as in the old ML4W setup: lighter and less tinted than the defaults
    decoration = {
        blur = {
            size = 6,
            passes = 2,
            noise = 0.0117,
            contrast = 0.8916,
            brightness = 1.0,
            vibrancy = 0.1696,
            vibrancy_darkness = 0.0,
        },
    },
})
