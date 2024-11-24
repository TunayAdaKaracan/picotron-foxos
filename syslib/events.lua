local events = {}

local event_handlers = {}
local forward = {}
local default_handlers = {
    keydown = keydown,
    keyup = keyup
}

local function match_event_name(pattern, str)
    local regex = "^" .. pattern:gsub("%*", ".*") .. "$"
    return string.match(str, regex) ~= nil
end

local function find_event_by_name(name)
    return find_by_key(event_handlers, function(key)
        return match_event_name(key, name)
    end)
end

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
        local event_name = msg.event

        add(processed_events, msg)
        
        for _, func in pairs(forward) do
            func(msg)
        end

        if default_handlers[event_name] then
            default_handlers[event_name](event_name)
        end

        local events_to_run = find_event_by_name(event_name)
        if #events_to_run != 0 then
            for _, funcs in all(events_to_run) do
                for func in all(funcs) do
                    func(msg)
                end
            end
        end

    until not msg

    return processed_events
end

-- TODO: Add timeouts
function events.wait_for_event(name, check)
    while true do
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