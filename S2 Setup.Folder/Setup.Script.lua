local function ErrorHandler(Error)
	local Trace = debug.traceback(nil, 2):sub(1, -2)
	return {Error, Trace:sub(1, #Trace - Trace:reverse():find(".\n") - 1) .. "\n"}
end

local function GetError(Result, Stack)
	return Result[1] .. "\nStack Begin\n" .. Result[2] .. (Stack or debug.traceback(nil, 2)) .. "Stack End"
end

if script.Parent:FindFirstChild("Config") and script.Parent.Config:FindFirstChild("IDs") then
	local Ran, Error = xpcall(require, ErrorHandler, script.Parent.Config.IDs)
	if Ran then
		if Error.Module then
			Ran, Error = xpcall(require, ErrorHandler, Error.Module)
			if Ran and Error.Run then
				Ran, Error = xpcall(Error.Run, ErrorHandler, Error)
				if Ran then
					return
				else
					warn("Failed to run " .. script.Parent.Name .. ":\n" .. GetError(Error))
				end
			else
				warn("Failed to load " .. script.Parent.Name .. ":\n" .. GetError(Error))
			end
		else
			warn("Failed to get Module ID " .. script.Parent.Name)
		end
	else
		warn("Failed to get IDs " .. script.Parent.Name .. ":\n" .. GetError(Error))
	end
else
	warn("Failed to find IDs module " .. script.Parent.Name)
end

if script:FindFirstChild("OnFail") then
	local Ran, Error =xpcall(require, ErrorHandler, script.Parent.Config.OnFail)
	if not Ran then
		warn("Failed to run OnFail " .. script.Parent.Name .. ":\n" .. GetError(Error))
	end
end