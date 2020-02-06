local LocalPlayer = game:GetService( "Players" ).LocalPlayer

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local KBU = require( game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "KeybindUtil" ) )

KBU.AddBind{ Name = "Fire", Category = "Surge 2.0", Callback = function (Began)
	local Weapons = Core.Selected[ LocalPlayer ]
	if Weapons then
		for a, _ in pairs( Weapons ) do
			if not a.ManualFire then
				(Began and Core.SetMouseDown or Core.SetMouseUp)(a)
			end
		end
	end
end, Key = Enum.UserInputType.MouseButton1, PadKey = Enum.KeyCode.ButtonR2, NoHandled = true}

KBU.AddBind{Name = "Reload", Category = "Surge 2.0", Callback = function(Held, Died)
	local Weapons = Core.Selected[LocalPlayer]
	if Weapons then
		for a, _ in pairs(Weapons) do
			if not a.PreventManualReload then
				Core[Held and "EmptyAmmo" or "Reload"](a)
			end
		end
	end
end, Key = Enum.KeyCode.R, PadKey = Enum.KeyCode.ButtonB, NoHandled = true, HoldFor = 0.5}

KBU.AddBind{Name = "Next_weapon_mode", Category = "Surge 2.0", Callback = function (Began)
	if Began then
		local Weapons = Core.Selected[ LocalPlayer ]
		if Weapons then
			for a, _ in pairs(Weapons) do
				if a.WeaponModes then
					Core.SetWeaponMode(a, a.CurWeaponMode + 1 > #a.WeaponModes and 1 or a.CurWeaponMode + 1)
				end
			end
		end
	end
end, Key = Enum.UserInputType.MouseButton3, PadKey = Enum.KeyCode.ButtonY, NoHandled = true}