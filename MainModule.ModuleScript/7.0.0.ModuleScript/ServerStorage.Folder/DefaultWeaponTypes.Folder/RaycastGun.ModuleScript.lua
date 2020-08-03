local Players = game:GetService("Players")
return function(Core)
	return {
		HandleServerReplication = function(Weapon, Time, ToNetwork, ...)
			if type(ToNetwork) ~= "table" then
				ToNetwork = {{ToNetwork, ...}}
			end
			
			local Barrels = Weapon.Barrels(Weapon.StatObj)
			local CloseTo = {}
			for  k, v in ipairs(ToNetwork) do
				local Barrel = type(Barrels) == "table" and Barrels[v[5] or 1] or Barrels
				if Barrel then
					local Hit, Normal, Offset, BarrelNum = unpack(v)
					local Material
					
					if typeof(Hit) == "Instance" then
						Material = Hit.Material
					elseif Hit then
						Material = Hit
						Hit = workspace.Terrain
					end
					
					local End
					if Hit then
						End = Hit.CFrame:PointToWorldSpace(Offset)
					else
						End = Offset
						Offset = nil
					end
					
					if Weapon.Placeholder and Hit and Hit ~= workspace.Terrain then
						local Axis
						if math.abs(Offset.X) > Hit.Size.X / 2 + 0.05 then
							Axis = "X"
						elseif math.abs(Offset.Y) > Hit.Size.Y / 2 + 0.05 then
							Axis = "Y"
						elseif math.abs(Offset.Z) > Hit.Size.Z / 2 + 0.05 then
							Axis = "Z"
						end
						if Axis then
							warn(Weapon.User.Name .. " may be hit box expanding - " .. Hit.Name .. " size " .. Axis .. " is " .. Hit.Size[Axis] / 2 .. " they claimed to hit at " .. Offset[Axis])
							return
						end
					end
					
					local Humanoids = (Weapon.WeaponType.GetBulletType(Weapon) or Core.BulletTypes.Kinetic)(Weapon.StatObj, Weapon, Weapon.User, Hit, Barrel, End)
					
					local FirstShot
					if #ToNetwork > 1 then
						FirstShot = k == 1
					end
					
					Weapon.WeaponType.AttackEvent:Fire(Weapon.StatObj, Weapon.User, Barrel, Hit, End, Normal, Material, Offset, FirstShot, #ToNetwork > 1 and k == 1 or nil, Humanoids)
					
					local BulRay = Ray.new(Barrel.Position, (End - Barrel.Position).Unit)
					for _, OPlr in ipairs(Players:GetPlayers()) do
						if OPlr ~= Weapon.User then
							if BulRay:Distance(OPlr.Character and OPlr.Character:FindFirstChild("HumanoidRootPart") and OPlr.Character.HumanoidRootPart.Position or Barrel.Position) <= 250 then
								if #ToNetwork == 1 then
									Core.WeaponReplication:FireClient(OPlr, Weapon.User, Weapon.StatObj, unpack(ToNetwork[1]))
								else
									CloseTo[OPlr] = CloseTo[OPlr] or {}
									CloseTo[OPlr][#CloseTo[OPlr] + 1] = v
								end
							end
						end
					end
				end
			end
			
			if #ToNetwork ~= 1 then
				for a, b in pairs(CloseTo) do
					if #b == 1 then
						Core.WeaponReplication:FireClient(a, Weapon.User, Weapon.StatObj, unpack(b[1]))
					else
						Core.WeaponReplication:FireClient(a, Weapon.User, Weapon.StatObj, b)
					end
				end
			end
		end,
	}
end