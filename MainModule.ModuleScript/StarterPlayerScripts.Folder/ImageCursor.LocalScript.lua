local LocalPlayer = game:GetService( "Players" ).LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )
	
local Mouse = LocalPlayer:GetMouse( )

local PrevIcon

Core.CursorImageChanged = function()
	local Weapon = Core.Selected[LocalPlayer] and next(Core.Selected[LocalPlayer])
	
	if not Weapon then return end
	
	if Weapon.GunStats.ShowCursor ~= false and Core.ShowCursor then
		if Core.Config.CursorImage or Weapon.CursorImage then
			PrevIcon = Mouse.Icon
			Mouse.Icon = Weapon.CursorImage or Core.Config.CursorImage
		else
			Mouse.Icon = PrevIcon
			PlayerGui.S2.GunCursor.Center.Visible = true
			game:GetService("UserInputService").MouseIconEnabled = false
			
			if not Core.CursorHeartbeat then
				Core.RunCursorHeartbeat()
			end
		end
	end
end
 
Core.WeaponSelected.Event:Connect( function ( Mod )
	
	local Weapon = Core.GetWeapon( Mod )
	
	if not Weapon or Weapon.User ~= LocalPlayer then return end
	
	if Weapon.GunStats.ShowCursor ~= false and Core.ShowCursor and ( Core.Config.CursorImage or Weapon.CursorImage ) then
		
		PrevIcon = Mouse.Icon
		
		Mouse.Icon = Weapon.CursorImage or Core.Config.CursorImage
		
	end
	
end )
 
Core.WeaponDeselected.Event:Connect( function ( Mod )
	
	local Weapon = Core.GetWeapon( Mod )
	
	if not Weapon or Weapon.User ~= LocalPlayer then return end
	
	if Weapon.GunStats.ShowCursor ~= false and Core.ShowCursor and ( Core.Config.CursorImage or Weapon.CursorImage ) then
		
		Mouse.Icon = PrevIcon
		
		PrevIcon = nil
		
	end
	
end )