local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

local UpdateRate = 1/20

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))

local Mode = {__mode = "k"}
local Excluded, Rotations = setmetatable({}, Mode), setmetatable({}, Mode)

local HeadRotRemote = Instance.new("RemoteEvent")
HeadRotRemote.Name = "HeadRot"
HeadRotRemote.OnServerEvent:Connect(function(Plr, Rotation, Disclude)
	Rotations[Plr] = Rotation
	Excluded[Plr] = Disclude
end)
HeadRotRemote.Parent = game:GetService("ReplicatedStorage"):WaitForChild("S2")

function HandleCharacter(Character)
	local OldHead = Character:WaitForChild("Head")
	PhysicsService:SetPartCollisionGroup(OldHead, "S2_ForcePenetration")
	
	local NewHead = Instance.new("Part")
	NewHead.Size = Vector3.new(2, 1, 1)
	NewHead.Massless = true
	NewHead.Transparency = 1
	NewHead.Name = "NewHead"
	CollectionService:AddTag(NewHead, "nopen")
	CollectionService:AddTag(NewHead, "s2headdamage")
	
	local OldWeld = Character:FindFirstChild("Neck", true)
	while not OldWeld do
		OldWeld = Character:FindFirstChild("Neck", true)
	end
	
	local NewWeld = OldWeld:Clone()
	NewWeld.Part1 = NewHead
	NewWeld.Name = "NewNeck"
	
	OldWeld:GetPropertyChangedSignal("Part0"):Connect(function()
		NewWeld.Part0 = OldWeld.Part0
	end)
	
	NewHead.Parent = OldHead.Parent
	NewWeld.Parent = OldWeld.Parent == OldHead and NewHead or OldWeld.Parent
end

function PlayerAdded(Plr)
	HandleCharacter(Plr.Character or Plr.CharacterAdded:Wait())
	Plr.CharacterAdded:Connect(HandleCharacter)
end
Players.PlayerAdded:Connect(PlayerAdded)
for _, Plr in ipairs(Players:GetPlayers()) do
	PlayerAdded(Plr)
end

while wait(UpdateRate) do
	if next(Rotations) then
		local Rots
		for _, Plr in ipairs(Players:GetPlayers()) do
			if not Excluded[Plr] then
				if Rotations[Plr] then
					local Rots = {}
					for b, c in pairs(Rotations) do
						if b ~= Plr then
							Rots[#Rots + 1] = {b, c}
						end
					end
					
					if next(Rots) then
						HeadRotRemote:FireClient(Plr, Rots)
					end
				else
					if not Rots then
						Rots = {}
						for b, c in pairs(Rotations) do
							Rots[#Rots + 1] = {b, c}
						end
					end
					
					HeadRotRemote:FireClient(Plr, Rots)
				end
			end
		end
		
		Rotations = setmetatable({}, Mode)
	end
end