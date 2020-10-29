local CollectionService, PhysicsService = game:GetService("CollectionService"), game:GetService("PhysicsService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function UpdateObject(Obj, Visible)
	if Obj:IsA("Model") then
		for _, Obj in ipairs(Obj:GetDescendants()) do
			if Obj:IsA("BasePart") then
				Obj.Transparency = Visible and 0 or 1
				PhysicsService:SetPartCollisionGroup(Obj, Visible and "Default" or "S2_NoCollide")
			end
		end
	end
end

local function Update()
	for _, Obj in ipairs(game.CollectionService:GetTagged("S2_TeamVisibility")) do
		if LocalPlayer.Team then
			local TeamName = LocalPlayer.Team:FindFirstChild("OriginalName") and string.sub(LocalPlayer.Team.OriginalName.Value.Name, 4) or LocalPlayer.Team.Name
			if CollectionService:HasTag(Obj, TeamName) then
				UpdateObject(Obj, false)
			else
				UpdateObject(Obj, true)
			end
		else
			UpdateObject(Obj, true)
		end
	end
end

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(Update)
Update()