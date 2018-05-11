local Core, Plr = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) ), game:GetService( "Players" ).LocalPlayer

local Mouse = Plr:GetMouse( )

local C3new, U2new = Color3.new, UDim2.new

local White, Red, Green = C3new( 1, 1, 1 ), BrickColor.Red( ).Color, BrickColor.Green( ).Color

local min, max, pow = math.min, math.max, math.pow

local Last, LastC = 0, nil

Core.ShowCursor = true

local ShowMode = 0

local GunCursor = script.Parent

Mouse.Move:Connect( function ( )
	
	GunCursor.Center.Position = U2new( 0, Mouse.X - 2, 0, Mouse.Y - 2 )
	
end )

local function outCubic(t, b, c, d)
  return c*(pow(t/d-1,3)+1)+b
end

local ShowCursor = Core.ShowCursor

game:GetService( "RunService" ).Heartbeat:Connect( function ( Total, Tick )
	
	local Weapon = Core.GetSelectedWeapon( Plr )
	
	if ShowCursor ~= Core.ShowCursor then
		
		ShowCursor = Core.ShowCursor
		
		if ShowCursor and Weapon.GunStats.ShowCursor ~= false then
			
			GunCursor.Center.Visible = true
			
			game:GetService( "UserInputService" ).MouseIconEnabled = false
			
			ShowMode = tick( ) + 1
			
		else
			
			GunCursor.Center.Visible = false
			
			game:GetService( "UserInputService" ).MouseIconEnabled = true
			
		end
		
	end
	
	if not Weapon or not Core.ShowCursor then
		
		return
		
	end
	
	local Humanoid = Core.GetValidHumanoid( Core.LPlrsTarget[ 1 ] )
	
	local Color = ( not Humanoid or Humanoid:FindFirstChild( "Silent" ) ) and White or Core.CheckTeamkill( Plr, Humanoid, Weapon.GunStats.AllowTeamKill, Weapon.GunStats.InvertTeamKill ) and Red or Green
	
	if Color == White then
		
		if tick( ) - Last <= 0.25 then
			
			Color = LastC
			
		end
		
	else
		
		LastC = Color
		
		Last = tick( )
		
	end
	
	local FireMode = Core.GetFireMode( Weapon )
	
	-- HANDLE COLOR AND ROTATION
	
	do local Perc = not Weapon.GunStats.ClipSize and 0 or ( Weapon.Reloading and Weapon.ReloadStart ) and math.max( 1 - ( tick( ) - Weapon.ReloadStart ) / ( Weapon.GunStats.ReloadDelay + ( Weapon.GunStats.InitialReloadDelay or 0 ) + ( Weapon.GunStats.FinalReloadDelay or 0 ) ), 0 ) or ( 1 - Weapon.Clip  / Weapon.GunStats.ClipSize )
	
	if not _G.S20Config.DisableCursorRotation or Weapon.Reloading then
		
		GunCursor.Center.Rotation = Perc * 360
		
	end
	
	if FireMode.CanFire == false then Perc = 1 end
	
	local AmmoCol = C3new( outCubic( Perc, Color.r, -0.5, 1 ), outCubic( Perc, Color.g, -0.5, 1 ), outCubic( Perc, Color.b, -0.5, 1 ) )
	
	GunCursor.Center.Bottom.BackgroundColor3 = AmmoCol
	
	GunCursor.Center.BottomL1.BackgroundColor3 = AmmoCol
	
	GunCursor.Center.BottomL2.BackgroundColor3 = AmmoCol
	
	GunCursor.Center.BottomR1.BackgroundColor3 = AmmoCol
	
	GunCursor.Center.BottomR2.BackgroundColor3 = AmmoCol end
	
	-- HANDLE WINDUP COLOUR
	
	do local PercW = 0.5 * ( Weapon.GunStats.WindupTime and min( 1 - ( Weapon.Windup or 0 ) / Weapon.GunStats.WindupTime, 1 ) or 0 )
	
	local ColW = C3new( Color.r - PercW, Color.g - PercW, Color.b - PercW )
	
	GunCursor.Center.Left.BackgroundColor3 = ColW
	
	GunCursor.Center.Right.BackgroundColor3 = ColW end
	
	-- HANDLE HEALTH COLOUR
		
	do local PercH = 0.8 * ( Plr.Character and Plr.Character:FindFirstChild( "Humanoid" ) and min( 1 - Plr.Character.Humanoid.Health / Plr.Character.Humanoid.MaxHealth, 1 ) or 0 )
	
	GunCursor.Center.Top.BackgroundColor3 = C3new( Color.r, Color.g - PercH, Color.b - PercH ) end
	
	-- HANDLE TRANSPARENCY
	
	do local Trans = min( max( 1 - ( ShowMode - tick( ) ), 0.2 ), 1 )
	
	local AutoTrans = FireMode.Automatic and Trans or 1
	
	local BurstTrans = ( FireMode.Automatic or ( FireMode.Shots and FireMode.Shots > 1 ) ) and Trans or 1
	
	GunCursor.Center.Bottom.BackgroundTransparency = ( ShowMode > tick( ) and FireMode.CanFire ~= false and Core.ActualSprinting ) and Trans or ( FireMode.CanFire == false or Core.ActualSprinting ) and 1 or 0.2
	
	GunCursor.Center.BottomL1.BackgroundTransparency = BurstTrans
	
	GunCursor.Center.BottomR1.BackgroundTransparency = BurstTrans
	
	GunCursor.Center.BottomR2.BackgroundTransparency = AutoTrans
	
	GunCursor.Center.BottomL2.BackgroundTransparency = AutoTrans end
	
	-- HANDLE POSITION
	
	do GunCursor.Center.Position = U2new( 0, Mouse.X - 2, 0, Mouse.Y - 2 )
	
	local Offset = ( 25 / Weapon.GunStats.AccurateRange * 10 ) + ( Weapon.GunStats.AccurateRange - Core.GetAccuracy( Weapon ) )
	
	GunCursor.Center.Bottom.Position = U2new( 0, 0, 0, Offset + 5 )
	
	GunCursor.Center.BottomL1.Position = U2new( 0, -5, 0, Offset + 5 )
	
	GunCursor.Center.BottomL2.Position = U2new( 0, -10, 0, Offset + 5 )
	
	GunCursor.Center.BottomR1.Position = U2new( 0, 5, 0, Offset + 5 )
	
	GunCursor.Center.BottomR2.Position = U2new( 0, 10, 0, Offset + 5 )
	
	GunCursor.Center.Top.Position = U2new( 0, 0, 0, -Offset - 8 )
	
	GunCursor.Center.Left.Position = U2new( 0, -Offset - 8, 0, 0 )
	
	GunCursor.Center.Right.Position = U2new( 0, Offset + 5, 0, 0 ) end
	
	-- HANDLE HIT VISIBILITY
	
	if Core.ResetHitMarker and tick( ) - Core.ResetHitMarker >= 0 then
		
		Core.ResetHitMarker = nil
		
		GunCursor.Center.TopDiag.Visible = false
		
		GunCursor.Center.LeftDiag.Visible = false
		
		GunCursor.Center.BottomDiag.Visible = false
		
		GunCursor.Center.RightDiag.Visible = false
		
	end
	
end )

Core.FireModeChanged.Event:Connect( function ( Weapon, Value )
	
	ShowMode = tick( ) + 1
	
end )

if Core.GetSelectedWeapon( Plr ) and Core.GetSelectedWeapon( Plr ).ShowCursor ~= false and Core.ShowCursor then
	
	GunCursor.Center.Visible = true
	
	game:GetService( "UserInputService" ).MouseIconEnabled = false
	
	ShowMode = tick( ) + 1
	
end
 
Core.WeaponSelected.Event:Connect( function ( Mod )
	
	local Weapon = Core.GetWeapon( Mod )
	
	if not Weapon or Weapon.User ~= Plr then return end
	
	if Weapon.GunStats.ShowCursor ~= false and Core.ShowCursor then
		
		GunCursor.Center.Visible = true
		
		GunCursor.Center.BackgroundTransparency = _G.S20Config.ShowCursorDot ~= true and 1 or 0
		
		game:GetService( "UserInputService" ).MouseIconEnabled = false
		
		ShowMode = tick( ) + 1
		
	end
	
end )
 
Core.WeaponDeselected.Event:Connect( function ( Mod )
	
	local Weapon = Core.GetWeapon( Mod )
	
	if not Weapon or Weapon.User ~= Plr then return end
	
	GunCursor.Center.Visible = false
	
	if Weapon.GunStats.ShowCursor ~= false then
		
		game:GetService( "UserInputService" ).MouseIconEnabled = true
		
	end
	
end )

return nil
