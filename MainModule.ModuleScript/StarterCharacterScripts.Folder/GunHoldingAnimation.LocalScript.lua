local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local AnimationWrapper = require(script.Parent:WaitForChild("AnimationWrapper"))

Core.WeaponSelected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon then
		local Animation = Weapon[AnimationWrapper.Humanoid.RigType.Name .. "HoldAnimation"]
		if Animation then
			Animation = AnimationWrapper.GetAnimation("HoldAnim", Animation, 1)
			Weapon.HoldAnimation = Animation
			Animation:Play()
		end
	end
end)

Core.WeaponDeselected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon and Weapon.HoldAnimation then
		Weapon.HoldAnimation = Weapon.HoldAnimation:Stop()
	end
end)