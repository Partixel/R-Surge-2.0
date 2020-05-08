local LocalPlayer = game:GetService("Players").LocalPlayer

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local KBU = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("KeybindUtil"))

local LastType, UserInput
local FireBind = KBU.AddBind{Name = "Fire", Category = "Surge 2.0", Callback = function(Began, Handled, _, Input)
	if not Began or not Handled then
		UserInput = Input
		local Weapons = Core.Selected[ LocalPlayer ]
		if Weapons then
			for a, _ in pairs( Weapons ) do
				if not a.ManualFire then
					(Began and Core.SetMouseDown or Core.SetMouseUp)(a)
				end
			end
		end
	end
end, Key = Enum.UserInputType.MouseButton1, PadKey = Enum.KeyCode.ButtonR2}

local Mouse = LocalPlayer:GetMouse()
function Core.GetLPlrsInputPos()
	if UserInput.UserInputType == Enum.UserInputType.Touch then
		return UserInput.Position.X, UserInput.Position.Y
	elseif LastType ~= Enum.UserInputType.Touch then
		return Mouse.X, Mouse.Y
	end
end

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

KBU.AddBind{Name = "Next_weapon_mode", Category = "Surge 2.0", Callback = function(Began)
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