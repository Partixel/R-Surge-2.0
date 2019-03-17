local Core, Plr, CollectionService = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) ), game:GetService( "Players" ).LocalPlayer, game:GetService( "CollectionService" )

local Mouse = Plr:GetMouse( )

local White, Red, Green = Color3.fromRGB( 255, 0, 255 ), Color3.fromRGB( 255, 0, 0 ), Color3.fromRGB( 0, 255, 0 )

local Last, LastC = 0, nil

Core.ShowCursor = true

local ShowMode = 0

local GunCursor = script.Parent

Mouse.Move:Connect( function ( )
	
	GunCursor.Center.Position = UDim2.new( 0, Mouse.X , 0, Mouse.Y )
	
end )

local function outCubic(t, b, c, d)
  return c*(math.pow(t/d-1,3)+1)+b
end

local ShowCursor = Core.ShowCursor

local Heartbeat 

function RunHeartbeat( )
	
	Heartbeat = game:GetService( "RunService" ).Heartbeat:Connect( function ( Total, Tick )
		
		local Weapon = Core.Selected[ Plr ] and next( Core.Selected[ Plr ] )
		
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
		
		if not Weapon or not Core.ShowCursor or _G.S20Config.CursorImage or Weapon.CursorImage then
			
			Heartbeat:Disconnect( )
			
			Heartbeat = nil
			
			return
			
		end
		
		local Humanoid = Core.GetValidHumanoid( Core.LPlrsTarget[ 1 ] )
		
		local Color = ( not Humanoid or CollectionService:HasTag( Humanoid, "s2_silent" ) ) and White or Core.CheckTeamkill( Plr, Humanoid, Weapon.GunStats.AllowTeamKill, Weapon.GunStats.InvertTeamKill ) and Red or Green
		
		if Color == White then
			
			if tick( ) - Last <= 0.25 then
				
				Color = LastC
				
			end
			
		else
			
			LastC = Color
			
			Last = tick( )
			
		end
		
		GunCursor.Center.BackgroundColor3 = Color
		
		local FireMode = Core.GetFireMode( Weapon )
		
		-- HANDLE COLOR AND ROTATION
		
		do local Perc = not Weapon.GunStats.ClipSize and 0 or ( Weapon.Reloading and Weapon.ReloadStart ) and math.max( 1 - ( tick( ) - Weapon.ReloadStart ) / ( Weapon.GunStats.ReloadDelay + ( Weapon.GunStats.InitialReloadDelay or 0 ) + ( Weapon.GunStats.FinalReloadDelay or 0 ) ), 0 ) or ( 1 - Weapon.Clip  / Weapon.GunStats.ClipSize )
		
		if not _G.S20Config.DisableCursorRotation or Weapon.Reloading then
			
			GunCursor.Center.Rotation = Perc * 360
			
		end
		
		local AmmoCol = Color3.new( outCubic( Perc, Color.r, -0.5, 1 ), outCubic( Perc, Color.g, -0.5, 1 ), outCubic( Perc, Color.b, -0.5, 1 ) )
		
		GunCursor.Center.Bottom.BackgroundColor3 = AmmoCol
		
		GunCursor.Center.BottomL1.BackgroundColor3 = AmmoCol
		
		GunCursor.Center.BottomL2.BackgroundColor3 = AmmoCol
		
		GunCursor.Center.BottomR1.BackgroundColor3 = AmmoCol
		
		GunCursor.Center.BottomR2.BackgroundColor3 = AmmoCol end
		
		-- HANDLE WINDUP COLOUR
		
		do local PercW = 0.5 * ( Weapon.GunStats.WindupTime == 0 and 0 or ( Weapon.GunStats.WindupTime and math.min( 1 - ( Weapon.Windup or 0 ) / Weapon.GunStats.WindupTime, 1 ) or 0 ) )
		
		local ColW = Color3.new( Color.r - PercW, Color.g - PercW, Color.b - PercW )
		
		GunCursor.Center.Left.BackgroundColor3 = ColW
		
		GunCursor.Center.Right.BackgroundColor3 = ColW end
		
		-- HANDLE HEALTH COLOUR
			
		do local PercH = 0.8 * ( Plr.Character and Plr.Character:FindFirstChild( "Humanoid" ) and math.min( 1 - Plr.Character.Humanoid.Health / Plr.Character.Humanoid.MaxHealth, 1 ) or 0 )
		
		GunCursor.Center.Top.BackgroundColor3 = Color3.new( Color.r, Color.g - PercH, Color.b - PercH ) end
		
		-- HANDLE TRANSPARENCY
		
		do local Trans = math.min( math.max( 1 - ( ShowMode - tick( ) ), 0 ), 1 )
		
		local AutoTrans = FireMode.Automatic and Trans or 1
		
		local BurstTrans = ( FireMode.Automatic or ( FireMode.Shots and FireMode.Shots > 1 ) ) and Trans or 1
		
		GunCursor.Center.Bottom.BackgroundTransparency = ( ShowMode > tick( ) and not FireMode.PreventFire and Core.ActualSprinting ) and Trans or ( FireMode.PreventFire or Core.ActualSprinting ) and 1 or 0
		
		GunCursor.Center.BottomL1.BackgroundTransparency = BurstTrans
		
		GunCursor.Center.BottomR1.BackgroundTransparency = BurstTrans
		
		GunCursor.Center.BottomR2.BackgroundTransparency = AutoTrans
		
		GunCursor.Center.BottomL2.BackgroundTransparency = AutoTrans end
		
		-- HANDLE POSITION
		
		do GunCursor.Center.Position = UDim2.new( 0, Mouse.X, 0, Mouse.Y )
		
		local Offset = ( 25 / Weapon.GunStats.AccurateRange * 10 ) + ( Weapon.GunStats.AccurateRange - Core.GetAccuracy( Weapon ) )
		
		GunCursor.Center.Bottom.Position = UDim2.new( 0, 0, 0, Offset + 5 )
		
		GunCursor.Center.BottomL1.Position = UDim2.new( 0, -5, 0, Offset + 5 )
		
		GunCursor.Center.BottomL2.Position = UDim2.new( 0, -10, 0, Offset + 5 )
		
		GunCursor.Center.BottomR1.Position = UDim2.new( 0, 5, 0, Offset + 5 )
		
		GunCursor.Center.BottomR2.Position = UDim2.new( 0, 10, 0, Offset + 5 )
		
		GunCursor.Center.Top.Position = UDim2.new( 0, 0, 0, -Offset - 8 )
		
		GunCursor.Center.Left.Position = UDim2.new( 0, -Offset - 8, 0, 0 )
		
		GunCursor.Center.Right.Position = UDim2.new( 0, Offset + 5, 0, 0 ) end
		
		-- HANDLE HIT VISIBILITY
		
		if Core.ResetHitMarker and tick( ) - Core.ResetHitMarker >= 0 then
			
			Core.ResetHitMarker = nil
			
			GunCursor.Center.TopDiag.Visible = false
			
			GunCursor.Center.LeftDiag.Visible = false
			
			GunCursor.Center.BottomDiag.Visible = false
			
			GunCursor.Center.RightDiag.Visible = false
			
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
		
		GunCursor.Center.Visible = true
		
		GunCursor.Center.BackgroundTransparency = _G.S20Config.ShowCursorDot ~= false and 0.3 or 1
		
		game:GetService( "UserInputService" ).MouseIconEnabled = false
		
		ShowMode = tick( ) + 1
		
	end
	
	if not Heartbeat then
		
		RunHeartbeat( )
		
	end
	
end

local Weapon = Core.Selected[ Plr ] and next( Core.Selected[ Plr ] )

if Weapon then
	
	WeaponSelected( Weapon.StatObj )
	
end
 
Core.WeaponSelected.Event:Connect( WeaponSelected )
 
Core.WeaponDeselected.Event:Connect( function ( Mod )
	
	local Weapon = Core.GetWeapon( Mod )
	
	if not Weapon or Weapon.User ~= Plr or _G.S20Config.CursorImage or Weapon.CursorImage then return end
	
	GunCursor.Center.Visible = false
	
	if Weapon.GunStats.ShowCursor ~= false then
		
		game:GetService( "UserInputService" ).MouseIconEnabled = true
		
	end
	
end )

return nil
