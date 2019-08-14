local Core, Plr, CollectionService = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) ), game:GetService( "Players" ).LocalPlayer, game:GetService( "CollectionService" )

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ):WaitForChild( "ThemeUtil" ) )

local Mouse = Plr:GetMouse( )

local White = Color3.fromRGB( 255, 0, 255 )

local Last, LastC = 0, nil

Core.ShowCursor = true

local ShowMode = 0

Mouse.Move:Connect( function ( )
	
	script.Parent.Center.Position = UDim2.new( 0, Mouse.X , 0, Mouse.Y )
	
end )

local function outCubic(t, b, c, d)
  return c*(math.pow(t/d-1,3)+1)+b
end

local ShowCursor = Core.ShowCursor

ThemeUtil.AddThemeKey( "S2_CursorColor", "S2_Cursor", Color3.fromRGB( 255, 0, 255 ) )

ThemeUtil.AddThemeKey( "S2_CursorTransparency", "S2_Cursor", 0 )

ThemeUtil.AddThemeKey( "S2_CursorBorder", "S2_Cursor", ThemeUtil.BaseThemes.Light.Inverted_BackgroundColor )

ThemeUtil.AddThemeKey( "S2_CursorBorderWidth", "S2_Cursor", 1 )

ThemeUtil.AddThemeKey( "S2_CursorWidth", "S2_Cursor", 2 )

ThemeUtil.AddThemeKey( "S2_CursorHeight", "S2_Cursor", 6 )

ThemeUtil.AddThemeKey( "S2_CursorRotation", "S2_Cursor", 0 )

ThemeUtil.AddThemeKey( "S2_CursorDistFromCenter", "S2_Cursor", 3 )

ThemeUtil.AddThemeKey( "S2_CursorCenterColor", "S2_Cursor", Color3.fromRGB( 255, 0, 255 ) )

ThemeUtil.AddThemeKey( "S2_CursorCenterTransparency", "S2_Cursor", 0.3 )

ThemeUtil.AddThemeKey( "S2_CursorCenterBorder", "S2_Cursor", ThemeUtil.BaseThemes.Light.Inverted_BackgroundColor )

ThemeUtil.AddThemeKey( "S2_CursorCenterBorderWidth", "S2_Cursor", 1 )

ThemeUtil.AddThemeKey( "S2_CursorCenterBorderTransparency", "S2_Cursor", 0.3 )

ThemeUtil.AddThemeKey( "S2_CursorCenterWidth", "S2_Cursor", 2 )

ThemeUtil.AddThemeKey( "S2_CursorCenterHeight", "S2_Cursor", 2 )

ThemeUtil.AddThemeKey( "S2_CursorCenterRotation", "S2_Cursor", 0 )

ThemeUtil.AddThemeKey( "S2_CursorSwapWidthHeight", "S2_Cursor", false )

ThemeUtil.AddThemeKey( "S2_CursorDynamicMovement", "S2_Cursor", true )

ThemeUtil.AddThemeKey( "S2_CursorRotate", "S2_Cursor", true )

ThemeUtil.AddThemeKey( "S2_CursorRotateReload", "S2_Cursor", true )

ThemeUtil.AddThemeKey( "S2_CursorCenterRotateWith", "S2_Cursor", true )

ThemeUtil.FinishedCategory( "S2_Cursor" )

ThemeUtil.BindUpdate( { script.Parent.Center.Middle.Bottom, script.Parent.Center.Middle.Bottom.L1, script.Parent.Center.Middle.Bottom.L2, script.Parent.Center.Middle.Bottom.R1, script.Parent.Center.Middle.Bottom.R2, script.Parent.Center.Middle.BottomLeftDiag, script.Parent.Center.Middle.BottomRightDiag, script.Parent.Center.Middle.Bottom, script.Parent.Center.Middle.Bottom, script.Parent.Center.Middle.Bottom, script.Parent.Center.Middle.Bottom, script.Parent.Center.Middle.Left, script.Parent.Center.Middle.Right, script.Parent.Center.Middle.Top, script.Parent.Center.Middle.TopLeftDiag, script.Parent.Center.Middle.TopRightDiag }, { BorderColor3 = "S2_CursorBorder", BorderSizePixel = "S2_CursorBorderWidth" } )

function UpdateSize( )
	
	local CenterWidth, CenterHeight, Width, Height = ThemeUtil.GetThemeFor( "S2_CursorCenterWidth" ), ThemeUtil.GetThemeFor( "S2_CursorCenterHeight"), ThemeUtil.GetThemeFor( "S2_CursorWidth" ), ThemeUtil.GetThemeFor( "S2_CursorHeight" )
	
	if ThemeUtil.GetThemeFor( "S2_CursorSwapWidthHeight" ) then
		
		Width, Height = Height, Width
		
	end
	
	script.Parent.Center.Size = UDim2.new( 0, CenterWidth, 0, CenterHeight )
	
	script.Parent.Center.Middle.Bottom.Size = UDim2.new( 0, Width, 0, Height )
	
	script.Parent.Center.Middle.BottomLeftDiag.Size = UDim2.new( 0, Height, 0, Width )
	
	script.Parent.Center.Middle.BottomRightDiag.Size = UDim2.new( 0, Height, 0, Width )
	
	script.Parent.Center.Middle.Left.Size = UDim2.new( 0, Height, 0, Width )
	
	script.Parent.Center.Middle.Right.Size = UDim2.new( 0, Height, 0, Width )
	
	script.Parent.Center.Middle.Top.Size = UDim2.new( 0, Width, 0, Height )
	
	script.Parent.Center.Middle.TopLeftDiag.Size = UDim2.new( 0, Height, 0, Width )
	
	script.Parent.Center.Middle.TopRightDiag.Size = UDim2.new( 0, Height, 0, Width )
	
	script.Parent.Center.Middle.Bottom.L1.Position = UDim2.new( 0, -Width - 3, 0, 0 )
	
	script.Parent.Center.Middle.Bottom.L2.Position = UDim2.new( 0, -Width * 2 - 6, 0, 0 )
	
	script.Parent.Center.Middle.Bottom.R1.Position = UDim2.new( 0, Width + 3, 0, 0 )
	
	script.Parent.Center.Middle.Bottom.R2.Position = UDim2.new( 0, Width * 2 + 6, 0, 0 )
	
end

function UpdatePos( _, Dist )
	
	local Diag = Dist + Dist / 2
	
	script.Parent.Center.Middle.BottomLeftDiag.Position = UDim2.new( 0, -Diag, 0, Diag )
	
	script.Parent.Center.Middle.BottomRightDiag.Position = UDim2.new( 0, Diag, 0, Diag )
	
	script.Parent.Center.Middle.TopLeftDiag.Position = UDim2.new( 0, -Diag, 0, -Diag )
	
	script.Parent.Center.Middle.TopRightDiag.Position = UDim2.new( 0, Diag, 0, -Diag )
	
end

ThemeUtil.BindUpdate( script.Parent.Center, { S2_CursorCenterWidth = UpdateSize, S2_CursorCenterHeight = UpdateSize, S2_CursorWidth = UpdateSize, S2_CursorHeight = UpdateSize, S2_CursorDistFromCenter = UpdatePos, S2_CursorSwapWidthHeight = UpdateSize, BackgroundTransparency = "S2_CursorCenterTransparency" } )

ThemeUtil.BindUpdate( { script.Parent.Center.Top, script.Parent.Center.Bottom, script.Parent.Center.Left, script.Parent.Center.Right }, { BackgroundColor3 = "S2_CursorCenterBorder", BackgroundTransparency = "S2_CursorCenterBorderTransparency", S2_CursorCenterBorderWidth = function ( Obj, Width )
	
	if Obj.Name == "Bottom" or Obj.Name == "Top" then
		
		Obj.Size = UDim2.new( 1, 0, 0, Width )
		
	else
		
		Obj.Size = UDim2.new( 0, Width, 1, Width * 2 )
		
	end
	
end } )

local Kids = script.Parent.Center.Middle:GetDescendants( )

ThemeUtil.BindUpdate( Kids, { BorderColor3 = "S2_CursorBorder" } )

ThemeUtil.BindUpdate( { script.Parent.Center.Middle.Left, script.Parent.Center.Middle.Right, script.Parent.Center.Middle.Top }, { BackgroundTransparency = "S2_CursorTransparency" } )

local ForceWeapon = {
	
	Clip = 10,
	
	GunStats = {
		
		ClipSize = 10
		
	}
	
}

local LastWep

function Core.RunCursorHeartbeat( )
	
	Core.CursorHeartbeat = game:GetService( "RunService" ).Heartbeat:Connect( function ( Total, Tick )
		
		local Weapon = Core.Selected[ Plr ] and next( Core.Selected[ Plr ] ) or Core.ForceShowCursor and ForceWeapon
		
		if ShowCursor ~= Core.ShowCursor then
			
			ShowCursor = Core.ShowCursor
			
			if ShowCursor and Weapon.GunStats.ShowCursor ~= false then
				
				script.Parent.Center.Visible = true
				
				game:GetService( "UserInputService" ).MouseIconEnabled = false
				
				ShowMode = tick( ) + 1
				
			else
				
				script.Parent.Center.Visible = false
				
				game:GetService( "UserInputService" ).MouseIconEnabled = true
				
			end
			
		end
		
		if not Weapon or not Core.ShowCursor or _G.S20Config.CursorImage or Weapon.CursorImage then
			
			Core.CursorHeartbeat:Disconnect( )
			
			Core.CursorHeartbeat = nil
			
			script.Parent.Center.Visible = false
			
			if not LastWep or _G.S20Config.CursorImage or LastWep.CursorImage then return end
			
			if not LastWep.GunStats then print( LastWep, LastWep.Tool ) return end
			
			if LastWep.GunStats.ShowCursor ~= false then
				
				game:GetService( "UserInputService" ).MouseIconEnabled = true
				
			end
			
			return
			
		end
		
		LastWep = Weapon
		
		local Humanoid = Core.GetValidHumanoid( Core.LPlrsTarget[ 1 ] )
		
		local Color = ( not Humanoid or CollectionService:HasTag( Humanoid, "s2_silent" ) ) or Core.CheckTeamkill( Plr, Humanoid, Weapon.GunStats.AllowTeamKill, Weapon.GunStats.InvertTeamKill ) and ThemeUtil.GetThemeFor( "Negative_Color3" ) or ThemeUtil.GetThemeFor( "Positive_Color3" )
		
		local CenterColor
		
		if Color == true then
			
			if tick( ) - Last <= 0.25 then
				
				Color = LastC
				
			else
				
				Color = ThemeUtil.GetThemeFor( "S2_CursorColor" )
				
				CenterColor = ThemeUtil.GetThemeFor( "S2_CursorCenterColor" )
				
			end
			
		else
			
			LastC = Color
			
			Last = tick( )
			
		end
		
		script.Parent.Center.BackgroundColor3 = CenterColor or Color
		
		if ThemeUtil.GetThemeFor( "S2_CursorCenterBorder" ) == ( CenterColor or ThemeUtil.GetThemeFor( "S2_CursorColor" ) ) then
			
			script.Parent.Center.Top.BackgroundColor3 = CenterColor or Color
			
			script.Parent.Center.Bottom.BackgroundColor3 = CenterColor or Color
			
			script.Parent.Center.Left.BackgroundColor3 = CenterColor or Color
			
			script.Parent.Center.Right.BackgroundColor3 = CenterColor or Color
			
		end
		
		local FireMode = Weapon == ForceWeapon and Core.FireModes.Auto or Core.GetFireMode( Weapon )
		
		-- HANDLE COLOR AND ROTATION
		
		do local Perc = not Weapon.GunStats.ClipSize and 0 or ( Weapon.Reloading and Weapon.ReloadStart ) and math.max( 1 - ( tick( ) - Weapon.ReloadStart ) / ( Weapon.GunStats.ReloadDelay + ( Weapon.GunStats.InitialReloadDelay or 0 ) + ( Weapon.GunStats.FinalReloadDelay or 0 ) ), 0 ) or ( 1 - Weapon.Clip  / Weapon.GunStats.ClipSize )
		
		local Rot, MidRot = ThemeUtil.GetThemeFor( "S2_CursorCenterRotation" ), ThemeUtil.GetThemeFor( "S2_CursorRotation" )
		
		local RotateCenterWith, ReloadRot = ThemeUtil.GetThemeFor( "S2_CursorCenterRotateWith" ), ThemeUtil.GetThemeFor( "S2_CursorRotateReload" )
		
		script.Parent.Center.Rotation = Rot
		
		if ( not _G.S20Config.DisableCursorRotation and ThemeUtil.GetThemeFor( "S2_CursorRotate") and ( not Weapon.Reloading or ReloadRot ) ) or ( ReloadRot and Weapon.Reloading ) then
			
			if RotateCenterWith then
				
				script.Parent.Center.Rotation = Rot + Perc * 360
				
				script.Parent.Center.Middle.Rotation = MidRot - Rot
				
			else
				
				script.Parent.Center.Middle.Rotation = MidRot - Rot + Perc * 360
				
			end
			
		else
			
			script.Parent.Center.Middle.Rotation = MidRot - Rot
			
		end
		
		local AmmoCol = Color3.new( outCubic( Perc, Color.r, -0.5, 1 ), outCubic( Perc, Color.g, -0.5, 1 ), outCubic( Perc, Color.b, -0.5, 1 ) )
		
		script.Parent.Center.Middle.Bottom.BackgroundColor3 = AmmoCol
		
		script.Parent.Center.Middle.Bottom.L1.BackgroundColor3 = AmmoCol
		
		script.Parent.Center.Middle.Bottom.L2.BackgroundColor3 = AmmoCol
		
		script.Parent.Center.Middle.Bottom.R1.BackgroundColor3 = AmmoCol
		
		script.Parent.Center.Middle.Bottom.R2.BackgroundColor3 = AmmoCol end
		
		-- HANDLE WINDUP COLOUR
		
		do local PercW = 0.5 * ( Weapon.GunStats.WindupTime == 0 and 0 or ( Weapon.GunStats.WindupTime and math.min( 1 - ( Weapon.Windup or 0 ) / Weapon.GunStats.WindupTime, 1 ) or 0 ) )
		
		local ColW = Color3.new( Color.r - PercW, Color.g - PercW, Color.b - PercW )
		
		script.Parent.Center.Middle.Left.BackgroundColor3 = ColW
		
		script.Parent.Center.Middle.Right.BackgroundColor3 = ColW end
		
		-- HANDLE HEALTH COLOUR
			
		do local PercH = 0.8 * ( Plr.Character and Plr.Character:FindFirstChild( "Humanoid" ) and math.min( 1 - Plr.Character.Humanoid.Health / Plr.Character.Humanoid.MaxHealth, 1 ) or 0 )
		
		script.Parent.Center.Middle.Top.BackgroundColor3 = Color3.new( Color.r, Color.g - PercH, Color.b - PercH ) end
		
		-- HANDLE TRANSPARENCY
		
		do local NormTrans = ThemeUtil.GetThemeFor( "S2_CursorTransparency" )
		
		local Trans = math.min( math.max( 1 - ( ShowMode - tick( ) ), NormTrans ), 1 )
		
		local AutoTrans = FireMode.Automatic and Trans or 1
		
		local BurstTrans = ( FireMode.Automatic or ( FireMode.Shots and FireMode.Shots > 1 ) ) and Trans or 1
		
		script.Parent.Center.Middle.Bottom.BackgroundTransparency = ( ShowMode > tick( ) and not FireMode.PreventFire and Core.ActualSprinting ) and Trans or ( FireMode.PreventFire or Core.ActualSprinting ) and 1 or NormTrans
		
		script.Parent.Center.Middle.Bottom.L1.BackgroundTransparency = BurstTrans
		
		script.Parent.Center.Middle.Bottom.R1.BackgroundTransparency = BurstTrans
		
		script.Parent.Center.Middle.Bottom.R2.BackgroundTransparency = AutoTrans
		
		script.Parent.Center.Middle.Bottom.L2.BackgroundTransparency = AutoTrans end
		
		-- HANDLE POSITION
		
		local Dist = ThemeUtil.GetThemeFor( "S2_CursorDistFromCenter" )
		
		do script.Parent.Center.Position = UDim2.new( 0, Mouse.X, 0, Mouse.Y )
		
		local Offset = ThemeUtil.GetThemeFor( "S2_CursorDynamicMovement" ) and ( Weapon == ForceWeapon and 0 or ( 25 / Weapon.GunStats.AccurateRange * 10 ) + ( Weapon.GunStats.AccurateRange - Core.GetAccuracy( Weapon ) ) ) or 0
		
		script.Parent.Center.Middle.Bottom.Position = UDim2.new( 0, 0, 0, Offset + Dist )
		
		script.Parent.Center.Middle.Left.Position = UDim2.new( 0, -Offset - Dist, 0, 0 )
		
		script.Parent.Center.Middle.Right.Position = UDim2.new( 0, Offset + Dist, 0, 0 )
		
		script.Parent.Center.Middle.Top.Position = UDim2.new( 0, 0, 0, -Offset - Dist ) end
		
		-- HANDLE HIT VISIBILITY
		
		if Core.ResetHitMarker and tick( ) - Core.ResetHitMarker >= 0 then
			
			Core.ResetHitMarker = nil
			
			script.Parent.Center.Middle.TopLeftDiag.Visible = false
			
			script.Parent.Center.Middle.TopRightDiag.Visible = false
			
			script.Parent.Center.Middle.BottomLeftDiag.Visible = false
			
			script.Parent.Center.Middle.BottomRightDiag.Visible = false
			
		end
		
	end )
	
end

Core.FireModeChanged.Event:Connect( function ( Weapon, Value )
	
	ShowMode = tick( ) + 1
	
end )

function WeaponSelected( Mod )
	
	local Weapon = Core.GetWeapon( Mod )
	
	if not Weapon or Weapon.User ~= Plr or _G.S20Config.CursorImage or Weapon.CursorImage then return end
	
	if Weapon.GunStats.ShowCursor ~= false and Core.ShowCursor then
		
		script.Parent.Center.Visible = true
		
		game:GetService( "UserInputService" ).MouseIconEnabled = false
		
		ShowMode = tick( ) + 1
		
	end
	
	if not Core.CursorHeartbeat then
		
		Core.RunCursorHeartbeat( )
		
	end
	
end

local Weapon = Core.Selected[ Plr ] and next( Core.Selected[ Plr ] )

if Weapon then
	
	WeaponSelected( Weapon.StatObj )
	
end
 
Core.WeaponSelected.Event:Connect( WeaponSelected )

Core.Visuals.CursorHitIndicator = Core.SharedVisuals.Event:Connect( function ( _, User, _, _, _, _, _, _, _, Humanoids )
	
	if Humanoids and User == Plr then
		
		local Noise
		
		for _, Hum in ipairs( Humanoids ) do
			
			if Hum[ 1 ].Parent then
				
				if not CollectionService:HasTag( Hum[ 1 ], "s2_silent" ) then Noise = true break end
				
			end
			
		end
		
		if not Noise then
			
			Core.ResetHitMarker = tick( ) + 0.2
			
			script.Parent.Center.Middle.TopLeftDiag.Visible = true
			
			script.Parent.Center.Middle.TopRightDiag.Visible = true
			
			script.Parent.Center.Middle.BottomLeftDiag.Visible = true
			
			script.Parent.Center.Middle.BottomRightDiag.Visible = true
			
		end
		
	end
	
end )

return nil
