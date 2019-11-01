local Players = game:GetService( "Players" )

return function(Core)
	local function TableCopy(Table)
		return {unpack(Table)}
	end
	
	local WeaponType WeaponType = {
		StoredAmmoChanged = Instance.new("BindableEvent"),
		ClipChanged = Instance.new("BindableEvent"),
		WeaponModes = {
			Auto = {Automatic = true},
			Semi = {},
			Burst = {Shots = 3},
			Safety = {PreventAttack = true},
		},
		Setup = function(Weapon)
			Weapon.Target = Weapon.Target
			Weapon.ShotRecoil = 0
			Weapon.Clip = Weapon.StartingClip or Weapon.ClipSize
			Weapon.StoredAmmo = Weapon.StartingStoredAmmo or Weapon.MaxStoredAmmo
			Weapon.CurBarrel = 1
			Weapon.ModeShots = 0
			Weapon.BarrelPart = Weapon.Barrels( Weapon.StatObj )
			
			if typeof(Weapon.User) == "Instance" and Weapon.User:IsA("Player") then
				Weapon.Target = Weapon.Target or Core.GetLPlrsTarget
			end
			
			Weapon.Ignore = Weapon.Ignores and Weapon.Ignores(Weapon.StatObj) or {}
			if typeof(Weapon.User) == "Instance" and Weapon.User:IsA("Player") then
				Weapon.Ignore[#Weapon.Ignore + 1] = Weapon.User.Character
				
				Weapon.Events[#Weapon.Events + 1] = Weapon.User.CharacterAdded:Connect(function(Char)
					Weapon.Ignore[#Weapon.Ignore + 1] = Char
				end)
			end
			
			if Weapon.StoredAmmo and Weapon.Clip then Weapon.StoredAmmo = Weapon.StoredAmmo - Weapon.Clip end
		end,
		Selected = function(Weapon)
			if not Weapon.ServerPlaceholder and Weapon.ClipReloadPerSecond and Weapon.Clip < Weapon.ClipSize and ( not Weapon.StoredAmmo or Weapon.StoredAmmo ~= 0 ) then
				Core.WeaponTick[Weapon] = true
			end
		end,
		Deselected = function(Weapon)
			if not Weapon.ServerPlaceholder then
				Weapon.ShotRecoil = 0
				Weapon.ModeShots = 0
			end
		end,
		Tick = function(Weapon, Step)
			local Needed
			
			if Weapon.ClipReloadPerSecond and Weapon.Clip < Weapon.ClipSize and (not Weapon.StoredAmmo or Weapon.StoredAmmo ~= 0) then
				Needed = true
				if not Weapon.Reloading and Weapon.LastClick and (Weapon.LastClick + (Weapon.ClipsReloadDelay or 0)) <= tick() then
					local Amnt = (Weapon.ClipRemainder or 0) + Weapon.ClipReloadPerSecond * Step
					Weapon.ClipRemainder = Amnt % 1
					Amnt = math.min(math.floor(Amnt), Weapon.ClipSize - Weapon.Clip)
					
					if Weapon.StoredAmmo then
						Amnt = math.min(Amnt, Weapon.StoredAmmo)
						WeaponType.SetStoredAmmo(Weapon, Weapon.StoredAmmo - Amnt)
					end
					
					if Amnt > 0 then
						WeaponType.SetClip(Weapon, Weapon.Clip + Amnt)
					end
				end
			end
			
			if Weapon.ShotRecoil > 0 then
				Needed = true
				if (Weapon.LastClick and Weapon.LastClick + 0.15 <= tick()) or Weapon.Reloading then
					Weapon.ShotRecoil = math.max(Weapon.ShotRecoil - 1, 0)
				end
			end
			
			return Needed
		end,
		HandleServerReplication = function(Weapon, User, ToNetwork, ...)
			
			if type( ToNetwork ) ~= "table" then
				
				ToNetwork = { { ToNetwork, ... } }
				
			end
	
			local Barrels = Weapon.Barrels( Weapon.StatObj )
			
			local CloseTo = { }
			
			for  k, v in ipairs(ToNetwork) do
				
				local Barrel = type( Barrels ) == "table" and Barrels[ v[ 5 ] or 1 ] or Barrels
				
				if Barrel then
					
					local Hit, Normal, Offset, BarrelNum = unpack( v )
					
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
					
					local Humanoids = ( Weapon.WeaponType.GetBulletType( Weapon ) or Core.BulletTypes.Kinetic )( Weapon.StatObj, Weapon, User, Hit, Barrel, End )
					
					local FirstShot
					
					if #ToNetwork > 1 then FirstShot = k == 1 end
					
					WeaponType.AttackEvent:Fire( Weapon.StatObj, User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, #ToNetwork > 1 and k == 1 or nil, Humanoids )
			
					local BulRay = Ray.new( Barrel.Position, ( End - Barrel.Position ).Unit )
					
					for _, OPlr in ipairs(Players:GetPlayers()) do
						
						if OPlr ~= User then
							
							if BulRay:Distance( OPlr.Character and OPlr.Character:FindFirstChild( "HumanoidRootPart" ) and OPlr.Character.HumanoidRootPart.Position or Barrel.Position ) <= 250 then
								
								if #ToNetwork == 1 then
									
									Core.WeaponReplication:FireClient( OPlr, User, Weapon.StatObj, unpack( ToNetwork[ 1 ] ) )
									
								else
									
									CloseTo[ OPlr ] = CloseTo[ OPlr ] or { }
									
									CloseTo[ OPlr ][ #CloseTo[ OPlr ] + 1 ] = v
									
								end
								
							end
							
						end
						
					end
					
				end
				
			end
			
			if #ToNetwork == 1 then return end
			
			for a, b in pairs( CloseTo ) do
				
				if #b == 1 then
					
					Core.WeaponReplication:FireClient( a, User, Weapon.StatObj, unpack( b[ 1 ] ) )
					
				else
					
					Core.WeaponReplication:FireClient( a, User, Weapon.StatObj, b )
					
				end
				
			end
		end,
		HandleClientReplication = function(StatObj, User, ToNetwork, ...)
			if type( ToNetwork ) ~= "table" then
				
				ToNetwork = { { ToNetwork, ...} }
				
			end
			
			local WeaponStats = Core.GetWeaponStats( StatObj )
	
			local Barrels = WeaponStats.Barrels( StatObj )
			
			for k, v in ipairs(ToNetwork) do
				
				local Barrel = type( Barrels ) == "table" and Barrels[ v[ 5 ] or 1 ] or Barrels
		
				if Barrel then
					
					local Hit, Normal, Offset, BarrelNum = unpack( v )
					
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
					
					local Humanoids = ( WeaponType.GetBulletType( WeaponStats ) or WeaponType.BulletTypes.Kinetic )( StatObj, WeaponStats, User, Hit, Barrel, End )
					
					local FirstShot
					
					if #ToNetwork > 1 then FirstShot = k == 1 end
					
					WeaponType.AttackEvent:Fire( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, Humanoids )
					
				end
			end
		end,
		Attack = function(Weapon)
			
			if Weapon.Clip ~= 0 and Weapon.Reloading and Weapon.Reloading ~= Weapon.MouseDown then
		
				Weapon.Reloading = false
		
			end
		
			if ( Weapon.LastClick and Weapon.LastClick >= tick( ) ) or Weapon.Reloading ~= nil then return end
		
			if Weapon.Clip == 0 then
		
				Core.Reload( Weapon )
		
				return
		
			end
		
			local ShotsPerClick = Weapon.ShotsPerClick or 1
		
			local OneAmmoPerClick = Weapon.OneAmmoPerClick or false
		
			if Weapon.ClipSize and Weapon.Clip - ( OneAmmoPerClick and 1 or ShotsPerClick ) < 0 then
		
				Core.Reload( Weapon )
		
				return
		
			end
		
			local LastClick = 1 / Weapon.FireRate
			
			local Start = Weapon.LastClick or tick( )
		
			local DelayBetweenShots = Weapon.DelayBetweenShots or 0
		
			Weapon.LastClick = Start + LastClick + ( DelayBetweenShots * ShotsPerClick )
		
			local ActualFired = 0
		
			local CurWeaponMode = Weapon.CurWeaponMode
			
			local ToNetwork = ShotsPerClick > 1 and DelayBetweenShots == 0 and { } or nil
			
			local OverStep = 0
		
			for BulNum = 1, ShotsPerClick do
		
				if ( not Core.Selected[ Weapon.User ] or not Core.Selected[ Weapon.User ][ Weapon ] ) or Weapon.CurWeaponMode ~= CurWeaponMode then break end
		
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
		
					local Hit, End, Normal, Material = Core.CanAttack(Weapon) and WeaponType.CanFire(Weapon, Barrel)
					
					if Hit ~= false then
		
						local IgnoreWater = Weapon.BulletType and ( Weapon.BulletType.Name == "Fire" or Weapon.BulletType.Name == "Lightning" )
		
						if IgnoreWater then
		
							if workspace.Terrain:ReadVoxels(Region3.new( Barrel.Position - Vector3.new( 2, 2, 2 ), Barrel.Position + Vector3.new( 2, 2, 2 ) ):ExpandToGrid(4), 4)[1][1][1] == Enum.Material.Water then
		
								Hit, End, Normal, Material = workspace.Terrain, Barrel.Position, -Barrel.CFrame.lookVector, Enum.Material.Water
		
							end
		
						end
		
						if not Hit then
		
							local _, Target = Weapon.Target( Weapon.StatObj, Barrel )
		
							if Target then
		
								local Origin = not Weapon.UseBarrelAsOrigin and Weapon.User and Weapon.User.Character and Weapon.User.Character:FindFirstChild( "NewHead" ) and Weapon.User.Character.NewHead.Position or Barrel.Position
								
								Target = CFrame.new( Origin, Target ) * CFrame.Angles( 0, 0, math.rad( math.random( 0, 3599 ) / 10 ) )
								
		                        Hit, End, Normal, Material = Core.FindPartOnRayWithIgnoreFunction( Ray.new( Origin, CFrame.new( Origin, ( Target + Target.lookVector * 1000 + Target.UpVector * math.random( 0, 1000 / WeaponType.GetAccuracy( Weapon ) / 2 ) ).p ).lookVector * Weapon.Range ), Core.IgnoreFunction, TableCopy( Weapon.Ignore ), not IgnoreWater )
								
							else
		
								Hit = false
		
							end
		
						end
		
						if Hit ~= false then
		
							if Weapon.Clip  and ( not OneAmmoPerClick or ( ShotsPerClick and ShotsPerClick > 1 and BulNum == 1 ) ) then
		
								WeaponType.SetClip( Weapon, Weapon.Clip - 1 )
		
							end
		
							Weapon.ShotRecoil = math.min( Weapon.ShotRecoil + math.abs( Weapon.Damage ) / 50, math.abs( Weapon.Damage ) / 5 * ShotsPerClick )
		
							local Offset = Hit and Hit.CFrame:pointToObjectSpace( End ) or nil
							
							local Humanoids = ( WeaponType.GetBulletType( Weapon ) or WeaponType.BulletTypes.Kinetic )( Weapon.StatObj, Weapon, Weapon.User, Hit, Barrel, End )
		
							if not Core.IsServer then
								
								local FirstShot
								
								if ShotsPerClick > 1 then FirstShot = BulNum == 1 end
								print( Weapon.StatObj, Weapon.User.Name)
								WeaponType.AttackEvent:Fire( Weapon.StatObj, Weapon.User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, Humanoids, tick( ) + _G.ServerOffset )
		
							end
							
							if ToNetwork then
								
								ToNetwork[ BulNum ] = { Hit == workspace.Terrain and Material or Hit, Normal, Hit == nil and End or Offset, Weapon.CurBarrel ~= 1 and Weapon.CurBarrel or nil }
								
							else
								
								if Core.IsServer then
									
									coroutine.wrap(Core.HandleServerReplication)( Weapon.User, Weapon.StatObj, tick( ), Hit == workspace.Terrain and Material or Hit, Normal, Hit == nil and End or Offset, Weapon.CurBarrel ~= 1 and Weapon.CurBarrel or nil )
									
								else
									
									Core.WeaponReplication:FireServer( Weapon.StatObj, tick( ) + _G.ServerOffset, Hit == workspace.Terrain and Material or Hit, Normal, Hit == nil and End or Offset, Weapon.CurBarrel ~= 1 and Weapon.CurBarrel or nil )
									
								end
								
							end
							
						end
		
					end
		
					if DelayBetweenShots > 0 and ShotsPerClick > 1 and Weapon.Clip ~= 0 then
						
						if OverStep < DelayBetweenShots then
							
							OverStep = OverStep + ( Core.HeartbeatWait( DelayBetweenShots ) - DelayBetweenShots )
							
						else
							
							OverStep = OverStep - DelayBetweenShots
							
						end
						
					end
		
				end
		
			end
			
			if ToNetwork then
				
				if Core.IsServer then
					
					coroutine.wrap(Core.HandleServerReplication)( Weapon.User, Weapon.StatObj, tick( ), ToNetwork)
					
				else
					
					Core.WeaponReplication:FireServer( Weapon.StatObj, tick( ) + _G.ServerOffset, ToNetwork )
					
				end
				
			end
		
			if ShotsPerClick > 1 and ShotsPerClick ~= ActualFired then
		
				Weapon.LastClick = Start + LastClick + ( DelayBetweenShots * ActualFired )
		
			end
		
			Weapon.ModeShots = Weapon.ModeShots + 1
		
			if not Weapon.Automatic and ( not Weapon.Shots or Weapon.Shots == 1 or Weapon.ModeShots >= Weapon.Shots ) then
				
				Core.EndAttack(Weapon)
		
			end
			
			if Weapon.LastClick < tick( ) then
				
				if Weapon.WindupTime == nil or Weapon.WindupTime == 0 then
					
					Core.Fire( Weapon)
			
				elseif not Weapon.Reloading and  Weapon.Windup and Weapon.Windup >= Weapon.WindupTime then
					
					Core.Fire( Weapon )
					
				end
				
			end
		
		end,
		EndAttack = function(Weapon)
			Weapon.ModeShots = 0
		end,
		Reload = function(Weapon)
			if not Weapon.StatObj or not Weapon.ClipSize or Weapon.ReloadDelay < 0 or Weapon.FireRate == 0 or Weapon.Reloading or ( Weapon.StoredAmmo and Weapon.StoredAmmo == 0 ) then return end
		
			if Weapon.ClipSize > 0 and Weapon.Clip ~= Weapon.ClipSize then
		
				local ReloadTick = Weapon.MouseDown or tick( )
		
				Weapon.Reloading = ReloadTick
		
				Weapon.ModeShots = 0
		
				local NewClip = math.floor( Weapon.Clip / ( Weapon.ReloadAmount or 1 ) ) * ( Weapon.ReloadAmount or 1 )
		
				if Weapon.StoredAmmo then
		
					Weapon.WeaponType.SetStoredAmmo( Weapon, Weapon.StoredAmmo + Weapon.Clip - NewClip )
		
				end
		
				Weapon.WeaponType.SetClip( Weapon, NewClip )
		
				Core.ReloadStart:Fire( Weapon.StatObj )
		
				local Delay = Weapon.ReloadDelay / math.ceil( Weapon.ClipSize / ( Weapon.ReloadAmount or 1 ) )
		
				Weapon.ReloadStart = tick( ) - Delay * Weapon.Clip / ( Weapon.ReloadAmount or 1 )
		
				if Weapon.InitialReloadDelay or ( Weapon.ReloadAmount or 1 ) == 1 then Core.HeartbeatWait( Weapon.InitialReloadDelay or 0.25 ) end
		
				if Weapon.Reloading == ReloadTick then
		
					local w = Delay
		
					local TotalExtra = 0
		
					for i = Weapon.Clip / ( Weapon.ReloadAmount or 1 ), math.ceil( Weapon.ClipSize / ( Weapon.ReloadAmount or 1 ) ) - 1 do
		
						Core.ReloadStepped:Fire( Weapon.StatObj )
		
						TotalExtra = TotalExtra + w - Delay
		
						if TotalExtra > Delay then
		
							TotalExtra = TotalExtra - Delay + Delay - w
		
						else
		
							w = Core.HeartbeatWait( Delay + Delay - w )
		
						end
		
						if Weapon.Reloading ~= ReloadTick then
							
							break
		
						end
		
						local Add = Weapon.StoredAmmo and math.min( ( Weapon.ReloadAmount or 1 ), Weapon.StoredAmmo ) or ( Weapon.ReloadAmount or 1 )
		
						Weapon.WeaponType.SetClip( Weapon, Weapon.Clip + Add )
		
						if Weapon.StoredAmmo then
		
							Weapon.WeaponType.SetStoredAmmo( Weapon, Weapon.StoredAmmo - Add )
		
							if Weapon.StoredAmmo == 0 then
		
								break
		
							end
		
						end
		
					end
		
				end
				
				if Weapon.LastClick and Weapon.LastClick < tick( ) then Weapon.LastClick = nil end
		
				if Weapon.Reloading == false or Weapon.Reloading == ReloadTick then
		
					Core.ReloadEnd:Fire( Weapon.StatObj )
		
					if Weapon.FinalReloadDelay then Core.HeartbeatWait( Weapon.FinalReloadDelay ) end
		
					Weapon.Reloading = nil
		
					Weapon.ReloadStart = nil
		
				end
			end
		end,
		BulletTypes = {
			Kinetic = function(StatObj, Weapon, User, Hit, Barrel, End)
				local Damageable, Damage = Core.DamageHelper(User, Hit, StatObj, Weapon.BulletType and Weapon.BulletType.DamageType or Core.DamageType.Kinetic, ( Barrel.Position - End ).magnitude / Weapon.Range)
				if Damageable then
					return {{Damageable, Damage}}
				end
			end,
			Lightning = function(StatObj, Weapon, User, Hit, Barrel, End)
				if Hit then
					local DamageType = Weapon.BulletType.DamageType or Core.DamageType.Electricity
					local Type = type( Weapon.BulletType.Type ) == "function" and Weapon.BulletType.Type or Weapon.BulletType.Type == "Stun" and WeaponType.BulletTypes or Weapon.BulletType.Type == "Fire" and Core.StartFireDamage
					local Dist = ( Barrel.Position - End ).magnitude / Weapon.Range
					
					local Damageables = {}
						
					local Material, Occupancy = workspace.Terrain:ReadVoxels(Region3.new(End - Vector3.new(2, 2, 2), End + Vector3.new(2, 2, 2)):ExpandToGrid(4), 4)
					if Material[1][1][1] == Enum.Material.Water then
						local Radius = Weapon.BulletType.Radius or 15
						
						Core.FakeExplosion({Position = End, BlastRadius = Radius, BlastPressure = 0, ExplosionType = Enum.ExplosionType.NoCraters}, function(Part, ExpDist)
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
							if Core.IsServer then
								Core.ApplyDamage(User, Info[3] > 0 and Core.GetBottomDamageable(Damageable) or Damageable, Info[1], StatObj, DamageType, Info[2], Info[3])
								if Type then
									Type(StatObj, Weapon, User, Hit, Damageable)
								end
							end
							EstimatedDamageables[#EstimatedDamageables + 1] = {Damageable, Info[3]}
						end
						
						return EstimatedDamageables
					end
				end
			end,
			Fire = function(StatObj, Weapon, User, Hit, Barrel, End)
				local Damageable, Damage = Core.DamageHelper(User, Hit, StatObj, Weapon.BulletType.DamageType or Core.DamageType.Fire, ( Barrel.Position - End ).magnitude / Weapon.Range)
				if Damageable then
					if Core.IsServer then
						Core.StartFireDamage(StatObj, Weapon, User, Hit, Damageable)
					end
					
					return {{Damageable, Damage}}
				end
			end,
			Stun = function(StatObj, Weapon, User, Hit, Barrel, End)
				local Damageable, Damage = Core.DamageHelper(User, Hit, StatObj, Weapon.BulletType.DamageType or Core.DamageType.Electricity, ( Barrel.Position - End ).magnitude / Weapon.Range)
				if Damageable then
					if Core.IsServer then
						Core.StartStun(StatObj, Weapon, User, Hit, Damageable)
					end
					
					return {{Damageable, Damage}}
				end
			end,
			Explosive = function(StatObj, Weapon, User, Hit, Barrel, End)
				if Hit or not Weapon.BulletType.ExplodeOnHit then
					return Core.DoExplosion(User, StatObj, End, Weapon.BulletType)
				end
			end
		},
		GetAccuracy = function ( Weapon )
		
			local ShotRecoil = Weapon.ShotRecoil
			
			if  Weapon.User.Character and Weapon.User.Character:FindFirstChild( "HumanoidRootPart" ) then
		
				local Vel = Weapon.User.Character.HumanoidRootPart.Velocity / Vector3.new( 1, 3, 1 )
		
				if Vel.magnitude > 0.1 then
		
					ShotRecoil = ShotRecoil + ( Vel.magnitude / 4 * Core.Config.MovementAccuracyPercentage )
		
				end
		
			end
			
			return math.max( Weapon.AccurateRange - ShotRecoil, 1 )
		
		end,
		GetBulletType = function ( Weapon )
		
			if not Weapon.BulletType then return WeaponType.BulletTypes.Kinetic end
		
			if WeaponType.BulletTypes[ Weapon.BulletType.Name ] then return WeaponType.BulletTypes[ Weapon.BulletType.Name ] end
		
			return Weapon.BulletType
		
		end,
		SetStoredAmmo = function ( Weapon, Value )
			
			if not Weapon.StoredAmmo or Weapon.StoredAmmo == Value then return end
			
			Weapon.StoredAmmo = Value
			
			WeaponType.StoredAmmoChanged:Fire( Weapon.StatObj, Value )
			
			if Weapon.ClipReloadPerSecond and Weapon.Clip < Weapon.ClipSize and Value ~= 0 then
				
				Core.WeaponTick[ Weapon ] = true
				
			end
			
		end,
		SetClip = function ( Weapon, Value )
		
			if not Weapon.Clip or Weapon.Clip == Value then return end
		
			Weapon.Clip = Value
		
			WeaponType.ClipChanged:Fire( Weapon.StatObj, Value )
		
		end,
		CanFire = function (Weapon, Barrel)
			if not Weapon.StatObj or Weapon.UseBarrelAsOrigin or Weapon.NoAntiWall or not Weapon.User.Character then return end
			local Hit, End, Normal, Material = Core.FindPartOnRayWithIgnoreFunction( Ray.new( Weapon.User.Character.HumanoidRootPart.Position, Barrel.Position - Weapon.User.Character.HumanoidRootPart.Position ), Core.IgnoreFunction, Weapon.Ignore )
			if Hit then
				return Hit, End, Normal, Material
			end
		end,
	}
	
	return WeaponType
end