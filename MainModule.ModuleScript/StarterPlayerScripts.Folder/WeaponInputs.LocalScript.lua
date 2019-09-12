local LocalPlayer = game:GetService( "Players" ).LocalPlayer

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local KBU = require( game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "KeybindUtil" ) )

KBU.AddBind{ Name = "Fire", Category = "Surge 2.0", Callback = function ( Began )
	
	local Weapons = Core.Selected[ LocalPlayer ]
	
	if Weapons then
		
		for a, _ in pairs( Weapons ) do
			
			if not a.GunStats.ManualFire then
				
				if Began then
					
					Core.SetMouseDown( a )
					
				else
					
					a.MouseDown = nil
					
					Core.FiringEnded:Fire( a.StatObj )
					
					a.ModeShots = 0
					
				end
				
			end
			
		end
		
	end

end, Key = Enum.UserInputType.MouseButton1, PadKey = Enum.KeyCode.ButtonR2, NoHandled = true }

KBU.AddBind{ Name = "Reload", Category = "Surge 2.0", Callback = function ( Began )

	if not Began then return end
	
	local Weapons = Core.Selected[ LocalPlayer ]
	
	if Weapons then
		
		for a, _ in pairs( Weapons ) do
			
			if not a.GunStats.AllowManualReload then
				
				Core.Reload( a )
				
			end
			
		end
		
	end

end, Key = Enum.KeyCode.R, PadKey = Enum.KeyCode.ButtonB, NoHandled = true }

KBU.AddBind{ Name = "Next_fire_mode", Category = "Surge 2.0", Callback = function ( Began )

	if not Began then return end
	
	local Weapons = Core.Selected[ LocalPlayer ]
	
	if Weapons then
		
		for a, _ in pairs( Weapons ) do
			
			Core.SetFireMode( a, a.CurFireMode + 1 > #a.GunStats.FireModes and 1 or a.CurFireMode + 1 )
			
		end
		
	end

end, Key = Enum.UserInputType.MouseButton3, PadKey = Enum.KeyCode.ButtonY, NoHandled = true }