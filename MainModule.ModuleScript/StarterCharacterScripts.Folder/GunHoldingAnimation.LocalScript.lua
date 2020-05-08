local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local AnimationWrapper = require(script.Parent:WaitForChild("AnimationWrapper"))

local HoldAnimation
Core.WeaponSelected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	HoldAnimation = Weapon[AnimationWrapper.Humanoid.RigType.Name .. "HoldAnimation"]
	if HoldAnimation then
		HoldAnimation = AnimationWrapper.GetAnimation("Hold", HoldAnimation, 1)
		HoldAnimation.AnimationTrack.Priority = Enum.AnimationPriority.Movement
		HoldAnimation:Play()
	end
end)

Core.WeaponDeselected.Event:Connect(function(StatObj)
	if HoldAnimation then
		HoldAnimation = HoldAnimation:Stop()
	end
end)