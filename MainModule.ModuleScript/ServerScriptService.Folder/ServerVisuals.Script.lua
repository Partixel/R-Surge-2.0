local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

function swordOut(Tool)
	Tool.GripRight = Vector3.new(-1,0,0)
	Tool.GripUp = Vector3.new(0,0,-1)
	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripPos = Vector3.new( 0, 0, 0.2 )
end

function swordUp(Tool)
	Tool.GripRight = Vector3.new(-1,0,0)
	Tool.GripUp = Vector3.new(0,1,0)
	Tool.GripForward = Vector3.new(0,0,1)
	Tool.GripPos = Vector3.new( 0, -0.2, 0 )
end

Core.WeaponTypes.Sword.Events.AttackAnimation = Core.WeaponTypes.Sword.AttackEvent.Event:Connect(function(StatObj, User, Type)
	local Weapon = Core.GetWeapon(StatObj)
	if Type == 0 then
		if not Weapon.Placeholder then
			local Anim = Instance.new("StringValue")
			Anim.Name = "toolanim"
			Anim.Value = "Slash"
			Anim.Parent = Weapon.StatObj.Parent
		end
	else
		if not Weapon.Placeholder then
			local Anim = Instance.new("StringValue")
			Anim.Name = "toolanim"
			Anim.Value = "Lunge"
			Anim.Parent = Weapon.StatObj.Parent
		end
					
		wait(0.25)
		
		if Weapon.StatObj.Parent then
			swordOut(Weapon.StatObj.Parent)
			
			wait(0.75)
			
			if Weapon.StatObj.Parent then
				swordUp(Weapon.StatObj.Parent)
			end
		end
	end
end)

Core.WeaponTypes.Sword.Events.AttackSound = Core.WeaponTypes.Sword.AttackEvent.Event:Connect(function(StatObj, User, Type)
	local Weapon = Core.GetWeapon(StatObj)
	if Type == 0 then
		if Weapon.SlashSound then
			local SlashSound = StatObj.Parent.Handle:FindFirstChild("SlashSound") or Weapon.SlashSound:Clone()
			SlashSound.Parent = StatObj.Parent.Handle
			SlashSound:Play()
		end
	elseif Weapon.LungeSound then
		local LungeSound = StatObj.Parent.Handle:FindFirstChild("LungeSound") or Weapon.LungeSound:Clone()
		LungeSound.Parent = StatObj.Parent.Handle
		LungeSound:Play()
	end
end)

Core.WeaponTypes.Sword.Events.VIPSparkles = Core.WeaponTypes.Sword.AttackEvent.Event:Connect(function(StatObj, User, Type)
	local Weapon = Core.GetWeapon(StatObj)
	if Type == 1 and typeof(User) == "Instance" and User:FindFirstChild("S2") and User.S2:FindFirstChild("VIPSparkles") and User.S2.VIPSparkles.Value then
		local Col = BrickColor.Random().Color
		
		if not Weapon.Sparkles then
			Weapon.Sparkles = {}
			for a = 1, 5 do
				for _, Part in ipairs(Weapon.DamageParts(Weapon.StatObj)) do
					Weapon.Sparkles[#Weapon.Sparkles + 1] = Instance.new("Sparkles", Part)
				end
			end
		end
		
		for _, Spark in ipairs(Weapon.Sparkles) do
			if Spark:IsA("Sparkles") then
				Spark.SparkleColor = Col
				Spark.Enabled = true
			end
		end
		
		wait(0.25)
		
		for _, Spark in ipairs(Weapon.Sparkles) do
			if Spark:IsA("Sparkles") then
				Spark.Enabled = false
			end
		end
	end
end)

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

Core.Events.ShotKnockback = Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect( function ( StatObj, _, Barrel, Hit, End )
	
	if not Barrel or not StatObj or not StatObj.Parent or not Hit or Hit.Anchored then return end
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if Weapon.ShotKnockbackPercentage == 0 then return end
	
	local Humanoid = Core.GetValidDamageable( Hit )
	
	if not Humanoid and not Weapon.KnockAll then return end
	
	local Velocity = ( End - Barrel.Position ).Unit * math.abs( Weapon.Damage ) * ( ( Weapon.Range - ( End - Barrel.Position ).magnitude ) / Weapon.Range ) * Weapon.ShotKnockbackPercentage * Vector3.new( 1, 0, 1 )
	
	--Hit.Velocity = Hit.Velocity + Velocity
	
	local BodyVelocity = Instance.new( "BodyVelocity", Hit )
	
	BodyVelocity.Velocity = Velocity * 0.2
	
	delay( 0.1, function( )
		
		BodyVelocity:Destroy( )
		
	end )
	
end )

Core.Events.HumanoidSelected = Core.WeaponSelected.Event:Connect( function ( StatObj )
	
	local Weapon = Core.GetWeapon( StatObj )
	
	local Hum = Weapon.User.Character and Weapon.User.Character:FindFirstChildOfClass( "Humanoid" )
	
	if Hum then
		
		if Weapon.WalkSpeedMod then
			
			local WSMod = Instance.new( "NumberValue" )
			
			WSMod.Name = "WalkSpeedModifier"
			
			WSMod.Value = Weapon.WalkSpeedMod
			
			Weapon.WSMod = WSMod
			
		end
		
		if Weapon.JumpPowerMod then
			
			local JPMod = Instance.new( "NumberValue" )
			
			JPMod.Name = "JumpPowerModifier"
			
			JPMod.Value = Weapon.JumpPowerMod
			
			Weapon.JPMod = JPMod
			
		end
		
	end
	
end )

Core.Events.HumanoidDeselected = Core.WeaponDeselected.Event:Connect( function ( StatObj )
	
	local Weapon = Core.GetWeapon( StatObj )
	
	local Hum = Weapon.User.Character and Weapon.User.Character:FindFirstChildOfClass( "Humanoid" )
	
	if Hum then
		
		if Weapon.WSMod then
			
			Weapon.WSMod:Destroy( )
			
			Weapon.WSMod = nil
			
		end
		
		if Weapon.JPMod then
			
			Weapon.JPMod:Destroy( )
			
			Weapon.JPMod = nil
			
		end
		
	end
	
end )