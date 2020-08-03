local Players = game:GetService("Players")

return function(Core)
	return {
		HandleServerReplication = function(Weapon, Time, Part, PartIndex)
			if Part then
				if typeof(Part) == "Instance" then
					if Weapon.Placeholder then
						if Weapon.ServerLastAttack and (Time + 0.001) < (Weapon.ServerLastAttack + 1/30) then
							return "Tried to do damage too quickly - " .. (math.floor((1 - (Time - Weapon.ServerLastAttack) / (1/30)) * 10000 + 0.5) / 100) .. "% sooner than it should have been"
						end
						
						if Weapon.User.Character and Weapon.User.Character:FindFirstChild("HumanoidRootPart") and (Weapon.User.Character.HumanoidRootPart.Position - Part.Position).magnitude >= 14.5 then
							return "Too far from their target - " .. (Weapon.User.Character.HumanoidRootPart.Position - Part.Position).magnitude .. " studs - " .. Part:GetFullName()
						end
						
						Weapon.ServerLastAttack = Time
					end
					
					if Weapon.LungeEnd and Time <= Weapon.LungeEnd then
						Weapon.Damage = Weapon["LungeDamage"]
					else
						Weapon.Damage = Weapon["SlashDamage"]
					end
					
					local Parts = Weapon.DamageParts(Weapon.StatObj)
					if type(Parts) == "table" then
						Parts = Parts[PartIndex or 1]
					end
					
					Core.DamageHelper(Weapon.User, Weapon.StatObj, Weapon.DamageType and Weapon.DamageType or Core.DamageType.Slash, Part, nil, {StartPosition = Parts.Position, RelativeEndPosition = Core.ClosestPoint(Part, Parts.Position)})
				else
					local Type = string.byte(Part)
					
					Weapon.WeaponType.AttackEvent:Fire(Weapon.StatObj, Weapon.User, Type)
					
					for _, OPlr in pairs(Players:GetPlayers()) do
						if OPlr ~= Weapon.User then
							Core.WeaponReplication:FireClient(OPlr, Weapon.User, Weapon.StatObj, Part)
						end
					end
					
					if Type == 1 then
						if Weapon.Placeholder and Weapon.LastLunge and (Time + 0.001) < (Weapon.LastLunge + 1) then
							return "Tried to do damage too quickly - " .. (math.floor((1 - (Time - Weapon.ServerLastAttack) / (1/30)) * 10000 + 0.5) / 100) .. "% sooner than it should have been"
						end
						
						Weapon.LungeEnd = Time + 1
					end
				end
			end
		end,
	}
end