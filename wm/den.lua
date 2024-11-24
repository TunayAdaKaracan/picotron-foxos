-- Some metadata about this WM
-- WM's should be switchable
local den = {
    name = "Den WM",
    description = "Default WM for FoxOS"
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
    for _, procdata in pairs(processes.get_process_list()) do
        -- Skip WM process and any other headless process
        if ppeek(procdata.id, 0x0) & 0x1 > 0 and procdata.id != 3 then
            add(tmp, procdata)
        end
    end
    return procdata
end

function den.draw()
    local processes = get_process_list()
end

function den.update()
    local processes = get_process_list()
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
        printh("This is a big OOF from den.lua")
    end
end

-- This function should save to /ram/shared/windows.pod
-- Do we need actual WM process to handle this or should it be handled within WM handler?
function den.save_process_data()
end


return den