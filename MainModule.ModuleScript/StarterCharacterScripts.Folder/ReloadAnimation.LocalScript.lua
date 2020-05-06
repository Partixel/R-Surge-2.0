local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local AnimationWrapper = require(script.Parent:WaitForChild("AnimationWrapper"))

Core.ReloadStart.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon then
		local Animation = Weapon[AnimationWrapper.Humanoid.RigType.Name .. "ReloadAnimation"]
		if Animation then
			Animation = AnimationWrapper.GetAnimation("ReloadAnim", Animation, 10)
			Weapon.ReloadAnimation = Animation
			Animation:Play(nil, nil, Animation.Length / (Weapon.ReloadDelay + (Weapon.InitialReloadDelay or 0) + (Weapon.FinalReloadDelay or 0)))
		end
	end
end)

Core.ReloadEnd.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon and Weapon.ReloadAnimation then
		Weapon.ReloadAnimation = Weapon.ReloadAnimation:Stop()
	end
end)