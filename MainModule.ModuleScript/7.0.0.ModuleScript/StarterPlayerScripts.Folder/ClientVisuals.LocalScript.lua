local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local RunService, Debris, Plr, CollectionService = game:GetService( "RunService" ), game:GetService( "Debris" ), game:GetService( "Players" ).LocalPlayer, game:GetService( "CollectionService" )

local TweenService = game:GetService( "TweenService" )

local Menu = require(game:GetService("ReplicatedStorage"):WaitForChild("MenuLib"):WaitForChild("Performance"))

require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("SharedVisuals"))

Core.WeaponTypes.Sword.Events.AttackSound = Core.WeaponTypes.Sword.AttackEvent.Event:Connect(function(StatObj, User, Type)
	local WeaponStats = Core.GetWeaponStats(StatObj)
	if Type == 0 then
		if WeaponStats.SlashSound then
			local SlashSound = StatObj.Parent.Handle:FindFirstChild("SlashSound") or WeaponStats.SlashSound:Clone()
			SlashSound.Parent = StatObj.Parent.Handle
			SlashSound:Play()
		end
	elseif WeaponStats.LungeSound then
		local LungeSound = StatObj.Parent.Handle:FindFirstChild("LungeSound") or WeaponStats.LungeSound:Clone()
		LungeSound.Parent = StatObj.Parent.Handle
		LungeSound:Play()
	end
end)

Core.WeaponTypes.Sword.Events.VIPSparkles = Core.WeaponTypes.Sword.AttackEvent.Event:Connect(function(StatObj, User, Type)
	local WeaponStats = Core.GetWeaponStats(StatObj)
	if Type == 1 and typeof(User) == "Instance" and User:FindFirstChild("S2") and User.S2:FindFirstChild("VIPSparkles") and User.S2.VIPSparkles.Value then
		local Col = BrickColor.Random().Color
		
		for _, Part in ipairs(WeaponStats.DamageParts(StatObj)) do
			if not Part:FindFirstChild("Sparkles") then
				for a = 1, 5 do
					Instance.new("Sparkles", Part)
				end
			end
		end
		
		for _, Part in ipairs(WeaponStats.DamageParts(StatObj)) do
			for _, Spark in ipairs(Part:GetChildren()) do
				if Spark:IsA( "Sparkles" ) then
					Spark.SparkleColor = Col
					Spark.Enabled = true
				end
			end
		end
		
		wait(0.25)
		
		for _, Part in ipairs(WeaponStats.DamageParts(StatObj)) do
			for _, Spark in ipairs(Part:GetChildren()) do
				if Spark:IsA( "Sparkles" ) then
					Spark.Enabled = false
				end
			end
		end
	end
end)

Core.WeaponTypes.RaycastGun.BulletArrived = Instance.new( "BindableEvent" )

coroutine.wrap( function ( ) game:GetService( "ContentProvider" ):PreloadAsync( { script } ) end )

local PhysicsService = game:GetService("PhysicsService")
local function AtPos( Position )
	
	local Part = Instance.new( "Part" )
	
	PhysicsService:SetPartCollisionGroup(Part, "S2_NoCollide")
	
	Part.Name = "AtPos"
	
	Part.Transparency = 1
	
	Part.Size = Vector3.new( )
	
	if pcall( function ( ) return Position:IsA( "BasePart" ) end ) then
		
		Part.Anchored = false
		
		local Weld = Instance.new( "Weld" )
		
		Weld.Part0 = Part
		
		Weld.Part1 = Position
		
		Weld.Parent = Part
		
	else
		
		Part.Anchored = true
		
		Part.CFrame = Position
		
	end
	
	Part.Parent = workspace.CurrentCamera
	
	return Part
	
end

local function PlaySoundAtPos( Position, Sound )
	
	local SoundObj = script[ Sound ]:Clone( )
	
	local Par1 = AtPos( Position )
	
	SoundObj.Parent = Par1
	
	Par1.Name = "SoundPart"
	
	SoundObj.Volume = SoundObj.Volume
	
	SoundObj:Play( )
	
	SoundObj.Ended:Connect( function ( ) wait( ) Par1:Destroy( ) end )
	
end

Core.Events.LongReloadSound = Core.ReloadStart.Event:Connect(function(StatObj, Delay)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon.ReloadSound and Weapon.LongReloadSound then
		local Part = type(Weapon.BarrelPart) == "table" and Weapon.BarrelPart[1] or Weapon.BarrelPart
		
		local ReloadSound = Part:FindFirstChild("ReloadSound") 
		if not ReloadSound then
			ReloadSound = Weapon.ReloadSound:Clone()
			ReloadSound.Name = "ReloadSound"
			ReloadSound.Parent = Part
		end
		
		ReloadSound.PlaybackSpeed = ReloadSound.TimeLength / (Delay + (Weapon.InitialReloadDelay or 0) + (Weapon.FinalReloadDelay or 0))
		ReloadSound:Play()
	end
end)

Core.Events.ShortReloadSound = Core.ReloadStepped.Event:Connect(function(StatObj, Delay)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon.ReloadSound and not Weapon.LongReloadSound then
		local Part = type(Weapon.BarrelPart) == "table" and Weapon.BarrelPart[1] or Weapon.BarrelPart
		
		local ReloadSound = Part:FindFirstChild("ReloadSound") 
		if not ReloadSound then
			ReloadSound = Weapon.ReloadSound:Clone()
			ReloadSound.Name = "ReloadSound"
			ReloadSound.Parent = Part
		end
		
		ReloadSound.PlaybackSpeed = ReloadSound.TimeLength / Delay
		ReloadSound:Play()
	end
end)

Core.Events.EndReloadSound = Core.ReloadEnd.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon.ReloadSound then
		local Part = type(Weapon.BarrelPart) == "table" and Weapon.BarrelPart[1] or Weapon.BarrelPart
		
		local ReloadSound = Part:FindFirstChild("ReloadSound") 
		if ReloadSound and ReloadSound.IsPlaying then
			ReloadSound:Stop()
		end
	end
end)

Core.Events.WindupSound = Core.WindupChanged.Event:Connect( function ( StatObj, Windup, State )
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if Weapon.WindupSound then
		
		local Part = type( Weapon.BarrelPart ) == "table" and Weapon.BarrelPart[ 1 ] or Weapon.BarrelPart
		
		if Part then
			
			local WindupSound = Part:FindFirstChild( "Windup" ) or Weapon.WindupSound:Clone( )
			
			WindupSound.Parent = Part
			
			WindupSound.Looped = true
			
			WindupSound.Pitch = math.min( ( Windup or 0 ) / (Weapon.WindupTime or 1), 1 ) * 0.75
			
			if State then
				
				WindupSound:Play( )
				
			elseif State == false then
				
				WindupSound:Stop( )
				
			end
			
		end
		
	end
	
end )

Core.Events.FireSoundEnd = Core.AttackEnded.Event:Connect( function ( StatObj )
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if Weapon.LongFiringSound then
		
		local Barrels = type( Weapon.BarrelPart ) == "table" and Weapon.BarrelPart or { Weapon.BarrelPart }
		
		for _, Obj in ipairs( Barrels ) do
			
			local Part = Obj
			
			local FireSound = Part and Part:FindFirstChild( "FireSound" )
			
			if FireSound then
				
				local Tween = TweenService:Create( FireSound, TweenInfo.new( type( Weapon.LongFiringSound ) == "number" and Weapon.LongFiringSound or 1 ), { Volume = 0 } )
				
				FireSound.Name = "Destroying"
				
				Tween.Completed:Connect( function ( ) FireSound:Destroy( ) end )
				
				Tween:Play( )
				
			end
			
		end
		
	end
	
end )

local TweenService, VZero = game:GetService( "TweenService" )

Core.CameraCenter = Core.CameraCenter or Vector3.new()

Core.Events.CameraRecoil = Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect( function ( StatObj, User )
	
	if User == Plr then
		
		local Weapon = Core.GetWeapon( StatObj )
		
		if Plr.Character and Plr.Character:FindFirstChild( "Humanoid" ) and Weapon.ScreenRecoilPercentage ~= 0 then
			
			local Hum = Plr.Character.Humanoid
			
			Hum.CameraOffset = Vector3.new( ( math.random( 5, 10 ) / 100 ), 0, ( math.random( 10, 20 ) / 100 ) ) * ( Weapon.Damage / 25 ) * Weapon.ScreenRecoilPercentage
			
			TweenService:Create( Hum, TweenInfo.new( 0.2 ), { CameraOffset = Core.CameraCenter } ):Play( )
			
		end
		
	end
	
end )

local function FlyBy( StatObj, User, Barrel, _, End )
	
	if not Barrel then return end
	
	local WeaponStats = Core.GetWeaponStats( StatObj )
	
	if WeaponStats.NoFlybyEffects then return end
	
	if User == Plr then return end
	
	local Pos = workspace.CurrentCamera.CFrame.p
	
	local Start = Barrel.Position
	
	if ( Start - Pos ).magnitude > ( End - Start ).magnitude + 50 then
		
		return
		
	end
	
	local Ray = Ray.new( Start, ( End - Start ).Unit ).Unit
	
	local ClosestPoint = Ray:ClosestPoint( Pos )
	
	local Distance = ( ClosestPoint - Pos ).magnitude
	
	if ( Start - Pos ).magnitude > ( End - Start ).magnitude then
		
		Distance = ( End - Pos ).magnitude
		
		ClosestPoint = End
		
	end
	
	if Distance < 75 then
		
		PlaySoundAtPos( CFrame.new( ClosestPoint ), "Flyby" .. math.random( 1, 4 ) )
		
	end
	
end

Menu:AddSetting{Name = "BulletFlyByNoise", Text = "Bullet Fly By Noise", Default = true, Update = function(Options, Val)
	if Val then
		if not Core.Events.FlyBy then
			Core.Events.FlyBy = Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect(FlyBy)
		end
	elseif Core.Events.FlyBy then
		Core.Events.FlyBy:Disconnect()
		Core.Events.FlyBy = nil
	end
end}

local GunBarrelEffectsEnabled = true
Core.Events.MuzzleEffects = Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect( function ( StatObj, User, Barrel, _, _, _, _, _, FirstShot )
	
	if not Barrel then return end
	
	local WeaponStats = Core.GetWeaponStats( StatObj )
	
	if WeaponStats.NoBarrelEffect then return end
	
	local Part = Barrel
	
	if FirstShot ~= false and WeaponStats.FireSound and ( not WeaponStats.LongFiringSound or not Part:FindFirstChild( "FireSound" ) ) then
		
		local FireSound = WeaponStats.FireSound:Clone( )
		
		FireSound.Name = "FireSound"
		
		FireSound.Parent = Part
		
		if not WeaponStats.LongFiringSound then
			
			FireSound.Ended:Connect( function ( ) wait( ) FireSound:Destroy( ) end )
			
		end
		
		FireSound:Play( )
		
	end
	
	if type( User ) == "userdata" and User:FindFirstChild( "S2" ) and User.S2:FindFirstChild( "VIPSparkles" ) and User.S2.VIPSparkles.Value then
		
		if not Part:FindFirstChildWhichIsA( "Sparkles" ) then
			
			local Sparkles = Instance.new( "Sparkles" )
			
			Sparkles.Enabled = false
			
			Sparkles:Clone( ).Parent = Part
			
			Sparkles:Clone( ).Parent = Part
			
			Sparkles:Clone( ).Parent = Part
			
			Sparkles.Parent = Part
			
		end
		
		local Sparks = Part:GetChildren( )
		
		local Col = BrickColor.Random( ).Color
		
		for _, Spark in ipairs( Sparks ) do
			
			if Spark:IsA( "Sparkles" ) then
				
				Spark.SparkleColor = Col
				
				Spark.Enabled = true
				
			end
			
		end
		
		wait( 0.2 )
		
		for _, Spark in ipairs( Sparks ) do
			
			if Spark:IsA( "Sparkles" ) then
				
				Spark.Enabled = false
				
			end
			
		end
		
	elseif GunBarrelEffectsEnabled then
		
		if not Part:FindFirstChild( "MuzzleFlash" ) then
			
			script.MuzzleFlash:Clone( ).Parent = Part
			
		end
		
		if not Part:FindFirstChild( "FireParticle" ) then
			
			script.FireParticle:Clone( ).Parent = Part
			
		end
		
		Part.MuzzleFlash.Enabled = true
		
		local SizeMult = math.clamp( math.abs( WeaponStats.Damage )  * ( WeaponStats.Range / 600 ), 60, 140 ) / 3
		
		Part.FireParticle.Size = NumberSequence.new(
			
			{
				
				NumberSequenceKeypoint.new( 0, 0.01 * SizeMult, 0.01 * SizeMult ),
				
				NumberSequenceKeypoint.new( 0.7, 0.01 * SizeMult, 0.01 * SizeMult ),
				
				NumberSequenceKeypoint.new( 1, 0, 0 )
				
			}
		)
		
		Part.FireParticle:Emit( 20 )
		
		if not Part:FindFirstChild( "SmokeParticle" ) then
			
			script.SmokeParticle:Clone( ).Parent = Part
			
		end
		
		for i = 1, 5 do
			
			Part.SmokeParticle:Emit( 5 )
			
			wait( )
			
			if not Part.Parent then break end
			
			if i == 1 then 
				
				Part.MuzzleFlash.Enabled = false
				
			end
			
		end
	end
	
end)

Menu:AddSetting{Name = "GunBarrelEffects", Text = "Gun Shot Particles", Default = GunBarrelEffectsEnabled, Update = function(Options, Val)
	GunBarrelEffectsEnabled = Val
end}

local function RenderSegment( User, WeaponStats, Start, End, Thickness )
	
	local Bullet = Instance.new( "BoxHandleAdornment" )
	
	Bullet.Name = "GunBullet"
	
	Bullet.Adornee = workspace.Terrain
	
	local Col = User.TeamColor.Color
	
	if WeaponStats.BulletColor or Core.BulletColor then
		
		Col = WeaponStats.BulletColor or Core.BulletColor
		
	elseif type( User ) == "userdata" and User:FindFirstChild( "S2Color" ) then
		
		Col = User.S2Color.Value.Color
		
	end
	
	Bullet.Color3 = Color3.new( Col.r * 3, Col.g * 3, Col.b * 3 )
	
	Bullet.Transparency = WeaponStats.BulletTransparency or Core.BulletTransparency or 0.2
	
	local Dist = ( Start - End ).magnitude
	
	local Size = ( WeaponStats.BulletSize or Core.BulletSize or 0.25 ) * Thickness
	
	Bullet.Size = Vector3.new( Size, Size, Dist )
		
	Bullet.CFrame = CFrame.new( ( Start + End ) / 2, End )
	
	Bullet.Parent = workspace.CurrentCamera
	
	return Bullet
	
end

local function RenderLightning( User, WeaponStats, Start, End, Thickness, BranchFactor, Jaggedness, Iterations )
	
	local Theta = math.atan( 2 * Jaggedness )
	
	local Segments = { { Start, End } }
	
	local Parts = {}
	
	for i = 1, Iterations do
		
		local TSegments = Segments
		
		Segments = { }
		
		for _, v in ipairs( TSegments ) do
			
			local Dist = ( v[ 1 ] - v[ 2 ] ).magnitude
			
			local MidPoint = ( v[ 1 ] + v[ 2 ] )/2
			
			local DVect = CFrame.new( MidPoint, v[ 2 ] )
			
			MidPoint = ( DVect * CFrame.Angles( 0, 0, math.random( ) * math.pi * 2 ) * CFrame.new( 0, math.random( ) * Dist * Jaggedness, 0 ) ).p
			
			local BranchLen = BranchFactor * Dist
			
			local Direction = ( DVect * ( CFrame.Angles( 0, 0, math.random( ) * math.pi * 2 ) * CFrame.Angles( 0, math.random( ) * Theta, 0 ) ) ).LookVector
			
			local Branch = Direction * BranchLen + MidPoint		

			if i ~= Iterations then
				
				Segments[ #Segments + 1 ] = { v[1], MidPoint }
				
				Segments[ #Segments + 1 ] = { MidPoint, v[ 2 ] }
				
				Segments[ #Segments + 1 ] = { MidPoint, Branch }
				
			else
				
				local Distl = Dist * Thickness
				
				Parts[ #Parts + 1 ] = RenderSegment( User, WeaponStats, v[ 1 ], MidPoint, 1 )
				
				Parts[ #Parts + 1 ] = RenderSegment( User, WeaponStats, MidPoint, v[ 2 ], 1 )
				
				Parts[ #Parts + 1 ] = RenderSegment( User, WeaponStats, MidPoint, Branch, BranchLen * Thickness )
				
			end
			
		end
		
	end
	
	return Parts
	
end

Core.Events.BulletEffect = Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect( function ( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, Humanoids )
	
	if not Barrel then return end
	
	local WeaponStats = Core.GetWeaponStats( StatObj )
	
	if WeaponStats.NoBulletEffect then return end
	
	if WeaponStats.BulletType and WeaponStats.BulletType.Name == "Lightning" then
		
		local Parts = RenderLightning( User, WeaponStats, Barrel.Position, End, 0.4, 0.2, 0.05, 4 )
		
		RunService.RenderStepped:wait( )
		
		local StartColor = Parts[ 1 ].Color3
		
		local ColBool = 0
		
		local WhiteColor = Color3.new( 0.9, 0.9, 0.9 )
		
		for i = 1, 20 do
			
			for _, v in ipairs( Parts ) do
				
				v.Transparency = v.Transparency * 1.1
				
				v.Color3 = ColBool == 0 and WhiteColor or StartColor
				
			end
			
			ColBool = ColBool == 0 and 1 or ColBool == 1 and 2 or 0
			
			if Parts[ 1 ].Transparency > 1 then
				
				break
				
			end
			
			RunService.Heartbeat:wait( )
			
		end
		
		for _, v in ipairs( Parts ) do
			
			v:Destroy()
			
		end
		
		Core.WeaponTypes.RaycastGun.BulletArrived:Fire( User, WeaponStats.BulletType, Barrel, End, Hit, Normal, Material, Offset, Humanoids )
		
	elseif WeaponStats.BulletType and WeaponStats.BulletType.Name == "Laser" then
		
		local Bullet = Instance.new( "BoxHandleAdornment" )
		
		Bullet.Name = "GunBullet"
		
		Bullet.Adornee = workspace.Terrain
		
		local Col = WeaponStats.BulletColor or (type(User) == "userdata" and User:FindFirstChild("S2") and User.S2:FindFirstChild("VIPColor") and User.S2.VIPColor.Value.Color) or User.TeamColor.Color
		
		Bullet.Color3 = Color3.new( Col.r * 3, Col.g * 3, Col.b * 3 )
		
		Bullet.Transparency = WeaponStats.BulletTransparency or 0.4
		
		Debris:AddItem( Bullet, 3 )
		
		local Size = WeaponStats.BulletSize or 0.25
		
		Bullet.Size = Vector3.new( Size, Size, ( Barrel.Position - End ).magnitude )
		
		local CF = CFrame.new( Barrel.Position, End )
		
		Bullet.CFrame = CF * CFrame.new(0, 0, -( Barrel.Position - End ).magnitude / 2)
		
		Bullet.Parent = workspace.CurrentCamera
		
		Core.WeaponTypes.RaycastGun.BulletArrived:Fire( User, WeaponStats.BulletType, Barrel, End, Hit, Normal, Material, Offset, Humanoids )
		
		for a = 1, WeaponStats.BulletType.VisibleFrames or 3 do
			
			RunService.Heartbeat:Wait( )
			
		end
		
		Bullet:Destroy( )
		
		return
		
	else
		
		local Size = WeaponStats.BulletSize or 0.27
		
		local Speed = WeaponStats.BulletSpeed or 3200
		
		local Length = math.min(WeaponStats.BulletLength or ((Speed / 60) * (WeaponStats.BulletLengthMod or 1)), Speed / 60)
		
		local CF = CFrame.new( Barrel.Position, End )
		
		local Dist = ( Barrel.Position - End ).magnitude
		
		local Cur = 0
		
		local Bullet = Instance.new( "BoxHandleAdornment" )
		
		Bullet.Name = "GunBullet"
		
		Bullet.Adornee = workspace.Terrain
		
		Bullet.Color3 = WeaponStats.BulletColor or (type(User) == "userdata" and User:FindFirstChild("S2") and User.S2:FindFirstChild("VIPColor") and User.S2.VIPColor.Value.Color) or User.TeamColor.Color
		
		Bullet.Color3 = Color3.new( Bullet.Color3.r * 3, Bullet.Color3.g * 3, Bullet.Color3.b * 3 )
		
		Bullet.Transparency = WeaponStats.BulletTransparency or 0.05
		
		Debris:AddItem( Bullet, 3 )
		
		Bullet.Parent = workspace.CurrentCamera
		
		RunService.RenderStepped:Wait( )
		
		local Arrived
		
		while Cur < Dist do
			
			if not Bullet or not Bullet.Parent then return end
			
			if not Arrived and Dist - Cur <= Length then
				
				Arrived = true
				
				Core.WeaponTypes.RaycastGun.BulletArrived:Fire( User, WeaponStats.BulletType, Barrel, End, Hit, Normal, Material, Offset, Humanoids )
				
			end
			
			local CurSize = math.min( Length, Dist - Cur )
			
			if CurSize <= 0 then break end
			
			Bullet.Size = Vector3.new( Size, Size, CurSize )
			
			Bullet.CFrame = CF * CFrame.new(0, 0, -( Cur + CurSize / 2 ))
			
			local Delta = RunService.Heartbeat:wait( )
			
			Cur = Cur + ( Speed * Delta )
			
		end
		
		Bullet:Destroy( )
		
	end
	
end )

local Impacts = {}

local ImpactNum = 0

local MaxBulletImpacts, BulletImpactDespawn = 150, 60

Menu.Settings[#Menu.Settings + 1] = {Name = "MaxBulletImpacts", Text = "Max Bullet Impacts", Default = MaxBulletImpacts, Min = 1, Update = function(Options, Val)
	MaxBulletImpacts = Val
end}

if Menu.SavedSettings and Menu.SavedSettings["MaxBulletImpacts"] == nil then
	Menu.SavedSettings["MaxBulletImpacts"] = MaxBulletImpacts
end

coroutine.wrap(Menu.Settings[#Menu.Settings].Update)(Menu, Menu.SavedSettings["MaxBulletImpacts"])

Menu.Settings[#Menu.Settings + 1] = {Name = "BulletImpactDespawn", Text = "Bullet Impact Despawn Time", Default = BulletImpactDespawn, Min = 1, Update = function(Options, Val)
	BulletImpactDespawn = Val
end}

if Menu.SavedSettings and Menu.SavedSettings["BulletImpactDespawn"] == nil then
	Menu.SavedSettings["BulletImpactDespawn"] = BulletImpactDespawn
end

coroutine.wrap(Menu.Settings[#Menu.Settings].Update)(Menu, Menu.SavedSettings["BulletImpactDespawn"])

if Menu.Tabs[1].Invalidate then
	Menu.Tabs[1]:Invalidate()
end

Core.Events.BulletImpact = Core.WeaponTypes.RaycastGun.BulletArrived.Event:Connect( function ( User, BulletType, _, End, Hit, Normal, Material, Offset, _ )
	
	if not BulletType or BulletType.Name == "Kinectic" or BulletType.Name == "Laser" then
		
		if not Hit or not Hit.Parent then return end
		
		if ImpactNum >= MaxBulletImpacts then
			
			ImpactNum = ImpactNum - 1
			
			local Impact = next( Impacts )
			
			Impact:Destroy( )
			
			Impacts[ Impact ] = nil
			
		end
		
		local BulletHit = Instance.new( "CylinderHandleAdornment" )
		
		BulletHit.Height = 0.03 + math.random( 1, 100 ) / 10000
		
		BulletHit.Radius = 0.2
		
		BulletHit.Name = "GunHit"
		
		local Humanoid = Core.GetValidDamageable( Hit )
		
		if Humanoid and Hit.Name == "NewHead" then
			
			Hit = Humanoid.Parent:FindFirstChild("Head") or Hit
			
		end
		
		BulletHit.Adornee = Hit
		
		BulletHit.Transparency = Hit.Transparency
		
		local Col = Hit == workspace.Terrain and workspace.Terrain:GetMaterialColor( Material ) or Hit.BrickColor
		
		BulletHit.Color3 = Color3.new( 0.1 + ( Col.r / 5 ), 0.1 + ( Col.g / 5 ), 0.1 + ( Col.b / 5 ) )
		
		if Humanoid and not CollectionService:HasTag( Humanoid, "s2_silent" ) then
			
			BulletHit.Color = BrickColor.Red( )
			
		end
		
		BulletHit.CFrame = CFrame.new( Offset, Hit.CFrame:pointToObjectSpace( Hit.CFrame:pointToWorldSpace( Offset ) + Normal ) )
		
		BulletHit.Parent = Hit
		
		Impacts[ BulletHit ] = true
		
		ImpactNum = ImpactNum + 1
		
		wait( BulletImpactDespawn )
		
		if Impacts[ BulletHit ] then
			
			ImpactNum = ImpactNum - 1
			
			Impacts[ BulletHit ] = nil
			
			BulletHit:Destroy( )
			
		end
		
	elseif BulletType.Name == "Explosive" then
		
		if not Hit and BulletType.ExplodeOnHit then return end
		
		local Exp = Instance.new( "Explosion" )
		
		Exp.BlastPressure = 0
		
		Exp.ExplosionType = Enum.ExplosionType.NoCraters
		
		Exp.Position = End
		
		Exp.BlastRadius = BulletType.BlastRadius
		
		Exp.Parent = workspace.CurrentCamera
		
	end
	
end )

Core.Events.BulletImpactSound = Core.WeaponTypes.RaycastGun.BulletArrived.Event:Connect( function( User, BulletType, Barrel, _, Hit, _, Material, Offset, _ )
	
	if not Hit then return end
	
	if BulletType and BulletType ~= "Kinectic" then return end
	
	local Humanoid = Core.GetValidDamageable( Hit )
	
	Offset = Hit.CFrame:pointToWorldSpace( Offset )
	
	if Humanoid and not CollectionService:HasTag( Humanoid, "s2_silent" ) then
		 
		local BloodParticle = script.BloodParticle:Clone( )
		
		local Par1 = AtPos( CFrame.new( Offset, Barrel.Position ) )
		
		BloodParticle.Parent = Par1
		
		local ImpactSound = script[ "FleshImpact" ]:Clone( )
		
		ImpactSound.Parent = Par1
		
		ImpactSound.Ended:Connect( function ( ) Par1:Destroy( ) end )
		
		ImpactSound:Play( )
		
		wait( )
		
		BloodParticle:Emit( 10 )
		
		Debris:AddItem( Par1, 2 )
	
	else
		
		local Par1 = AtPos( CFrame.new( Offset, Barrel.Position ) )
		
		local HitParticle = script.HitParticle:Clone( )
		
		local Col = Hit == workspace.Terrain and workspace.Terrain:GetMaterialColor( Material ) or Hit.Color
		
		HitParticle.Color = ColorSequence.new( Color3.new( Col.r - 0.059, Col.g - 0.059, Col.b - 0.059 ) )
		
		HitParticle.Transparency = NumberSequence.new( Hit.Transparency, Hit.Transparency )
		
		Debris:AddItem( Par1, 2 )
		
		HitParticle.Parent = Par1 
		
		HitParticle:Emit( 20 )
		
		local ImpactSound = script[ ( ( Material == Enum.Material.Metal or Material == Enum.Material.CorrodedMetal or Material == Enum.Material.DiamondPlate ) and "MetalImpact" ) or ( ( Material == Enum.Material.Wood or Material == Enum.Material.WoodPlanks ) and "WoodImpact" ) or ( ( Material == Enum.Material.Grass or Material == Enum.Material.Ground or Material == Enum.Material.LeafyGrass ) and "GrassImpact" ) or ( ( Material == Enum.Material.Glacier or Material == Enum.Material.Ice or Material == Enum.Material.Neon or Hit.Transparency > 0 ) and "GlassImpact" ) or "ConcreteImpact" ]:Clone( )
		
		ImpactSound.Parent = Par1
		
		ImpactSound.Ended:Connect( function ( ) Par1:Destroy( ) end )
		
		ImpactSound:Play( )
		
	end
	
end )