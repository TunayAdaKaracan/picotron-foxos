-- Without this, screen does not appear.
_apply_system_settings(_fetch_local("/appdata/system/settings.pod"))

local code = fetch("/system/syslib/system.lua")
local func, err = load(code)
-- Intentional crash if we can't load this file
if not func then _printh("** could not load head **"..err) end
func()

local process = require("process")

-- To pass the boot screen we need atleast 2 processes.
printh("Creating pm")
process.create_foxos_process("/system/managers/pm.lua")
printh("Creating wm")
process.create_foxos_process("/system/managers/wm.lua")

-- signal(37) what makes skip boot screen
_signal(37)

-- TODO: User process scheduler

-- Heart of the OS
while true do
    -- Runs a process with a given amount of cpu
    _run_process_slice(2, 0.1)
    local _, used = _run_process_slice(3, 0.9)

    -- A small debugger lol
    --printh("Used: "..tostring(used))
    flip()
end