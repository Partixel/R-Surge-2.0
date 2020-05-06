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

Core.ReloadStart.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon then
		local Animation = Weapon[Humanoid.RigType.Name .. "ReloadAnimation"]
		if Animation then
			Animation = GetAnimation(Animation)
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