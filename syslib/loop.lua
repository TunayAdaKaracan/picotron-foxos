-- Runtime Init
poke(0x0, 0x0)
-- Loop
if _init then
    _init()
end

if not (_draw or _update) then return end

local should_close = false

function _frame()
    if _update then
        _update()
    end

    if _draw then
        _draw()
    end
end

-- Possibly a process might want to stay hanged in a state until something happens.
-- I.E: events.wait_for_event function
function _frame_end()
    flip()
end

while not should_close do
    _frame()
    _frame_end()
end