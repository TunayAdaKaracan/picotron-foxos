-- Screen requires process module
local process = require("process")

local screen = {
    _default_fonts = {
        _fetch_local("/system/fonts/p8.font"),
        _fetch_local("/system/fonts/lil.font")
    }
}

function screen.init(w, h)
    -- Some draw default stuff i really don't care much
    pal()
    poke(0x5508, 0x3f)
    poke(0x5509, 0x3f)
    poke(0x5f56, 0x40)

    -- This process is no more headless
    poke(0x0, 0x1)

    -- TODO: Add font.
    -- I am lazy af
    --poke(0x4000, get(_fetch_local("/system/fonts/lil.font")))

    screen.update(w, h)
end

function screen.update(w, h)
    screen._display = userdata("u8", w, h)
    screen.map_screen(screen._display)
    screen.set_draw_target()
    process.broadcast("process_screen_update", {pid=pid(), width=w, height=h})
end

function screen.map_screen(u)
    -- Set window width, height, vidmode
    -- I have zero idea about what vidmode really does.
    -- Each of these values are u16, without these blitting another process's screen to WM does not work
    poke2(0x5478, u:width(), u:height(), 0)
    _map_ram(u, 0x10000)
end

function screen.set_draw_target(u)
    screen._target = u or screen._display
    _set_draw_target(screen._target)
end

-- Maybe let user do this without a function?
function screen.set_default_primary_font(font)
    screen._default_fonts[1] = font
end

function screen.set_default_secondary_font(font)
    screen._default_fonts[2] = font
end

function screen.set_primary_font(font)
    local new_font = font or screen._default_fonts[1]
    poke(0x4000, get(font))
end

-- TODO: Lookup secondary font location
function screen.set_secondary_font(font)
    local new_font = font or screen._default_fonts[2]
    --poke()
end

return screen