_apply_system_settings(_fetch_local("/appdata/system/settings.pod"))

local code = fetch("/system/syslib/system.lua")
local func, err = load(code)
if not func then _printh("** could not load head **"..err) end
func()

local process = require("process")

_printh("Creating pm")
process.create_foxos_process("/system/managers/pm.lua")
_printh("Creating wm")
process.create_foxos_process("/system/managers/wm.lua")
_signal(37)

while true do
    _run_process_slice(2, 0.1)
    local _, used = _run_process_slice(3, 0.9)
    printh("Used: "..tostring(used))
    flip()
end