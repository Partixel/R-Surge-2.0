local Module = { }

local RunService, Players, ContextActionService, CollectionService = game:GetService( "RunService" ), game:GetService( "Players" ), game:GetService( "ContextActionService" ), game:GetService( "CollectionService" )

while not _G.S20Config do wait( ) end

local Config = _G.S20Config

Module.ShotRemote = script:WaitForChild( "ShotRemote" )

Module.ClientSync = script.ClientSync

Module.DropHat = script.DropHat

Module.WeaponSelected = script.WeaponSelected

Module.WeaponDeselected = script.WeaponDeselected

Module.ReloadStart = script.ReloadStart

Module.ReloadStepped = script.ReloadStepped

Module.ReloadEnd = script.ReloadEnd

Module.StoredAmmoChanged = script.StoredAmmoChanged

Module.ClipChanged = script.ClipChanged

Module.FireModeChanged = script.FireModeChanged

Module.WindupChanged = script.WindupChanged

Module.DamageableAdded = script.DamageableAdded

Module.FiringEnded = script.FiringEnded

Module.Killed = script.Killed

Module.FireModes = {

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

	local ResH, ResD = Module.GetDamage( User, Hit, GunStats.Damage, Type, Dist, GunStats.DistanceModifier, GunStats.AllowTeamKill, WeaponName, GunStats.InvertTeamKill )

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

Module.BulletTypes = {

	Kinetic = { Func = function ( StatObj, GunStats, User, Hit, Barrel, End )
		
		local WeaponName = Module.GetGunName( StatObj )
		
		local DamageType = GunStats.BulletType and GunStats.BulletType.DamageType or Module.DamageType.Kinetic
	
		local ResH, ResD = Module.GetDamage( User, Hit, GunStats.Damage, DamageType, ( Barrel.Position - End ).magnitude / GunStats.Range, GunStats.DistanceModifier, GunStats.AllowTeamKill, WeaponName, GunStats.InvertTeamKill )
	
		if ResH then
			
			return Module.DamageObj( User, { { ResH, ResD, Hit.Name } }, WeaponName, DamageType )
	
		end

	end },

	Lightning = { Func = function ( StatObj, GunStats, User, Hit, Barrel, End )

		if ( not Hit ) then return end

		local Material, Occupancy = workspace.Terrain:ReadVoxels( Region3.new( End - Vector3.new( 2, 2, 2 ), End + Vector3.new( 2, 2, 2 ) ):ExpandToGrid( 4 ), 4 )

		local Humanoids = { }

		local WeaponName = Module.GetGunName( StatObj )

		if( Material[ 1 ][ 1 ][ 1 ] == Enum.Material.Water ) then

			local Radius = GunStats.BulletType.Radius or 15

			local Type = type( GunStats.BulletType.Type ) == "function" and GunStats.BulletType.Type or GunStats.BulletType.Type == "Stun" and Stun

			FakeExplosion( { Position = End, BlastRadius = Radius, BlastPressure = 0, ExplosionType = Enum.ExplosionType.NoCraters }, function ( Part, Dist )

				if Module.IgnoreFunction( Part ) then return end

				local ResH, ResD
				
				if Type then
					
					ResH, ResD = Type( StatObj, GunStats, User, Part, ( End - Part.Position ).magnitude / Radius, GunStats.BulletType.DamageType or Module.DamageType.Electricity, WeaponName )
					
				else
					
					ResH, ResD = Module.GetDamage( User, Part, GunStats.Damage, GunStats.BulletType.DamageType or Module.DamageType.Electricity, ( End - Part.Position ).magnitude / Radius, GunStats.DistanceModifier, GunStats.AllowTeamKill, WeaponName, GunStats.InvertTeamKill )
					
				end

				if ResH and ResH:GetState( ) == Enum.HumanoidStateType.Swimming and ResD > ( ( Humanoids[ ResH ] or { } )[ 1 ] or 0 ) then

					Humanoids[ ResH ] = { ResD, Part.Name }

				end

			end )

		end

		local ResH, ResD = Module.GetDamage( User, Hit, GunStats.Damage, GunStats.BulletType.DamageType or Module.DamageType.Electricity, ( Barrel.Position - End ).magnitude / GunStats.Range, GunStats.DistanceModifier, GunStats.AllowTeamKill, WeaponName, GunStats.InvertTeamKill )

		if ResH and ResD > ( ( Humanoids[ ResH ] or { } )[ 1 ] or 0 ) then
			
			Humanoids[ ResH ] = { ResD, Hit.Name }
			
		end

		if next( Humanoids ) then
			
			local Hums = { }
			
			for a, b in pairs( Humanoids ) do
				
				Hums[ #Hums + 1 ] = { a, b[ 1 ], b[ 2 ] }
				
			end

			return Module.DamageObj( User, Hums, WeaponName, GunStats.BulletType.DamageType or Module.DamageType.Electricity )

		end

	end },

	Fire = { Func = function ( StatObj, GunStats, User, Hit, Barrel, End )
		
		local WeaponName = Module.GetGunName( StatObj )
		
		local ResH, ResD = Module.GetDamage( User, Hit, GunStats.Damage, GunStats.BulletType.DamageType or Module.DamageType.Fire, ( Barrel.Position - End ).magnitude / GunStats.Range, GunStats.DistanceModifier, GunStats.AllowTeamKill, WeaponName, GunStats.InvertTeamKill )
		
		if ResH then
			
			local Damaged = Module.DamageObj( User, { { ResH, ResD, Hit.Name } }, WeaponName, GunStats.BulletType.DamageType or Module.DamageType.Fire )
			
			if next( Damaged ) then
				
				spawn( function ( )
						
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
						
						Module.DamageObj( User, { { ResH, ResD, HitName } }, WeaponName, GunStats.BulletType.DamageType or Module.DamageType.Fire )
						
						wait( 0.3 )
						
					end
					
					if Fire then Fire:Destroy( ) end
					
					Event1:Disconnect( )
					
					if Event2 then Event2:Disconnect( ) end
					
				end )
				
				return Damaged
				
			end
			
		end

	end },

	Stun = { Func = function ( StatObj, GunStats, User, Hit, Barrel, End )

		local ResH, ResD = Stun( StatObj, GunStats, User, Hit, ( Barrel.Position - End ).magnitude / GunStats.Range, GunStats.BulletType.DamageType or Module.DamageType.Electricity )

		if ResH then

			return Module.DamageObj( User, { { ResH, ResD, Hit.Name } }, Module.GetGunName( StatObj ), GunStats.BulletType.DamageType or Module.DamageType.Electricity )

		end

	end },

	Explosive = { Func = function ( StatObj, GunStats, User, Hit, Barrel, End )

		if not Hit and GunStats.BulletType.ExplodeOnHit then return end

		local BlastRadius = GunStats.BulletType.BlastRadius

		local JointRadius = GunStats.BulletType.DestroyJointRadiusPercent or 1

		local Type = type( GunStats.BulletType.Type ) == "function" and GunStats.BulletType.Type or GunStats.BulletType.Type == "Stun" and Stun

		local Humanoids = { }

		local WeaponName = Module.GetGunName( StatObj )

		FakeExplosion( { Position = End, BlastRadius = BlastRadius, BlastPressure = GunStats.BulletType.BlastPressure, ExplosionType = GunStats.BulletType.ExplosionType }, function ( Part, Dist )

			if Module.IgnoreFunction( Part ) or not Part.Parent or Part.Parent:IsA( "Tool" ) then return end

			local ResH, ResD
			
			if Type then
				
				ResH, ResD = Type( StatObj, GunStats, User, Part, ( End - Part.Position ).magnitude / BlastRadius, GunStats.BulletType.DamageType or Module.DamageType.Explosive, WeaponName )
				
			else
				
				ResH, ResD = Module.GetDamage( User, Part, GunStats.Damage, GunStats.BulletType.DamageType or Module.DamageType.Electricity, ( End - Part.Position ).magnitude / BlastRadius, GunStats.DistanceModifier, GunStats.AllowTeamKill, WeaponName, GunStats.InvertTeamKill )
				
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

			return Module.DamageObj( User, Hums, WeaponName, GunStats.BulletType.DamageType or Module.DamageType.Explosive )

		end

	end }

}

Module.Damageables = setmetatable( { }, { __mode = "k" } )

workspace.DescendantAdded:Connect( function ( Child )
	
	if not Module.Damageables[ Child ] and ( Child:IsA( "Humanoid" ) or ( Child:IsA( "DoubleConstrainedValue" ) and Child.Name == "Health" ) ) then
		
		Module.Damageables[ Child ] = true
		
		Module.DamageableAdded:Fire( Child )
		
	end
	
end )

local Descendants = workspace:GetDescendants( )

for a = 1, #Descendants do
	
	if not Module.Damageables[ Descendants[ a ] ] and ( Descendants[ a ]:IsA( "Humanoid" ) or ( Descendants[ a ]:IsA( "DoubleConstrainedValue" ) and Descendants[ a ].Name == "Health" ) ) then
		
		Module.Damageables[ Descendants[ a ] ] = true
		
		Module.DamageableAdded:Fire( Descendants[ a ] )
		
	end
	
end

Module.Visuals = { }

local IsClient = RunService:IsClient( )

local IsServer = RunService:IsServer( )

local ArmUtil

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

function Module.GetGunName( StatObj )

	return GunStatFolder:FindFirstChild( StatObj.Value, true ).Name

end

function Module.GetGunStats( StatObj )

	local StatMod = GunStatFolder:FindFirstChild( StatObj.Value, true )

	local Stats = require( StatMod )

	if not Stats.Required then

		Stats.Required = true
		
		if IsClient then
			
			spawn( function ( ) game:GetService( "ContentProvider" ):PreloadAsync( { StatMod } ) end )
			
		end

	end

	return Stats

end

function Module.ToolAdded( Tool, Plr )
	
	local StatObj = Tool:FindFirstChild( "GunStat" )

	if StatObj and not Module.Weapons[ StatObj ] then
		
		if IsServer and _G.S20Config.ArmWelds then

			local GunStats = Module.GetGunStats( StatObj )
			
			if GunStats.LeftWeld or GunStats.RightWeld then
				
				ArmUtil( Plr, Tool, GunStats.LeftWeld, GunStats.RightWeld )
				
			end

		end

		if IsClient then

			local Weapon = Module.Setup( StatObj )

			Module.PlayerToUser( Weapon, Plr )

		else

			Module.Weapons[ StatObj ] = true

			Tool.Equipped:Connect( function ( Mouse )
				
				Module.WeaponSelected:Fire( StatObj, Plr )

			end )

			Tool.Unequipped:Connect( function ( Mouse )
				
				Module.WeaponDeselected:Fire( StatObj, Plr )

			end )

		end

	end

end

function Module.Spawned( Plr )

	local Children = Plr.Character:GetChildren( )

	for a = 1, #Children do

		Module.ToolAdded( Children[ a ], Plr )

	end

	Plr.Character.ChildAdded:Connect( function ( Tool )

		Module.ToolAdded( Tool, Plr )

	end )

end

if IsServer then

	Module.ServerVisuals = Instance.new( "BindableEvent" )

	Module.ObjDamaged = Instance.new( "BindableEvent" )

	ArmUtil = require( script.ArmUtil )

	Module.HandleServer = function ( Plr, Time, StatObj, HitMat, End, Normal, Offset, BulNum, User, BarrelNum )

		if not StatObj or not StatObj.Parent then return end

		User = User or Plr

		if tick( ) - Time > 1 then warn( ( User.Name .. " took too long to send shot packet, discarding! - %f" ):format( tick( ) - Time ) ) return end

		local GunStats = Module.GetGunStats( StatObj )

		local Barrel = GunStats.Barrels( StatObj )

		Barrel = type( Barrel ) == "table" and Barrel[ BarrelNum or 1 ] or Barrel

		if not Barrel then return end
		
		local Hit, Material
		
		if typeof( HitMat ) == "Instance" then
			
			Hit = HitMat
			
			Material = Hit.Material
			
		elseif Hit then
			
			Material = HitMat
			
			Hit = workspace.Terrain
			
		end
		
		local Humanoids = ( Module.GetBulletType( GunStats ).Func or Module.BulletTypes.Kinetic.Func )( StatObj, GunStats, User, Hit, Barrel, End )

		Module.ServerVisuals:Fire( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, BulNum, Humanoids )

		if IsClient then

			Module.SharedVisuals:Fire( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, BulNum, Humanoids )

			if Players.LocalPlayer == User and Humanoids then

				Module.DamagedObj:Fire( Humanoids )

			end

			return

		end

		local BulRay = Ray.new( Barrel.Position, ( End - Barrel.Position ).Unit )

		local Plrs = Players:GetPlayers( )

		for a = 1, #Plrs do

			if Plrs[ a ] ~= User then

				if BulRay:Distance( Plrs[ a ].Character and Plrs[ a ].Character:FindFirstChild( "HumanoidRootPart" ) and Plrs[ a ].Character.HumanoidRootPart.Position or Barrel.Position ) <= 250 then

					Module.ShotRemote:FireClient( Plrs[ a ], StatObj, User, HitMat, End, Normal, Offset, BulNum, BarrelNum, Humanoids )

				end

			elseif Humanoids then

				Module.ShotRemote:FireClient( Plrs[ a ], Humanoids )

			end

		end

	end

	Module.ShotRemote.OnServerEvent:Connect( Module.HandleServer )

	Module.ClientSync.OnServerInvoke = function ( Plr, ClientTime )

		return tick( )

	end

	Module.DropHat.OnServerEvent:Connect( function ( Plr )

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

	local ClntDmg = Instance.new( "RemoteEvent" )

	ClntDmg.Name = "ClientDamage"
	
	ClntDmg.OnServerEvent:Connect( function ( Plr, Time, DamageInfos, WeaponName, TypeName, IgnoreSpecial )
		
		if tick( ) - Time > 1 then warn( ( Plr.Name .. " took too long to send shot packet, discarding! - %f" ):format( tick( ) - Time ) ) return end
		
		Module.DamageObj( Plr, DamageInfos, WeaponName, TypeName, IgnoreSpecial )
		
	end )

	ClntDmg.Parent = game:GetService( "ReplicatedStorage" )
	
	Module.KilledEvents = { }
	
	Module.DamageInfos = setmetatable( { }, { __mode = "k" } )

	function Module.DamageObj( User, DamageInfos, WeaponName, TypeName, IgnoreSpecial )
		
		local Killed = { }
		
		local Damaged = { }
		
		local a, b = next( DamageInfos )
		
		while a do
			
			local Damageable, Damage = b[ 1 ], b[ 2 ]
			
			if Damageable.Parent and not Damageable.Parent:FindFirstChildOfClass( "ForceField" ) and Damage ~= 0 then
				
				local Amount, PrevHealth
				
				if Damageable:IsA( "Humanoid" ) then
					
					PrevHealth = Damageable.Health
					
					Amount = Damage > 0 and ( Damageable.Health > Damage and Damage or Damageable.Health ) or ( Damageable.Health - Damage < Damageable.MaxHealth and Damage or Damageable.Health - Damageable.MaxHealth )
					
					Damageable.Health = Damageable.Health - Amount
					
					if PrevHealth > 0 and Damageable.Health <= 0 then
						
						Killed[ Damageable ] = b[ 3 ]
						
					end
	
					if Damage > Damageable.MaxHealth - ( Damageable.MaxHealth / 20 ) then
	
						Damageable:AddCustomStatus( "Vital" )
	
					end
					
				elseif Damageable:IsA( "DoubleConstrainedValue" ) then
					
					PrevHealth = Damageable.Value
					
					Amount = Damage > 0 and ( Damageable.Value > Damage and Damage or Damageable.Value ) or ( Damageable.Value - Damage < Damageable.MaxValue and Damage or Damageable.Value - Damageable.MaxValue )
					
					Damageable.Value = Damageable.Value - Amount
					
					if PrevHealth > 0 and Damageable.Value <= 0 then
						
						Killed[ Damageable ] = b[ 3 ]
						
					end
	
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
					
					Module.DamageInfos[ Damageable ] = Module.DamageInfos[ Damageable ] or { }
					
					Module.DamageInfos[ Damageable ][ User ] = ( Module.DamageInfos[ Damageable ][ User ] or 0 ) + Amount
					
					delay( 30, function ( )
		
						if Module.DamageInfos[ Damageable ] and Module.DamageInfos[ Damageable ][ User ] then
							
							Module.DamageInfos[ Damageable ][ User ] = Module.DamageInfos[ Damageable ][ User ] - Amount
							
							if Module.DamageInfos[ Damageable ][ User ] <= 0 then
								
								Module.DamageInfos[ Damageable ][ User ] = nil
								
								if not next( Module.DamageInfos[ Damageable ] ) then
									
									Module.DamageInfos[ Damageable ] = nil
									
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
		
					Module.ObjDamaged:Fire( User, Damageable, Amount, PrevHealth )
					
				end
				
			end
			
			a, b = next( DamageInfos, a )
	
		end
		
		if next( Killed ) then
			
			for a, b in pairs( Module.KilledEvents ) do
				
				spawn( function ( )
					
					b( Killed, User, WeaponName, TypeName )
					
				end )
				
			end
			
		end
		
		return Damaged
		
	end
	
end

if IsClient then

	Module.ClientVisuals = Instance.new( "BindableEvent" )

	Module.SharedVisuals = Instance.new( "BindableEvent" )

	Module.DamagedObj = Instance.new( "BindableEvent" )

	game:GetService( "ReplicatedStorage" ):WaitForChild( "ClientDamage" ).OnClientEvent:Connect( function ( Other, Amount, Killed )

		if Killed then

			print( "Damaged " .. Other .. " for " .. Amount )

		else

			print( Amount .. " damage taken from " .. Other )

		end

	end )

	Module.ShotRemote.OnClientEvent:Connect( function ( StatObj, User, HitMat, End, Normal, Offset, BulNum, BarrelNum, Humanoids  )

		if User == nil then

			Module.DamagedObj:Fire( StatObj )

		elseif StatObj then

			local GunStats = Module.GetGunStats( StatObj )
			
			if GunStats then
	
				local Barrel = GunStats.Barrels( StatObj )
	
				Barrel = type( Barrel ) == "table" and Barrel[ BarrelNum or 1 ] or Barrel
	
				if not Barrel then return end
				
				local Hit, Material
				
				if typeof( HitMat ) == "Instance" then
					
					Hit = HitMat
					
					Material = Hit.Material
					
				elseif Hit then
					
					Material = HitMat
					
					Hit = workspace.Terrain
					
				end
	
				Module.SharedVisuals:Fire( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, BulNum, Humanoids )
				
			end

		end

	end )

	local KBU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )

	KBU.AddBind{ Name = "Fire", Category = "Surge 2.0", Callback = function ( Began )

		local Weapon = Module.GetSelectedWeapon( Players.LocalPlayer )

		if not Weapon or not Weapon.Selected or Weapon.GunStats.ManualFire then return end

		if Began then
			
			Weapon.MouseDown = tick( )

		else
			
			Weapon.MouseDown = nil
			
			Module.FiringEnded:Fire( Weapon.StatObj )

			Weapon.ModeShots = 0

		end

	end, Key = Enum.UserInputType.MouseButton1, PadKey = Enum.KeyCode.ButtonR2, NoHandled = true }

	KBU.AddBind{ Name = "Reload", Category = "Surge 2.0", Callback = function ( Began )

		if not Began then return end

		local Weapon = Module.GetSelectedWeapon( Players.LocalPlayer )

		if not Weapon or not Weapon.Selected or Weapon.AllowManualReload == false then return end

		Module.Reload( Weapon )

	end, Key = Enum.KeyCode.R, PadKey = Enum.KeyCode.ButtonB, NoHandled = true }

	KBU.AddBind{ Name = "Next_fire_mode", Category = "Surge 2.0", Callback = function ( Began )

		if not Began then return end

		local Weapon = Module.GetSelectedWeapon( Players.LocalPlayer )

		if not Weapon or not Weapon.Selected then return end

		Module.NextFireMode( Weapon )

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

				Module.DropHat:FireServer( )

			end

		end

	end, Key = Enum.KeyCode.Equals, NoHandled = true }
	
	Module.LPlrsTarget = { }

	function Module.GetLPlrsTarget( )

		return nil, Module.LPlrsTarget[ 2 ]

	end

	spawn( function ( )

		while true do

			local StartTime = tick( )

			local ServerTime = Module.ClientSync:InvokeServer( StartTime )

			local ClientTime = tick( )

			_G.ServerOffset = ServerTime + ( ClientTime - StartTime ) / 2 - ClientTime

			wait( 30 )

		end

	end )

end

Module.Weapons = setmetatable( { }, { __mode = 'k' } )

RunService.Heartbeat:Connect( function ( Step )
	
	local Selected

	for a, b in pairs( Module.Weapons ) do

		if b == true then

			if not a:IsDescendantOf( game ) then

				Module.Weapons[ a ] = nil

			end

		elseif not a:IsDescendantOf( game ) then

			Module.Destroy( b )

		elseif b.Selected then
			
			if not Selected then
					
				Selected = true
				
				if Players.LocalPlayer then
	
					local UnitRay = Players.LocalPlayer:GetMouse( ).UnitRay
	
					Module.LPlrsTarget = { Module.FindPartOnRayWithIgnoreFunction( Ray.new( UnitRay.Origin, UnitRay.Direction * 5000 ), Module.IgnoreFunction, { Players.LocalPlayer.Character }) }
	
				end
				
			end

			if b.MouseDown then

				if b.GunStats.WindupTime == nil then
					
					Module.Fire( b )
					
				elseif b.Reloading then

					if b.Windup or b.WindupSound then

						Module.SetWindup( b, math.max( b.Windup - ( Step * 2 ), 0 ) )

					end

				elseif b.Windup and b.Windup >= b.GunStats.WindupTime then
					
					Module.Fire( b )

				else

					Module.SetWindup( b, ( b.Windup or 0 ) + Step )

				end

			else
				
				if b.Windup then
					
					Module.SetWindup( b, math.max( b.Windup - ( Step * 2 ), 0 ) )
					
				end
				
				if b.GunStats.ClipReloadPerSecond and not b.Reloading and b.LastClick and b.Clip < b.GunStats.ClipSize and ( not b.StoredAmmo or b.StoredAmmo ~= 0 ) and ( b.LastClick + ( b.GunStats.ClipsReloadDelay or 0 ) ) <= tick( ) then
					
					local Amnt = ( b.ClipRemainder or 0 ) + b.GunStats.ClipReloadPerSecond * Step
					
					b.ClipRemainder = Amnt % 1
					
					Amnt = math.min( math.floor( Amnt ), b.GunStats.ClipSize - b.Clip )
					
					if b.StoredAmmo then
						
						Amnt = math.min( Amnt, b.StoredAmmo )
			
						Module.SetStoredAmmo( b, b.StoredAmmo - Amnt )
			
					end
					
					if Amnt > 0 then
				
						Module.SetClip( b, b.Clip + Amnt )
						
					end
					
				end

			end

			if b.LastClick and ( b.LastClick + 0.15 <= tick( ) or b.Reloading ) then

				if b.ShotRecoil > 0 then

					b.ShotRecoil = math.max( b.ShotRecoil - 1, 0 )

				else

					b.ShotRecoil = 0

				end

			end

		end

	end

end )

local Selected = setmetatable( { }, { __mode = 'k' } )

function Module.GetSelectedWeapon( Plr )

	local Sel = Selected[ Plr or "" ]

	if Sel and Sel.Selected then return Sel end

	for a, b in pairs( Module.Weapons ) do

		if b.Selected and ( Plr == nil or b.User == Plr ) then

			Selected[ Plr or "" ] = b

			return b

		end

	end

	Selected[ Plr or "" ] = nil

end

function Module.GetWeapon( StatObj )

	return Module.Weapons[ StatObj ] ~= true and Module.Weapons[ StatObj ] or nil

end

Module.WeaponSelected.Event:Connect( function ( StatObj, User )

	local Weapon = Module.GetWeapon( StatObj )

	if not Weapon then return end

	if Weapon.LastClick < tick( ) + ( Weapon.GunStats.SelectDelay or 0.2 ) then

		Weapon.LastClick = tick( ) + ( Weapon.GunStats.SelectDelay or 0.2 )

	end

	Weapon.Selected = tick( )

	Weapon.Reloading = nil

	if Weapon.ReloadDelay then

		ContextActionService:BindAction( "Reload", function ( Name, State, Input )

			if State ~= Enum.UserInputState.Begin or not Weapon.Selected then return end

			Module.Reload( Weapon )

		end, true )

		ContextActionService:SetImage( "Reload", "rbxassetid://371461853" )

	end

end )

Module.WeaponDeselected.Event:Connect( function ( StatObj, User )

	local Weapon = Module.GetWeapon( StatObj )

	if not Weapon then return end

	Weapon.ShotRecoil = 0

	Weapon.ModeShots = 0

	if Weapon.Windup then

		Module.SetWindup( Weapon, 0 )

	end

	Weapon.Selected = nil
	
	Weapon.MouseDown = nil

	Weapon.Reloading = nil

	if Weapon.ReloadDelay then

		ContextActionService:UnbindAction( "Reload" )

	end

	Module.ReloadEnd:Fire( StatObj )

end )

function Module.PlayerToUser( Weapon, Plr )

	Weapon.User = Weapon.User or Plr

	Weapon.Ignore = Weapon.Ignore or { }

	Weapon.Ignore[ #Weapon.Ignore + 1 ] = Weapon.User.Character

	Weapon.Events[ #Weapon.Events + 1 ] = Plr.CharacterAdded:Connect( function ( Char )

		Weapon.Ignore[ #Weapon.Ignore + 1 ] = Char

	end )

	Weapon.Target = Weapon.Target or Module.GetLPlrsTarget

	return Weapon

end

function Module.Setup( StatObj )

	local GunStats = Module.GetGunStats( StatObj )

	local Weapon = { }

	Module.Weapons[ StatObj ] = Weapon

	Weapon.GunStats = GunStats

	if not Weapon.GunStats.AccurateRange then

		Weapon.GunStats.AccurateRange = Weapon.GunStats.Accuracy < 1 and 25 / Weapon.GunStats.Accuracy or 200 / Weapon.GunStats.Accuracy
		
		warn( StatObj:GetFullName( ) .. " is using Accuracy which has been deprecated for AccurateRange, please update this before the 5/12/18" )
		
	end

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
			
			Module.WeaponSelected:Fire( StatObj, Weapon.User )

		end )

		Weapon.Events[ #Weapon.Events + 1 ] = StatObj.Parent.Unequipped:Connect( function ( )
			
			Module.WeaponDeselected:Fire( StatObj, Weapon.User )

		end )

	end

	return Weapon

end

function Module.Destroy( Weapon )

	if not Weapon.StatObj then return end
	
	if Weapon.Selected then
		
		Module.WeaponDeselected:Fire( Weapon.StatObj, Weapon.User )
		
	end

	for a, b in pairs( Selected ) do if b == Weapon then Selected [ a ] = nil end end

	Module.Weapons[ Weapon.StatObj ] = nil

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

function Module.SetWindup( Weapon, Value )

	local Started

	if not Weapon.Windup then

		Started = true

	elseif Value == 0 then

		Value = nil

		Started = false

	end

	Weapon.Windup = Value
	
	Module.WindupChanged:Fire( Weapon.StatObj, Value, Started )

end

function Module.GetFireMode( Weapon )

	local Mode = Weapon.GunStats.FireModes[ Weapon.CurFireMode ]

	if Module.FireModes[ Mode ] then return Module.FireModes[ Mode ] end

	return Mode

end

function Module.SetFireMode( Weapon, Value )

	Weapon.CurFireMode = Value

	Module.FireModeChanged:Fire( Weapon.StatObj, Value )

end

function Module.NextFireMode( Weapon )

	if Weapon.CurFireMode + 1 > #Weapon.GunStats.FireModes then

		Module.SetFireMode( Weapon, 1 )

	else

		Module.SetFireMode( Weapon, Weapon.CurFireMode + 1 )

	end

end

function Module.GetBulletType( GunStats )

	if not GunStats.BulletType then return Module.BulletTypes.Kinetic end

	if Module.BulletTypes[ GunStats.BulletType.Name ] then return Module.BulletTypes[ GunStats.BulletType.Name ] end

	return GunStats.BulletType

end

function Module.IgnoreFunction( Part )
	
    return not CollectionService:HasTag( Part, "nopen" ) and ( not Part or not Part.Parent or CollectionService:HasTag( Part, "forcepen" ) or Part.Parent:IsA( "Accoutrement" ) or Part.Transparency >= 1 or ( Module.GetValidHumanoid( Part ) == nil and Part.CanCollide == false ) ) or false

end

end

function Module.FindPartOnRayWithIgnoreFunction( R, IgnoreFunction, Ignore, IgnoreWater )

	local Hit, Pos, Normal, Material = workspace( "FindPartOnRayWithIgnoreList", R, Ignore, false, IgnoreWater == nil and true or IgnoreWater )

	if not Hit or not IgnoreFunction( Hit ) then

		return Hit, Pos, Normal, Material

	end

	Ignore[ #Ignore + 1 ] = Hit

	R = Ray.new( Pos - R.Unit.Direction, R.Unit.Direction * ( R.Direction.magnitude - ( Pos - R.Origin ).magnitude ) )

	return Module.FindPartOnRayWithIgnoreFunction( R, IgnoreFunction, Ignore, IgnoreWater )

end

function Module.GetAccuracy( Weapon )

	local ShotRecoil = Weapon.ShotRecoil
	
	if  Weapon.User.Character and Weapon.User.Character:FindFirstChild( "HumanoidRootPart" ) then

		local Vel = Weapon.User.Character.HumanoidRootPart.Velocity / Vector3.new( 1, 3, 1 )

		if Vel.magnitude > 0.1 then

			ShotRecoil = ShotRecoil + ( Vel.magnitude / 4 * Config.MovementAccuracyPercentage )

		end

	end
	
	return math.max( Weapon.GunStats.AccurateRange - ShotRecoil, 1 )

end

Module.PreventReload = { }

function Module.Reload( Weapon )
	
	if not Weapon.StatObj or not Weapon.GunStats.ClipSize or Weapon.GunStats.ReloadDelay < 0 or Weapon.GunStats.FireRate == 0 or Weapon.Reloading or next( Module.PreventReload ) or ( Weapon.StoredAmmo and Weapon.StoredAmmo == 0 ) then return end

	if Weapon.GunStats.ClipSize > 0 and Weapon.Clip ~= Weapon.GunStats.ClipSize then

		local ReloadTick = Weapon.MouseDown or tick( )

		Weapon.Reloading = ReloadTick

		Weapon.ModeShots = 0

		local NewClip = math.floor( Weapon.Clip / ( Weapon.GunStats.ReloadAmount or 1 ) ) * ( Weapon.GunStats.ReloadAmount or 1 )

		if Weapon.StoredAmmo then

			Module.SetStoredAmmo( Weapon, Weapon.StoredAmmo + Weapon.Clip - NewClip )

		end

		Module.SetClip( Weapon, NewClip )

		Module.ReloadStart:Fire( Weapon.StatObj )

		local Delay = Weapon.GunStats.ReloadDelay / math.ceil( Weapon.GunStats.ClipSize / ( Weapon.GunStats.ReloadAmount or 1 ) )

		Weapon.ReloadStart = tick( ) - Delay * Weapon.Clip / ( Weapon.GunStats.ReloadAmount or 1 )

		if Weapon.GunStats.InitialReloadDelay or ( Weapon.GunStats.ReloadAmount or 1 ) == 1 then hbwait( Weapon.GunStats.InitialReloadDelay or 0.25 ) end

		if Weapon.Reloading == ReloadTick then

			local w = Delay

			local TotalExtra = 0

			for i = Weapon.Clip / ( Weapon.GunStats.ReloadAmount or 1 ), math.ceil( Weapon.GunStats.ClipSize / ( Weapon.GunStats.ReloadAmount or 1 ) ) - 1 do

				Module.ReloadStepped:Fire( Weapon.StatObj )

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

				Module.SetClip( Weapon, Weapon.Clip + Add )

				if Weapon.StoredAmmo then

					Module.SetStoredAmmo( Weapon, Weapon.StoredAmmo - Add )

					if Weapon.StoredAmmo == 0 then

						break

					end

				end

			end

		end

		if Weapon.Reloading == false or Weapon.Reloading == ReloadTick then

			Module.ReloadEnd:Fire( Weapon.StatObj )

			if Weapon.GunStats.FinalReloadDelay then hbwait( Weapon.GunStats.FinalReloadDelay ) end

			Weapon.Reloading = nil

			Weapon.ReloadStart = nil

		end

	end

end

function Module.SetStoredAmmo( Weapon, Value )

	if not Weapon.StoredAmmo or Weapon.StoredAmmo == Value then return end

	Weapon.StoredAmmo = Value

	Module.StoredAmmoChanged:Fire( Weapon.StatObj, Value )

end

function Module.SetClip( Weapon, Value )

	if not Weapon.Clip or Weapon.Clip == Value then return end

	Weapon.Clip = Value

	Module.ClipChanged:Fire( Weapon.StatObj, Value )

end

Module.PreventFire = { }

function Module.CanFire( Weapon, Barrel )
	
	if next( Module.PreventFire ) then return false end

	if ( typeof( Weapon.User ) == "Instance" and Weapon.User:IsA( "Player" ) and not Weapon.User.Character ) or ( Weapon.User.Character and Weapon.User.Character:FindFirstChild( "Humanoid" ) and Weapon.User.Character.Humanoid:GetState( ) == Enum.HumanoidStateType.Dead ) then return false end

	if not Weapon.StatObj or Weapon.GunStats.UseBarrelAsOrigin or Weapon.GunStats.NoAntiWall or not Weapon.User.Character then return end

	local Hit, End, Normal, Material = Module.FindPartOnRayWithIgnoreFunction( Ray.new( Weapon.User.Character.HumanoidRootPart.Position, Barrel.Position - Weapon.User.Character.HumanoidRootPart.Position ), Module.IgnoreFunction, Weapon.Ignore )

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

function Module.Fire( Weapon )

	if Weapon == nil then return end

	local FireMode = Module.GetFireMode( Weapon )
	
	if Weapon.Clip ~= 0 and Weapon.Reloading and Weapon.Reloading ~= Weapon.MouseDown then

		Weapon.Reloading = false

	end

	if FireMode.PreventFire or Weapon.LastClick >= tick( ) or Weapon.Reloading ~= nil then return end

	if Weapon.Clip == 0 then

		Module.Reload( Weapon )

		return

	end

	local ShotsPerClick = Weapon.GunStats.ShotsPerClick or 1

	local OneAmmoPerClick = Weapon.GunStats.OneAmmoPerClick or false

	if Weapon.GunStats.ClipSize and Weapon.Clip - ( OneAmmoPerClick and 1 or ShotsPerClick ) < 0 then

		Module.Reload( Weapon )

		return

	end

	local LastClick = 1 / Weapon.GunStats.FireRate

	local Start = tick( )

	local DelayBetweenShots = Weapon.GunStats.DelayBetweenShots or 0

	Weapon.LastClick = Start + LastClick + ( DelayBetweenShots * ShotsPerClick )

	local ActualFired = 0

	local CurFireMode = Weapon.CurFireMode

	for BulNum = 1, ShotsPerClick do

		if not Weapon.Selected or Weapon.CurFireMode ~= CurFireMode then break end

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

			local Hit, End, Normal, Material = Module.CanFire( Weapon, Barrel )
			
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
						
                        Hit, End, Normal, Material = Module.FindPartOnRayWithIgnoreFunction( Ray.new( Origin, CFrame.new( Origin, ( Target + Target.lookVector * 1000 + Target.UpVector * math.random( 0, 1000 / Module.GetAccuracy( Weapon ) / 2 ) ).p ).lookVector * Weapon.GunStats.Range - Vector3.new( 0, Config.BulletDrop / 1000 * Weapon.GunStats.Range, 0 ) ), Module.IgnoreFunction, TableCopy( Weapon.Ignore ), not IgnoreWater )
						
					else

						Hit = false

					end

				end

				if Hit ~= false then

					if Weapon.Clip  and ( not OneAmmoPerClick or ( ShotsPerClick and ShotsPerClick > 1 and BulNum == 1 ) ) then

						Module.SetClip( Weapon, Weapon.Clip - 1 )

					end

					Weapon.ShotRecoil = math.min( Weapon.ShotRecoil + math.abs( Weapon.GunStats.Damage ) / 50, math.abs( Weapon.GunStats.Damage ) / 5 * ShotsPerClick )

					local Offset = Hit and Hit.CFrame:pointToObjectSpace( End ) or nil
					
					if Offset then Offset = Vector3.new( Offset.X / Hit.Size.X, Offset.Y / Hit.Size.Y, Offset.Z / Hit.Size.Z ) end

					if IsClient then

						if Players.LocalPlayer == Weapon.User then

							Module.ClientVisuals:Fire( Weapon.StatObj, Barrel, Hit, End, Normal, Material, Offset, BulNum ~= 1 and BulNum or nil )

						end

						if not IsServer then

							Module.SharedVisuals:Fire( Weapon.StatObj, Weapon.User, Barrel, Hit, End, Normal, Material, Offset, BulNum ~= 1 and BulNum or nil )

						end

					end

					if IsServer then

						Module.HandleServer( nil, tick( ), Weapon.StatObj, Hit == workspace.Terrain and Material or Hit, End, Normal, Offset, BulNum ~= 1 and BulNum or nil, Weapon.User, Weapon.CurBarrel ~= 1 and Weapon.CurBarrel or nil )

					else

						Module.ShotRemote:FireServer( tick( ) + _G.ServerOffset, Weapon.StatObj, Hit == workspace.Terrain and Material or Hit, End, Normal, Offset, BulNum ~= 1 and BulNum or nil, Players.LocalPlayer ~= Weapon.User and Weapon.User or nil, Weapon.CurBarrel ~= 1 and Weapon.CurBarrel or nil )

					end

				end

			end

			if DelayBetweenShots > 0 and ShotsPerClick > 1 and Weapon.Clip ~= 0 then

				hbwait( DelayBetweenShots )

			end

		end

	end

	if ShotsPerClick > 1 and ShotsPerClick ~= ActualFired then

		Weapon.LastClick = Start + LastClick + ( DelayBetweenShots * ActualFired )

	end

	Weapon.ModeShots = Weapon.ModeShots + 1

	if not FireMode.Automatic and ( not FireMode.Shots or FireMode.Shots == 1 or Weapon.ModeShots >= FireMode.Shots ) then
		
		Weapon.MouseDown = nil
		
		Module.FiringEnded:Fire( Weapon.StatObj )

		Weapon.ModeShots = 0

	end

end

Module.DamageType = {

	Kinetic = "Kinetic",

	Explosive = "Explosive",

	Slash = "Slash",

	Fire = "Fire",

	Electricity = "Electricity",
	
	Heal = "Heal"

}

function Module.GetTeamInfo( Obj )

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

function Module.CheckTeamkill( P1, P2, AllowTeamKill, InvertTeamKill )
	
	local TC1, N1, PlrObj1 = Module.GetTeamInfo( P1 )

	local TC2, N2, PlrObj2 = Module.GetTeamInfo( P2 )

	if PlrObj1 and PlrObj2 and PlrObj1 == PlrObj2 then return Config.SelfDamage or false end
	
	if ( AllowTeamKill == nil and Config.AllowTeamKill ) or AllowTeamKill then return true end

	if Config.AllowNeutralTeamKill and ( N1 or N2 ) then return true end

	if InvertTeamKill then return not ActualTeamKill( TC1, N1, TC2, N2 ) else return ActualTeamKill( TC1, N1, TC2, N2 ) end

end

function Module.GetValidHumanoid( Obj )

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

function Module.GetDamage( User, Hit, OrigDamage, Type, Distance, DistanceModifier, IgnoreTeam, WeaponName, InvertTeamKill )

	local Humanoid = Module.GetValidHumanoid( Hit )

	if not Humanoid then return end

	if Module.IgnoreFunction( Hit ) then return false end

	if not Module.CheckTeamkill( User, Humanoid, IgnoreTeam, InvertTeamKill ) then return false end
	
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

		Distance = Distance * ( DistanceModifier or Config.DistanceDamageMultiplier )

		Damage = Damage * ( 1 - Distance )

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

		Module.Spawned( Players.LocalPlayer )

	end

	Players.LocalPlayer.CharacterAdded:Connect( function ( )

		Module.Spawned( Players.LocalPlayer )

	end )

else
	
	local function HandlePlr( Plr )
		
		if Plr.Character then Module.Spawned( Plr ) end

		Plr.CharacterAdded:Connect( function ( )

			Module.Spawned( Plr )

		end )
		
	end

	Players.PlayerAdded:Connect( HandlePlr )
	
	local Plrs = Players:GetPlayers( )
	
	for a = 1, #Plrs do
		
		HandlePlr( Plrs[ a ] )
		
	end

end

return Module
