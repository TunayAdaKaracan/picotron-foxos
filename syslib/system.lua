-- This package is for stuff that are included in every process.
-- Mostly for QOL stuff

do
    local loaded_packages = {}
    function require(filename)
        if filename:ext() == nil then
            filename ..= ".lua"
        end
        local path = fullpath(filename)

        -- If the path is not a absolout path, it might be a system library
        if not fetch(path) then
            if fetch("/system/syslib/"..filename) then
                path = "/system/syslib/"..filename
            elseif fetch("/appdata/lib/"..filename) then
                path = "/appdata/lib/"..filename
            end
        end

        local code = fetch(path)
        local func, err = load(code, "@"..filename, "t", _ENV)

        if err or func == nil then
            _printh("BIG ERROR: "..err)
            return
        end

        local result = func()
        if result != nil then
            loaded_packages[path] = result
        end
        return result
    end

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

    function printh(text)
        _printh("[PROC "..tostring(pid()).."]: "..tostring(text))
    end

    function print(text, x, y, color)
        _print_p8scii(text, x, y, color)
    end

    ppeek = _ppeek
end