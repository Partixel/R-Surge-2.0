local Core = { Config = require( game:GetService("ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Config" ) ) or _G.S20Config }

local RunService, Players, ContextActionService, CollectionService = game:GetService( "RunService" ), game:GetService( "Players" ), game:GetService( "ContextActionService" ), game:GetService( "CollectionService" )

local IsServer = RunService:IsServer( )

Core.ShotRemote = script:WaitForChild( "ShotRemote" )

Core.ClientSync = script.ClientSync

Core.WeaponSelected = Instance.new( "BindableEvent" )

Core.WeaponDeselected = Instance.new( "BindableEvent" )

Core.ReloadStart = Instance.new( "BindableEvent" )

Core.ReloadStepped = Instance.new( "BindableEvent" )

Core.ReloadEnd = Instance.new( "BindableEvent" )

Core.StoredAmmoChanged = Instance.new( "BindableEvent" )

Core.ClipChanged = Instance.new( "BindableEvent" )

Core.FireModeChanged = Instance.new( "BindableEvent" )

Core.WindupChanged = Instance.new( "BindableEvent" )

Core.FiringEnded = Instance.new( "BindableEvent" )

Core.Visuals = { }

Core.ShowCursor = true

local Heartbeat = RunService.Heartbeat
local function hbwait(num)
	local t=0
	while t<num do
		t = t + Heartbeat:Wait()
	end
	return t
end

local function FakeExplosion(Properties, OnHit)
	local Explosion = Instance.new("Explosion")
	Explosion.Visible = false
	for a, b in pairs(Properties) do
		Explosion[a] = b
	end

	Explosion.DestroyJointRadiusPercent = 0
	Explosion.Hit:Connect(OnHit)
	Explosion.Parent = Properties.Parent or workspace
	wait()
end

function Core.StartStun(StatObj, GunStats, User, Hit, Damageable)
	if Damageable:IsA("Humanoid") then
		Damageable.PlatformStand = true
		if Damageable.RootPart then Damageable.RootPart.RotVelocity = Vector3.new(10, 0, 0) end

		coroutine.wrap(function()
			for a = 1, 60 do
				wait( 0.1 )
				
				if Damageable.RootPart then
					Damageable.RootPart.RotVelocity = Vector3.new(0, math.random(-5, 5), 0)
				end
			end

			Damageable.PlatformStand = false
		end)()
	end
end

function Core.StartFireDamage(StatObj, GunStats, User, Hit, Damageable)
	local Doused
	local Fire = Instance.new("Fire" , Hit)
	
	local Event1 = Damageable.ChildAdded:Connect(function(Obj)
		if Obj.Name == "InWater" then
			Doused = true
		end
	end)
	
	local Event2 = Damageable:IsA("Humanoid") and Damageable.Swimming:Connect(function()
		Doused = true
	end)
	
	for i = 1, 20 do
		if Doused then
			break
		end
		
		local Damageable, Damage = Core.DamageHelper(User, Hit, StatObj, GunStats.BulletType.DamageType or Core.DamageType.Fire, 0)
		if not Damageable then break end
		
		wait(0.3)
	end
	
	Fire:Destroy()
	Event1:Disconnect()
	
	if Event2 then Event2:Disconnect() end
end

function Core.DoExplosion(User, WeaponStat, Position, Options)
	local WeaponStats = type(WeaponStat) == "table" and WeaponStat or Core.GetGunStats(WeaponStat)
	local DamageType = Options.DamageType or Core.DamageType.Explosive
	local Type = type(Options.Type) == "function" and Options.Type or Options.Type == "Stun" and Core.BulletTypes or Options.Type == "Fire" and Core.StartFireDamage
	
	local Damageables = {}
	
	local BlastRadius, JointRadius = Options.BlastRadius, Options.DestroyJointRadiusPercent or 1
	FakeExplosion({Position = Position, Visible = Options.Visible, Parent = Options.Parent, BlastRadius = BlastRadius, BlastPressure = Options.BlastPressure, ExplosionType = Options.ExplosionType}, function(Part, Dist)
		Dist = Dist / BlastRadius
		local Damageable = Core.GetValidDamageable(Part)
		if Damageable then
			if Core.CanDamage(User, Damageable, Part, WeaponStat, Dist) then
				local Damage = Core.CalculateDamageFor(Part, WeaponStat, Dist)
				if not Damageables[Damageable] or Damage > Damageables[Damageable][3] then
					Damageables[Damageable] = {Part, Dist, Damage}
				end
			end
		elseif IsServer and Dist <= JointRadius then
			-----------------------------------------------------------------check for both parts in range of joints
			Part:BreakJoints()
			--[[Part.CFrame = Part.CFrame + Vector3.new( 0, 0.01, 0 )-----------------------REMOVE THIS ONCE https://devforum.roblox.com/t/pgs-changing-velocity-of-a-part-doesnt-wake-it/73708 IS FIXED PLAES FASE GSDFG DS GHSE EGFD SSGDF GSFDGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
			Part.Velocity = Part.Velocity + ( CFrame.new( Explosion.Position, Part.Position ).lookVector * Distance * Explosive * 30 )]]
		end
	end)

	if next(Damageables) then
		local EstimatedDamageables = {}
		for Damageable, Info in pairs(Damageables) do
			if IsServer then
				Core.ApplyDamage(User, Info[3] > 0 and Core.GetBottomDamageable(Damageable) or Damageable, Info[1], WeaponStat, DamageType, Info[2], Info[3])
				if Type then
					Type(WeaponStat, WeaponStats, User, Info[1], Damageable)
				end
			end
			EstimatedDamageables[#EstimatedDamageables + 1] = {Damageable, Info[3]}
		end
		
		return EstimatedDamageables
	end
end

Core.BulletTypes = {
	Kinetic = function(StatObj, GunStats, User, Hit, Barrel, End)
		local Damageable, Damage = Core.DamageHelper(User, Hit, StatObj, GunStats.BulletType and GunStats.BulletType.DamageType or Core.DamageType.Kinetic, ( Barrel.Position - End ).magnitude / GunStats.Range)
		if Damageable then
			return {{Damageable, Damage}}
		end
	end,
	Lightning = function(StatObj, GunStats, User, Hit, Barrel, End)
		if Hit then
			local DamageType = GunStats.BulletType.DamageType or Core.DamageType.Electricity
			local Type = type( GunStats.BulletType.Type ) == "function" and GunStats.BulletType.Type or GunStats.BulletType.Type == "Stun" and Core.BulletTypes or GunStats.BulletType.Type == "Fire" and Core.StartFireDamage
			local Dist = ( Barrel.Position - End ).magnitude / GunStats.Range
			
			local Damageables = {}
				
			local Material, Occupancy = workspace.Terrain:ReadVoxels(Region3.new(End - Vector3.new(2, 2, 2), End + Vector3.new(2, 2, 2)):ExpandToGrid(4), 4)
			if Material[1][1][1] == Enum.Material.Water then
				local Radius = GunStats.BulletType.Radius or 15
				
				FakeExplosion({Position = End, BlastRadius = Radius, BlastPressure = 0, ExplosionType = Enum.ExplosionType.NoCraters}, function(Part, ExpDist)
					ExpDist = Dist + ExpDist / Radius * 0.75
					local Damageable = Core.GetValidDamageable(Part)
					if Damageable and Damageable:GetState() == Enum.HumanoidStateType.Swimming and Core.CanDamage(User, Damageable, Part, StatObj, Dist) then
						local Damage = Core.CalculateDamageFor(Hit, StatObj, Dist)
						if not Damageables[Damageable] or Damage > Damageables[Damageable][3] then
							Damageables[Damageable] = {Part, Dist, Damage}
						end
					end
				end)
			end
			
			local Damageable = Core.GetValidDamageable(Hit)
			if Damageable and Core.CanDamage(User, Damageable, Hit, StatObj, Dist) then
				local Damage = Core.CalculateDamageFor(Hit, StatObj, Dist)
				if not Damageables[Damageable] or Damage > Damageables[Damageable][3] then
					Damageables[Damageable] = {Hit, Dist, Damage}
				end
			end
			
			if next(Damageables) then
				local EstimatedDamageables = {}
				for Damageable, Info in pairs(Damageables) do
					if IsServer then
						Core.ApplyDamage(User, Info[3] > 0 and Core.GetBottomDamageable(Damageable) or Damageable, Info[1], StatObj, DamageType, Info[2], Info[3])
						if Type then
							Type(StatObj, GunStats, User, Hit, Damageable)
						end
					end
					EstimatedDamageables[#EstimatedDamageables + 1] = {Damageable, Info[3]}
				end
				
				return EstimatedDamageables
			end
		end
	end,
	Fire = function(StatObj, GunStats, User, Hit, Barrel, End)
		local Damageable, Damage = Core.DamageHelper(User, Hit, StatObj, GunStats.BulletType.DamageType or Core.DamageType.Fire, ( Barrel.Position - End ).magnitude / GunStats.Range)
		if Damageable then
			if IsServer then
				Core.StartFireDamage(StatObj, GunStats, User, Hit, Damageable)
			end
			
			return {{Damageable, Damage}}
		end
	end,
	Stun = function(StatObj, GunStats, User, Hit, Barrel, End)
		local Damageable, Damage = Core.DamageHelper(User, Hit, StatObj, GunStats.BulletType.DamageType or Core.DamageType.Electricity, ( Barrel.Position - End ).magnitude / GunStats.Range)
		if Damageable then
			if IsServer then
				Core.StartStun(StatObj, GunStats, User, Hit, Damageable)
			end
			
			return {{Damageable, Damage}}
		end
	end,
	Explosive = function(StatObj, GunStats, User, Hit, Barrel, End)
		if Hit or not GunStats.BulletType.ExplodeOnHit then
			return Core.DoExplosion(User, StatObj, End, GunStats.BulletType)
		end
	end
}

Core.Damageables = setmetatable({}, {__mode = "k"})
Core.DamageableAdded = Instance.new( "BindableEvent" )
workspace.DescendantAdded:Connect(function(Obj)
	if not Core.Damageables[Obj] and (Obj:IsA("Humanoid") or (Obj:IsA("DoubleConstrainedValue") and Obj.Name == "Health")) then
		Core.Damageables[Obj] = true
		Core.DamageableAdded:Fire(Obj)
	end
end )

for _, Obj in ipairs(workspace:GetDescendants()) do
	if not Core.Damageables[Obj] and (Obj:IsA("Humanoid") or (Obj:IsA("DoubleConstrainedValue") and Obj.Name == "Health")) then
		Core.Damageables[Obj] = true
		Core.DamageableAdded:Fire(Obj)
	end
end

local GunStatFolder
if IsServer then
	GunStatFolder = game:GetService("ReplicatedStorage"):FindFirstChild("GunStats")
	
	if not GunStatFolder then
		GunStatFolder = Instance.new("Folder")
		GunStatFolder.Name = "GunStats"
		GunStatFolder.Parent = game:GetService("ReplicatedStorage")
	end
else
	GunStatFolder = game:GetService("ReplicatedStorage"):WaitForChild("GunStats")
end

function Core.GetGunStats(StatObj)
	return require( GunStatFolder:FindFirstChild(StatObj.Value, true))
end

Core.Weapons = setmetatable( { }, { __mode = 'k' } )

function Core.GetWeapon( StatObj )

	return Core.Weapons[ StatObj ] ~= true and Core.Weapons[ StatObj ] or nil

end

Core.Selected = setmetatable( { }, { __mode = 'k' } )

Core.WeaponTick = setmetatable( { }, { __mode = 'k' } )

function Core.RunSelected( )
	
	Core.SelectedHB = Heartbeat:Connect( function ( Step )
		
		if IsServer then
			
			if not next( Core.Selected ) then
				
				Core.SelectedHB:Disconnect( )
				
				Core.SelectedHB = nil
				
				return
				
			end
			
		else
			
			if not Core.Selected[ Players.LocalPlayer ] then
				
				Core.SelectedHB:Disconnect( )
				
				Core.SelectedHB = nil
				
				return
				
			end
			
			local UnitRay = Players.LocalPlayer:GetMouse( ).UnitRay
			
			Core.LPlrsTarget = { Core.FindPartOnRayWithIgnoreFunction( Ray.new( UnitRay.Origin, UnitRay.Direction * 5000 ), Core.IgnoreFunction, { Players.LocalPlayer.Character } ) }
			
		end
		
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
						
						if ( c.LastClick and c.LastClick + 0.15 <= tick( ) ) or c.Reloading then
							
							c.ShotRecoil = math.max( c.ShotRecoil - 1, 0 )
							
						end
						
					end
					
					if not Needed then
						
						Core.WeaponTick[ c ] = nil
						
					end
	
				end
				
			end
			
		end
		
	end )
	
end

function Core.SetMouseDown( Weapon )
	
	Weapon.MouseDown = tick( )
	
	if Weapon.LastClick and Weapon.LastClick < tick( ) then Weapon.LastClick = nil end
	
	Core.WeaponTick[ Weapon ] = true
	
end

Core.WeaponSelected.Event:Connect( function ( StatObj, User )

	local Weapon = Core.GetWeapon( StatObj )

	if not Weapon then return end

	if not Weapon.LastClick or Weapon.LastClick < tick( ) + ( Weapon.GunStats.SelectDelay or 0.2 ) then

		Weapon.LastClick = tick( ) + ( Weapon.GunStats.SelectDelay or 0.2 )

	end
	
	if Weapon.GunStats.ClipReloadPerSecond and Weapon.Clip < Weapon.GunStats.ClipSize and ( not Weapon.StoredAmmo or Weapon.StoredAmmo ~= 0 ) then
		
		Core.WeaponTick[ Weapon ] = true
		
	end
	
	Core.Selected[ User ] = Core.Selected[ User ] or { }
	
	Core.Selected[ User ][ Weapon ] = tick( )
	
	if not Core.SelectedHB then
		
		Core.RunSelected( )
		
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

function Core.DestroyWeapon( Weapon )
	
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
	
	local StatObj = Weapon.StatObj

	for a, b in pairs( Weapon ) do

		Weapon[ a ] = nil

	end

	if StatObj.Parent then

		StatObj.Parent:Destroy( )

	end
	
	StatObj:Destroy( )

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

	Weapon.Events = {
		
		StatObj.AncestryChanged:Connect( function ( )
			
			if not StatObj:IsDescendantOf( game ) then
				
				Core.DestroyWeapon( Weapon )
				
			end
			
		end )
	
	}

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

Core.FireModes = {

	Auto = { Name = "Auto", Automatic = true },

	Semi = { Name = "Semi" },

	Burst = { Name = "Burst", Shots = 3 },

	Safety = { Name = "Safety", PreventFire = true }

}

function Core.GetFireMode( Weapon )

	local Mode = Weapon.GunStats.FireModes[ Weapon.CurFireMode ]

	if Core.FireModes[ Mode ] then return Core.FireModes[ Mode ] end

	return Mode

end

function Core.SetFireMode( Weapon, Value )

	Weapon.CurFireMode = Value

	Core.FireModeChanged:Fire( Weapon.StatObj, Value )

end

function Core.GetBulletType( GunStats )

	if not GunStats.BulletType then return Core.BulletTypes.Kinetic end

	if Core.BulletTypes[ GunStats.BulletType.Name ] then return Core.BulletTypes[ GunStats.BulletType.Name ] end

	return GunStats.BulletType

end

function Core.IgnoreFunction( Part )
	
    return not CollectionService:HasTag( Part, "nopen" ) and ( not Part or not Part.Parent or CollectionService:HasTag( Part, "forcepen" ) or Part.Parent:IsA( "Accoutrement" ) or Part.Transparency >= 1 or ( Core.GetValidDamageable( Part ) == nil and Part.CanCollide == false ) ) or false

end

function Core.FindPartOnRayWithIgnoreFunction( R, IgnoreFunction, Ignore, IgnoreWater )
	
	local UnitDirection = R.Unit.Direction
	
	local Hit, Pos, Normal, Material
	
	while true do
		
		Hit, Pos, Normal, Material = workspace:FindPartOnRayWithIgnoreList( R, Ignore, false, IgnoreWater == nil and true or IgnoreWater )
		
		if not Hit or not IgnoreFunction( Hit ) then
			
			return Hit, Pos, Normal, Material
			
		end
		
		Ignore[ #Ignore + 1 ] = Hit
		
		R = Ray.new( Pos - UnitDirection, UnitDirection * ( R.Direction.magnitude - ( ( Pos - UnitDirection ) - R.Origin ).magnitude ) )
		
	end

end

function Core.GetAccuracy( Weapon )

	local ShotRecoil = Weapon.ShotRecoil
	
	if  Weapon.User.Character and Weapon.User.Character:FindFirstChild( "HumanoidRootPart" ) then

		local Vel = Weapon.User.Character.HumanoidRootPart.Velocity / Vector3.new( 1, 3, 1 )

		if Vel.magnitude > 0.1 then

			ShotRecoil = ShotRecoil + ( Vel.magnitude / 4 * Core.Config.MovementAccuracyPercentage )

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
		
		if Weapon.LastClick and Weapon.LastClick < tick( ) then Weapon.LastClick = nil end

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

local function TableCopy( Table )

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

	if FireMode.PreventFire or ( Weapon.LastClick and Weapon.LastClick >= tick( ) ) or Weapon.Reloading ~= nil then return end

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
	
	local Start = Weapon.LastClick or tick( )

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

						local Origin = not Weapon.GunStats.UseBarrelAsOrigin and Weapon.User and Weapon.User.Character and Weapon.User.Character:FindFirstChild( "NewHead" ) and Weapon.User.Character.NewHead.Position or Barrel.Position
						
						Target = CFrame.new( Origin, Target ) * CFrame.Angles( 0, 0, math.rad( math.random( 0, 3599 ) / 10 ) )
						
                        Hit, End, Normal, Material = Core.FindPartOnRayWithIgnoreFunction( Ray.new( Origin, CFrame.new( Origin, ( Target + Target.lookVector * 1000 + Target.UpVector * math.random( 0, 1000 / Core.GetAccuracy( Weapon ) / 2 ) ).p ).lookVector * Weapon.GunStats.Range ), Core.IgnoreFunction, TableCopy( Weapon.Ignore ), not IgnoreWater )
						
					else

						Hit = false

					end

				end

				if Hit ~= false then

					if Weapon.Clip  and ( not OneAmmoPerClick or ( ShotsPerClick and ShotsPerClick > 1 and BulNum == 1 ) ) then

						Core.SetClip( Weapon, Weapon.Clip - 1 )

					end

					Weapon.ShotRecoil = math.min( Weapon.ShotRecoil + math.abs( Weapon.GunStats.Damage ) / 50, math.abs( Weapon.GunStats.Damage ) / 5 * ShotsPerClick )

					local Offset = Hit and Hit.CFrame:pointToObjectSpace( End ) or nil
					
					local Humanoids = ( Core.GetBulletType( Weapon.GunStats ) or Core.BulletTypes.Kinetic )( Weapon.StatObj, Weapon.GunStats, Weapon.User, Hit, Barrel, End )

					if not IsServer then
						
						local FirstShot
						
						if ShotsPerClick > 1 then FirstShot = BulNum == 1 end

						if Players.LocalPlayer == Weapon.User then

							Core.ClientVisuals:Fire( Weapon.StatObj, Barrel, Hit, End, Normal, Material, Offset, FirstShot )

						end
						
						Core.SharedVisuals:Fire( Weapon.StatObj, Weapon.User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, Humanoids, tick( ) + _G.ServerOffset )

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
	
	if Weapon.LastClick < tick( ) then
		
		if Weapon.GunStats.WindupTime == nil or Weapon.GunStats.WindupTime == 0 then
			
			Core.Fire( Weapon)
	
		elseif not Weapon.Reloading and  Weapon.Windup and Weapon.Windup >= Weapon.GunStats.WindupTime then
			
			Core.Fire( Weapon )
			
		end
		
	end

end

Core.DamageType = {

	Kinetic = "Kinetic",

	Explosive = "Explosive",

	Slash = "Slash",

	Fire = "Fire",

	Electricity = "Electricity",
	
	Heal = "Heal"

}

function Core.GetTeamInfo(Obj)
	if type(Obj) == "table" then
		return Obj.TeamColor, Obj.Neutral, Obj.Character
	elseif Obj:IsA("Player") then
		return Obj.TeamColor, Obj.Neutral, Obj.Character
	end

	local PlrObj = Players:GetPlayerFromCharacter(Obj.Parent)
	if PlrObj then
		return PlrObj.TeamColor, PlrObj.Neutral, Obj.Parent
	elseif Obj:FindFirstChild("TeamColor") then
		return Obj.TeamColor.Value, Obj:FindFirstChild("Neutral") and Obj.Neutral.Value or false, Obj.Parent
	else
		return BrickColor.White(), not Obj:FindFirstChild("Neutral") and true or Obj.Neutral.Value, Obj.Parent
	end
end

function Core.CheckTeamkill(P1, P2, AllowTeamKill, InvertTeamKill)
	if (AllowTeamKill == nil and Core.Config.AllowTeamKill) or AllowTeamKill then return true end
	
	local TC1, N1, Char1 = Core.GetTeamInfo(P1)
	local TC2, N2, Char2 = Core.GetTeamInfo(P2)
	local TeamKill
	if Char1 == Char2 then
		TeamKill = Core.Config.AllowSelfDamage
	elseif N1 and N2 then
		TeamKill = Core.Config.AllowNeutralTeamKill
	elseif (N1 and not N2) or (not N1 and N2) then
		TeamKill = true
	elseif TC1 ~= TC2 then
		TeamKill = true
		for a = 1, #Core.Config.AllowTeamKillFor do
			if Core.Config.AllowTeamKillFor[ a ][ TC1.name ] and Core.Config.AllowTeamKillFor[ a ][ TC2.name ] then
				TeamKill = false
				break
			end
		end
	end
	
	if InvertTeamKill then
		return not TeamKill
	else
		return TeamKill
	end
end

function Core.GetTopDamageable(Damageable)
	while Damageable.Parent:IsA("Humanoid") or Damageable.Parent.Name == "Health" do
		Damageable = Damageable.Parent
	end
	
	return Damageable
end

function Core.GetBottomDamageable(Damageable)
	local Health = Damageable:FindFirstChild("Health")
	while Health and Health.Value > 0 do
		Damageable, Health = Health, Health:FindFirstChild("Health")
	end
	return Damageable
end

function Core.GetValidDamageable(Obj, Top)
	if Obj and Obj:IsDescendantOf(game) then
		local Damageable = Obj:FindFirstChild("Health") or Obj.Parent:FindFirstChildOfClass("Humanoid") or Obj.Parent:FindFirstChild("Health") or Obj.Parent.Parent:FindFirstChildOfClass("Humanoid") or Obj.Parent.Parent:FindFirstChild("Health")
		
		if Damageable and ((Damageable:IsA("Humanoid") and Damageable.Health > 0) or (Damageable:IsA("DoubleConstrainedValue") and Damageable.Value > 0)) then
			return Damageable
		end
	end
end

function Core.CanDamage(Attacker, Damageable, Hit, WeaponStat, Distance)
	local WeaponStats = type(WeaponStat) == "table" and WeaponStat or Core.GetGunStats(WeaponStat)
	return not Core.IgnoreFunction(Hit) and Core.CheckTeamkill(Attacker, Damageable, WeaponStats.AllowTeamKill, WeaponStats.InvertTeamKill ) and (not Distance or Distance < 1) and not Damageable.Parent:FindFirstChildOfClass("ForceField")
end

function Core.CalculateDamageFor(Hit, WeaponStat, Distance)
	local WeaponStats = type(WeaponStat) == "table" and WeaponStat or Core.GetGunStats(WeaponStat)
	local Damage = WeaponStats.Damage
	
	local HitName = Hit.Name:lower()
	if HitName:find("head") or HitName == "uppertorso" or CollectionService:HasTag(Hit, "s2headdamage") then
		Damage = Damage * Core.Config.HeadDamageMultiplier
	elseif HitName:find("leg") or HitName:find("arm") or HitName:find("hand") or HitName:find("foot") or CollectionService:HasTag(Hit, "s2limbdamage") then
		Damage = Damage * Core.Config.LimbDamageMultiplier
	end

	if Distance then
		if WeaponStats.InvertDistanceModifier or (WeaponStats.InvertDistanceModifier ~= false and Core.Config.InvertDistanceModifier) then
			Damage = Damage * (1 - Distance) * ((WeaponStats.DistanceDamageModifier or WeaponStats.DistanceModifier) or Core.Config.DistanceDamageModifier or 1)
		else
			Damage = Damage * (1 - Distance * ((WeaponStats.DistanceDamageModifier or WeaponStats.DistanceModifier) or Core.Config.DistanceDamageModifier or 1))
		end
	end
	
	return Damage
end

if IsServer then
	local ClientDamage = Instance.new( "RemoteEvent" )
	ClientDamage.Name = "ClientDamage"
	ClientDamage.OnServerEvent:Connect(function(Attacker, Time, Hit, WeaponStat, DamageType, Distance)
		if tick() - Time > 1 then
			warn(Attacker.Name .. " took too long to send shot packet, discarding! - " .. (tick( ) - Time))
		else
			Core.DamageHelper(Attacker, Hit, WeaponStat, DamageType, Distance)
		end
	end)
	
	ClientDamage.Parent = script.Parent
	--Attacker, Hit, WeaponStat, DamageType, Distance, DamageSplits{Damageable, Damage}
	Core.ObjDamaged = Instance.new( "BindableEvent" )
	
	Core.DamageInfos = setmetatable( { }, { __mode = "k" } )
	
	function Core.ApplyDamage(Attacker, Damageable, Hit, WeaponStat, DamageType, Distance, Dmg, DamageSplits, RemainingDamage, DamageSplits)
		local Damage = Dmg * (RemainingDamage or 1)
		
		local Resistance = 1
		if Damageable:FindFirstChild("Resistances") then
			for _, ResistanceObj in ipairs(Damageable.Resistances:GetChildren()) do
				if ResistanceObj.Name == WeaponStat.Value or ResistanceObj.Name == DamageType or ResistanceObj.Name == "All" then
					Resistance = Resistance * ResistanceObj.Value
				end
			end
		end
		if Core.Config.Resistances and Core.Config.Resistances[DamageType] then
			Resistance = Resistance * Core.Config.Resistances[DamageType]
		end
		Damage = Damage * Resistance * ( Core.Config.GlobalDamageMultiplier or 1 )
		
		if Damage == 0 then return end
		
		local Prop, MaxProp
		if Damageable:IsA( "Humanoid" ) then
			Prop, MaxProp = "Health", "MaxHealth"
		else
			Prop, MaxProp = "Value", "MaxValue"
		end
		
		if Damage < 0 and Damageable[Prop] == Damageable[MaxProp] then
			Damage = 0
		else
			Damage = Damage > 0 and (Damageable[Prop] > Damage and Damage or Damageable[Prop]) or (Damageable[Prop] - Damage < Damageable[MaxProp] and Damage or Damageable[Prop] - Damageable[MaxProp])
			
			Damageable[Prop] = Damageable[Prop] - Damage
			if Damageable[Prop] <= 0 then
				if Damageable:IsA("Humanoid") then
					Damageable.HealthChanged:Connect(function()
						Damageable.Health = 0
					end)
				else
					Damageable:GetPropertyChangedSignal("Value"):Connect(function()
						Damageable.Value = 0
					end)
				end
			end
		end
		
		if Damage > (Damageable[MaxProp] - (Damageable[MaxProp] / 20)) then
			CollectionService:AddTag(Damageable, "VitalDamage")
		end
		
		local First = not DamageSplits
		DamageSplits = DamageSplits or {}
		if Damage ~= 0 then
			DamageSplits[#DamageSplits + 1] = {Damageable, Damage}
		end
		
		if Damage ~= Dmg * (RemainingDamage or 1) then
			if Damage > 0 then
				local NextDamageable = Damageable.Parent
				
				if NextDamageable and not CollectionService:HasTag(NextDamageable, "s2norecursivedamage") and ((NextDamageable:IsA("Humanoid") and NextDamageable.Health > 0) or (NextDamageable.Name == "Health" and NextDamageable.Value > 0)) then
					Core.ApplyDamage(Attacker, NextDamageable, Hit, WeaponStat, DamageType, Distance, Dmg, DamageSplits, (RemainingDamage or 1) - (Damage / Dmg))
				end
			else
				local NextDamageable = Damageable:FindFirstChild("Health")
				
				if NextDamageable and NextDamageable.Value > 0 and not CollectionService:HasTag(NextDamageable, "s2norecursivedamage") then
					Core.ApplyDamage(Attacker, NextDamageable, Hit, WeaponStat, DamageType, Distance, Dmg, DamageSplits, (RemainingDamage or 1) - (Damage / Dmg))
				end
			end
		end
		
		if First and next(DamageSplits) then
			if Players:GetPlayerFromCharacter(Damageable.Parent) then
				ClientDamage:FireClient(Players:GetPlayerFromCharacter(Core.GetTopDamageable(Damageable).Parent), DamageSplits, Attacker.Name)
			end
			
			if typeof(Attacker) == "Instance" then
				ClientDamage:FireClient(Attacker, DamageSplits)
			end
			
			Core.ObjDamaged:Fire(Attacker, Hit, WeaponStat, DamageType, Distance, DamageSplits)
		end
	end
end
-- returns Damageable if one is found, on server will also do damage
function Core.DamageHelper(Attacker, Hit, WeaponStat, DamageType, Distance)
	local Damageable = Core.GetValidDamageable(Hit)
	if Damageable and Core.CanDamage(Attacker, Damageable, Hit, WeaponStat, Distance) then
		local Damage = Core.CalculateDamageFor(Hit, WeaponStat, Distance)
		if IsServer then
			Core.ApplyDamage(Attacker, Damage > 0 and Core.GetBottomDamageable(Damageable) or Damageable, Hit, WeaponStat, DamageType, Distance, Damage)
		end
		return Damageable, Damage
	end
end

local function ToolAdded( Tool, Plr )
	
	local StatObj = Tool:FindFirstChild( "GunStat" )

	if StatObj and not Core.Weapons[ StatObj ] then

		if IsServer then

			Core.Weapons[ StatObj ] = true

			Tool.Equipped:Connect( function ( )
				
				Core.WeaponSelected:Fire( StatObj, Plr )

			end )

			Tool.Unequipped:Connect( function ( )
				
				Core.WeaponDeselected:Fire( StatObj, Plr )

			end )

		else

			local Weapon = Core.Setup( StatObj )

			Core.PlayerToUser( Weapon, Plr )

		end

	end

end

local function Spawned( Plr )

	local Children = Plr.Character:GetChildren( )

	for a = 1, #Children do

		ToolAdded( Children[ a ], Plr )

	end

	Plr.Character.ChildAdded:Connect( function ( Tool )

		ToolAdded( Tool, Plr )

	end )

end

if IsServer then

	Core.ServerVisuals = Instance.new( "BindableEvent" )
	
	local function HandlePlr( Plr )
		
		if Plr.Character then Spawned( Plr ) end

		Plr.CharacterAdded:Connect( function ( )

			Spawned( Plr )

		end )
		
	end

	Players.PlayerAdded:Connect( HandlePlr )
	
	local Plrs = Players:GetPlayers( )
	
	for a = 1, #Plrs do
		
		HandlePlr( Plrs[ a ] )
		
	end

	Core.HandleServer = function ( Plr, Time, StatObj, ToNetwork, User, _Offset, _User, _BarrelNum )
		
		if not StatObj or not StatObj.Parent then return end
		
		if type( ToNetwork ) ~= "table" then
			
			ToNetwork = { { ToNetwork, User, _Offset, _BarrelNum } }
			
			User = _User
			
		end

		User = User or Plr

		if tick( ) - Time > 1 then
			
			warn( User.Name .. " took too long to send shot packet, discarding! - "  .. ( tick( ) - Time ) )
			
			return
			
		end

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
					
					End = Hit.CFrame:PointToWorldSpace( Offset )
					
				else
					
					End = Offset
					
					Offset = nil
					
				end
				
				if Hit then
					
					local Axis
					
					if math.abs( Offset.X ) > Hit.Size.X / 2 + 0.05 then
						
						Axis = "X"
						
					elseif math.abs( Offset.Y ) > Hit.Size.Y / 2 + 0.05 then
						
						Axis = "Y"
						
					elseif math.abs( Offset.Z ) > Hit.Size.Z / 2 + 0.05 then
						
						Axis = "Z"
						
					end
					
					if Axis then
						
						warn( User.Name .. " may be hit box expanding - " .. Hit.Name .. " size " .. Axis .. " is " .. Hit.Size[ Axis ] / 2 .. " they claimed to hit at " .. Offset[ Axis ] )
						
						return
						
					end
					
				end
				
				local Humanoids = ( Core.GetBulletType( GunStats ) or Core.BulletTypes.Kinetic )( StatObj, GunStats, User, Hit, Barrel, End )
				
				local FirstShot
				
				if #ToNetwork > 1 then FirstShot = a == 1 end
				
				Core.ServerVisuals:Fire( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, #ToNetwork > 1 and a == 1 or nil, Humanoids, Time )
		
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
	
else

	Core.ClientVisuals = Instance.new( "BindableEvent" )

	Core.SharedVisuals = Instance.new( "BindableEvent" )
	
	if Players.LocalPlayer.Character then

		Spawned( Players.LocalPlayer )

	end

	Players.LocalPlayer.CharacterAdded:Connect( function ( )

		Spawned( Players.LocalPlayer )

	end )
	
	game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("ClientDamage").OnClientEvent:Connect(function(DamageSplits, Attacker)
		if Attacker then
			local TotalDamage, Split = 0, ""
			for i, DamageSplit in ipairs(DamageSplits) do
				TotalDamage = TotalDamage + DamageSplit[2]
				Split = Split .. DamageSplit[1].Name .. ":" .. (math.floor(math.abs(DamageSplit[2]) * 100 + 0.5) / 100) .. (i == #DamageSplits and "" or ", ")
			end
			
			print("You took " .. (math.floor(math.abs(TotalDamage) * 100 + 0.5) / 100) .. (TotalDamage > 0 and " damage" or " healing") .. " from " .. Attacker .. " (" .. Split .. ")")
		else
			local TotalDamage, Split = 0, ""
			for i, DamageSplit in ipairs(DamageSplits) do
				TotalDamage = TotalDamage + DamageSplit[2]
				Split = Split .. DamageSplit[1].Name .. ":" .. (math.floor(math.abs(DamageSplit[2]) * 100 + 0.5) / 100) .. (i == #DamageSplits and "" or ", ")
			end
			
			print("You did " .. (math.floor(math.abs(TotalDamage) * 100 + 0.5) / 100) .. (TotalDamage > 0 and " damage" or " healing") .. " to " .. Core.GetTopDamageable(DamageSplits[1][1]).Parent.Name .. " (" .. Split .. ")")
		end
	end)
	
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
					
					End = Hit.CFrame:PointToWorldSpace( Offset )
					
				else
					
					End = Offset
					
					Offset = nil
								
				end
				
				local Humanoids = ( Core.GetBulletType( GunStats ) or Core.BulletTypes.Kinetic )( StatObj, GunStats, User, Hit, Barrel, End )
				
				local FirstShot
				
				if #ToNetwork > 1 then FirstShot = a == 1 end
				
				Core.SharedVisuals:Fire( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, Humanoids, Time )
				
			end
			
		end

	end )
	
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
