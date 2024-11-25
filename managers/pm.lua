-- Useless AF
-- Deprecated

local events = require("events")

function _update()
    events.process_events()
end

-- To test if our wildcard events are running properly
-- To be deleted after stable versions
events.on_event("key*", function(ev)
    printh("Relayed event "..ev.event.." from : "..tostring(ev._from))
end)