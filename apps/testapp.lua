local screen = require("screen")

function _init()
    w, h = 80, 80
    x = 0
    y = 0
    last_time = time()
    screen.init(80, 80)
end

function _update()
    x = (x + (time() - last_time)*100) % (w-16)
    y = (y + (time() - last_time)*100) % (h-16)
    last_time = time()
end

function _draw()
    cls(0)
    rectfill(x, y, x+16, y+16, 8)
end