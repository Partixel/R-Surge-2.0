return function(Core)
	local WeaponType WeaponType = {
		WeaponModes = {
			Drop = {Drop = true},
		},
		Attack = function(Weapon)
			if Weapon.LastClick and Weapon.LastClick >= tick( ) then return false end
			
			Weapon.LastClick = (Weapon.LastClick or tick()) + 1 / Weapon.ThrowRate
			
			local Handle = Weapon.StatObj.Parent:FindFirstChild("Handle")
			if Handle then
				local Throwable = Weapon.Throwable:Clone()
				Throwable:SetPrimaryPartCFrame(Handle.CFrame)
				Throwable.Parent = workspace
				
				WeaponType.AttackEvent:Fire( Weapon.StatObj, Weapon.User, Throwable )
				
				if Weapon.ExplosionDelay then
					Core.HeartbeatWait(Weapon.ExplosionDelay)
				end
				
				if Throwable.Parent then
					Core.DoExplosion(Weapon.User, Weapon.StatObj, Throwable.PrimaryPart.Position, setmetatable({Parent = workspace, Visible = true, ExplosionType = Enum.ExplosionType.NoCraters}, {__index = Weapon.ExplosionSettings}))
				end
				
				Throwable:Destroy()
			end
			
			Core.EndAttack(Weapon)
		end,
	}
	
	return WeaponType
end