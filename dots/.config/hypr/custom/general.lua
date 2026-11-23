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
    -- Group tabs (Super+G) as a title-bar strip attached to the window; colors come from the matugen template
    group = {
        groupbar = {
            font_family = "Fira Sans",
            font_size = 14,
            font_weight_active = "semibold",
            font_weight_inactive = "medium",
            height = 30,
            gradients = true, -- filled tabs instead of a thin indicator line
            rounding = 12,
            gradient_rounding = 12,
            round_only_edges = true, -- one strip with rounded ends, not separate pills
            gradient_round_only_edges = true,
            indicator_height = 0,
            gaps_in = 2,
            gaps_out = 0,
            keep_upper_gap = false,
            blur = false,
        },
    },
})
