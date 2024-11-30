-- input.lua requires events module
local events = require("events")

local state = {
    mouse = {
        x = 0,
        y = 0,
        b = 0
    },
    keyboard = {
        frame_keys = {},
        keys = {}
    }
}
local inputs = {}

events.on_event("mouse", function(event)
    state.mouse.x, state.mouse.y, state.mouse.b = event.mx, event.my, event.mb
end)

events.hook("reset_event_state", function()
    state.keyboard.frame_keys = {}
end)

events.on_event("keyup", function(event)
    add(state.keyboard.keys, events.scancode)
    add(state.keyboard.frame_keys, events.scancode)
end)

events.on_event("keydown", function(event)
    del(state.keyboard.keys, events.scancode)
end)

function inputs.mouse()
    return state.mouse.x, state.mouse.y, state.mouse.m
end

function inputs.key(scancode)
    return contains(state.keyboard.keys, scancode)
end

function inputs.keyp(scancode)
    return contains(state.keyboard.frame_keys, scancode)
end