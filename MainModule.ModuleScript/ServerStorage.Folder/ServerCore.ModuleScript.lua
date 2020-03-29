local Players, CollectionService = game:GetService("Players"), game:GetService("CollectionService")

return function(Core, script)
	
	----[[WEAPONS]]----
	function Core.HandleHoldReplication(User, StatObj, Time)
		if StatObj and StatObj.Parent then
			local Weapon = Core.GetWeapon(StatObj)
			if Weapon then
				if Weapon.Placeholder then
					if Time and tick() - Time > 0.6 then
						warn(User.Name .. " sent an invalid server S2 hold replication request " .. (tick() - Time) .. " seconds ago: Took too long to send replication packet, discarding! "  .. (tick() - Time - 0.6) .. "\n", User, StatObj, Time, tick())
						return
					elseif StatObj.Parent.Parent ~= User.Character then
						warn(User.Name .. " sent an invalid server S2 hold replication request " .. (tick() - Time) .. " seconds ago: Weapon is not selected " .. StatObj:GetFullName() .. "\n", User, StatObj, Time)
						return
					end
				end
				Weapon.HoldStart = Time
			else
				warn(User.Name .. " sent an invalid server S2 hold replication request " .. (tick() - Time) .. " seconds ago: Weapon doesn't exist\n", User, StatObj, Time)
			end
		else
			warn(User.Name .. " sent an invalid server S2 hold replication request " .. (tick() - Time) .. " seconds ago: StatObj doesn't exist\n", User, StatObj, Time)
		end
	end
	
	Core.HoldReplication = Instance.new("RemoteEvent")
	Core.HoldReplication.Name = "HoldReplication"
	Core.HoldReplication.OnServerEvent:Connect(Core.HandleHoldReplication)
	Core.HoldReplication.Parent = script
	
	function Core.HandleWindupReplication(User, StatObj, Time, State)
		if StatObj and StatObj.Parent then
			local Weapon = Core.GetWeapon(StatObj)
			if Weapon then
				if Weapon.Placeholder then
					if Time and tick() - Time > 0.6 then
						warn(User.Name .. " sent an invalid server S2 hold replication request " .. (tick() - Time) .. " seconds ago: Took too long to send replication packet, discarding! "  .. (tick() - Time - 0.6) .. "\n", User, StatObj, Time, tick())
						return
					elseif StatObj.Parent.Parent ~= User.Character then
						warn(User.Name .. " sent an invalid server S2 hold replication request " .. (tick() - Time) .. " seconds ago: Weapon is not selected " .. StatObj:GetFullName() .. "\n", User, StatObj, Time)
						return
					end
				end
				for _, Plr in ipairs(Players:GetPlayers()) do
					if Plr ~= User then
						Core.WindupReplication:FireClient(Plr, User, StatObj, Time, State)
					end
				end
			else
				warn(User.Name .. " sent an invalid server S2 hold replication request " .. (tick() - Time) .. " seconds ago: Weapon doesn't exist\n", User, StatObj, Time)
			end
		else
			warn(User.Name .. " sent an invalid server S2 hold replication reques " .. (tick() - Time) .. " seconds agot: StatObj doesn't exist\n", User, StatObj, Time)
		end
	end
	
	Core.WindupReplication = Instance.new("RemoteEvent")
	Core.WindupReplication.Name = "WindupReplication"
	Core.WindupReplication.OnServerEvent:Connect(Core.HandleWindupReplication)
	Core.WindupReplication.Parent = script
	
	Core.ReplicateWeaponMode = Instance.new("RemoteEvent")
	Core.ReplicateWeaponMode.Name = "ReplicateWeaponMode"
	Core.ReplicateWeaponMode.OnServerEvent:Connect(function(User, StatObj, Mode)
		if StatObj and StatObj.Parent then
			local Weapon = Core.GetWeapon(StatObj)
			if Weapon then
				Core.SetWeaponMode(Core.GetWeapon(StatObj), Mode)
			else
				warn(User.Name .. " sent an invalid server S2 hold replication request: Weapon doesn't exist\n", User, StatObj, Mode)
			end
		else
			warn(User.Name .. " sent an invalid server S2 hold replication request: StatObj doesn't exist\n", User, StatObj, Mode)
		end
		
	end)
	Core.ReplicateWeaponMode.Parent = script
	
	----[[DAMAGE]]----
	local ClientDamage = Instance.new("RemoteEvent")
	ClientDamage.Name = "ClientDamage"
	--[[ClientDamage.OnServerEvent:Connect(function(Attacker, Time, Hit, WeaponStat, DamageType, Distance)
		if tick() - Time > 1 then
			warn(Attacker.Name .. " took too long to send shot packet, discarding! - " .. (tick() - Time))
		else
			Core.DamageHelper(Attacker, Hit, WeaponStat, DamageType, Distance)
		end
	end)]]
	ClientDamage.Parent = script
	
	local function CalculateResistances(Attacker, WeaponStat, DamageType, Resistances, Instances)
		local Resistance = 1
		if Instances then
			for _, ResistanceObj in ipairs(Resistances) do
				if ResistanceObj.Name == WeaponStat.Value or ResistanceObj.Name == DamageType or ResistanceObj.Name == "All" then
					Resistance = Resistance * ResistanceObj.Value
				elseif (ResistanceObj.Name == "Neutral" and Attacker.Neutral) or (ResistanceObj.Name == "Team" and ResistanceObj.Value == Attacker.Team) or (ResistanceObj.Name == "Player" and ResistanceObj.Value == Attacker) then
					Resistance = Resistance * CalculateResistances(WeaponStat, DamageType, ResistanceObj:GetChildren(), Instances, true)
				end
			end
		else
			for Key, Value in pairs(Resistances) do
				if Key == WeaponStat.Value or Key == DamageType or Key == "All" then
					Resistance = Resistance * Value
				elseif (Key == "Neutral" and Attacker.Neutral) or Key == Attacker.Team or Key == Attacker then
					Resistance = Resistance * CalculateResistances(WeaponStat, DamageType, Value, Instances, true)
				end
			end
		end
		return Resistance
	end
	
	--Attacker, Hit, WeaponStat, DamageType, Distance, DamageSplits{Damageable, Damage}
	Core.ObjDamaged = Instance.new("BindableEvent")
	Core.DamageInfos = setmetatable({}, {__mode = "k"})
	function Core.ApplyDamage(Attacker, Damageable, Hit, WeaponStat, DamageType, Distance, Dmg, RelativePosition, DamageSplits, RemainingDamage, DamageSplits)
		local WeaponStats = type(WeaponStat) == "table" and WeaponStat or Core.GetWeapon(WeaponStat) or Core.GetWeaponStats(WeaponStat)
		local Damage = Dmg * (RemainingDamage or 1) * ((Damageable:FindFirstChild("Resistances") and CalculateResistances(Attacker, WeaponStat, DamageType, Damageable.Resistances:GetChildren(), true) or 1) * CalculateResistances(Attacker, WeaponStat, DamageType, WeaponStats.Resistances))
		
		if Damage == 0 then return end
		
		local Prop, MaxProp
		if Damageable:IsA("Humanoid") then
			Prop, MaxProp = "Health", "MaxHealth"
		else
			Prop, MaxProp = "Value", "MaxValue"
		end
		
		if Damage < 0 and Damageable[Prop] == Damageable[MaxProp] then
			Damage = 0
		else
			Damage = Damage > 0 and (Damageable[Prop] > Damage and Damage or Damageable[Prop]) or (Damageable[Prop] - Damage < Damageable[MaxProp] and Damage or Damageable[Prop] - Damageable[MaxProp])
			
			Damageable[Prop] = Damageable[Prop] - Damage
			if Damageable[Prop] <= 0 then
				if Damageable:IsA("Humanoid") then
					Damageable.HealthChanged:Connect(function()
						Damageable.Health = 0
					end)
				else
					Damageable:GetPropertyChangedSignal("Value"):Connect(function()
						Damageable.Value = 0
					end)
				end
			end
		end
		
		if Damage > (Damageable[MaxProp] - (Damageable[MaxProp] / 20)) then
			CollectionService:AddTag(Damageable, "VitalDamage")
		end
		
		local First = not DamageSplits
		DamageSplits = DamageSplits or {}
		if Damage ~= 0 then
			DamageSplits[#DamageSplits + 1] = {Damageable, Damage}
		end
		
		if Damage ~= Dmg * (RemainingDamage or 1) then
			if Damage > 0 then
				local NextDamageable = Damageable.Parent
				
				if NextDamageable and not CollectionService:HasTag(NextDamageable, "s2norecursivedamage") and ((NextDamageable:IsA("Humanoid") and NextDamageable.Health > 0) or (NextDamageable.Name == "Health" and NextDamageable.Value > 0)) then
					Core.ApplyDamage(Attacker, NextDamageable, Hit, WeaponStat, DamageType, Distance, Dmg, RelativePosition, DamageSplits, (RemainingDamage or 1) - (Damage / Dmg))
				end
			else
				local NextDamageable = Damageable:FindFirstChild("Health")
				
				if NextDamageable and NextDamageable.Value > 0 and not CollectionService:HasTag(NextDamageable, "s2norecursivedamage") then
					Core.ApplyDamage(Attacker, NextDamageable, Hit, WeaponStat, DamageType, Distance, Dmg, RelativePosition, DamageSplits, (RemainingDamage or 1) - (Damage / Dmg))
				end
			end
		end
		
		if First and next(DamageSplits) then
			if Players:GetPlayerFromCharacter(Damageable.Parent) then
				ClientDamage:FireClient(Players:GetPlayerFromCharacter(Core.GetTopDamageable(Damageable).Parent), DamageSplits, Attacker.Name)
			end
			
			if typeof(Attacker) == "Instance" then
				ClientDamage:FireClient(Attacker, DamageSplits, Hit, RelativePosition)
			end
			
			Core.ObjDamaged:Fire(Attacker, Hit, WeaponStat, DamageType, Distance, DamageSplits, RelativePosition)
		end
	end
	
	----[[PLAYER HANDLING]]----
	Players.PlayerAdded:Connect(Core.HandlePlr)
	for _, Plr in ipairs(Players:GetPlayers()) do
		Core.HandlePlr(Plr)
	end
	
	function Core.HandleServerReplication(User, StatObj, Time, ...)
		if StatObj and StatObj.Parent then
			local Weapon = Core.GetWeapon(StatObj)
			if Weapon then
				local CancelReplication
				if Weapon.Placeholder then
					if tick() - Time > 0.6 then
						CancelReplication = "Took too long to send replication packet, discarding! "  .. (tick() - Time - 0.6) .. " - Server tick: " .. tick()
					elseif StatObj.Parent.Parent ~= User.Character then
						CancelReplication = "Weapon is not selected " .. StatObj:GetFullName()
					elseif not User.Character then
						local Damageable = User.Character:FindFirstChildOfClass("Humanoid")
						if Damageable and Damageable:GetState() == Enum.HumanoidStateType.Dead and tick() > Core.LastDeath[Damageable] + 0.61  then
							CancelReplication = "User is dead"
						end
					end
				end
				if not CancelReplication then
					CancelReplication = Weapon.WeaponType.HandleServerReplication(Weapon, Time, ...)
				end
				if CancelReplication then
					warn(User.Name .. " sent an invalid server S2 replication request " .. (tick() - Time) .. " seconds ago: " .. CancelReplication .. "\n", User, StatObj, Time, ...)
				end
				if not Weapon.WeaponType.ShouldCancelHold or Weapon.WeaponType.ShouldCancelHold(Weapon, Time, ...) then
					Weapon.HoldStart = nil
				end
			else
				warn(User.Name .. " sent an invalid server S2 replication request " .. (tick() - Time) .. " seconds ago: Weapon doesn't exist\n", User, StatObj, Time, ...)
			end
		else
			warn(User.Name .. " sent an invalid server S2 replication request " .. (tick() - Time) .. " seconds ago: StatObj doesn't exist\n", User, StatObj, Time, ...)
		end
	end
	
	Core.WeaponReplication = Instance.new("RemoteEvent")
	Core.WeaponReplication.Name = "WeaponReplication"
	Core.WeaponReplication.OnServerEvent:Connect(Core.HandleServerReplication)
	Core.WeaponReplication.Parent = script
end