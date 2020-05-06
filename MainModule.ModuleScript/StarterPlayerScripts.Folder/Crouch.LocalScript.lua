local TweenService = game:GetService("TweenService")
local Plr = game:GetService("Players").LocalPlayer

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local KBU = require(Plr:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("KeybindUtil"))
local PU = require(Plr:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("PoseUtil"))

Core.PreventCrouch = {}

local AnimationA = {
	Left = {
		CFrame.new(-1, -1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
		CFrame.new(-0.5, 1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0)
	},
	Right = {
		CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
		CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0)
	}
}
local AnimationB = {
	Left = {
		CFrame.new(-1, -1.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
		CFrame.new(-0.5, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0) * CFrame.Angles(math.rad(20), 0, math.rad(-90))
	},
	Right = {
		CFrame.new(1, 0, -0.6, 0, 0, 1, 0, 1, 0, -1, -0, -0) * CFrame.Angles(math.rad(2), math.rad(20), 0),
		CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0)
	}
}

function lerp(a, b, t)
    return a * (1-t) + (b*t)
end

local WSMod, JPMod
PU.Watch("Crouching", "Crouch", function(NPlr, State, Offset)
	if NPlr == Plr then
		local Hum = NPlr.Character and NPlr.Character:FindFirstChildOfClass("Humanoid")
		if Hum then
			if WSMod then
				WSMod:Destroy()
			end
			
			if JPMod then
				JPMod:Destroy()
			end
			
			if State then
				local Weapon = Core.Selected[Plr] and next(Core.Selected[Plr])
				
				WSMod = Instance.new("NumberValue")
				WSMod.Name = "WalkSpeedModifier"
				WSMod.Value = Weapon and Weapon.CrouchSpeedMultiplier or Core.Config.WeaponTypeOverrides.All.CrouchSpeedMultiplier
				WSMod.Parent = Hum
				
				JPMod = Instance.new("NumberValue")
				JPMod.Name = "JumpPowerModifier"
				JPMod.Value = Weapon and Weapon.CrouchJumpPowerMultiplier or Core.Config.WeaponTypeOverrides.All.CrouchJumpPowerMultiplier
				JPMod.Parent = Hum
			else
				WSMod, JPMod = nil, nil
			end
		end
	end
	
	if NPlr.Character then
		local Torso = NPlr.Character:FindFirstChild("Torso")
		local Hum = NPlr.Character:FindFirstChild("Humanoid")
		if Torso and Hum then
			local Time
			local LeftHip = Torso:FindFirstChild("Left Hip")
			if LeftHip then
				local TargetA, TargetB = State and AnimationB.Left[1] or AnimationA.Left[1], State and AnimationB.Left[2] or AnimationA.Left[2]
				Time =  LeftHip.C0:toObjectSpace(TargetA).p.magnitude
				local Perc = TweenService:GetValue(math.min(Offset / Time, 1), Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				LeftHip.C0, LeftHip.C1 = LeftHip.C0:lerp(TargetA, Perc), LeftHip.C1:lerp(TargetB, Perc)
				if Perc < 1 then
					TweenService:Create(LeftHip, TweenInfo.new(Time - Offset, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {C0 = TargetA, C1 = TargetB}):Play()
				end
			end
			
			local RightHip = Torso:FindFirstChild("Right Hip")
			if RightHip then
				local TargetA, TargetB = State and AnimationB.Right[1] or AnimationA.Right[1], State and AnimationB.Right[2] or AnimationA.Right[2]
				Time = Time or RightHip.C0:toObjectSpace(TargetA).p.magnitude
				local Perc = TweenService:GetValue(math.min(Offset / Time, 1), Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				RightHip.C0, RightHip.C1 = RightHip.C0:lerp(TargetA, Perc), RightHip.C1:lerp(TargetB, Perc)
				if Perc < 1 then
					TweenService:Create(RightHip, TweenInfo.new(Time - Offset, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {C0 = TargetA, C1 = TargetB}):Play()
				end
			end
			
			local Perc = TweenService:GetValue(math.min(Offset / (Time or 1), 1), Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			Hum.HipHeight = lerp(Hum.HipHeight, State and -1 or 0, Perc)
			if Perc < 1 then
				TweenService:Create(Hum, TweenInfo.new((Time or 1) - Offset, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {HipHeight = State and -1 or 0}):Play()
			end
		end
	end
end)

local Debounce, Last
KBU.AddBind{Name = "Crouch", Category = "Surge 2.0", Callback = function(Began, Died)
	if not Died then
		if Began and Debounce then
			return Last
		else
			Last = Began
			if Began then
				if next(Core.PreventCrouch) then
					return false
				elseif Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") and Plr.Character:FindFirstChildOfClass("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
					local Weapon = Core.Selected[Plr] and next(Core.Selected[Plr])
					if Weapon then
						if not Weapon.AllowCrouch then
							return false
						end
					elseif not Core.Config.WeaponTypeOverrides.All.AllowCrouch then
						return false
					end
					
					PU.SetPose("Crouching", true)
					PU.SetPose("Sprinting", false)
					
					Debounce = true
					wait()
					Debounce = false
				end
			else
				PU.SetPose("Crouching", false)
				
				Debounce = true
				wait()
				Debounce = false
			end
		end
	end
end, Key = Enum.KeyCode.C, PadKey = Enum.KeyCode.ButtonL3, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true}

Core.WeaponSelected.Event:Connect(function(StatObj)
	local WeaponStats = Core.GetWeaponStats(StatObj)
	if WeaponStats then
		if not WeaponStats.AllowCrouch then
			KBU.SetToggle("Crouch", false)
		end
	elseif not Core.Config.WeaponTypeOverrides.All.AllowCrouch then
		KBU.SetToggle("Crouch", false)
	end
end)

Core.WeaponDeselected.Event:Connect(function(StatObj)
	if Core.Config.AllowCrouching == false then
		KBU.SetToggle("Crouch", false)
	end
end)