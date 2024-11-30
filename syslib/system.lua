-- This package is for stuff that are included in every process.
-- Mostly for QOL stuff
do
    -- TODO: Change include semantics.
    -- Any filename that does not end with .lua should be first checked on system libraries.
    -- I.E: require("screen") gets system file while require("screen.lua") gets file in same location (if present)
    local loaded_packages = {}
    function require(filename)
        if filename:ext() == nil then
            filename ..= ".lua"
        end
        local path = fullpath(filename)

        -- If the path is not a absolute path, it might be a system library
        if not fetch(path) then
            if fetch("/system/syslib/"..filename) then
                path = "/system/syslib/"..filename
            elseif fetch("/appdata/lib/"..filename) then
                path = "/appdata/lib/"..filename
            end
        end

        if loaded_packages[path] then
            return loaded_packages[path]
        end
        
        local code = fetch(path)
        local func, err = load(code, "@"..filename, "t", _ENV)

        if err or func == nil then
            printh("BIG ERROR: "..err)
            return
        end

        local result = func()
        if result != nil then
            loaded_packages[path] = result
        end
        return result
    end

    function printh(text)
        _printh("[PROC "..tostring(pid()).."]: "..tostring(text))
    end

    function debug(text)
        printh("[PROC "..tostring(pid()).." DEBUG]: "..tostring(text))
    end

    function print(text, x, y, color)
        _print_p8scii(text, x, y, color)
    end

    -- Utilities

    function all_keys(tbl)
        local key = nil
        return function()
            key = next(tbl, key)
            return key
        end
    end

    function all_values(tbl)
        local key = nil 
    
        return function()
            key = next(tbl, key)
            if key == nil then
                return nil
            else
                return tbl[key]
            end
        end
    end
    all = all_values
    
    function contains(t, val)
        for _, tval in pairs(t) do
            if tval == val then return true end
        end
        return false
    end

    function find_by_key(tbl, callback)
        local tmp = {}

        for key, value in pairs(tbl) do
            if callback(key) then
                add(tmp, {key, value})
            end
        end

        return tmp
    end

    --[[
        local messages = {
            {content="hello", author="Kutup"},
            {content="How?", author="Kutup"}
        }
        
        find_by_value(messages, {content="hello"}) -> { {1, {content="hello", author="Kutup"}} }
        find_by_value(messages, {author="Kutup"}) -> { {1, {content="hello", author="Kutup"}}, {2, {content="How?", author="Kutup"}} }
        find_by_value(messages, function(value)
            return value..content == "hello"
        end) -> Same as first one
    ]]
    function find_by_value(tbl, callback)
        local tmp = {}
        if type(callback) == "table" then
            local fields = callback
            callback = function(check_value)
                for key, value in pairs(fields) do 
                    if check_value[key] == nil or check_value[key] != value then
                        return false
                    end
                end
                return true
            end
        end

        for key, value in pairs(tbl) do
            if callback(value) then
                add(tmp, {key, value})
            end
        end

        return tmp
    end

    -- TODO: Implement other string and QOL features
    function string:ext()
		local loc = split(self,"#",false)[1]
		-- max extension length: 16
		for i = 1,16 do
			if (string.sub(loc,-i,-i) == ".") then
				-- try to find double ext first e.g. .p8.png  but not .info.pod
				for j = i+1,16 do
					if (string.sub(loc,-j,-j) == "/") return string.sub(loc, -i + 1) -- path separator -> return just the single segment
					if (string.sub(loc,-j,-j) == "." and #loc > j) return string.sub(loc, -j + 1)
				end
				return string.sub(loc, -i + 1)
			end
		end
		return nil -- "no extension"
	end

    -- Functions defined in this format means they are either aliases or they are trying to replace function with a better alternative
    -- For this case I added ability to use unpack with an iterator
    unpack = function(data)
        if type(data) == "table" then return table.unpack(data) end
        if type(data) == "function" then
            return function()
                local value = data()
                if value == nil then return nil end
                return table.unpack(value)
            end
        end

        debug("unpack function is not implemented for type of '"..type(data).."'")
        return function()
            return nil
        end
    end

    random = function(rnd_start, rnd_end, integer)
        if not rnd_end and rnd_start then
            rnd_end = rnd_start
            rnd_start = 0
        end

        if rnd_start > rnd_end then
            local tmp = rnd_start
            rnd_start = rnd_end
            rn_end = tmp
        end

        integer = integer or false

        local rand = rnd(rnd_end - rnd_start) + rnd_start
        if not integer then return rand end
        -- TODO: Rethink this part. Should we really round it up?
        return rand % flr(rand) >= 0.5 and ceil(rand) or flr(rand)
    end

    -- Kernel functions will be accessible. However, most kernel functions will have a better alternative within the system.
    -- Raw kernel functions still should be avoided unless there is no alternative
    -- Those who can be used as they are has an alias to make typing easier
    ppeek = _ppeek
end