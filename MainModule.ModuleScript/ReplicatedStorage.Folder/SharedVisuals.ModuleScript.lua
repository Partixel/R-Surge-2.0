local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local RunService, Debris, Plr, CollectionService = game:GetService( "RunService" ), game:GetService( "Debris" ), game:GetService( "Players" ).LocalPlayer, game:GetService( "CollectionService" )

function swordOut(Handle)
	for a, b in ipairs(Handle:GetJoints()) do
		if b.Name == "RightGrip" then
			b.C1 = CFrame.new(0, 0, 0.200000003, -1, 0, -0, 0, 0, -1, 0, -1, -0)
		end
	end
end

function swordUp(Handle)
	for a, b in ipairs(Handle:GetJoints()) do
		if b.Name == "RightGrip" then
			b.C1 = CFrame.new(0, -0.200000003, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
		end
	end
end

Core.WeaponTypes.Sword.Events.AttackAnimation = Core.WeaponTypes.Sword.AttackEvent.Event:Connect(function(StatObj, User, Type)
	local Run
	if Core.IsServer  then
		Run = not Core.GetWeapon(StatObj).Placeholder
	elseif typeof(User) == "Instance" then
		Run = true
	end
	
	if Run then
		if Type == 0 then
			if User == Plr then
				local Anim = Instance.new("StringValue")
				Anim.Name = "toolanim"
				Anim.Value = "Slash"
				Anim.Parent = StatObj.Parent
			end
		else
			if User == Plr then
				local Anim = Instance.new("StringValue")
				Anim.Name = "toolanim"
				Anim.Value = "Lunge"
				Anim.Parent = StatObj.Parent
			end
			
			local Handle = StatObj.Parent:FindFirstChild("Handle")
			
			wait(0.25)
			
			if Handle and Handle.Parent then
				swordOut(Handle)
				
				wait(0.75)
				
				if Handle.Parent then
					swordUp(Handle)
				end
			end
		end
	end
end)

Core.Events.HumanoidSelected = Core.WeaponSelected.Event:Connect( function ( StatObj )
	local Weapon = Core.GetWeapon(StatObj)
	
	local Run = true
	if Core.IsServer then
		Run = not Weapon.Placeholder
	end
	
	if Run then
		local Hum = Weapon.User.Character and Weapon.User.Character:FindFirstChildOfClass("Humanoid")
		if Hum then
			if Weapon.WalkSpeedMod then
				local WSMod = Instance.new("NumberValue")
				WSMod.Name = "WalkSpeedModifier"
				WSMod.Value = Weapon.WalkSpeedMod
				WSMod.Parent = Hum
				Weapon.WSMod = WSMod
			end
			
			if Weapon.JumpPowerMod then
				local JPMod = Instance.new("NumberValue")
				JPMod.Name = "JumpPowerModifier"
				JPMod.Value = Weapon.JumpPowerMod
				JPMod.Parent = Hum
				Weapon.JPMod = JPMod
			end
		end
	end
end)

Core.Events.HumanoidDeselected = Core.WeaponDeselected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	
	local Run = true
	if Core.IsServer then
		Run = not Weapon.Placeholder
	end
	
	if Run then
		local Hum = Weapon.User.Character and Weapon.User.Character:FindFirstChildOfClass("Humanoid")
		if Hum then
			if Weapon.WSMod then
				Weapon.WSMod:Destroy()
				Weapon.WSMod = nil
			end
			
			if Weapon.JPMod then
				Weapon.JPMod:Destroy()
				Weapon.JPMod = nil
			end
		end
	end
end)

return nil