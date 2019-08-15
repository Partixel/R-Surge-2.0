local Core = { }

local RunService, Players, ContextActionService, CollectionService, ContentProvider = game:GetService( "RunService" ), game:GetService( "Players" ), game:GetService( "ContextActionService" ), game:GetService( "CollectionService" ), game:GetService( "ContentProvider" )

while not _G.S20Config do wait( ) end

local Config = _G.S20Config

Core.ShotRemote = script:WaitForChild( "ShotRemote" )

Core.ClientSync = script.ClientSync

Core.DropHat = script.DropHat

Core.WeaponSelected = Instance.new( "BindableEvent" )

Core.WeaponDeselected = Instance.new( "BindableEvent" )

Core.ReloadStart = Instance.new( "BindableEvent" )

Core.ReloadStepped = Instance.new( "BindableEvent" )

Core.ReloadEnd = Instance.new( "BindableEvent" )

Core.StoredAmmoChanged = Instance.new( "BindableEvent" )

Core.ClipChanged = Instance.new( "BindableEvent" )

Core.FireModeChanged = Instance.new( "BindableEvent" )

Core.WindupChanged = Instance.new( "BindableEvent" )

Core.DamageableAdded = Instance.new( "BindableEvent" )

Core.FiringEnded = Instance.new( "BindableEvent" )

Core.FireModes = {

	Auto = { Name = "Auto", Automatic = true },

	Semi = { Name = "Semi" },

	Burst = { Name = "Burst", Shots = 3 },

	Safety = { Name = "Safety", PreventFire = true }

}

local function hbwait(num)
	local t=0
	while t<num do
		t = t + game["Run Service"].Heartbeat:wait( )
	end
	return t
end

local function FakeExplosion( Properties, OnHit )

	local Explosion = Instance.new( "Explosion" )

	for a, b in pairs( Properties ) do

		Explosion[ a ] = b

	end

	Explosion.DestroyJointRadiusPercent = 0

	Explosion.Hit:Connect( OnHit )

	Explosion.Visible = false

	Explosion.Parent = workspace

	wait( )

end

local function Stun( StatObj, GunStats, User, Hit, Dist, Type, WeaponName )

	local ResH, ResD = Core.GetDamage( User, Hit, GunStats.Damage, Type, Dist, GunStats.DistanceModifier, GunStats.AllowTeamKill, WeaponName, GunStats.InvertTeamKill, GunStats.InvertDistanceModifier )

	if ResH and ResH and ResH:IsA( "Humanoid" ) then

		ResH.PlatformStand = true

		if ResH.RootPart then ResH.RootPart.RotVelocity = Vector3.new( 10, 0, 0 ) end

		coroutine.wrap( function ( )

			for a = 1, 60 do

				wait( 0.1 )

				if ResH.RootPart then ResH.RootPart.RotVelocity = Vector3.new( 0, math.random( -5, 5 ), 0 ) end

			end

			if ResH then ResH.PlatformStand = false end

		end )( )

	end

	return ResH, ResD

end

local function FireDamage( StatObj, GunStats, User, Hit, ResH, ResD )
	
	local Fire, Doused, Event2
	
	local Event1; Event1 = ResH.ChildAdded:Connect( function ( Obj )
		
		if Obj.Name == "InWater" then
			
			Doused = true
			
			Event1:Disconnect( )
			
		end
		
	end )
	
	if ResH:IsA( "Humanoid" ) then
		
		if ResH.RootPart then
			
			Fire = Instance.new( "Fire" , ResH.RootPart )
			
		end
		
		Event2 = ResH.Swimming:Connect( function( )
			
			Doused = true
			
		end )
		
	end
	
	local HitName = Hit.Name
	
	for i = 1, 20 do
		
		if Doused then
			
			break
			
		end
		
		Core.DamageObj( User, { { ResH, ResD, HitName } }, StatObj.Value, GunStats.BulletType.DamageType or Core.DamageType.Fire )
		
		wait( 0.3 )
		
	end
	
	if Fire then Fire:Destroy( ) end
	
	Event1:Disconnect( )
	
	if Event2 then Event2:Disconnect( ) end
	
end

Core.BulletTypes = {

	Kinetic = { Func = function ( StatObj, GunStats, User, Hit, Barrel, End )
		
		local DamageType = GunStats.BulletType and GunStats.BulletType.DamageType or Core.DamageType.Kinetic
	
		local ResH, ResD = Core.GetDamage( User, Hit, GunStats.Damage, DamageType, ( Barrel.Position - End ).magnitude / GunStats.Range, GunStats.DistanceModifier, GunStats.AllowTeamKill, StatObj.Value, GunStats.InvertTeamKill, GunStats.InvertDistanceModifier )
	
		if ResH then
			
			return Core.DamageObj( User, { { ResH, ResD, Hit.Name } }, StatObj.Value, DamageType )
	
		end

	end },

	Lightning = { Func = function ( StatObj, GunStats, User, Hit, Barrel, End )

		if ( not Hit ) then return end

		local Material, Occupancy = workspace.Terrain:ReadVoxels( Region3.new( End - Vector3.new( 2, 2, 2 ), End + Vector3.new( 2, 2, 2 ) ):ExpandToGrid( 4 ), 4 )

		local Humanoids = { }

		if( Material[ 1 ][ 1 ][ 1 ] == Enum.Material.Water ) then

			local Radius = GunStats.BulletType.Radius or 15

			local Type = type( GunStats.BulletType.Type ) == "function" and GunStats.BulletType.Type or GunStats.BulletType.Type == "Stun" and Stun

			FakeExplosion( { Position = End, BlastRadius = Radius, BlastPressure = 0, ExplosionType = Enum.ExplosionType.NoCraters }, function ( Part, Dist )

				if Core.IgnoreFunction( Part ) then return end

				local ResH, ResD
				
				if Type then
					
					ResH, ResD = Type( StatObj, GunStats, User, Part, ( End - Part.Position ).magnitude / Radius, GunStats.BulletType.DamageType or Core.DamageType.Electricity, StatObj.Value )
					
				else
					
					ResH, ResD = Core.GetDamage( User, Part, GunStats.Damage, GunStats.BulletType.DamageType or Core.DamageType.Electricity, ( End - Part.Position ).magnitude / Radius, GunStats.DistanceModifier, GunStats.AllowTeamKill, StatObj.Value, GunStats.InvertTeamKill, GunStats.InvertDistanceModifier )
					
				end

				if ResH and ResH:GetState( ) == Enum.HumanoidStateType.Swimming and ResD > ( ( Humanoids[ ResH ] or { } )[ 1 ] or 0 ) then

					Humanoids[ ResH ] = { ResD, Part.Name }

				end

			end )

		end

		local ResH, ResD = Core.GetDamage( User, Hit, GunStats.Damage, GunStats.BulletType.DamageType or Core.DamageType.Electricity, ( Barrel.Position - End ).magnitude / GunStats.Range, GunStats.DistanceModifier, GunStats.AllowTeamKill, StatObj.Value, GunStats.InvertTeamKill, GunStats.InvertDistanceModifier )

		if ResH and ResD > ( ( Humanoids[ ResH ] or { } )[ 1 ] or 0 ) then
			
			Humanoids[ ResH ] = { ResD, Hit.Name }
			
		end

		if next( Humanoids ) then
			
			local Hums = { }
			
			for a, b in pairs( Humanoids ) do
				
				Hums[ #Hums + 1 ] = { a, b[ 1 ], b[ 2 ] }
				
			end

			return Core.DamageObj( User, Hums, StatObj.Value, GunStats.BulletType.DamageType or Core.DamageType.Electricity )

		end

	end },

	Fire = { Func = function ( StatObj, GunStats, User, Hit, Barrel, End )
		
		local ResH, ResD = Core.GetDamage( User, Hit, GunStats.Damage, GunStats.BulletType.DamageType or Core.DamageType.Fire, ( Barrel.Position - End ).magnitude / GunStats.Range, GunStats.DistanceModifier, GunStats.AllowTeamKill, StatObj.Value, GunStats.InvertTeamKill, GunStats.InvertDistanceModifier )
		
		if ResH then
			
			local Damaged = Core.DamageObj( User, { { ResH, ResD, Hit.Name } }, StatObj.Value, GunStats.BulletType.DamageType or Core.DamageType.Fire )
			
			if next( Damaged ) then
				
				FireDamage( StatObj, GunStats, User, Hit, ResH, ResD )
				
				return Damaged
				
			end
			
		end

	end },

	Stun = { Func = function ( StatObj, GunStats, User, Hit, Barrel, End )

		local ResH, ResD = Stun( StatObj, GunStats, User, Hit, ( Barrel.Position - End ).magnitude / GunStats.Range, GunStats.BulletType.DamageType or Core.DamageType.Electricity )

		if ResH then

			return Core.DamageObj( User, { { ResH, ResD, Hit.Name } }, StatObj.Value, GunStats.BulletType.DamageType or Core.DamageType.Electricity )

		end

	end },

	Explosive = { Func = function ( StatObj, GunStats, User, Hit, Barrel, End )

		if not Hit and GunStats.BulletType.ExplodeOnHit then return end

		local BlastRadius = GunStats.BulletType.BlastRadius

		local JointRadius = GunStats.BulletType.DestroyJointRadiusPercent or 1

		local Type = type( GunStats.BulletType.Type ) == "function" and GunStats.BulletType.Type or GunStats.BulletType.Type == "Stun" and Stun

		local Humanoids = { }

		FakeExplosion( { Position = End, BlastRadius = BlastRadius, BlastPressure = GunStats.BulletType.BlastPressure, ExplosionType = GunStats.BulletType.ExplosionType }, function ( Part, Dist )

			if Core.IgnoreFunction( Part ) or not Part.Parent or Part.Parent:IsA( "Tool" ) then return end

			local ResH, ResD
			
			if Type then
				
				ResH, ResD = Type( StatObj, GunStats, User, Part, ( End - Part.Position ).magnitude / BlastRadius, GunStats.BulletType.DamageType or Core.DamageType.Explosive, StatObj.Value )
				
			else
				
				ResH, ResD = Core.GetDamage( User, Part, GunStats.Damage, GunStats.BulletType.DamageType or Core.DamageType.Explosive, ( End - Part.Position ).magnitude / BlastRadius, GunStats.DistanceModifier, GunStats.AllowTeamKill, StatObj.Value, GunStats.InvertTeamKill, GunStats.InvertDistanceModifier )
				
			end

			if ResH and ResD > ( ( Humanoids[ ResH ] or { } )[ 1 ] or 0 ) then

				Humanoids[ ResH ] = { ResD, Part.Name }

				return

			elseif ResH == nil and Dist / BlastRadius <= JointRadius then

				-----------------------------------------------------------------check for both parts in range of joints
				Part:BreakJoints( )

			end

		end )

		if next( Humanoids ) then
			
			local Hums = { }
			
			for a, b in pairs( Humanoids ) do
				
				Hums[ #Hums + 1 ] = { a, b[ 1 ], b[ 2 ] }
				
			end

			return Core.DamageObj( User, Hums, StatObj.Value, GunStats.BulletType.DamageType or Core.DamageType.Explosive )

		end

	end }

}

Core.Damageables = setmetatable( { }, { __mode = "k" } )

workspace.DescendantAdded:Connect( function ( Child )
	
	if not Core.Damageables[ Child ] and ( Child:IsA( "Humanoid" ) or ( Child:IsA( "DoubleConstrainedValue" ) and Child.Name == "Health" ) ) then
		
		Core.Damageables[ Child ] = true
		
		Core.DamageableAdded:Fire( Child )
		
	end
	
end )

local Descendants = workspace:GetDescendants( )

for a = 1, #Descendants do
	
	if not Core.Damageables[ Descendants[ a ] ] and ( Descendants[ a ]:IsA( "Humanoid" ) or ( Descendants[ a ]:IsA( "DoubleConstrainedValue" ) and Descendants[ a ].Name == "Health" ) ) then
		
		Core.Damageables[ Descendants[ a ] ] = true
		
		Core.DamageableAdded:Fire( Descendants[ a ] )
		
	end
	
end

Core.Visuals = { }

local IsClient = RunService:IsClient( )

local IsServer = RunService:IsServer( )

local GunStatFolder

if IsServer then
	
	GunStatFolder = game:GetService( "ReplicatedStorage" ):FindFirstChild( "GunStats" )
	
	if not GunStatFolder then
	
		GunStatFolder = Instance.new( "Folder" )
	
		GunStatFolder.Name = "GunStats"
	
		GunStatFolder.Parent = game:GetService( "ReplicatedStorage" )
	
	end
	
else
	
	GunStatFolder = game:GetService( "ReplicatedStorage" ):WaitForChild( "GunStats" )
	
end

function Core.GetGunStats( StatObj )

	local StatMod = GunStatFolder:FindFirstChild( StatObj.Value, true )

	local Stats = require( StatMod )

	if not Stats.Required then

		Stats.Required = true
		
		if IsClient then
			
			coroutine.wrap( ContentProvider.PreloadAsync )( ContentProvider, { StatMod } )
			
		end

	end

	return Stats

end

function Core.ToolAdded( Tool, Plr )
	
	local StatObj = Tool:FindFirstChild( "GunStat" )

	if StatObj and not Core.Weapons[ StatObj ] then

		if IsClient then

			local Weapon = Core.Setup( StatObj )

			Core.PlayerToUser( Weapon, Plr )

		else

			Core.Weapons[ StatObj ] = true

			Tool.Equipped:Connect( function ( )
				
				Core.WeaponSelected:Fire( StatObj, Plr )

			end )

			Tool.Unequipped:Connect( function ( )
				
				Core.WeaponDeselected:Fire( StatObj, Plr )

			end )

		end

	end

end

function Core.Spawned( Plr )

	local Children = Plr.Character:GetChildren( )

	for a = 1, #Children do

		Core.ToolAdded( Children[ a ], Plr )

	end

	Plr.Character.ChildAdded:Connect( function ( Tool )

		Core.ToolAdded( Tool, Plr )

	end )

end


Core.Weapons = setmetatable( { }, { __mode = 'k' } )

function Core.GetWeapon( StatObj )

	return Core.Weapons[ StatObj ] ~= true and Core.Weapons[ StatObj ] or nil

end

Core.Selected = setmetatable( { }, { __mode = 'k' } )

Core.WeaponTick = setmetatable( { }, { __mode = 'k' } )

local SelectedHB

function RunSelected( )
	
	SelectedHB = RunService.Heartbeat:Connect( function ( Step )
		
		if not Core.Selected[ Players.LocalPlayer ] then SelectedHB:Disconnect( ) SelectedHB = nil end
		
		local UnitRay = Players.LocalPlayer:GetMouse( ).UnitRay
		
		Core.LPlrsTarget = { Core.FindPartOnRayWithIgnoreFunction( Ray.new( UnitRay.Origin, UnitRay.Direction * 5000 ), Core.IgnoreFunction, { Players.LocalPlayer.Character } ) }
		
		if next( Core.WeaponTick ) then
			
			local Remove = { }
			
			for c, _ in pairs( Core.WeaponTick ) do
				
				if c.MouseDown then
	
					if c.GunStats.WindupTime == nil or c.GunStats.WindupTime == 0 then
						
						Core.Fire( c )
						
					elseif c.Reloading then
	
						if c.Windup or c.WindupSound then
	
							Core.SetWindup( c, math.max( c.Windup - ( Step * 2 ), 0 ) )
	
						end
	
					elseif c.Windup and c.Windup >= c.GunStats.WindupTime then
						
						Core.Fire( c )
	
					else
	
						Core.SetWindup( c, ( c.Windup or 0 ) + Step )
	
					end
	
				else
					
					local Needed
					
					if c.Windup then
						
						Needed = true
						
						Core.SetWindup( c, math.max( c.Windup - ( Step * 2 ), 0 ) )
						
					end
					
					if c.GunStats.ClipReloadPerSecond and c.Clip < c.GunStats.ClipSize and ( not c.StoredAmmo or c.StoredAmmo ~= 0 ) then
						
						Needed = true
						
						if not c.Reloading and c.LastClick and ( c.LastClick + ( c.GunStats.ClipsReloadDelay or 0 ) ) <= tick( ) then
							
							local Amnt = ( c.ClipRemainder or 0 ) + c.GunStats.ClipReloadPerSecond * Step
							
							c.ClipRemainder = Amnt % 1
							
							Amnt = math.min( math.floor( Amnt ), c.GunStats.ClipSize - c.Clip )
							
							if c.StoredAmmo then
								
								Amnt = math.min( Amnt, c.StoredAmmo )
								
								Core.SetStoredAmmo( c, c.StoredAmmo - Amnt )
								
							end
							
							if Amnt > 0 then
								
								Core.SetClip( c, c.Clip + Amnt )
								
							end
							
						end
						
					end
					
					if c.ShotRecoil > 0 then
						
						Needed = true
						
						if c.LastClick and ( c.LastClick + 0.15 <= tick( ) or c.Reloading ) then
							
							c.ShotRecoil = math.max( c.ShotRecoil - 1, 0 )
							
						end
						
					end
					
					if not Needed then
						
						Remove[ #Remove + 1 ] = c
						
					end
	
				end
				
			end
			
			for a = 1, #Remove do
				
				Core.WeaponTick[ Remove[ a ] ] = nil
				
			end
			
		end
		
	end )
	
end

function Core.SetMouseDown( Weapon )
	
	Weapon.MouseDown = tick( )
	
	Core.WeaponTick[ Weapon ] = true
	
end

Core.WeaponSelected.Event:Connect( function ( StatObj, User )

	local Weapon = Core.GetWeapon( StatObj )

	if not Weapon then return end

	if Weapon.LastClick < tick( ) + ( Weapon.GunStats.SelectDelay or 0.2 ) then

		Weapon.LastClick = tick( ) + ( Weapon.GunStats.SelectDelay or 0.2 )

	end
	
	if Weapon.GunStats.ClipReloadPerSecond and Weapon.Clip < Weapon.GunStats.ClipSize and ( not Weapon.StoredAmmo or Weapon.StoredAmmo ~= 0 ) then
		
		Core.WeaponTick[ Weapon ] = true
		
	end
	
	Core.Selected[ User ] = Core.Selected[ User ] or { }
	
	Core.Selected[ User ][ Weapon ] = tick( )
	
	if not SelectedHB then
		
		RunSelected( )
		
	end
	
	if not Weapon.GunStats.ReloadWhileUnequipped then
		
		Weapon.Reloading = nil
		
	end

	if Weapon.ReloadDelay then

		ContextActionService:BindAction( "Reload", function ( Name, State, Input )

			if State ~= Enum.UserInputState.Begin or not Core.Selected[ Weapon.User ] or not Core.Selected[ Weapon.User ][ Weapon ] then return end

			Core.Reload( Weapon )

		end, true )

		ContextActionService:SetImage( "Reload", "rbxassetid://371461853" )

	end

end )

Core.WeaponDeselected.Event:Connect( function ( StatObj, User )

	local Weapon = Core.GetWeapon( StatObj )

	if not Weapon then return end

	Weapon.ShotRecoil = 0

	Weapon.ModeShots = 0

	if Weapon.Windup then

		Core.SetWindup( Weapon, 0 )

	end
	
	if Core.Selected[ User ] then
		
		Core.Selected[ User ][ Weapon ] = nil
		
		if not next( Core.Selected[ User ] ) then
			
			Core.Selected[ User ] = nil
			
		end
		
	end
	
	Core.WeaponTick[ Weapon ] = nil
	
	Weapon.MouseDown = nil
	
	if not Weapon.GunStats.ReloadWhileUnequipped then
		
		Weapon.Reloading = nil
		
	end

	if Weapon.ReloadDelay then

		ContextActionService:UnbindAction( "Reload" )

	end

	Core.ReloadEnd:Fire( StatObj )

end )

function Core.Destroy( Weapon )

	if not Weapon.StatObj then return end

	if Core.Selected[ Weapon.User ] and Core.Selected[ Weapon.User ][ Weapon ] then
		
		Core.WeaponDeselected:Fire( Weapon.StatObj, Weapon.User )
		
	end

	Core.Weapons[ Weapon.StatObj ] = nil

	ContextActionService:UnbindAction( "Reload" )

	for a, b in pairs( Weapon.Events ) do

		Weapon.Events[ a ]:Disconnect( )

		Weapon.Events[ a ] = nil

	end

	if Weapon.StatObj.Parent then

		Weapon.StatObj.Parent:Destroy( )

	end

	for a, b in pairs( Weapon ) do

		Weapon[ a ] = nil

	end

	Weapon = nil

end

function Core.PlayerToUser( Weapon, Plr )

	Weapon.User = Weapon.User or Plr

	Weapon.Ignore = Weapon.Ignore or { }

	Weapon.Ignore[ #Weapon.Ignore + 1 ] = Weapon.User.Character

	Weapon.Events[ #Weapon.Events + 1 ] = Plr.CharacterAdded:Connect( function ( Char )

		Weapon.Ignore[ #Weapon.Ignore + 1 ] = Char

	end )

	Weapon.Target = Weapon.Target or Core.GetLPlrsTarget

	return Weapon

end

function Core.Setup( StatObj )

	local GunStats = Core.GetGunStats( StatObj )

	local Weapon = { }

	Core.Weapons[ StatObj ] = Weapon

	Weapon.GunStats = GunStats

	Weapon.Ignore = GunStats.Ignores and GunStats.Ignores( StatObj ) or { }

	Weapon.Target = GunStats.Target

	Weapon.User = GunStats.User

	Weapon.Events = { }

	Weapon.LastClick = 0

	Weapon.ShotRecoil = 0

	Weapon.StatObj = StatObj

	Weapon.Clip = GunStats.StartingClip or GunStats.ClipSize

	Weapon.StoredAmmo = GunStats.StartingStoredAmmo or GunStats.MaxStoredAmmo

	if Weapon.StoredAmmo and Weapon.Clip then Weapon.StoredAmmo = Weapon.StoredAmmo - Weapon.Clip end

	Weapon.CurBarrel = 1

	Weapon.ModeShots = 0

	Weapon.CurFireMode = 1

	Weapon.BarrelPart = GunStats.Barrels( StatObj )

	if StatObj.Parent and StatObj.Parent:IsA( "Tool" ) then

		Weapon.Events[ #Weapon.Events + 1 ] = StatObj.Parent.Equipped:Connect( function ( )
			
			Core.WeaponSelected:Fire( StatObj, Weapon.User )

		end )

		Weapon.Events[ #Weapon.Events + 1 ] = StatObj.Parent.Unequipped:Connect( function ( )
			
			Core.WeaponDeselected:Fire( StatObj, Weapon.User )

		end )

	end

	return Weapon

end

function Core.SetWindup( Weapon, Value )

	local Started

	if not Weapon.Windup then

		Started = true

	elseif Value == 0 then

		Value = nil

		Started = false

	end

	Weapon.Windup = Value
	
	Core.WindupChanged:Fire( Weapon.StatObj, Value, Started )

end

function Core.GetFireMode( Weapon )

	local Mode = Weapon.GunStats.FireModes[ Weapon.CurFireMode ]

	if Core.FireModes[ Mode ] then return Core.FireModes[ Mode ] end

	return Mode

end

function Core.SetFireMode( Weapon, Value )

	Weapon.CurFireMode = Value

	Core.FireModeChanged:Fire( Weapon.StatObj, Value )

end

function Core.NextFireMode( Weapon )

	if Weapon.CurFireMode + 1 > #Weapon.GunStats.FireModes then

		Core.SetFireMode( Weapon, 1 )

	else

		Core.SetFireMode( Weapon, Weapon.CurFireMode + 1 )

	end

end

function Core.GetBulletType( GunStats )

	if not GunStats.BulletType then return Core.BulletTypes.Kinetic end

	if Core.BulletTypes[ GunStats.BulletType.Name ] then return Core.BulletTypes[ GunStats.BulletType.Name ] end

	return GunStats.BulletType

end

function Core.IgnoreFunction( Part )
	
    return not CollectionService:HasTag( Part, "nopen" ) and ( not Part or not Part.Parent or CollectionService:HasTag( Part, "forcepen" ) or Part.Parent:IsA( "Accoutrement" ) or Part.Transparency >= 1 or ( Core.GetValidHumanoid( Part ) == nil and Part.CanCollide == false ) ) or false

end

if IsServer then
	
	-------------- TODO REMOVE THIS SMH
	
	for a, b in pairs( workspace:GetDescendants( ) ) do
		
		pcall( function ( )
			
			if b:IsA( "BasePart" ) and b.Parent:IsA( "BasePart" ) and Core.IgnoreFunction( b.Parent ) and not Core.IgnoreFunction( b ) then
				
				warn( ( " :strap gnidneffO\nkrow stsil erongi tsacyar eht woh ot eud strap rehto nihtiw strap evah uoy fi kaerb lliw 2S" ):reverse( ) .. b:GetFullName( ) .. ( "\nedisni\n" ):reverse( ) .. b.Parent:GetFullName( ) )
				
			end
			
		end )
		
	end
	
	workspace.DescendantAdded:Connect( function ( Obj )
		
		pcall( function ( )
			
			if Obj:IsA( "BasePart" ) and Obj.Parent:IsA( "BasePart" ) and Core.IgnoreFunction( Obj.Parent ) and not Core.IgnoreFunction( Obj ) then
				
				warn( ( " :strap gnidneffO\nkrow stsil erongi tsacyar eht woh ot eud strap rehto nihtiw strap evah uoy fi kaerb lliw 2S" ):reverse( ) .. Obj:GetFullName( ) .. ( "\nedisni\n" ):reverse( ) .. Obj.Parent:GetFullName( ) )
				
			end
			
		end )
		
	end )
	
end

function Core.FindPartOnRayWithIgnoreFunction( R, IgnoreFunction, Ignore, IgnoreWater )
	
	local Hit, Pos, Normal, Material = workspace:FindPartOnRayWithIgnoreList( R, Ignore, false, IgnoreWater == nil and true or IgnoreWater )
	
	if not Hit or not IgnoreFunction( Hit ) then

		return Hit, Pos, Normal, Material

	end

	Ignore[ #Ignore + 1 ] = Hit

	R = Ray.new( Pos - R.Unit.Direction, R.Unit.Direction * ( R.Direction.magnitude - ( Pos - R.Origin ).magnitude ) )

	return Core.FindPartOnRayWithIgnoreFunction( R, IgnoreFunction, Ignore, IgnoreWater )

end

function Core.GetAccuracy( Weapon )

	local ShotRecoil = Weapon.ShotRecoil
	
	if  Weapon.User.Character and Weapon.User.Character:FindFirstChild( "HumanoidRootPart" ) then

		local Vel = Weapon.User.Character.HumanoidRootPart.Velocity / Vector3.new( 1, 3, 1 )

		if Vel.magnitude > 0.1 then

			ShotRecoil = ShotRecoil + ( Vel.magnitude / 4 * Config.MovementAccuracyPercentage )

		end

	end
	
	return math.max( Weapon.GunStats.AccurateRange - ShotRecoil, 1 )

end

Core.PreventReload = { }

function Core.Reload( Weapon )
	
	if not Weapon.StatObj or not Weapon.GunStats.ClipSize or Weapon.GunStats.ReloadDelay < 0 or Weapon.GunStats.FireRate == 0 or Weapon.Reloading or next( Core.PreventReload ) or ( Weapon.StoredAmmo and Weapon.StoredAmmo == 0 ) then return end

	if Weapon.GunStats.ClipSize > 0 and Weapon.Clip ~= Weapon.GunStats.ClipSize then

		local ReloadTick = Weapon.MouseDown or tick( )

		Weapon.Reloading = ReloadTick

		Weapon.ModeShots = 0

		local NewClip = math.floor( Weapon.Clip / ( Weapon.GunStats.ReloadAmount or 1 ) ) * ( Weapon.GunStats.ReloadAmount or 1 )

		if Weapon.StoredAmmo then

			Core.SetStoredAmmo( Weapon, Weapon.StoredAmmo + Weapon.Clip - NewClip )

		end

		Core.SetClip( Weapon, NewClip )

		Core.ReloadStart:Fire( Weapon.StatObj )

		local Delay = Weapon.GunStats.ReloadDelay / math.ceil( Weapon.GunStats.ClipSize / ( Weapon.GunStats.ReloadAmount or 1 ) )

		Weapon.ReloadStart = tick( ) - Delay * Weapon.Clip / ( Weapon.GunStats.ReloadAmount or 1 )

		if Weapon.GunStats.InitialReloadDelay or ( Weapon.GunStats.ReloadAmount or 1 ) == 1 then hbwait( Weapon.GunStats.InitialReloadDelay or 0.25 ) end

		if Weapon.Reloading == ReloadTick then

			local w = Delay

			local TotalExtra = 0

			for i = Weapon.Clip / ( Weapon.GunStats.ReloadAmount or 1 ), math.ceil( Weapon.GunStats.ClipSize / ( Weapon.GunStats.ReloadAmount or 1 ) ) - 1 do

				Core.ReloadStepped:Fire( Weapon.StatObj )

				TotalExtra = TotalExtra + w - Delay

				if TotalExtra > Delay then

					TotalExtra = TotalExtra - Delay + Delay - w

				else

					w = hbwait( Delay + Delay - w )

				end

				if Weapon.Reloading ~= ReloadTick then
					
					break

				end

				local Add = Weapon.StoredAmmo and math.min( ( Weapon.GunStats.ReloadAmount or 1 ), Weapon.StoredAmmo ) or ( Weapon.GunStats.ReloadAmount or 1 )

				Core.SetClip( Weapon, Weapon.Clip + Add )

				if Weapon.StoredAmmo then

					Core.SetStoredAmmo( Weapon, Weapon.StoredAmmo - Add )

					if Weapon.StoredAmmo == 0 then

						break

					end

				end

			end

		end

		if Weapon.Reloading == false or Weapon.Reloading == ReloadTick then

			Core.ReloadEnd:Fire( Weapon.StatObj )

			if Weapon.GunStats.FinalReloadDelay then hbwait( Weapon.GunStats.FinalReloadDelay ) end

			Weapon.Reloading = nil

			Weapon.ReloadStart = nil

		end

	end

end

function Core.SetStoredAmmo( Weapon, Value )
	
	if not Weapon.StoredAmmo or Weapon.StoredAmmo == Value then return end
	
	Weapon.StoredAmmo = Value
	
	Core.StoredAmmoChanged:Fire( Weapon.StatObj, Value )
	
	if Weapon.GunStats.ClipReloadPerSecond and Weapon.Clip < Weapon.GunStats.ClipSize and Value ~= 0 then
		
		Core.WeaponTick[ Weapon ] = true
		
	end
	
end

function Core.SetClip( Weapon, Value )

	if not Weapon.Clip or Weapon.Clip == Value then return end

	Weapon.Clip = Value

	Core.ClipChanged:Fire( Weapon.StatObj, Value )

end

Core.PreventFire = { }

function Core.CanFire( Weapon, Barrel )
	
	if next( Core.PreventFire ) then return false end

	if ( typeof( Weapon.User ) == "Instance" and Weapon.User:IsA( "Player" ) and not Weapon.User.Character ) or ( Weapon.User.Character and Weapon.User.Character:FindFirstChild( "Humanoid" ) and Weapon.User.Character.Humanoid:GetState( ) == Enum.HumanoidStateType.Dead ) then return false end

	if not Weapon.StatObj or Weapon.GunStats.UseBarrelAsOrigin or Weapon.GunStats.NoAntiWall or not Weapon.User.Character then return end

	local Hit, End, Normal, Material = Core.FindPartOnRayWithIgnoreFunction( Ray.new( Weapon.User.Character.HumanoidRootPart.Position, Barrel.Position - Weapon.User.Character.HumanoidRootPart.Position ), Core.IgnoreFunction, Weapon.Ignore )

	if Hit then

		return Hit, End, Normal, Material

	end

end

function TableCopy( Table )

	local New = { }

	for a = 1, #Table do

		New[ a ] = Table[ a ]

	end

	return New

end

function Core.Fire( Weapon )

	if Weapon == nil then return end

	local FireMode = Core.GetFireMode( Weapon )
	
	if Weapon.Clip ~= 0 and Weapon.Reloading and Weapon.Reloading ~= Weapon.MouseDown then

		Weapon.Reloading = false

	end

	if FireMode.PreventFire or Weapon.LastClick >= tick( ) or Weapon.Reloading ~= nil then return end

	if Weapon.Clip == 0 then

		Core.Reload( Weapon )

		return

	end

	local ShotsPerClick = Weapon.GunStats.ShotsPerClick or 1

	local OneAmmoPerClick = Weapon.GunStats.OneAmmoPerClick or false

	if Weapon.GunStats.ClipSize and Weapon.Clip - ( OneAmmoPerClick and 1 or ShotsPerClick ) < 0 then

		Core.Reload( Weapon )

		return

	end

	local LastClick = 1 / Weapon.GunStats.FireRate

	local Start = tick( )

	local DelayBetweenShots = Weapon.GunStats.DelayBetweenShots or 0

	Weapon.LastClick = Start + LastClick + ( DelayBetweenShots * ShotsPerClick )

	local ActualFired = 0

	local CurFireMode = Weapon.CurFireMode
	
	local ToNetwork = ShotsPerClick > 1 and DelayBetweenShots == 0 and { } or nil
	
	local OverStep = 0

	for BulNum = 1, ShotsPerClick do

		if ( not Core.Selected[ Weapon.User ] or not Core.Selected[ Weapon.User ][ Weapon ] ) or Weapon.CurFireMode ~= CurFireMode then break end

		local Barrel = type( Weapon.BarrelPart ) == "table" and Weapon.BarrelPart[ Weapon.CurBarrel ] or Weapon.BarrelPart

		if Barrel and Barrel.Parent and Barrel.Parent.Parent then

			if type( Weapon.BarrelPart ) == "table" then

				if Weapon.CurBarrel >= #Weapon.BarrelPart then

					Weapon.CurBarrel = 1

				else

					Weapon.CurBarrel = Weapon.CurBarrel + 1

				end

			end

			ActualFired = ActualFired + 1

			local Hit, End, Normal, Material = Core.CanFire( Weapon, Barrel )
			
			if Hit ~= false then

				local IgnoreWater = Weapon.GunStats.BulletType and ( Weapon.GunStats.BulletType.Name == "Fire" or Weapon.GunStats.BulletType.Name == "Lightning" )

				if IgnoreWater then

					if workspace.Terrain:ReadVoxels(Region3.new( Barrel.Position - Vector3.new( 2, 2, 2 ), Barrel.Position + Vector3.new( 2, 2, 2 ) ):ExpandToGrid(4), 4)[1][1][1] == Enum.Material.Water then

						Hit, End, Normal, Material = workspace.Terrain, Barrel.Position, -Barrel.CFrame.lookVector, Enum.Material.Water

					end

				end

				if not Hit then

					local _, Target = Weapon.Target( Weapon.StatObj, Barrel )

					if Target then

						local Origin = not Weapon.GunStats.UseBarrelAsOrigin and Weapon.User and Weapon.User.Character and Weapon.User.Character:FindFirstChild( "Head" ) and Weapon.User.Character.Head.Position or Barrel.Position
						
						Target = CFrame.new( Origin, Target ) * CFrame.Angles( 0, 0, math.rad( math.random( 0, 3599 ) / 10 ) )
						
                        Hit, End, Normal, Material = Core.FindPartOnRayWithIgnoreFunction( Ray.new( Origin, CFrame.new( Origin, ( Target + Target.lookVector * 1000 + Target.UpVector * math.random( 0, 1000 / Core.GetAccuracy( Weapon ) / 2 ) ).p ).lookVector * Weapon.GunStats.Range - Vector3.new( 0, Config.BulletDrop / 1000 * Weapon.GunStats.Range, 0 ) ), Core.IgnoreFunction, TableCopy( Weapon.Ignore ), not IgnoreWater )
						
					else

						Hit = false

					end

				end

				if Hit ~= false then

					if Weapon.Clip  and ( not OneAmmoPerClick or ( ShotsPerClick and ShotsPerClick > 1 and BulNum == 1 ) ) then

						Core.SetClip( Weapon, Weapon.Clip - 1 )

					end

					Weapon.ShotRecoil = math.min( Weapon.ShotRecoil + math.abs( Weapon.GunStats.Damage ) / 50, math.abs( Weapon.GunStats.Damage ) / 5 * ShotsPerClick )

					local Offset = Hit and ( Hit.CFrame:pointToObjectSpace( End ) / Hit.Size ) or nil
					
					local Humanoids = ( Core.GetBulletType( Weapon.GunStats ).Func or Core.BulletTypes.Kinetic.Func )( Weapon.StatObj, Weapon.GunStats, Weapon.User, Hit, Barrel, End )

					if IsClient then
						
						local FirstShot
						
						if ShotsPerClick > 1 then FirstShot = BulNum == 1 end

						if Players.LocalPlayer == Weapon.User then

							Core.ClientVisuals:Fire( Weapon.StatObj, Barrel, Hit, End, Normal, Material, Offset, FirstShot )

						end
						
						if not IsServer then
							
							Core.SharedVisuals:Fire( Weapon.StatObj, Weapon.User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, Humanoids, tick( ) + _G.ServerOffset )

						end

					end
					
					if ToNetwork then
						
						ToNetwork[ BulNum ] = { Hit == workspace.Terrain and Material or Hit, Normal, Hit == nil and End or Offset, Weapon.CurBarrel ~= 1 and Weapon.CurBarrel or nil }
						
					else
						
						if IsServer then
							
							Core.HandleServer( nil, tick( ), Weapon.StatObj, Hit == workspace.Terrain and Material or Hit, Normal, Hit == nil and End or Offset, Weapon.User, Weapon.CurBarrel ~= 1 and Weapon.CurBarrel or nil )
							
							else
							
							Core.ShotRemote:FireServer( tick( ) + _G.ServerOffset, Weapon.StatObj, Hit == workspace.Terrain and Material or Hit, Normal, Hit == nil and End or Offset, Players.LocalPlayer ~= Weapon.User and Weapon.User or nil, Weapon.CurBarrel ~= 1 and Weapon.CurBarrel or nil )
							
						end
						
					end
					
					--Weapon.Shotaaa = ( Weapon.Shotaaa or 0  ) + 1
					
				end

			end

			if DelayBetweenShots > 0 and ShotsPerClick > 1 and Weapon.Clip ~= 0 then
				
				if OverStep < DelayBetweenShots then
					
					OverStep = OverStep + ( hbwait( DelayBetweenShots ) - DelayBetweenShots )
					
				else
					
					OverStep = OverStep - DelayBetweenShots
					
				end
				
			end

		end

	end
	
	if ToNetwork then
		
		if IsServer then
			
			Core.HandleServer( nil, tick( ), Weapon.StatObj, ToNetwork, Weapon.User )
			
		else
			
			Core.ShotRemote:FireServer( tick( ) + _G.ServerOffset, Weapon.StatObj, ToNetwork, Players.LocalPlayer ~= Weapon.User and Weapon.User or nil )
			
		end
		
	end

	if ShotsPerClick > 1 and ShotsPerClick ~= ActualFired then

		Weapon.LastClick = Start + LastClick + ( DelayBetweenShots * ActualFired )

	end

	Weapon.ModeShots = Weapon.ModeShots + 1

	if not FireMode.Automatic and ( not FireMode.Shots or FireMode.Shots == 1 or Weapon.ModeShots >= FireMode.Shots ) then
		
		Weapon.MouseDown = nil
		
		Core.FiringEnded:Fire( Weapon.StatObj )

		Weapon.ModeShots = 0

	end

end

--[[coroutine.wrap( function ( )
	
	while wait( 1 ) do
		
		for _, a in pairs( Core.Selected ) do
			
			for c, _ in pairs( a ) do
				
				print( c.Shotaaa )
				
				c.Shotaaa = 0
				
			end
		
		end
		
	end
	
end)( )]]

Core.DamageType = {

	Kinetic = "Kinetic",

	Explosive = "Explosive",

	Slash = "Slash",

	Fire = "Fire",

	Electricity = "Electricity",
	
	Heal = "Heal"

}

function Core.GetTeamInfo( Obj )

	if type( Obj ) == "table" then

		return Obj.TeamColor, Obj.Neutral

	end

	if Obj:IsA( "Player" ) then

		return Obj.TeamColor, Obj.Neutral, Obj

	end

	local PlrObj = Players:GetPlayerFromCharacter( Obj.Parent )

	if PlrObj then

		return PlrObj.TeamColor, PlrObj.Neutral, PlrObj

	end

	if Obj:FindFirstChild( "TeamColor" ) then

		return Obj.TeamColor.Value, false

	end

	return BrickColor.White( ), true

end

local function ActualTeamKill( TC1, N1, TC2, N2 )

	if TC1 == TC2 or ( N1 and N2 ) then

		return false

	end

	local CanKill = true

	for a = 1, #Config.AllowTeamKillFor do

		if Config.AllowTeamKillFor[ a ][ TC1.name ] and Config.AllowTeamKillFor[ a ][ TC2.name ] then

			CanKill = false

		end

	end

	return CanKill
	
end

function Core.CheckTeamkill( P1, P2, AllowTeamKill, InvertTeamKill )
	
	local TC1, N1, PlrObj1 = Core.GetTeamInfo( P1 )

	local TC2, N2, PlrObj2 = Core.GetTeamInfo( P2 )

	if PlrObj1 and PlrObj2 and PlrObj1 == PlrObj2 then return Config.SelfDamage or false end
	
	if ( AllowTeamKill == nil and Config.AllowTeamKill ) or AllowTeamKill then return true end

	if Config.AllowNeutralTeamKill and ( N1 or N2 ) then return true end

	if InvertTeamKill then return not ActualTeamKill( TC1, N1, TC2, N2 ) else return ActualTeamKill( TC1, N1, TC2, N2 ) end

end

function Core.GetValidHumanoid( Obj )

	if not Obj or not Obj:IsDescendantOf( game ) then return end

	local Hum = Obj:FindFirstChild( "Health" ) or Obj.Parent:FindFirstChildOfClass( "Humanoid" ) or Obj.Parent:FindFirstChild( "Health" ) or Obj.Parent.Parent:FindFirstChildOfClass( "Humanoid" ) or Obj.Parent.Parent:FindFirstChild( "Health" )
	
	if Hum and ( ( Hum:IsA( "Humanoid" ) and Hum.Health > 0 ) or ( not Hum:IsA( "Humanoid" ) and Hum.Value > 0 ) ) then
		
		local Health = Hum:FindFirstChild( "Health" )
		
		while Health and Health.Value > 0 do
			
			Hum, Health = Health, Health:FindFirstChild( "Health" )
			
		end
		
		return Hum
	
	end

end

function Core.GetDamage( User, Hit, OrigDamage, Type, Distance, DistanceModifier, IgnoreTeam, WeaponName, InvertTeamKill, InvertDistanceModifier )

	local Humanoid = Core.GetValidHumanoid( Hit )

	if not Humanoid then return end

	if Core.IgnoreFunction( Hit ) then return false end

	if not Core.CheckTeamkill( User, Humanoid, IgnoreTeam, InvertTeamKill ) then return false end
	
	local Damage = OrigDamage

	local hitName = Hit.Name:lower( )

	if hitName == "head" or hitName == "uppertorso" or CollectionService:HasTag( Hit, "s2headdamage" ) then

		Damage = Damage * Config.HeadDamageMultiplier

	elseif hitName:find( "leg" ) or hitName:find( "arm" ) or CollectionService:HasTag( Hit, "s2limbdamage" ) then

		Damage = Damage * Config.LimbDamageMultiplier

	elseif hitName:find( "hand" ) or hitName:find( "foot" ) or CollectionService:HasTag( Hit, "s2appendagedamage" ) then

		Damage = Damage * Config.AppendageDamageMultiplier

	end

	if Distance then

		if Distance > 1 then return false end
		
		if InvertDistanceModifier or ( InvertDistanceModifier ~= false and Config.InvertDistanceModifier ) then
			
			Distance = ( 1 - Distance ) * ( DistanceModifier or Config.DistanceDamageMultiplier )
			
			Damage = Damage * Distance
			
		else
			
			Distance = Distance * ( DistanceModifier or Config.DistanceDamageMultiplier )
			
			Damage = Damage * ( 1 - Distance )
			
		end

	end

	local Resistance = 1
	
	if Humanoid:FindFirstChild( "Resistances" ) then
		
		local Resistances = Humanoid.Resistances:GetChildren( )
		
		for a = 1, #Resistances do
			
			if Resistances[ a ].Name == WeaponName or Resistances[ a ].Name == Type or Resistances[ a ].Name == "All" then
				
				Resistance = Resistance * Resistances[ a ].Value
				
			end
			
		end
		
	end
	
	if Config.Resistances and Config.Resistances[ Type ] then
		
		Resistance = Resistance * Config.Resistances[ Type ]
		
	end

	Damage = Damage * Resistance * ( Config.GlobalDamageMultiplier or 1 )

	if Damage == 0 or ( OrigDamage > 0 and Damage < 0 ) or ( OrigDamage < 0 and Damage > 0 ) then

		return false

	end

	return Humanoid, Damage

end

if IsClient then

	if Players.LocalPlayer.Character then

		Core.Spawned( Players.LocalPlayer )

	end

	Players.LocalPlayer.CharacterAdded:Connect( function ( )

		Core.Spawned( Players.LocalPlayer )

	end )

else
	
	local function HandlePlr( Plr )
		
		if Plr.Character then Core.Spawned( Plr ) end

		Plr.CharacterAdded:Connect( function ( )

			Core.Spawned( Plr )

		end )
		
	end

	Players.PlayerAdded:Connect( HandlePlr )
	
	local Plrs = Players:GetPlayers( )
	
	for a = 1, #Plrs do
		
		HandlePlr( Plrs[ a ] )
		
	end

end

if IsServer then

	Core.ServerVisuals = Instance.new( "BindableEvent" )

	Core.ObjDamaged = Instance.new( "BindableEvent" )

	Core.HandleServer = function ( Plr, Time, StatObj, ToNetwork, User, _Offset, _User, _BarrelNum )
		
		if not StatObj or not StatObj.Parent then return end
		
		if type( ToNetwork ) ~= "table" then
			
			ToNetwork = { { ToNetwork, User, _Offset, _BarrelNum } }
			
			User = _User
			
		end

		User = User or Plr

		if tick( ) - Time > 1 then warn( ( User.Name .. " took too long to send shot packet, discarding! - %f" ):format( tick( ) - Time ) ) return end

		local GunStats = Core.GetGunStats( StatObj )

		local Barrels = GunStats.Barrels( StatObj )
		
		local CloseTo = { }

		local Plrs = Players:GetPlayers( )
		
		for a = 1, #ToNetwork do
			
			local Barrel = type( Barrels ) == "table" and Barrels[ ToNetwork[ a ][ 5 ] or 1 ] or Barrels
			
			if Barrel then
				
				local Hit, Normal, Offset, BarrelNum = unpack( ToNetwork[ a ] )
				
				local Material
				
				if typeof( Hit ) == "Instance" then
					
					Material = Hit.Material
					
				elseif Hit then
					
					Material = Hit
					
					Hit = workspace.Terrain
					
				end
				
				local End
				
				if Hit then
					
					End = Hit.CFrame:PointToWorldSpace( Offset * Hit.Size )
					
				else
					
					End = Offset
					
					Offset = nil
								
				end
				
				local Humanoids = ( Core.GetBulletType( GunStats ).Func or Core.BulletTypes.Kinetic.Func )( StatObj, GunStats, User, Hit, Barrel, End )
				
				local FirstShot
				
				if #ToNetwork > 1 then FirstShot = a == 1 end
				
				Core.ServerVisuals:Fire( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, #ToNetwork > 1 and a == 1 or nil, Humanoids, Time )
				
				if IsClient then
		
					Core.SharedVisuals:Fire( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, #ToNetwork > 1 and a == 1 or nil, Humanoids, Time )
		
					return
		
				end
		
				local BulRay = Ray.new( Barrel.Position, ( End - Barrel.Position ).Unit )
				
				for b = 1, #Plrs do
					
					if Plrs[ b ] ~= Plr then
						
						if BulRay:Distance( Plrs[ b ].Character and Plrs[ b ].Character:FindFirstChild( "HumanoidRootPart" ) and Plrs[ b ].Character.HumanoidRootPart.Position or Barrel.Position ) <= 250 then
							
							if #ToNetwork == 1 then
								
								Core.ShotRemote:FireClient( Plrs[ b ], Time, StatObj, User, ToNetwork[ 1 ][ 1 ], ToNetwork[ 1 ][ 2 ], _Offset, _BarrelNum )
								
							else
								
								CloseTo[ Plrs[ b ] ] = CloseTo[ Plrs[ b ] ] or { }
								
								CloseTo[ Plrs[ b ] ][ #CloseTo[ Plrs[ b ] ] + 1 ] = ToNetwork[ a ]
								
							end
							
						end
						
					end
					
				end
				
			end
			
		end
		
		if #ToNetwork == 1 then return end
		
		for a, b in pairs( CloseTo ) do
			
			if #b == 1 then
				
				Core.ShotRemote:FireClient( a, Time, StatObj, User, b[ 1 ][ 1 ], b[ 1 ][ 2 ], b[ 1 ][ 3 ], b[ 1 ][ 4 ], b[ 1 ][ 5 ] )
				
			else
				
				Core.ShotRemote:FireClient( a, Time, StatObj, User, b )
				
			end
			
		end

	end

	Core.ShotRemote.OnServerEvent:Connect( Core.HandleServer )

	Core.ClientSync.OnServerInvoke = function ( Plr, ClientTime )

		return tick( )

	end

	Core.DropHat.OnServerEvent:Connect( function ( Plr )

		if Config.HatMode == 1 or not Plr.Character then return end

		local Hats = Plr.Character:GetChildren( )

		for a = 1, #Hats do

			if Hats[ a ]:IsA( "Accessory" ) then

				if Config.HatMode == 2 then

					Hats[ a ]:Destroy( )

				else

					Hats[ a ].Parent = workspace

					local Reset

					local Event = Hats[ a ].AncestryChanged:Connect( function ( )

						Reset = true

					end )

					delay( 5, function ( )

						if not Reset then

							Hats[ a ]:Destroy( )

						end

					end )

				end

			end

		end

	end )
	
	Core.KilledEvents = { }
	
	Core.DamageInfos = setmetatable( { }, { __mode = "k" } )

	local ClntDmg = Instance.new( "RemoteEvent" )

	function Core.DamageObj( User, DamageInfos, WeaponName, TypeName, IgnoreSpecial )
		
		local Killed = { }
		
		local Damaged = { }
		
		for _, a in pairs( DamageInfos ) do
			
			local Damageable, Damage = a[ 1 ], a[ 2 ]
			
			if Damageable.Parent and not Damageable.Parent:FindFirstChildOfClass( "ForceField" ) and Damage ~= 0 then
				
				local Amount, PrevHealth
				
				if Damageable:IsA( "Humanoid" ) then
					
					PrevHealth = Damageable.Health
					
					Amount = Damage > 0 and ( Damageable.Health > Damage and Damage or Damageable.Health ) or ( Damageable.Health - Damage < Damageable.MaxHealth and Damage or Damageable.Health - Damageable.MaxHealth )
					
					Damageable.Health = Damageable.Health - Amount
					
					if PrevHealth > 0 and Damageable.Health <= 0 then
						
						Killed[ Damageable ] = a[ 3 ]
						
					end
	
					if Damage > Damageable.MaxHealth - ( Damageable.MaxHealth / 20 ) then
	
						Damageable:AddCustomStatus( "Vital" )
	
					end
					
				else
					
					PrevHealth = Damageable.Value
					
					Amount = Damage > 0 and ( Damageable.Value > Damage and Damage or Damageable.Value ) or ( Damageable.Value - Damage < Damageable.MaxValue and Damage or Damageable.Value - Damageable.MaxValue )
					
					Damageable.Value = Damageable.Value - Amount
					
					if PrevHealth > 0 and Damageable.Value <= 0 then
						
						Killed[ Damageable ] = a[ 3 ]
						
					end
	
				end
				
				if Damage ~= Amount and Damageable.Parent then
					
					if Damage > 0 and ( ( Damageable.Parent:IsA( "Humanoid" ) and Damageable.Parent.Health > 0 ) or ( Damageable.Parent.Name == "Health" and not Damageable.Parent:IsA( "Humanoid" ) and Damageable.Parent.Value > 0 ) ) and not CollectionService:HasTag( Damageable, "s2noupwardsdamage" ) then
						
						DamageInfos[ #DamageInfos + 1 ] = { Damageable.Parent, Damage - Amount, a[ 3 ] }
						
					elseif Damage < 0 and Damageable:FindFirstChild( "Health" ) and not Damageable:FindFirstChild( "Health" ):IsA( "Humanoid" ) and ( not CollectionService:HasTag( Damageable, "s2recursivehealfromdeath" ) or Damageable:FindFirstChild( "Health" ).Value > 0 ) and not CollectionService:HasTag( Damageable:FindFirstChild( "Health" ), "s2norecursivedamage" ) then
						
						DamageInfos[ #DamageInfos + 1 ] = { Damageable:FindFirstChild( "Health" ), Damage - Amount, a[ 3 ] }
						
					end
					
				end
				
				if Amount ~= 0 then
					
					Damaged[ #Damaged + 1 ] = { Damageable, Amount }
					
					Core.DamageInfos[ Damageable ] = Core.DamageInfos[ Damageable ] or { }
					
					Core.DamageInfos[ Damageable ][ User ] = ( Core.DamageInfos[ Damageable ][ User ] or 0 ) + Amount
					
					delay( 30, function ( )
		
						if Core.DamageInfos[ Damageable ] and Core.DamageInfos[ Damageable ][ User ] then
							
							Core.DamageInfos[ Damageable ][ User ] = Core.DamageInfos[ Damageable ][ User ] - Amount
							
							if Core.DamageInfos[ Damageable ][ User ] <= 0 then
								
								Core.DamageInfos[ Damageable ][ User ] = nil
								
								if not next( Core.DamageInfos[ Damageable ] ) then
									
									Core.DamageInfos[ Damageable ] = nil
									
								end
								
							end
							
						end
		
					end )
		
					if Players:GetPlayerFromCharacter( Damageable.Parent ) then
		
						ClntDmg:FireClient( Players:GetPlayerFromCharacter( Damageable.Parent ), User.Name, Amount )
		
					end
		
					if typeof( User ) == "Instance" and Damageable.Parent then
		
						ClntDmg:FireClient( User, Damageable.Parent.Name, Amount, true )
		
					end
		
					Core.ObjDamaged:Fire( User, Damageable, Amount, PrevHealth )
					
				end
				
			end
	
		end
		
		if next( Killed ) then
			
			for a, b in pairs( Core.KilledEvents ) do
				
				coroutine.wrap( b )( Killed, User, WeaponName, TypeName )
				
			end
			
		end
		
		return Damaged
		
	end

	ClntDmg.Name = "ClientDamage"
	
	ClntDmg.OnServerEvent:Connect( function ( Plr, Time, DamageInfos, WeaponName, TypeName, IgnoreSpecial )
		
		if tick( ) - Time > 1 then warn( ( Plr.Name .. " took too long to send shot packet, discarding! - %f" ):format( tick( ) - Time ) ) return end
		
		Core.DamageObj( Plr, DamageInfos, WeaponName, TypeName, IgnoreSpecial )
		
	end )

	ClntDmg.Parent = script.Parent
	
end

if IsClient then

	Core.ClientVisuals = Instance.new( "BindableEvent" )

	Core.SharedVisuals = Instance.new( "BindableEvent" )
	
	function Core.DamageObj( User, DamageInfos, WeaponName, TypeName, IgnoreSpecial )
		
		local Damaged = { }
		
		local a, b = next( DamageInfos )
		
		while a do
			
			local Damageable, Damage = b[ 1 ], b[ 2 ]
			
			if Damageable.Parent and not Damageable.Parent:FindFirstChildOfClass( "ForceField" ) and Damage ~= 0 then
				
				local Amount, PrevHealth
				
				if Damageable:IsA( "Humanoid" ) then
					
					PrevHealth = Damageable.Health
					
					Amount = Damage > 0 and ( Damageable.Health > Damage and Damage or Damageable.Health ) or ( Damageable.Health - Damage < Damageable.MaxHealth and Damage or Damageable.Health - Damageable.MaxHealth )
					
				elseif Damageable:IsA( "DoubleConstrainedValue" ) then
					
					PrevHealth = Damageable.Value
					
					Amount = Damage > 0 and ( Damageable.Value > Damage and Damage or Damageable.Value ) or ( Damageable.Value - Damage < Damageable.MaxValue and Damage or Damageable.Value - Damageable.MaxValue )
	
				end
				
				if Damage ~= Amount and Damageable.Parent then
					
					if Damage > 0 and ( ( Damageable.Parent:IsA( "Humanoid" ) and Damageable.Parent.Health > 0 ) or ( Damageable.Parent.Name == "Health" and not Damageable.Parent:IsA( "Humanoid" ) and Damageable.Parent.Value > 0 ) ) and not CollectionService:HasTag( Damageable, "s2noupwardsdamage" ) then
						
						DamageInfos[ #DamageInfos + 1 ] = { Damageable.Parent, Damage - Amount, b[ 3 ] }
						
					elseif Damage < 0 and Damageable:FindFirstChild( "Health" ) and not Damageable:FindFirstChild( "Health" ):IsA( "Humanoid" ) and ( not CollectionService:HasTag( Damageable, "s2recursivehealfromdeath" ) or Damageable:FindFirstChild( "Health" ).Value > 0 ) and not CollectionService:HasTag( Damageable:FindFirstChild( "Health" ), "s2norecursivedamage" ) then
						
						DamageInfos[ #DamageInfos + 1 ] = { Damageable:FindFirstChild( "Health" ), Damage - Amount, b[ 3 ] }
						
					end
					
				end
				
				if Amount ~= 0 then
					
					Damaged[ #Damaged + 1 ] = { Damageable, Amount }
					
				end
				
			end
			
			a, b = next( DamageInfos, a )
	
		end
		
		return Damaged
		
	end

	game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "ClientDamage" ).OnClientEvent:Connect( function ( Other, Amount, Killed )

		if Killed then

			print( "Damaged " .. Other .. " for " .. Amount )

		else

			print( Amount .. " damage taken from " .. Other )

		end

	end )
	
	Core.ShotRemote.OnClientEvent:Connect( function ( Time, StatObj, User, ToNetwork, _Normal, _Offset, _BarrelNum )
		
		if not StatObj or not StatObj.Parent then return end
		
		if type( ToNetwork ) ~= "table" then
			
			ToNetwork = { { ToNetwork, _Normal, _Offset, _BarrelNum } }
			
		end
		
		local GunStats = Core.GetGunStats( StatObj )

		local Barrels = GunStats.Barrels( StatObj )
		
		for a = 1, #ToNetwork do
			
			local Barrel = type( Barrels ) == "table" and Barrels[ ToNetwork[ a ][ 5 ] or 1 ] or Barrels
	
			if Barrel then
				
				local Hit, Normal, Offset, BarrelNum = unpack( ToNetwork[ a ] )
				
				local Material
				
				if typeof( Hit ) == "Instance" then
					
					Material = Hit.Material
					
				elseif Hit then
					
					Material = Hit
					
					Hit = workspace.Terrain
					
				end
				
				local End
				
				if Hit then
					
					End = Hit.CFrame:PointToWorldSpace( Offset * Hit.Size )
					
				else
					
					End = Offset
					
					Offset = nil
								
				end
				
				local Humanoids = ( Core.GetBulletType( GunStats ).Func or Core.BulletTypes.Kinetic.Func )( StatObj, GunStats, User, Hit, Barrel, End )
				
				local FirstShot
				
				if #ToNetwork > 1 then FirstShot = a == 1 end
				
				Core.SharedVisuals:Fire( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, Humanoids, Time )
				
			end
			
		end

	end )
	
	local Mouse = Players.LocalPlayer:GetMouse( )
	
	local PrevIcon
	 
	Core.WeaponSelected.Event:Connect( function ( Mod )
		
		local Weapon = Core.GetWeapon( Mod )
		
		if not Weapon or Weapon.User ~= Players.LocalPlayer then return end
		
		if Weapon.GunStats.ShowCursor ~= false and Core.ShowCursor and ( _G.S20Config.CursorImage or Weapon.CursorImage ) then
			
			PrevIcon = Mouse.Icon
			
			Mouse.Icon = Weapon.CursorImage or _G.S20Config.CursorImage
			
		end
		
	end )
	 
	Core.WeaponDeselected.Event:Connect( function ( Mod )
		
		local Weapon = Core.GetWeapon( Mod )
		
		if not Weapon or Weapon.User ~= Players.LocalPlayer then return end
		
		if Weapon.GunStats.ShowCursor ~= false and Core.ShowCursor and ( _G.S20Config.CursorImage or Weapon.CursorImage ) then
			
			Mouse.Icon = PrevIcon
			
			PrevIcon = nil
			
		end
		
	end )

	local KBU = require( game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "KeybindUtil" ) )

	KBU.AddBind{ Name = "Fire", Category = "Surge 2.0", Callback = function ( Began )
		
		local Weapons = Core.Selected[ Players.LocalPlayer ]
		
		if Weapons then
			
			for a, _ in pairs( Weapons ) do
				
				if not a.GunStats.ManualFire then
					
					if Began then
						
						Core.SetMouseDown( a )
						
					else
						
						a.MouseDown = nil
						
						Core.FiringEnded:Fire( a.StatObj )
						
						a.ModeShots = 0
						
					end
					
				end
				
			end
			
		end

	end, Key = Enum.UserInputType.MouseButton1, PadKey = Enum.KeyCode.ButtonR2, NoHandled = true }

	KBU.AddBind{ Name = "Reload", Category = "Surge 2.0", Callback = function ( Began )

		if not Began then return end
		
		local Weapons = Core.Selected[ Players.LocalPlayer ]
		
		if Weapons then
			
			for a, _ in pairs( Weapons ) do
				
				if not a.GunStats.AllowManualReload then
					
					Core.Reload( a )
					
				end
				
			end
			
		end

	end, Key = Enum.KeyCode.R, PadKey = Enum.KeyCode.ButtonB, NoHandled = true }

	KBU.AddBind{ Name = "Next_fire_mode", Category = "Surge 2.0", Callback = function ( Began )

		if not Began then return end
		
		local Weapons = Core.Selected[ Players.LocalPlayer ]
		
		if Weapons then
			
			for a, _ in pairs( Weapons ) do
				
				Core.NextFireMode( a )
				
			end
			
		end

	end, Key = Enum.UserInputType.MouseButton3, PadKey = Enum.KeyCode.ButtonY, NoHandled = true }

	KBU.AddBind{ Name = "Drop_hat", Category = "Surge 2.0", Callback = function ( Began )

		if Config.HatMode == 1 then return end

		if Players.LocalPlayer.Character then

			local Found

			local Hats = Players.LocalPlayer.Character:GetChildren( )

			for a = 1, #Hats do

				if Hats[ a ]:IsA( "Accessory" ) then

					Found = true

				end

			end

			if Found then

				Core.DropHat:FireServer( )

			end

		end

	end, Key = Enum.KeyCode.Equals, NoHandled = true }
	
	Core.LPlrsTarget = { }

	function Core.GetLPlrsTarget( )

		return nil, Core.LPlrsTarget[ 2 ]

	end

	coroutine.wrap( function ( )

		while true do

			local StartTime = tick( )

			local ServerTime = Core.ClientSync:InvokeServer( StartTime )

			local ClientTime = tick( )

			_G.ServerOffset = ServerTime + ( ClientTime - StartTime ) / 2 - ClientTime

			wait( 30 )

		end

	end )( )

end

return Core
