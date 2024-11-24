local screen = {
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
    --poke(0x4000, get(_fetch_local("/ststem/fonts/lil.font")))

    screen.update(w, h)
end

function screen.update(w, h)
    screen._display = userdata("u8", w, h)
    screen.map_screen(screen._display)
    screen.set_draw_target()
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

return screen