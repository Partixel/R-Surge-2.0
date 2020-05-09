local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local AnimationWrapper = require(script.Parent:WaitForChild("AnimationWrapper"))

local ReloadAnimation
Core.Events.LongReloadAnimation = Core.ReloadStart.Event:Connect(function(StatObj, Delay)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon.LongReloadSound then
		ReloadAnimation = Weapon[AnimationWrapper.Humanoid.RigType.Name .. "ReloadAnimation"]
		if ReloadAnimation then
			ReloadAnimation = AnimationWrapper.GetAnimation("Reload", ReloadAnimation, 15)
			local Speed = ReloadAnimation.AnimationTrack.Length / (Delay + (Weapon.InitialReloadDelay or 0) + (Weapon.FinalReloadDelay or 0))
			ReloadAnimation.AnimationTrack.Priority = Enum.AnimationPriority.Action
			ReloadAnimation:Play(0.1 * Speed, nil, Speed)
		end
	end
end)

local UniqueNames = {}
local Playing = {}
Core.Events.ShortReloadAnimation = Core.ReloadStepped.Event:Connect(function(StatObj, Delay)
	local Weapon = Core.GetWeapon(StatObj)
	if not Weapon.LongReloadSound then
		local ReloadAnimation = Weapon[AnimationWrapper.Humanoid.RigType.Name .. "ReloadAnimation"]
		if ReloadAnimation then
			local MyName = UniqueNames[#UniqueNames] or tostring({})
			UniqueNames[#UniqueNames] = nil
			
			ReloadAnimation = AnimationWrapper.GetAnimation("Reload" .. MyName, ReloadAnimation, 15)
			if not ReloadAnimation.HandleStop then
				ReloadAnimation.HandleStop = true
				ReloadAnimation.AnimationTrack.Stopped:Connect(function()
					Playing[ReloadAnimation] = nil
					
					wait(0.15)
					
					UniqueNames[#UniqueNames + 1] = MyName
				end)
			end
			
			Playing[ReloadAnimation] = true
			local Speed = ReloadAnimation.AnimationTrack.Length / Delay
			ReloadAnimation.AnimationTrack.Priority = Enum.AnimationPriority.Action
			ReloadAnimation:Play(0.1 * Speed, nil, Speed)
		end
	end
end)

Core.ReloadEnd.Event:Connect(function(StatObj)
	if ReloadAnimation and ReloadAnimation.AnimationTrack.IsPlaying then
		ReloadAnimation = ReloadAnimation:Stop()
	end
	
	for ReloadAnimation, _ in pairs(Playing) do
		ReloadAnimation:Stop()
	end
end)