local PhysicsService = game:GetService("PhysicsService")

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))

local function HandleHat(Hat)
	if Hat:IsA("Accessory") then
		for _, Part in ipairs(Hat:GetDescendants()) do
			if Part:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(Part, "S2_ForcePenetration")
			end
		end
	end
end

script.Parent.Parent.ChildAdded:Connect(HandleHat)
for _, Obj in ipairs(script.Parent.Parent:GetChildren()) do
	HandleHat(Obj)
end

PhysicsService:SetPartCollisionGroup(script.Parent.Parent:WaitForChild("HumanoidRootPart"), "S2_ForcePenetration")