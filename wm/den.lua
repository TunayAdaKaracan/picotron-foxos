-- Some metadata about this WM
-- WM's should be switchable
local events = require("events")
local process = require("process")

local den = {
    name = "Den WM",
    description = "Default WM for FoxOS"
}

local windows = {}

local function get_process_list()
    local tmp = {}
    for _, procdata in pairs(process.get_process()) do
        -- Skip WM process and any other headless process
        if ppeek(procdata.id, 0x0) & 0x1 > 0 and procdata.id != 3 then
            add(tmp, procdata)
        end
    end
    return tmp
end

local function get_window(pid)
    local check = find_by_value(windows, {pid=pid})
    if #check == 0 then return nil end
    return check[1][2]
end

-- WM functions

function den.load()
end

function den.unload()
end

function den.draw()
    cls(5)

    for process_ in all(get_process_list()) do
        -- _blit_process_video
        -- 1: pid
        -- 2: ?
        -- 3: ?
        -- 4: width or nil -> nil uses 0x5478
        -- 5: height or nil -> nil uses 0x547a
        -- 6: dest x
        -- 7: dest y
        -- returns: nil or ?
        -- if not nil then there is a problem
        local window = get_window(process_.id)
        _blit_process_video(process_.id, 0, 0, nil, nil, window.x, window.y)
    end

    pset(mx, my, 7)
end

function den.update()
    if mb == 1 then
        local win = get_window(4)
        win.x = mx
        win.y = my
    end
end

function den.create_new_process(event)
    add(windows, {
        x = 0,
        y = 0,
        pid = event.id
    })
end

function den.delete_process(event)
    for window in all(windows) do
        if window.pid == event.id then
            del(windows, window)
            break
        end
    end
end

-- This function should save to /ram/shared/windows.pod
-- Do we need actual WM process to handle this or should it be handled within WM handler?
function den.save_process_data()
end

events.on_event("mouse", function(event)
    mx, my, mb = event.mx, event.my, event.mb
end)

return den