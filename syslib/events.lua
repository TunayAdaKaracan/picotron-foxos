local events = {}

--[[
    Ref structure
    events_handlers = {
        "*" = {
            "xyz" = func,
            "abc" = func
        }
    }
]]

local event_handlers = {}
local default_handlers = {
    keydown = keydown,
    keyup = keyup
}
local event_buffer = {
    index = 1,
    events = {}
}

local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf, true) or random(8, 0xb, true)
        return string.format('%x', v)
    end)
end

local function reset_event_states()
    frame_keys = {}
end

local function match_event_name(pattern, str)
    local regex = "^" .. pattern:gsub("%*", ".*") .. "$"
    return string.match(str, regex) ~= nil
end

local function find_event_by_name(name)
    return find_by_key(event_handlers, function(key)
        return match_event_name(key, name)
    end)
end

function events.on_event(name, func)
    local event_uuid = uuid()
    event_handlers[name] = event_handlers[name] or {}
    event_handlers[name][event_uuid] = func
    return {
        uuid = event_uuid,
        name = name,
        delete = function(self)
            events.remove_event(self.uuid, self.name)
        end
    }
end

-- Event name is not necessary, however, for performance reasons passing it is still better
function events.remove_event(event_uuid, event_name)
    if not event_name then
        for event_name, handlers in pairs(event_handlers) do
            for uuid in all_keys(handlers) do
                if event_handlers[event_name][uuid] then
                    event_handlers[event_name][uuid] = nil
                    return true
                end
            end
        end
        return false
    end

    if event_handlers[event_name] and event_handlers[event_name][event_uuid] then
        event_handlers[event_name][event_uuid] = nil
        return true
    end
    
    return false
end

function events.process_events()
    local processed_events = {}
    reset_event_states()
    repeat
        -- An event buffer system. Event buffer used when the process is waiting for an event.
        -- Any event that is not the process have been waiting for, are added to this buffer
        -- After wait ends, in the next update all buffered events are processed
        -- Still experimental. Could be removed
        local msg
        if event_buffer.index <= #event_buffer.events then
            msg = event_buffer.events[event_buffer.index]
            if event_buffer.index == #event_buffer.events then
                event_buffer.index = 0
                event_buffer.events = {}
            end
            event_buffer.index += 1
        else
            msg = _read_message()
        end
        if not msg then return end
        local event_name = msg.event

        add(processed_events, msg)

        if default_handlers[event_name] then
            default_handlers[event_name](event_name)
        end

        local events_to_run = find_event_by_name(event_name)
        if #events_to_run != 0 then
            for _, handlers in unpack(all(events_to_run)) do
                for func in all(handlers) do
                    func(msg)
                end
            end
        end

    until not msg

    return processed_events
end

-- TODO: Add timeouts
function events.wait_for_event(name, check, use_buffer)
    while true do
        repeat
            local msg = _read_message()
            if not msg then break end

            if msg.event == name then
                if not check or check(msg) then
                    return msg
                end
            elseif use_buffer then
                add(event_buffer.events, msg)
            end
        until not msg
        _frame_end()
    end
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