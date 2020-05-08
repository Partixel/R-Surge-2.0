local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local PoseUtil = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("PoseUtil"))
local KeybindUtil = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("KeybindUtil"))

return function(Main, ModFolder, VH_Events)
	Core.Config.SwordFloat = ModFolder:WaitForChild("SwordFloat").Value
	Main.Events[#Main.Events + 1] = ModFolder.SwordFloat.Changed:Connect(function(Value)
		Core.Config.SwordFloat = Value
	end)
	
	Core.Config.AllowAtEase = ModFolder:WaitForChild("AtEase").Value
	Main.Events[#Main.Events + 1] = ModFolder.AtEase.Changed:Connect(function(Value)
		Core.Config.AllowAtEase = Value
		if not Value then
			KeybindUtil.SetToggle("At_ease", false)
		end
	end)
	
	if ModFolder:WaitForChild("Tools").Value then
		Core.SetBackpackDisabled("S2_ToolsCommand", false)
	else
		Core.SetBackpackDisabled("S2_ToolsCommand", true)
		game.Players.LocalPlayer.Character.Humanoid:UnequipTools()
	end
	Main.Events[#Main.Events + 1] = ModFolder.Tools.Changed:Connect(function(Value)
		if Value then
			Core.SetBackpackDisabled("S2_ToolsCommand", false)
		else
			Core.SetBackpackDisabled("S2_ToolsCommand", true)
			game.Players.LocalPlayer.Character.Humanoid:UnequipTools()
		end
	end)
	
	Core.Config.AllowSprinting = ModFolder:WaitForChild("Sprint").Value
	Main.Events[#Main.Events + 1] = ModFolder.Sprint.Changed:Connect(function(Value)
		Core.Config.AllowSprinting = Value
		if not Value then
			PoseUtil.SetPose("Sprinting", false)
		end
	end)
	
	Core.Config.AllowCrouching = ModFolder:WaitForChild("Crouch").Value
	Main.Events[#Main.Events + 1] = ModFolder.Crouch.Changed:Connect(function(Value)
		Core.Config.AllowCrouching = Value
		if not Value then
			PoseUtil.SetPose("Crouching", false)
		end
	end)
	
	Core.Config.AllowSalute = ModFolder:WaitForChild("Salute").Value
	Main.Events[#Main.Events + 1] = ModFolder.Salute.Changed:Connect(function(Value)
		Core.Config.AllowSalute = Value
		if not Value then
			KeybindUtil.SetToggle("Salute", false)
		end
	end)
	
	Core.Config.AllowSurrender = ModFolder:WaitForChild("Surrender").Value
	Main.Events[#Main.Events + 1] = ModFolder.Surrender.Changed:Connect(function(Value)
		Core.Config.AllowSurrender = Value
		if not Value then
			KeybindUtil.SetToggle("Surrender", false)
		end
	end)
	
	Core.Config.WeaponTypeOverrides.All.AllowTeamKill = ModFolder:WaitForChild("TeamKill").Value
	Main.Events[#Main.Events + 1] = ModFolder.TeamKill.Changed:Connect(function(Value)
		Core.Config.WeaponTypeOverrides.All.AllowTeamKill = Value
	end)
end