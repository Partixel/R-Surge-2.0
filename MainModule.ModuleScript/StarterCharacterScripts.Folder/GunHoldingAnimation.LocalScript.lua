local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local Humanoid = script.Parent.Parent:WaitForChild("Humanoid")
local Animations = {}
local function GetAnimation(AnimProps)
	if not Animations[AnimProps] then
		local Animation = Instance.new("Animation")
		Animation.AnimationId = "rbxassetid://" .. AnimProps.Id
		Animations[AnimProps] = Humanoid:LoadAnimation(Animation)
	end
	
	return Animations[AnimProps]
end

Core.WeaponSelected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon then
		local Animation = Weapon[Humanoid.RigType.Name .. "HoldAnimation"]
		if Animation then
			Animation = GetAnimation(Animation)
			Weapon.HoldAnimation = Animation
			Animation:Play(nil, 1)
		end
	end
end)

Core.WeaponDeselected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon and Weapon.HoldAnimation then
		Weapon.HoldAnimation = Weapon.HoldAnimation:Stop()
	end
end)