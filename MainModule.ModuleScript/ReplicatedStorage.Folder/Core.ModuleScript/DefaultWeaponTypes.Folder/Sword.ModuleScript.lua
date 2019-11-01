local Players = game:GetService( "Players" )
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
		OnHit = function(Weapon, Part)
			if not Weapon.DamageDebounce and Core.CanAttack(Weapon) then
				local Damageable = Core.GetValidDamageable(Part)
				if Damageable and Core.CanDamage(Weapon.User, Damageable, Part, Weapon) then
					Weapon.DamageDebounce = true
					if Core.IsServer then
						coroutine.wrap(Core.HandleServerReplication)(Weapon.User, Weapon.StatObj, tick(), Part)
					else
						Core.WeaponReplication:FireServer(Weapon.StatObj, tick() + _G.ServerOffset, Part)
					end
					wait()
					Weapon.DamageDebounce = nil
				end
			end
		end,
		Setup = function(Weapon)
			for _, Part in ipairs(Weapon.DamageParts(Weapon.StatObj)) do
				Part.Touched:Connect(function(Part)
					WeaponType.OnHit(Weapon,Part)
				end)
			end
		end,
		HandleServerReplication = function(Weapon, User, Part)
			if Part then
				if typeof(Part) == "Instance" then
					--if User.Character and User.Character:FindFirstChild("HumanoidRootPart") and (User.Character.HumanoidRootPart.Position - Part.Position).magnitude < 13 then
						Weapon.Damage = Weapon[Weapon.CurDamageType or "SlashDamage"]
						local Damageable, Damage = Core.DamageHelper(User, Part, Weapon.StatObj, Weapon.DamageType and Weapon.DamageType or Core.DamageType.Slash)
						if Damageable then
							return {{Damageable, Damage}}
						end
					--[[else
						warn("Discounting sword damage as " .. User.Name .. " was too far from their target: " .. (User.Character.HumanoidRootPart.Position - Part.Position).magnitude .. " studs - " .. Part:GetFullName())
					end]]
				else
					local Part = string.byte(Part)
					WeaponType.AttackEvent:Fire(Weapon.StatObj, Weapon.User, Part)
					if Part == 0 then
						Weapon.CurDamageType = nil
					else
						Weapon.CurDamageType = "LungeDamage"
						
						wait(1)
						Weapon.CurDamageType = nil
					end
				end
			end
		end,
		Attack = function(Weapon)
			if not Weapon.AttackDebounce then
				Weapon.AttackDebounce = true
				
				if Weapon.LastAttack and Weapon.MouseDown - Weapon.LastAttack < 0.2 then
					WeaponType.AttackEvent:Fire(Weapon.StatObj, Weapon.User, 1)
					if Core.IsServer then
						coroutine.wrap(Core.HandleServerReplication)(Weapon.User, Weapon.StatObj, tick(), string.char(1))
					else
						Core.WeaponReplication:FireServer(Weapon.StatObj, tick() + _G.ServerOffset, string.char(1))
					end
					
					if Weapon.SwordFloat ~= "none" and (Core.Config.SwordFloat == "mid" or Core.Config.SwordFloat == "full") and Weapon.User.Character and Weapon.User.Character:FindFirstChild("HumanoidRootPart") then
						local FloatForce = Instance.new("BodyVelocity")
						FloatForce.Name = "SwordFloat"
						FloatForce.Velocity = Vector3.new(0, (Weapon.SwordFloat or Core.Config.SwordFloat) == "full" and 10 or 5, 0)
						FloatForce.MaxForce = Vector3.new(0, GetMass(Weapon.User.Character) * workspace.Gravity, 0)
						FloatForce.Parent = Weapon.User.Character.HumanoidRootPart
						game.Debris:AddItem(FloatForce, 0.5)
					end
					
					wait(1)
				else
					WeaponType.AttackEvent:Fire(Weapon.StatObj, Weapon.User, 0)
					if Core.IsServer then
						coroutine.wrap(Core.HandleServerReplication)(Weapon.User, Weapon.StatObj, tick(), string.char(0))
					else
						Core.WeaponReplication:FireServer(Weapon.StatObj, tick() + _G.ServerOffset, string.char(0))
					end
				end
			
				Weapon.LastAttack = Weapon.MouseDown
				Weapon.AttackDebounce = nil
			end
			Core.EndAttack(Weapon)
		end,
	}
	
	return WeaponType
end