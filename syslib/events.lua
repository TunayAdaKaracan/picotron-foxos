local events = {}

local event_handlers = {}
local forward = {}
local default_handlers = {
    keydown = keydown,
    keyup = keyup
}

-- TODO: Support wildcards
function events.on_event(name, func)
    event_handlers[name] = event_handlers[name] or {}
    add(event_handlers[name], func)
end

function events.process_events()
    local processed_events = {}
    reset_event_states()
    repeat
        local msg = _read_message()
        if not msg then return end

        add(process_events, msg)
        
        for _, func in pairs(forward) do
            func(msg)
        end

        if default_handlers[msg.event] then
            default_handlers[msg.event](msg.event)
        end

        if event_handlers[msg.event] then
            for _, func in pairs(event_handlers[msg.event]) do
                func(msg)
            end
        end

    until not msg

    return processed_events
end

-- TODO: Replace this with generic events
function events.subscribe_to_events(func)
    add(forward, func)
end

function events.wait_for_event(name, check)
    local exit = false
    while not exit do
        repeat
            local msg = _read_message()
            if not msg then break end

            if msg.event == name then
                if not check or check(msg) then
                    return msg
                end
            end
        until not msg
        _frame_end()
    end
end

local function reset_event_states()
    frame_keys = {}
end

-- Keyboard events
-- TODO: Key Mappings
-- TODO: Maybe inputs should have their own module?
local keys = {}
local frame_keys = {}

local function contains(t, val)
    for _, tval in pairs(t) do
        if tval == val then return true end
    end
    return false
end

local function keydown(msg)
    add(keys, msg.scancode)
    add(frame_keys, msg.scancode)
end

local function keyup(msg)
    del(keys, msg.scancode)
end

function events.key(scancode)
    return contains(keys, scancode)
end

function events.keyp(scancode)
    return contains(frame_keys, scancode)
end

return events