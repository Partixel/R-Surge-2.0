local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

Core.Visuals.ShotKnockback = Core.ServerVisuals.Event:Connect( function ( StatObj, _, Barrel, Hit, End )
	
	if not Barrel or not StatObj or not StatObj.Parent or not Hit or Hit.Anchored then return end
	
	local GunStats = Core.GetGunStats( StatObj )
	
	if Core.Config.ShotKnockbackPercentage == 0 or GunStats.Knockback == 0 then return end
	
	local Humanoid = Core.GetValidHumanoid( Hit )
	
	if not Humanoid and not GunStats.KnockAll then return end
	
	local Velocity = ( End - Barrel.Position ).Unit * math.abs( GunStats.Damage ) * ( ( GunStats.Range - ( End - Barrel.Position ).magnitude ) / GunStats.Range ) * Core.Config.ShotKnockbackPercentage * Vector3.new( 1, 0, 1 ) * ( GunStats.Knockback or 1 )
	
	--Hit.Velocity = Hit.Velocity + Velocity
	
	local BodyVelocity = Instance.new( "BodyVelocity", Hit )
	
	BodyVelocity.Velocity = Velocity * 0.2
	
	delay( 0.1, function( )
		
		BodyVelocity:Destroy( )
		
	end )
	
end )

Core.Visuals.HumanoidSelected = Core.WeaponSelected.Event:Connect( function ( StatObj, User )
	
	if not StatObj or not StatObj.Parent then return end
	
	local Weapon = Core.GetWeapon( StatObj )
	
	local Hum = User.Character and User.Character:FindFirstChildOfClass( "Humanoid" )
	
	if Weapon and Hum then
		
		if Weapon.GunStats.WalkSpeedMod then
			
			local WSMod = Instance.new( "NumberValue" )
			
			WSMod.Name = "WalkSpeedModifier"
			
			WSMod.Value = Weapon.GunStats.WalkSpeedMod
			
			Weapon.WSMod = WSMod
			
		end
		
		if Weapon.GunStats.JumpPowerMod then
			
			local JPMod = Instance.new( "NumberValue" )
			
			JPMod.Name = "JumpPowerModifier"
			
			JPMod.Value = Weapon.GunStats.JumpPowerMod
			
			Weapon.JPMod = JPMod
			
		end
		
	end
	
end )

Core.Visuals.HumanoidDeselected = Core.WeaponDeselected.Event:Connect( function ( StatObj, User )
	
	if not StatObj or not StatObj.Parent then return end
	
	local Weapon = Core.GetWeapon( StatObj )
	
	local Hum = User.Character and User.Character:FindFirstChildOfClass( "Humanoid" )
	
	if Weapon and Hum then
		
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