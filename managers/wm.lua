local screen = require("screen")
local events = require("events")

local selected_wm = "den"
local current_wm = nil

local function load_wm(name)
    if current_wm then
        current_wm.unload()
    end
    
    current_wm = require(name)
    current_wm.load()
end

function _init()
    screen.init(480, 270)
    load_wm("/system/wm/"..selected_wm)
end

function _draw()
    current_wm.draw()
end

function _update()
    events.process_events()
    current_wm.update()
end

events.on_event("process_screen_update", function(event)
    -- safety
    if pid() > 3 then
        current_wm.screen_update(event)
    end
end)

events.on_event("system_kill_process", function(event)
    current_wm.delete_process(event)
end)