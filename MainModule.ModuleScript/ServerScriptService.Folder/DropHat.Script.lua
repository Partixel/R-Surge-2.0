local CollectionService = game:GetService("CollectionService")
local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))

local DropHatRemote = Instance.new("RemoteEvent")
DropHatRemote.Name = "DropHatRemote"

DropHatRemote.OnServerEvent:Connect(function(Plr)
	if Core.Config.HatMode == 1 or not Plr.Character then return end
	
	for _, Hat in ipairs(Plr.Character:GetChildren()) do
		if Hat:IsA("Accessory") and not CollectionService:HasTag(Hat, "s2nodrop") then
			if Core.Config.HatMode == 2 then
				Hat:Destroy()
			else
				Hat.Parent = workspace
				
				local Event; Event = Hat.AncestryChanged:Connect(function()
					Event:Disconnect()
					Event = nil
				end)
				
				delay(5, function()
					if Event then
						Hat:Destroy()
					end
				end)
			end
		end
	end
end)

DropHatRemote.Parent = game:GetService("ReplicatedStorage"):WaitForChild("S2")