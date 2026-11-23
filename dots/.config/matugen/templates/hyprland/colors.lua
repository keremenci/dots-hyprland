hl.config({
    general = {
        col = {
            active_border   = "rgba({{colors.outline_variant.default.hex_stripped}}77)",
            inactive_border = "rgba({{colors.surface_container_low.default.hex_stripped}}33)",
        },
    },
    misc = {
        background_color = "rgba({{colors.surface.dark.hex_stripped}}FF)",
    },
    group = {
        -- Grouped windows keep the normal window borders; locked groups get the tertiary accent
        col = {
            border_active          = "rgba({{colors.outline_variant.default.hex_stripped}}77)",
            border_inactive        = "rgba({{colors.surface_container_low.default.hex_stripped}}33)",
            border_locked_active   = "rgba({{colors.tertiary.default.hex_stripped}}AA)",
            border_locked_inactive = "rgba({{colors.tertiary.default.hex_stripped}}44)",
        },
        groupbar = {
            col = {
                active          = "rgba({{colors.surface_container_high.default.hex_stripped}}FF)",
                inactive        = "rgba({{colors.surface_container_low.default.hex_stripped}}FF)",
                locked_active   = "rgba({{colors.tertiary_container.default.hex_stripped}}FF)",
                locked_inactive = "rgba({{colors.surface_container_low.default.hex_stripped}}FF)",
            },
            text_color                 = "rgba({{colors.primary.default.hex_stripped}}FF)",
            text_color_inactive        = "rgba({{colors.on_surface_variant.default.hex_stripped}}FF)",
            text_color_locked_active   = "rgba({{colors.on_tertiary_container.default.hex_stripped}}FF)",
            text_color_locked_inactive = "rgba({{colors.on_surface_variant.default.hex_stripped}}FF)",
        },
    },
})

hl.window_rule({
    match        = { pin = 1 },
    border_color = "rgba({{colors.primary.default.hex_stripped}}AA) rgba({{colors.primary.default.hex_stripped}}77)",
})
