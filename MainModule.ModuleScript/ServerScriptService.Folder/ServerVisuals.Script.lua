local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))

require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("SharedVisuals"))

Core.WeaponTypes.Throwable.Events.HideThrowable = Core.WeaponTypes.Throwable.AttackEvent.Event:Connect(function(StatObj, User, Throwable)
	local Weapon = Core.GetWeapon(StatObj)
	
	if Weapon.HideOnThrow then
		local OriginalTransparency = {}
		for _, Part in ipairs(Weapon.StatObj.Parent:GetDescendants()) do
			if Part:IsA("BasePart") then
				OriginalTransparency[Part] = Part.Transparency
				Part.Transparency = 1
			end
		end
		
		Core.HeartbeatWait(1 / Weapon.ThrowRate)
		
		for Part, Transparency in pairs(OriginalTransparency) do
			Part.Transparency = Transparency
		end
	end
end)

local Red = BrickColor.Red().Color
Core.WeaponTypes.Throwable.Events.ThrowablePulse = Core.WeaponTypes.Throwable.AttackEvent.Event:Connect(function(StatObj, User, Throwable)
	local Weapon = Core.GetWeapon(StatObj)
	
	local ticksound = Instance.new("Sound")
	ticksound.SoundId = "rbxasset://sounds\\clickfast.wav"
	ticksound.Parent = Throwable.PrimaryPart
	
	local OriginalColor = {}
	local OriginalTexture = {}
	for _, Part in ipairs(Throwable:GetDescendants()) do
		if Part:IsA("BasePart") then
			OriginalColor[Part] = Part.Color
			if Part:IsA("MeshPart") then
				OriginalTexture[Part] = Part.TextureID
			end
		end
	end
	
	local Delay = Weapon.ExplosionDelay
	local Last = true
	for a = 1, 15 do
		Last = not Last
		for Part, Color in pairs(OriginalColor) do
			if OriginalTexture[Part] then
				Part.TextureID = Last and OriginalTexture[Part] or ""
			end
			Part.Color = Last and Color or Red
		end
		ticksound:play()
		local Time = Core.HeartbeatWait(Delay/7) * 0.8
		Delay = Delay - Time
	end
end)

Core.Events.SelectedNoise = Core.WeaponSelected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon.SelectionSound then
		local SelectionSound = StatObj.Parent.Handle:FindFirstChild("SelectionSound") or Weapon.SelectionSound:Clone()
		SelectionSound.Parent = StatObj.Parent.Handle
		SelectionSound:Play()
	end
end)

Core.Events.DeselectedNoise = Core.WeaponDeselected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon.DeselectionSound then
		local DeselectionSound = StatObj.Parent.Handle:FindFirstChild("DeselectionSound") or Weapon.DeselectionSound:Clone()
		DeselectionSound.Parent = StatObj.Parent.Handle
		DeselectionSound:Play()
	end
end)

Core.Events.ShotKnockback = Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect(function(StatObj, _, Barrel, Hit, End)
	if Hit and not Hit.Anchored then
		local Weapon = Core.GetWeapon(StatObj)
		if Weapon.ShotKnockbackPercentage ~= 0 then
			local Humanoid = Core.GetValidDamageable(Hit)
			if Humanoid or Weapon.KnockAll then
				local BodyVelocity = Instance.new("BodyVelocity", Hit)
				BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				BodyVelocity.Velocity = ((End - Barrel.Position).Unit * math.abs(Weapon.Damage) * ((Weapon.Range - (End - Barrel.Position).magnitude) / Weapon.Range) * Weapon.ShotKnockbackPercentage * Vector3.new(1, 0, 1)) * 0.2
				
				delay(0.1, function()
					BodyVelocity:Destroy()
				end)
			end
		end
	end
end)