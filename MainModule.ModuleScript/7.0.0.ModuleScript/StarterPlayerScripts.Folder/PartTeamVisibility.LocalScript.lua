local CollectionService, PhysicsService = game:GetService("CollectionService"), game:GetService("PhysicsService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function Update()
	print("Do team change", LocalPlayer.Team.Name)
	for _, Part in ipairs(game.CollectionService:GetTagged("S2_TeamVisibility")) do
		if LocalPlayer.Team then
			local TeamName = LocalPlayer.Team:FindFirstChild("OriginalName") and string.sub(LocalPlayer.Team.OriginalName.Value.Name, 4) or LocalPlayer.Team.Name
			if CollectionService:HasTag(Part, TeamName) then
				Part.Transparency = 1
				PhysicsService:SetPartCollisionGroup(Part, "S2_NoCollide")
			else
				Part.Transparency = 0
				PhysicsService:SetPartCollisionGroup(Part, "Default")
			end
		else
			Part.Transparency = 0
			PhysicsService:SetPartCollisionGroup(Part, "Default")
		end
	end
end

game.Players.LocalPlayer:GetPropertyChangedSignal("Team"):Connect(Update)
Update()