local function GetMass(Parent)
	local Total = 0
	for _, Obj in ipairs(Parent:GetChildren()) do
		if Obj:IsA( "BasePart" ) then
			Total = Total + Obj:GetMass()
		end
		
		Total = Total + GetMass(Obj)		
	end
	return Total
end

return function(Core)
	local WeaponType WeaponType = {
		WeaponModes = {
			Slash = {},
			Safety = {PreventAttack = true},
		},
		OnHit = function(Weapon, Part, PartIndex)
			if (not Weapon.DamageCooldown or tick() >= Weapon.DamageCooldown) and Core.CanAttack(Weapon) then
				local Damageable = Core.GetValidDamageable(Part)
				if Damageable and Core.CanDamage(Weapon.User, Damageable, Part, Weapon) then
					Weapon.DamageCooldown = tick() + 1/30
					coroutine.wrap(Core.HandleServerReplication)(Weapon.User, Weapon.StatObj, tick(), Part, PartIndex)
				end
			end
		end,
		Setup = function(Weapon)
			local Parts = Weapon.DamageParts(Weapon.StatObj)
			if type(Parts) == "table" then
				for i, Part in ipairs(Weapon.DamageParts(Weapon.StatObj)) do
					Part.Touched:Connect(function(Part)
						WeaponType.OnHit(Weapon, Part, i)
					end)
				end
			else
				Parts.Touched:Connect(function(Part)
					WeaponType.OnHit(Weapon, Part)
				end)
			end
		end,
		ShouldCancelHold = function(Weapon, Time, Part)
			return typeof(Part) ~= "Instance"
		end,
		Attack = function(Weapon)
			if not Weapon.AttackCooldown or tick() >= Weapon.AttackCooldown then
				if Weapon.LastAttack and Weapon.MouseDown - Weapon.LastAttack < 0.2 then
					WeaponType.AttackEvent:Fire(Weapon.StatObj, Weapon.User, 1)
					coroutine.wrap(Core.HandleServerReplication)(Weapon.User, Weapon.StatObj, tick(), string.char(1))
					
					if Weapon.SwordFloat ~= "none" and (Core.Config.SwordFloat == "mid" or Core.Config.SwordFloat == "full") and Weapon.User.Character and Weapon.User.Character:FindFirstChild("HumanoidRootPart") then
						local FloatForce = Instance.new("BodyVelocity")
						FloatForce.Name = "SwordFloat"
						FloatForce.Velocity = Vector3.new(0, (Weapon.SwordFloat or Core.Config.SwordFloat) == "full" and 10 or 5, 0)
						FloatForce.MaxForce = Vector3.new(0, GetMass(Weapon.User.Character) * workspace.Gravity, 0)
						FloatForce.Parent = Weapon.User.Character.HumanoidRootPart
						game.Debris:AddItem(FloatForce, 0.5)
					end
					
					Weapon.AttackCooldown = tick() + 1
				else
					WeaponType.AttackEvent:Fire(Weapon.StatObj, Weapon.User, 0)
					coroutine.wrap(Core.HandleServerReplication)(Weapon.User, Weapon.StatObj, tick(), string.char(0))
				end
			
				Weapon.LastAttack = Weapon.MouseDown
			end
			Core.EndAttack(Weapon)
		end,
	}
	
	return WeaponType
end