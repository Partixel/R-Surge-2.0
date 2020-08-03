return {
	Get = function()
		local Config = require(game:GetService("ServerScriptService"):WaitForChild("S2 Setup"):WaitForChild("Config"))
		local Version = Config.Version
		
		if Version == nil then
			error("S2 - The specified module version does not exist so loading has aborted: Version specified in config: " .. tostring(Version) .. " - s" .. tostring(Config.SetupVersion))
		elseif script:FindFirstChild(Version) then
			return script:FindFirstChild(Version)
		else
			local Target = Version:split(".")
			for i = 1, 3 do
				Target[i] = tonumber(Target[i]) or Target[i]
			end
			if type(Target[1]) == "number" and type(Target[2]) == "number" and type(Target[3]) == "number" then
				error("S2 - The specified module version does not exist so loading has aborted: Version specified in config: " .. Version .. " - s" .. Config.SetupVersion)
			end
			
			local Max, MaxModule
			for _, Module in ipairs(script:GetChildren()) do
				local MyVersion = Module.Name:split(".")
				for i = 1, 3 do
					MyVersion[i] = tonumber(MyVersion[i])
				end
				
				if Target[1] == MyVersion[1] or (type(Target[1]) == "string" and (not Max or Max[1] <= MyVersion[1])) then
					if Max and type(Target[1]) == "string" and Max[1] < MyVersion[1] then Max = nil end
					if Target[2] == MyVersion[2] or (type(Target[2]) == "string" and (not Max or Max[2] <= MyVersion[2])) then
						if Max and type(Target[2]) == "string" and Max[2] < MyVersion[2] then Max = nil end
						if Target[3] == MyVersion[3] or (type(Target[3]) == "string" and (not Max or Max[3] < MyVersion[3])) then
							Max, MaxModule = MyVersion, Module
						end
					end
				end
			end
			
			if Max then
				return MaxModule
			else
				error("S2 - The specified module version does not exist so loading has aborted: Version specified in config: " .. Version .. " - s" .. Config.SetupVersion)
			end
		end
	end,
	Run = function(self)
		local Module = self:Get()
		
		print("S2 - Loading version " .. Module.Name .. " - s" .. require(game:GetService("ServerScriptService"):WaitForChild("S2 Setup"):WaitForChild("Config")).SetupVersion)
		return require(Module)
	end,
}