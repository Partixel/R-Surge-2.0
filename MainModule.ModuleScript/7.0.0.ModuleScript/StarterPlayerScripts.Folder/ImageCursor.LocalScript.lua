local LocalPlayer = game:GetService("Players").LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))

local PrevIcon
Core.CursorImageChanged = function()
	local Weapon = Core.Selected[LocalPlayer] and next(Core.Selected[LocalPlayer])
	if not Weapon then return end
	if Weapon.ShowCursor ~= false and Core.ShowCursor ~= false then
		if Weapon.CursorImage then
			PrevIcon = Mouse.Icon
			Mouse.Icon = Weapon.CursorImage
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

Core.WeaponSelected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon.User == LocalPlayer and Weapon.ShowCursor ~= false and Core.ShowCursor ~= false and Weapon.CursorImage then
		PrevIcon = Mouse.Icon
		Mouse.Icon = Weapon.CursorImage
	end
end)

Core.WeaponDeselected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon.User == LocalPlayer and Weapon.ShowCursor ~= false and Core.ShowCursor ~= false and Weapon.CursorImage then
		Mouse.Icon = PrevIcon or ""
		PrevIcon = nil
	end
end)