-- Some metadata about this WM
-- WM's should be switchable
local events = require("events")

local den = {
    name = "Den WM",
    description = "Default WM for FoxOS"
}

local state = {
    mx=0, my=0, mb=0
}

local processes = {}

local function create_process_data(pid)

end

local function find_process_data(pid)
    for _, procdata in pairs(processes) do
        if procdata.id == pid then
            return procdata
        end
    end
    return nil
end

local function get_process_list()
    local tmp = {}
    for _, procdata in pairs(process.get_process_list()) do
        -- Skip WM process and any other headless process
        if ppeek(procdata.id, 0x0) & 0x1 > 0 and procdata.id != 3 then
            add(tmp, procdata)
        end
    end
    return procdata
end

function den.load()
end

function den.unload()
end

function den.draw()
    cls(5)
    rect(0, 0, 100, 100, 22)
    local clr = 7
    if state.mb == 1 then
        clr = 0
    end
    pset(state.mx, state.my, clr)
end

function den.update()
end

function den.create_new_process(procdata)
    add(processes, create_process_data(procdata))
end

function den.delete_process(procdata)
    local data = find_process_data(procdata.id)
    if data != nil then
        del(processes, data)
    else
        -- Shouldn't happen but incase
        debug("This is a big OOF from den.lua")
    end
end

-- This function should save to /ram/shared/windows.pod
-- Do we need actual WM process to handle this or should it be handled within WM handler?
function den.save_process_data()
    
end

events.on_event("mouse", function(ev)
    state.mx, state.my, state.mb = ev.mx, ev.my, ev.mb
end)

return den