local Config, Core = _G.S20Config, require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

repeat wait( ) until Config

local RunService, Debris, Plr, CollectionService = game:GetService( "RunService" ), game:GetService( "Debris" ), game:GetService( "Players" ).LocalPlayer, game:GetService( "CollectionService" )

local TweenService = game:GetService( "TweenService" )

local Used = setmetatable( { }, { __mode = 'k' } )

local function GetVisualBarrel( Barrel, DontCreate )
	
	local Part = Used[ Barrel ]
	
	if not Part then
		
		if DontCreate then return end
		
		Part = Instance.new( "Part" )
		
		Part.Name = Barrel.Name .. "_Barrel"
		
		Part.CanCollide = false
		
		Part.Transparency = 1
		
		Part.Size = Vector3.new( )
		
		Part.CFrame = Barrel.CFrame
		
		Part.Anchored = false
		
		Used[ Barrel ] = Part
		
	end
	
	Part.Parent = workspace.CurrentCamera
	
	if not Part:FindFirstChild( "Weld" ) then
		
		local Weld = Instance.new( "Weld" )
		
		Weld.Part0 = Part
		
		Weld.Part1 = Barrel
		
		Weld.Parent = Part
		
	end
	
	return Part
	
end

Core.BulletArrived = Instance.new( "BindableEvent" )

spawn( function ( ) game:GetService( "ContentProvider" ):PreloadAsync( { script } ) end )

local function AtPos( Position )
	
	local Part = Instance.new( "Part" )
	
	Part.Name = "AtPos"
	
	Part.CanCollide = false
	
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

Core.Visuals.ReloadSound = Core.ReloadStepped.Event:Connect( function ( StatObj )
	
	if not StatObj or not StatObj.Parent then return end
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if not Weapon.GunStats.ReloadSound then return end
	
	local Part = GetVisualBarrel( type( Weapon.BarrelPart ) == "table" and Weapon.BarrelPart[ 1 ] or Weapon.BarrelPart )
	
	local ReloadSound = Part:FindFirstChild( "ReloadSound" ) or Weapon.GunStats.ReloadSound:Clone( )
	
	ReloadSound.Name = "ReloadSound"
	
	ReloadSound.Parent = Part
	
	if Weapon.GunStats.LongReloadSound then
		
		if ReloadSound.Playing then return end
		
		--ReloadSound.PlaybackSpeed =  ReloadSound.TimeLength / ( Weapon.GunStats.ReloadDelay * ( Weapon.GunStats.ReloadAmount / Weapon.GunStats.ClipSize ) )
		
		ReloadSound.Looped = true
		
	end
	
	ReloadSound:Play( )
	
end )

Core.Visuals.EndReloadSound = Core.ReloadEnd.Event:Connect( function ( StatObj )
	
	if not StatObj or not StatObj.Parent then return end
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if not Weapon.GunStats.ReloadSound then return end
	
	local Part = GetVisualBarrel( type( Weapon.BarrelPart ) == "table" and Weapon.BarrelPart[ 1 ] or Weapon.BarrelPart )
	
	local ReloadSound = Part:FindFirstChild( "ReloadSound" )
	
	if ReloadSound then ReloadSound:Stop( ) end
	
end )

Core.Visuals.WindupSound = Core.WindupChanged.Event:Connect( function ( StatObj, Windup, State )
	
	if not StatObj or not StatObj.Parent then return end
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if not Weapon.GunStats.WindupSound then return end
	
	local Part = GetVisualBarrel( type( Weapon.BarrelPart ) == "table" and Weapon.BarrelPart[ 1 ] or Weapon.BarrelPart )
	
	local WindupSound = Part:FindFirstChild( "Windup" ) or Weapon.GunStats.WindupSound:Clone( )
	
	WindupSound.Parent = Part
	
	WindupSound.Looped = true
	
	WindupSound.Pitch = math.min( ( Windup or 0 ) / (Weapon.GunStats.WindupTime or 1), 1 ) * 0.75
	
	if State then
		
		WindupSound:Play( )
		
	elseif State == false then
		
		WindupSound:Stop( )
		
	end
	
end )

Core.Visuals.FireSoundEnd = Core.FiringEnded.Event:Connect( function ( StatObj )
	
	if not StatObj or not StatObj.Parent then return end
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if Weapon.GunStats.LongFiringSound then
		
		local Barrels = type( Weapon.BarrelPart ) == "table" and Weapon.BarrelPart or { Weapon.BarrelPart }
		
		for a = 1, #Barrels do
			
			local Part = GetVisualBarrel( Barrels[ a ], true )
			
			local FireSound = Part and Part:FindFirstChild( "FireSound" )
			
			if FireSound then
				
				local Tween = TweenService:Create( FireSound, TweenInfo.new( type( Weapon.GunStats.LongFiringSound ) == "number" and Weapon.GunStats.LongFiringSound or 1 ), { Volume = 0 } )
				
				FireSound.Name = "Destroying"
				
				Tween.Completed:Connect( function ( ) FireSound:Destroy( ) end )
				
				Tween:Play( )
				
			end
			
		end
		
	end
	
end )

local TweenService, VZero = game:GetService( "TweenService" ), Vector3.new( )

Core.Visuals.CameraRecoil = Core.ClientVisuals.Event:Connect( function ( StatObj )
	
	if not StatObj or not StatObj.Parent then return end
	
	local GunStats = Core.GetGunStats( StatObj )
	
	if Plr.Character and Plr.Character:FindFirstChild( "Humanoid" ) and GunStats.AllowCameraShake ~= false then
		
		local Hum = Plr.Character.Humanoid
		
		Hum.CameraOffset = Vector3.new( ( math.random( 5, 10 ) / 100 ), 0, ( math.random( 10, 20 ) / 100 ) ) * Config.ScreenRecoilPercentage * ( GunStats.Damage / 25 )
		
		TweenService:Create( Hum, TweenInfo.new( 0.2 ), { CameraOffset = VZero } ):Play( )
		
	end
	
end )

Core.Visuals.HitIndicator = Core.SharedVisuals.Event:Connect( function ( _, User, _, _, _, _, _, _, _, Humanoids )
	
	if Humanoids and User == Plr then
		
		local Type = 1
		
		local Noise
		
		for a = 1, #Humanoids do
			
			if Humanoids[ a ][ 1 ].Parent then
				
				if not CollectionService:HasTag( Humanoids[ a ][ 1 ], "s2_silent" ) then Noise = true end
				
				if Humanoids[ a ][ 1 ]:IsA( "Humanoid" ) then Type = 2 end
				
			end
			
		end
		
		if not Noise then return end
		
		local HitSound = _G.S20Config.HitSound and _G.S20Config.HitSound:Clone() or script.HitSound:Clone( )
		
		HitSound.Pitch = HitSound.Pitch * Type
		
		HitSound.Ended:Connect( function ( ) wait( ) HitSound:Destroy( ) end )
		
		HitSound.Parent = workspace.CurrentCamera
		
		HitSound:Play( )
		
	end
	
end )

Core.Visuals.FlyBy = Core.SharedVisuals.Event:Connect( function ( StatObj, User, Barrel, _, End )
	
	if not Barrel or not StatObj or not StatObj.Parent then return end
	
	local GunStats = Core.GetGunStats( StatObj )
	
	if GunStats.NoFlybyEffects then return end
	
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
	
end )

Core.Visuals.BarrelEffects = Core.SharedVisuals.Event:Connect( function ( StatObj, User, Barrel, _, _, _, _, _, FirstShot )
	
	if not Barrel or not StatObj or not StatObj.Parent then return end
	
	local GunStats = Core.GetGunStats( StatObj )
	
	if GunStats.NoBarrelEffect then return end
	
	local Part = GetVisualBarrel( Barrel )
	
	if FirstShot ~= false and GunStats.FireSound and ( not GunStats.LongFiringSound or not Part:FindFirstChild( "FireSound" ) ) then
		
		local FireSound = GunStats.FireSound:Clone( )
		
		FireSound.Name = "FireSound"
		
		FireSound.Parent = Part
		
		if not GunStats.LongFiringSound then
			
			FireSound.Ended:Connect( function ( ) wait( ) FireSound:Destroy( ) end )
			
		end
		
		FireSound:Play( )
		
	end
	
	if type( User ) == "userdata" and User:FindFirstChild( "S2Sparkles" ) and User.S2Sparkles.Value then
		
		if not Part:FindFirstChild( "Sparkles" ) then
			
			local Sparkles = Instance.new( "Sparkles" )
			
			Sparkles.Enabled = false
			
			Sparkles:Clone( ).Parent = Part
			
			Sparkles:Clone( ).Parent = Part
			
			Sparkles:Clone( ).Parent = Part
			
			Sparkles.Parent = Part
			
		end
		
		local Sparks = Part:GetChildren( )
		
		local Col = BrickColor.Random( ).Color
		
		for a = 1, #Sparks do
			
			if Sparks[ a ]:IsA( "Sparkles" ) then
				
				Sparks[ a ].SparkleColor = Col
				
				Sparks[ a ].Enabled = true
				
			end
			
		end
		
		wait( 0.2 )
		
		for a = 1, #Sparks do
			
			if Sparks[ a ]:IsA( "Sparkles" ) then
				
				Sparks[ a ].Enabled = false
				
			end
			
		end
		
	else
		
		if not Part:FindFirstChild( "FireParticle" ) then
			
			script.FireParticle:Clone( ).Parent = Part
			
		end
		
		local SizeMult = math.clamp( math.abs( GunStats.Damage )  * ( GunStats.Range / 600 ), 60, 140 ) / 3
		
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
			
		end
	end
	
end )

local function RenderSegment( User, GunStats, Start, End, Thickness )
	
	local Bullet = Instance.new( "BoxHandleAdornment" )
	
	Bullet.Name = "GunBullet"
	
	Bullet.Adornee = workspace.Terrain
	
	local Col = User.TeamColor.Color
	
	if GunStats.BulletColor or Core.BulletColor then
		
		Col = GunStats.BulletColor or Core.BulletColor
		
	elseif type( User ) == "userdata" and User:FindFirstChild( "S2Color" ) then
		
		Col = User.S2Color.Value.Color
		
	end
	
	Bullet.Color3 = Col
	
	Bullet.Transparency = GunStats.BulletTransparency or Core.BulletTransparency or 0.2
	
	local Dist = ( Start - End ).magnitude
	
	local Size = ( GunStats.BulletSize or Core.BulletSize or 0.25 ) * Thickness
	
	Bullet.Size = Vector3.new( Size, Size, Dist )
		
	Bullet.CFrame = CFrame.new( ( Start + End ) / 2, End )
	
	Bullet.Parent = workspace.CurrentCamera
	
	return Bullet
	
end

local function RenderLightning( User, GunStats, Start, End, Thickness, BranchFactor, Jaggedness, Iterations )
	
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
			
			local Direction = ( DVect * ( CFrame.Angles( 0, 0, math.random( ) * math.pi * 2 ) * CFrame.Angles( 0, math.random( ) * Theta, 0 ) ) ).lookVector
			
			local Branch = Direction * BranchLen + MidPoint		

			if i ~= Iterations then
				
				Segments[ #Segments + 1 ] = { v[1], MidPoint }
				
				Segments[ #Segments + 1 ] = { MidPoint, v[ 2 ] }
				
				Segments[ #Segments + 1 ] = { MidPoint, Branch }
				
			else
				
				local Distl = Dist * Thickness
				
				Parts[ #Parts + 1 ] = RenderSegment( User, GunStats, v[ 1 ], MidPoint, 1 )
				
				Parts[ #Parts + 1 ] = RenderSegment( User, GunStats, MidPoint, v[ 2 ], 1 )
				
				Parts[ #Parts + 1 ] = RenderSegment( User, GunStats, MidPoint, Branch, BranchLen * Thickness )
				
			end
			
		end
		
	end
	
	return Parts
	
end

Core.Visuals.BulletEffect = Core.SharedVisuals.Event:Connect( function ( StatObj, User, Barrel, Hit, End, Normal, Material, Offset, _, Humanoids, Time )
	
	if not Barrel or not StatObj or not StatObj.Parent then return end
	
	local GunStats = Core.GetGunStats( StatObj )
	
	if GunStats.NoBulletEffect then return end
	
	if GunStats.BulletType and GunStats.BulletType.Name == "Lightning" then
		
		local Parts = RenderLightning( User, GunStats, Barrel.Position, End, 0.4, 0.2, 0.05, 4 )
		
		RunService.RenderStepped:wait( )
		
		local StartColor = Parts[ 1 ].Color3
		
		local ColBool = 0
		
		local WhiteColor = Color3.new( 0.9, 0.9, 0.9 )
		
		for i = 1, 20 do
			
			for _, v in pairs( Parts ) do
				
				v.Transparency = v.Transparency * 1.1
				
				v.Color3 = ColBool == 0 and WhiteColor or StartColor
				
			end
			
			ColBool = ColBool == 0 and 1 or ColBool == 1 and 2 or 0
			
			if Parts[ 1 ].Transparency > 1 then
				
				break
				
			end
			
			RunService.RenderStepped:wait( )
			
		end
		
		Core.BulletArrived:Fire( User, GunStats.BulletType, Barrel, End, Hit, Normal, Material, Offset, Humanoids )
		
	elseif GunStats.BulletType and GunStats.BulletType.Name == "Laser" then
		
		local Bullet = Instance.new( "BoxHandleAdornment" )
		
		Bullet.Name = "GunBullet"
		
		Bullet.Adornee = workspace.Terrain
		
		local Col = User.TeamColor.Color
		
		if GunStats.BulletColor or Core.BulletColor then
			
			Col = GunStats.BulletColor or Core.BulletColor
			
		elseif type( User ) == "userdata" and User:FindFirstChild( "S2Color" ) then
			
			Col = User.S2Color.Value.Color
			
		end
		
		Bullet.Color3 = Col
		
		Bullet.Transparency = GunStats.BulletTransparency or Core.BulletTransparency or 0.4
		
		Debris:AddItem( Bullet, 3 )
		
		local Size = GunStats.BulletSize or Core.BulletSize or 0.25
		
		Bullet.Size = Vector3.new( Size, Size, ( Barrel.Position - End ).magnitude )
		
		local CF = CFrame.new( Barrel.Position, End )
		
		Bullet.CFrame = CF + CF.lookVector * ( ( Barrel.Position - End ).magnitude / 2 )
		
		Bullet.Parent = workspace.CurrentCamera
		
		Core.BulletArrived:Fire( User, GunStats.BulletType, Barrel, End, Hit, Normal, Material, Offset, Humanoids )
		
		for a = 1, GunStats.BulletType.VisibleFrames or 3 do
			
			RunService.RenderStepped:wait( )
			
		end
		
		Bullet:Destroy( )
		
		return
		
	else
		
		local Size = GunStats.BulletSize or Config.BulletSize or 0.27
		
		local Speed = GunStats.BulletSpeed or Config.BulletSpeed or 1600
		
		local Length = math.min(  Speed / ( 60 + math.abs( GunStats.BulletLengthMod or Config.BulletLengthMod or 0 ) ), Speed / 60 )
		
		local CF = CFrame.new( Barrel.Position, End )
		
		local Dist = ( Barrel.Position - End ).magnitude
		
		local Cur = 0
		
		local Bullet = Instance.new( "BoxHandleAdornment" )
		
		Bullet.Name = "GunBullet"
		
		Bullet.Adornee = workspace.Terrain
		
		Bullet.Color3 = GunStats.BulletColor or ( type( User ) == "userdata" and User:FindFirstChild( "S2Color" ) and User.S2Color.Value ~= User.TeamColor and User.S2Color.Value.Color ) or Config.BulletColor or User.TeamColor.Color
		
		Bullet.Transparency = GunStats.BulletTransparency or Config.BulletTransparency or 0.05
		
		Debris:AddItem( Bullet, 3 )
		
		Bullet.Parent = workspace.CurrentCamera
		
		RunService.RenderStepped:wait( )
		
		local Arrived
		
		while Cur < Dist do
			
			if not Bullet or not Bullet.Parent then return end
			
			if not Arrived and Dist - Cur <= Length then
				
				Arrived = true
				
				Core.BulletArrived:Fire( User, GunStats.BulletType, Barrel, End, Hit, Normal, Material, Offset, Humanoids )
				
			end
			
			local CurSize = math.min( Length, Dist - Cur )
			
			if CurSize <= 0 then break end
			
			Bullet.Size = Vector3.new( Size, Size, CurSize )
			
			Bullet.CFrame = CF + CF.lookVector * ( Cur + CurSize / 2 )
			
			local Delta = RunService.RenderStepped:wait( )
			
			Cur = Cur + ( Speed * Delta )
			
		end
		
		Bullet:Destroy( )
		
		--[[local Size = GunStats.BulletSize or Config.BulletSize or 0.2
		
		local Speed = GunStats.BulletSpeed or Config.BulletSpeed or 1600
		
		local Length = math.min( Speed / ( 60 + math.abs( GunStats.BulletLengthMod or Config.BulletLengthMod or 0 ) ), Speed / 60 )
		
		local CF = CFrame.new( Barrel.Position, End )
		
		local Dist = ( Barrel.Position - End ).magnitude
		
		local Bullet = Instance.new( "BoxHandleAdornment" )
		
		Bullet.Name = "GunBullet"
		
		Bullet.Adornee = workspace.Terrain
		
		Bullet.Color3 = GunStats.BulletColor or ( type( User ) == "userdata" and User:FindFirstChild( "S2Color" ) and User.S2Color.Value ~= User.TeamColor and User.S2Color.Value.Color ) or Config.BulletColor or User.TeamColor.Color
		
		Bullet.Transparency = GunStats.BulletTransparency or Config.BulletTransparency or 0.3
		
		Bullet.Size = Vector3.new( Size, Size, math.min( Length, Dist ) )
		
		Bullet.CFrame = CF + CF.lookVector * Bullet.Size.Z / 2 + CF.lookVector
		
		Debris:AddItem( Bullet, 3 )
		
		Bullet.Parent = workspace.CurrentCamera
		
		RunService.Heartbeat:Wait( )
			
		local AlmostEndDist = math.max( Dist - Length, 0 )
		
		if AlmostEndDist > 0 then
			
			local AlmostEndCF = CF + CF.lookVector * Bullet.Size.Z / 2 + CF.lookVector * AlmostEndDist
			
			local Tween = TweenService:Create( Bullet, TweenInfo.new( ( AlmostEndDist / Dist ) * ( Dist / Speed ), Enum.EasingStyle.Linear ), { CFrame = AlmostEndCF } )
			
			Tween:Play( )
			
			Tween.Completed:Wait( )
			
		end
		
		Core.BulletArrived:Fire( User, GunStats.BulletType, Barrel, End, Hit, Normal, Material, Offset, Humanoids )
		
		local Tween = TweenService:Create( Bullet, TweenInfo.new( ( ( Dist - AlmostEndDist ) / Dist ) * ( Dist / Speed ), Enum.EasingStyle.Linear ), { CFrame = CF + CF.lookVector * Dist, Size = Vector3.new( Size, Size, 0 ) } )
		
		Tween:Play( )
		
		Tween.Completed:Wait( )
		
		Bullet:Destroy( )]]
		
	end
	
end )

local CurCC

Core.Visuals.BulletImpact = Core.BulletArrived.Event:Connect( function ( User, BulletType, _, End, Hit, Normal, Material, Offset, _ )
	
	if not BulletType or BulletType.Name == "Kinectic" or BulletType.Name == "Laser" then
		
		if not Hit or not Hit.Parent then return end
		
		local BulletHit = Instance.new( "CylinderHandleAdornment" )
		
		BulletHit.Height = 0.03 + math.random( 1, 100 ) / 10000
		
		BulletHit.Radius = 0.2
		
		BulletHit.Name = "GunHit"
		
		BulletHit.Transparency = Hit.Transparency
		
		BulletHit.Adornee = Hit
		
		local Col = Hit == workspace.Terrain and workspace.Terrain:GetMaterialColor( Material ) or Hit.BrickColor
		
		BulletHit.Color3 = Color3.new( 0.1 + ( Col.r / 5 ), 0.1 + ( Col.g / 5 ), 0.1 + ( Col.b / 5 ) )
		
		local ActualOffset = Offset * Hit.Size
		
		BulletHit.CFrame = CFrame.new( ActualOffset, Hit.CFrame:pointToObjectSpace( Hit.CFrame:pointToWorldSpace( ActualOffset ) + Normal ) )
		
		local BulletHit2 = Instance.new( "CylinderHandleAdornment" )
		
		BulletHit2.Height = 0.01 + math.random( 1, 100 ) / 10000
		
		BulletHit2.Radius = 0.2
		
		BulletHit2.Name = "GunHit"
		
		BulletHit2.Transparency = Hit.Transparency + 0.6
		
		BulletHit2.Adornee = Hit
		
		BulletHit2.Color3 = Color3.new( 0.6, 0.6, 0.2 )
		
		BulletHit2.CFrame = BulletHit.CFrame
		
		local Humanoid = Core.GetValidHumanoid( Hit )
		
		if Humanoid and not CollectionService:HasTag( Humanoid, "s2_silent" ) then
			
			BulletHit.Color = BrickColor.Red( )
			
		end
		
		local Event; Event = Hit:GetPropertyChangedSignal( "Transparency" ):Connect( function ( )
			
			BulletHit.Transparency = Hit.Transparency
			
		end )
		
		local Event2; Event2 = Hit.AncestryChanged:Connect( function ( )
			
			if not Hit:IsDescendantOf( workspace ) then
				
				BulletHit.Visible = false
				
			else
				
				BulletHit.Visible = true
				
			end
			
		end )
		
		local Event3; Event3 = Hit:GetPropertyChangedSignal( "Size" ):Connect( function ( )
			
			local ActualOffset = Vector3.new( Offset.X * Hit.Size.X, Offset.Y * Hit.Size.Y, Offset.Z * Hit.Size.Z )
			
			BulletHit.CFrame = CFrame.new( ActualOffset, Hit.CFrame:pointToObjectSpace( Hit.CFrame:pointToWorldSpace( ActualOffset ) + Normal ) )
			
		end )
		
		Debris:AddItem( BulletHit, 120 )
		
		delay( 120, function ( )
			
			BulletHit:Destroy( )
			
			Event:Disconnect( )
			
			Event2:Disconnect( )
			
			Event3:Disconnect( )
			
		end )
		
		BulletHit2.Parent = workspace.CurrentCamera
		
		BulletHit.Parent = workspace.CurrentCamera
		
		for a = 1, 6 do
			
			if not BulletHit2.Parent then return end
			
			BulletHit2.Transparency = BulletHit2.Transparency + 0.067
			
			BulletHit2.Radius = BulletHit2.Radius + 0.067
			
			RunService.RenderStepped:wait( )
			
		end
		
	elseif BulletType.Name == "Explosive" then
		
		if not Hit and BulletType.ExplodeOnHit then return end
		
		local Exp = Instance.new( "Explosion" )
		
		Exp.BlastPressure = 0
		
		Exp.ExplosionType = Enum.ExplosionType.NoCraters
		
		Exp.Position = End
		
		Exp.BlastRadius = BulletType.BlastRadius
		
		Exp.Parent = workspace.CurrentCamera
		
		if Plr and Plr.Character and Plr.Character:FindFirstChild( "HumanoidRootPart" ) and ( Plr.Character.HumanoidRootPart.Position - End ).magnitude < BulletType.BlastRadius then
			
			local Dist = math.min( 1.4 - ( Plr.Character.HumanoidRootPart.Position - End ).magnitude / ( BulletType.BlastRadius + 10 ), 1 )
			
			local Snd = Instance.new( "Sound" )
			
			Snd.SoundId = "rbxassetid://405684182"
			
			Snd.Volume = 1
			
			Snd.TimePosition = 7.1 - ( 7.1 * Dist ) + 1
			
			Snd.Ended:Connect( function ( ) wait( ) Snd:Destroy( ) end )
			
			Snd.Parent = workspace.CurrentCamera
			
			Snd:Play( )
			
			local CC = workspace.CurrentCamera:FindFirstChild( "S2CC" ) or Instance.new( "ColorCorrectionEffect" )
			
			CC.Name = "S2CC"
			
			local LocalCC = tick( )
			
			CurCC = LocalCC
			
			CC.Contrast = Dist
			
			CC.Saturation = -Dist
			
			CC.Brightness = Dist
			
			CC.Enabled = true
			
			CC.Parent = workspace.CurrentCamera
			
			for i = 5 - ( 5 * Dist ), 5 do
				
				if LocalCC ~= CurCC then return end
				
				CC.Brightness = 1 - i / 8
				
				wait( )
				
			end
			
			wait( 3 )
			
			if LocalCC ~= CurCC then return end
			
			for i = 30 - ( 30 * Dist ), 30 do
				
				if LocalCC ~= CurCC then return end
				
				CC.Contrast = 1 - i / 30
				
				CC.Saturation = i / 30 - 1
				
				CC.Brightness = 0.375 - i / 80
				
				wait( )
				
			end
			
			CC.Contrast = 0
			
			CC.Saturation = 0
			
			CC.Enabled = false
			
		end
		
	end
	
end )

Core.Visuals.BulletImpactSound = Core.BulletArrived.Event:Connect( function( User, BulletType, Barrel, _, Hit, _, Material, Offset, _ )
	
	if not Hit then return end
	
	if BulletType and BulletType ~= "Kinectic" then return end
	
	local HitSound = "BulletHitConcrete"
	
	local HitPos = Hit.CFrame:pointToWorldSpace( Offset * Hit.Size )
	
	local Humanoid = Core.GetValidHumanoid( Hit )
	
	if Humanoid and not CollectionService:HasTag( Humanoid, "s2_silent" ) and Core.CheckTeamkill( User, Humanoid ) then
		
		HitSound = "BulletHitFlesh"
		
		coroutine.wrap( function ( )
			
			local BloodParticle = script.BloodParticle:Clone( )
			
			local Par1 = AtPos( CFrame.new( HitPos, Barrel.Position ) )
			
			BloodParticle.Parent = Par1
			
			wait( )
			
			BloodParticle:Emit( 10 )
			
			Debris:AddItem( Par1, 2 )
			
		end )( )
	
	elseif Material == Enum.Material.Metal or Material == Enum.Material.CorrodedMetal or Material == Enum.Material.DiamondPlate then
		
		HitSound = "BulletHitMetal"
		
		coroutine.wrap( function ( )
			
			local HitParticle = script.HitParticle:Clone( )
			
			local Col = Hit == workspace.Terrain and workspace.Terrain:GetMaterialColor( Material ) or Hit.Color
			
			Col = Color3.new( Col.r - 15 / 255, Col.g - 15 / 255, Col.b - 15 / 255 )
			
			HitParticle.Color = ColorSequence.new( Col )
			
			HitParticle.Transparency = NumberSequence.new( Hit.Transparency, Hit.Transparency )
			
			local Par1 = AtPos( CFrame.new( HitPos, Barrel.Position ) )
			
			HitParticle.Parent = Par1 
			
			wait( )
			
			HitParticle:Emit( 20 )
			
			Debris:AddItem( Par1, 2 )
			
		end )( )
		
	elseif Material == Enum.Material.Wood or Material == Enum.Material.WoodPlanks then
		
		HitSound = "BulletHitWood"
		
		coroutine.wrap( function ( )
			
			local HitParticle = script.HitParticle:Clone( )
			
			HitParticle.LightEmission = 0.1
			
			local Col = Hit == workspace.Terrain and workspace.Terrain:GetMaterialColor( Material ) or Hit.Color
			
			Col = Color3.new( Col.r - 15 / 255, Col.g - 15 / 255, Col.b - 15 / 255 )
			
			HitParticle.Color = ColorSequence.new( Col )
			
			HitParticle.Transparency = NumberSequence.new( Hit.Transparency, Hit.Transparency )
			
			local Par1 = AtPos( CFrame.new( HitPos, Barrel.Position ) )
			
			HitParticle.Parent = Par1
			
			wait( )
			
			HitParticle:Emit( 20 )
			
			Debris:AddItem( Par1, 2 )
			
		end )( )
		
	elseif Material == Enum.Material.Grass or Material == Enum.Material.Ground or Material == Enum.Material.LeafyGrass then
		
		HitSound = "BulletHitGrass"
		
		coroutine.wrap( function ( )
			
			local HitParticle = script.HitParticle:Clone( )
			
			HitParticle.LightEmission = 0.1 
			
			local Col = Hit == workspace.Terrain and workspace.Terrain:GetMaterialColor( Material ) or Hit.Color
			
			Col = Color3.new( Col.r - 15 / 255, Col.g - 15 / 255, Col.b - 15 / 255 )
			
			HitParticle.Color = ColorSequence.new( Col )
			
			HitParticle.Transparency = NumberSequence.new( 0, 0 )
			
			HitParticle.Size = NumberSequence.new( { NumberSequenceKeypoint.new( 0, 0.4, 0.2 ), NumberSequenceKeypoint.new( 0.279, 0.4, 0.0625 ), NumberSequenceKeypoint.new( 1, 0, 0 ) } )
			
			local Par1 = AtPos( CFrame.new( HitPos, Barrel.Position ) )
			
			HitParticle.Parent = Par1
			
			wait( )
			
			HitParticle:Emit( 20 )
			
			Debris:AddItem( Par1, 2 )
			
		end )( )
		
	elseif Material == Enum.Material.Glacier or Material == Enum.Material.Ice or Material == Enum.Material.Neon or Hit.Transparency > 0 then
		
		HitSound = "BulletHitGlass"
		
		coroutine.wrap( function ( )
			
			local HitParticle = script.HitParticle:Clone( )
			
			HitParticle.LightEmission = 0.1
			
			local Col = Hit == workspace.Terrain and workspace.Terrain:GetMaterialColor( Material ) or Hit.Color
			
			Col = Color3.new( Col.r - 15 / 255, Col.g - 15 / 255, Col.b - 15 / 255 )
			
			HitParticle.Color = ColorSequence.new( Col )
			
			HitParticle.Transparency = NumberSequence.new( 0.8, 0.8 )
			
			HitParticle.Size = NumberSequence.new( { NumberSequenceKeypoint.new( 0, 0.4, 0.2 ), NumberSequenceKeypoint.new( 0.279, 0.4, 0.0625 ), NumberSequenceKeypoint.new( 1, 0, 0 ) } )
			
			local Par1 = AtPos( CFrame.new( HitPos, Barrel.Position ) )
			
			HitParticle.Parent = Par1
			
			wait( )
			
			HitParticle:Emit( 20 )
			
			Debris:AddItem( Par1, 2 )
			
		end )( )
		
	end
	
	PlaySoundAtPos( CFrame.new( HitPos ), HitSound  )
	
end )
