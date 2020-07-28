local Players = game:GetService("Players")

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))

local LocationPingRemote = Instance.new("RemoteEvent")
LocationPingRemote.Name = "LocationgPingRemote"
LocationPingRemote.Parent = game:GetService("ReplicatedStorage"):WaitForChild("S2")

local FakeStat = {AllowNeutralTeamKill = true, InvertTeamKill = true}

LocationPingRemote.OnServerEvent:Connect(function(Player, Pos, Type)
	for _, Plr in ipairs(Players:GetPlayers()) do
		if Plr ~= Player and Core.CheckTeamkill(FakeStat, Player, Plr) then
			LocationPingRemote:FireClient(Plr, Pos, Type)
		end
	end
end)