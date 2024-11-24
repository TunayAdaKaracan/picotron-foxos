local events = {}

local event_handlers = {}
local forward = {}

local keys = {}
local frame_keys = {}

-- TODO: Support wildcards
function events.on_event(name, func)
    if not event_handlers[name] then
        event_handlers[name] = {}
    end
    add(event_handlers[name], func)
end

function events.process_events()
    frame_keys = {}
    repeat
        local msg = _read_message()
        if not msg then return end

        for _, func in pairs(forward) do
            func(msg)
        end

        if msg.event == "keydown" then
            add(keys, msg.scancode)
            add(frame_keys, msg.scancode)
        elseif msg.event == "keyup" then
            del(keys, msg.scancode)
        end

        if event_handlers[msg.event] then
            for _, func in pairs(event_handlers[msg.event]) do
                func(msg)
            end
        end

    until not msg

    return all_events
end

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

local function contains(t, val)
    for _, tval in pairs(t) do
        if tval == val then return true end
    end
    return false
end

function events.key(scancode)
    return contains(keys, scancode)
end

function events.keyp(scancode)
    return contains(frame_keys, scancode)
end

return events