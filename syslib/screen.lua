local screen = {
}

function screen.init(w, h)
    pal()
    poke(0x5508, 0x3f)
    poke(0x5509, 0x3f)
    poke(0x5f56, 0x40)

    poke(0x0, 0x1)
    --poke(0x4000, get(_fetch_local("/ststem/fonts/lil.font")))

    screen.update(w, h)
end

function screen.update(w, h)
    screen._display = userdata("u8", w, h)
    screen.map_screen(screen._display)
    screen.set_draw_target()
end

function screen.map_screen(u)
    poke2(0x5478, u:width())
    poke2(0x547a, u:height())
    poke2(0x547c, 0)
    _map_ram(u, 0x10000)
end

function screen.set_draw_target(u)
    screen._target = u or screen._display
    _set_draw_target(screen._target)
end

return screen