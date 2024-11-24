
local process = {}

function process.get_prog_name(path)
    local parts = split(path, "/", false)
    local parts = split(parts[#parts], ".", false)
    return parts[1], parts[2]
end

function process.create_foxos_process(path)
    local name, ext = process.get_prog_name(path)

    if ext == ".p64" or ext == ".p64.png" or ext == ".p64.rom" then
        path ..="/main.lua"
    end

    local segs = split(path,"/",false)
    local program_path = string.sub(path, 1, -#segs[#segs] - 2)

    local source = [[
        do
            local core_lib = load(fetch("/system/syslib/system.lua"))
            if not core_lib then
                printh("CAN'T INCLUDE CORE LIB")
            end
            core_lib()
        end

        cd("]]..program_path..[[")

        require("]]..path..[[")
        require("/system/syslib/loop.lua")
    ]]
    
    local pid = _create_process_from_code(source, name.."."..ext)
    process.broadcast("system_create_new_process", {id=pid})
end

function process.get_process(pid)
    if pid == nil then
        return _get_process_list()
    end

    for _, procdata in pairs(_get_process_list()) do
        if procdata.id == pid then
            return procdata
        end
    end

    return nil
end

-- Potentially dangerous. Do we care?
-- Since we have all kernel available to all processes at anytime, it doesn't matter much if we deny a request or not
function process.kill_process(pid)
    _kill_process(pid)
    process.broadcast("system_kill_process", {id=pid})
end

-- since instead of pm sending this, we can still have _from field as it is
function process.broadcast(name, data)
    if type(name) == "table" then
        data = name
    else
        data = data or {}
        data.event = name
    end
    for _, procdata in pairs(process.get_process()) do
        send_message(procdata.id, data)
    end
end

function process.has_window(pid)
    return ppeek(pid, 0x0) & 0x1 > 0
end

-- Get another process' window information from WM
-- Returns nil if WM does not have this information at all
-- How to? Either by waiting or using a shared file??
function process.get_window(pid)
end

return process