local LocalPlayer = game:GetService( "Players" ).LocalPlayer

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )
	
local Mouse = LocalPlayer:GetMouse( )

local PrevIcon
 
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