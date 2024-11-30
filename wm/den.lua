-- Some metadata about this WM
-- WM's should be switchable
local events = require("events")
local input = require("input")
local process = require("process")

local den = {
    name = "Den WM",
    description = "Default WM for FoxOS"
}

local windows = {}

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
        --_blit_process_video(process_.id, 0, 0, nil, nil, window.x, window.y)
end

function den.update()
end

local function create_window(pid, w, h)

end

local function update_window(pid, w, h,)

end

function den.screen_update(event)
    if #find_by_value(windows, {pid=event.pid}) == 0 then
        create_window(event.pid, event.width, event.height) 
    else
        update_window(event.pid, event.width, event.height)
    end
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

return den