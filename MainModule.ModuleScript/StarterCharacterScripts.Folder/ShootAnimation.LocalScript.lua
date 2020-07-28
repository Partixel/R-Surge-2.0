local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local AnimationWrapper = require(script.Parent:WaitForChild("AnimationWrapper"))

local LocalPlayer = game:GetService("Players").LocalPlayer

local ShootAnimation
Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect(function(StatObj, User, Barrel, Hit, End, Normal, Material, Offset, _, Humanoids)
	if User == LocalPlayer then
		local Weapon = Core.GetWeapon(StatObj)
		ShootAnimation = Weapon[AnimationWrapper.Humanoid.RigType.Name .. "ShootAnimation"]
		if ShootAnimation then
			ShootAnimation = AnimationWrapper.GetAnimation("Shoot", ShootAnimation, 1)
			ShootAnimation.AnimationTrack.Priority = Enum.AnimationPriority.Action
			ShootAnimation:Play()
		end
	end
end)

Core.WeaponDeselected.Event:Connect(function(StatObj)
	if ShootAnimation then
		ShootAnimation = ShootAnimation:Stop()
	end
end)