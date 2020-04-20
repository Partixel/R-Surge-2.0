local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
if Core.Config.TeamCounts then
	Core.Config.TeamCounts = Core.Config.TeamCounts == true and "%PlayerCount% - %TeamName%" or Core.Config.TeamCounts
	
	local Teams = game:GetService("Teams")
	for _, Team in ipairs(Teams:GetTeams()) do
		local Name = Team.Name
		
		Team.Name = Core.Config.TeamCounts:gsub("%%(%w*)%%", {["PlayerCount"] = #Team:GetPlayers(), ["TeamName"] = Name})
		
		local Obj = Instance.new("ObjectValue")
		Obj.Name = "S2_" .. Name
		Obj.Value = Team
		Obj.Parent = Teams
		
		Team.PlayerAdded:Connect(function()
			Team.Name = Core.Config.TeamCounts:gsub("%%(%w*)%%", {["PlayerCount"] = #Team:GetPlayers(), ["TeamName"] = Name})
		end)
		Team.PlayerRemoved:Connect(function()
			Team.Name = Core.Config.TeamCounts:gsub("%%(%w*)%%", {["PlayerCount"] = #Team:GetPlayers(), ["TeamName"] = Name})
		end)
	end
end