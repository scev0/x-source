DebugConfig = {
	-- global config table, so it can be changed via debug interface
	enabled = false,
	reprRecursionDepth = 2,
	reprIndentStep = "  ",
}

local init
local onUpdate

function init()
	if IsLuaDebugInputEnabled() then
		DebugConfig.enabled = true
		SetScript("onUpdate", onUpdate)
	end
end

-- Get string representation of Lua value, including table content (recursion depth defined in DebugConfig or passed as argument)
-- Function defined globally so it can be used in all addons for debugging
function ToReprString(value, recursiondepth, indent)
	if type(value) == "string" then
		return string.format("%q", value)
	end
	recursiondepth = recursiondepth or DebugConfig.reprRecursionDepth
	if recursiondepth > 0 and type(value) == "table" then
		indent = indent or ""
		local result = tostring(value) .. " = {"
		local newline = "\n" .. indent
		local firstnewline = newline
		for k, v in pairs(value) do
			result = string.format("%s%s%s[%s] = %s%s",
				result,
				firstnewline,
				DebugConfig.reprIndentStep,
				ToReprString(k, recursiondepth - 1, indent .. DebugConfig.reprIndentStep),
				ToReprString(v, recursiondepth - 1, indent .. DebugConfig.reprIndentStep),
				newline)
			firstnewline = ""
		end
		return result .. "}"
	end
	return tostring(value)
end

---------------------------------------------------------------------------------
-- Lua debug input
---------------------------------------------------------------------------------

function onUpdate()
	local input = ReadLuaDebugInput()
	if input then
		-- execute Lua input
		local func, errormsg = loadstring(input)
		if not func then
			SetLuaDebugOutput("Error while loading Lua input: " .. errormsg)
		else
			SetLuaDebugOutput("Executing Lua input: " .. input)
			local success, returnvalue = pcall(func)
			if not success then
				SetLuaDebugOutput("  Error while executing Lua input: " .. returnvalue)
			elseif returnvalue ~= nil then
				SetLuaDebugOutput("  Return value: " .. ToReprString(returnvalue, DebugConfig.reprRecursionDepth))
			else
				SetLuaDebugOutput("  Finished without return value")
			end
		end
	end
end

---------------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------------

init()
