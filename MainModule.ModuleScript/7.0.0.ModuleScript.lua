local ConfigClone = game:GetService("ServerScriptService"):WaitForChild("S2 Setup").Config:Clone()
local Config = require(ConfigClone)

local CoroutineErrorHandling = require(game:GetService("ReplicatedStorage"):FindFirstChild("CoroutineErrorHandling") or game:GetService("ServerStorage"):FindFirstChild("CoroutineErrorHandling") and game:GetService("ServerStorage").CoroutineErrorHandling:FindFirstChild("MainModule") or 4851605998)

require(game:GetService("ServerStorage"):FindFirstChild("TimeSync") and game:GetService("ServerStorage").TimeSync:FindFirstChild("MainModule") or 4698309617) -- TimeSync
require(game:GetService("ServerStorage"):FindFirstChild("MenuLib") and game:GetService("ServerStorage").MenuLib:FindFirstChild("MainModule") or 3717582194) -- MenuLib

local LoaderModule = require(game:GetService("ServerStorage"):FindFirstChild("LoaderModule") and game:GetService("ServerStorage").LoaderModule:FindFirstChild("MainModule") or 03593768376)("S2", Config.Disabled or {})
LoaderModule(script:WaitForChild("ReplicatedStorage"))

ConfigClone.Parent = game:GetService("ReplicatedStorage"):WaitForChild("S2")

LoaderModule(script:WaitForChild("ServerStorage"), nil, false)
LoaderModule(script:WaitForChild("ServerScriptService"))
LoaderModule(script:WaitForChild("StarterPlayerScripts"))
LoaderModule(script:WaitForChild("StarterCharacterScripts"))
LoaderModule(script:WaitForChild("StarterGui"))
LoaderModule(script:WaitForChild("MenuModules"), game:GetService("ServerStorage"):WaitForChild("MenuModules"), nil, {["S2VIP"] = true})

local LuaRequire = function (...) return require(...) end

if Config.DebugEnabled ~= false then
	CoroutineErrorHandling.CoroutineWithStack(require, game:GetService("ServerStorage"):FindFirstChild("DebugUtil") and game:GetService("ServerStorage").DebugUtil:FindFirstChild("MainModule") or 953754819)
end

CoroutineErrorHandling.CoroutineWithStack(require, game:GetService("ServerStorage"):FindFirstChild("ThemeUtil") and game:GetService("ServerStorage").ThemeUtil:FindFirstChild("MainModule") or 2230572960)

if not game:GetService("ServerStorage"):FindFirstChild("VH_Command_Modules") then
	local Folder = Instance.new("Folder")
	Folder.Name = "VH_Command_Modules"
	Folder.Parent = game:GetService("ServerStorage")
end
LoaderModule(script:WaitForChild("VH_Command_Modules"), game:GetService("ServerStorage").VH_Command_Modules)

return nil