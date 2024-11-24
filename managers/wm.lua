local events = require("events")
local screen = require("screen")

function _init()
    screen.init(480, 270)
end

function _draw()
    cls(7)
    rect(0, 0, 100, 100, 22)
end

function _update()
    events.process_events()
end

events.on_event("*", function(event)
    send_message(2, event)
end)