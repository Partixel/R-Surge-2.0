local Players = game:GetService("Players")

return function(Core, script)
	game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Config").Parent = nil
	
	Core.TimeSync = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("TimeSync"))
	
	local function AddWeaponType(Module)
		local WeaponType = require(Module)(Core)
		WeaponType.Events = {}
		WeaponType.AttackEvent = Instance.new("BindableEvent")
		Core.WeaponTypes[Module.Name] = WeaponType
	end
	
	local SharedWeaponTypesFolder = game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("SharedWeaponTypes")
	SharedWeaponTypesFolder.Parent = nil
	SharedWeaponTypesFolder.ChildAdded:Connect(AddWeaponType)
	for _, Module in ipairs(SharedWeaponTypesFolder:GetChildren()) do
		AddWeaponType(Module)
	end
	
	Core.CurrentFrame = 0
	game:GetService("RunService").RenderStepped:Connect(function()
		Core.CurrentFrame += 1
	end)
	
	local TargetFrame
	local LPlrsTarget
	function Core.GetLPlrsTarget()
		if TargetFrame ~= Core.CurrentFrame then
			local UnitRay = workspace.CurrentCamera:ScreenPointToRay(Core.GetLPlrsInputPos())
			LPlrsTarget = {Core.Raycast(UnitRay.Origin, UnitRay.Direction * 5000, Core.IgnoreFunction, {Players.LocalPlayer.Character})}
			TargetFrame = Core.CurrentFrame
		end
		
		return LPlrsTarget
	end
	
	--[[local ActualTargetFrame
	local ActualLPlrsTarget
	function Core.GetLPlrsActualTarget(Weapon)
		if ActualTargetFrame ~= Core.CurrentFrame then
			local Origin = Weapon.WeaponType.GetOrigin(Weapon)
			ActualLPlrsTarget = {Core.Raycast(Origin, Core.GetLPlrsTarget()[2] - Origin, Core.IgnoreFunction, {Players.LocalPlayer.Character})}
			ActualTargetFrame = Core.CurrentFrame
		end
		
		return ActualLPlrsTarget
	end]]
	
	function Core.GetLPlrsTargetForRaycast()
		return nil, Core.GetLPlrsTarget()[2]
	end
	
	Core.HandlePlr(Players.LocalPlayer)
	
	function Core.HandleServerReplication(User, StatObj, Time, ...)
		Core.WeaponReplication:FireServer(StatObj, Time + Core.TimeSync.ServerOffset, ...)
	end
	
	Core.WeaponReplication = script:WaitForChild("WeaponReplication")
	Core.WeaponReplication.OnClientEvent:Connect(function(User, StatObj, ...)
		if StatObj and StatObj.Parent then
			local WeaponType = Core.GetWeaponType(StatObj)
			if WeaponType then
				if WeaponType.HandleClientReplication then
					WeaponType.HandleClientReplication(StatObj, User, ...)
				end
			else
				warn(User.Name .. " sent an invalid client S2 replication request: WeaponType doesn't exist\n", User, StatObj, ...)
			end
		else
			warn(User.Name .. " sent an invalid client S2 replication request: StatObj doesn't exist\n", User, StatObj, ...)
		end
	end)
	
	Core.WindupReplication = script:WaitForChild("WindupReplication")
	Core.WindupReplication.OnClientEvent:Connect(function(User, StatObj, Time, State)
		if StatObj and StatObj.Parent then
			local WeaponType = Core.GetWeaponType(StatObj)
			if WeaponType then
				local Weapon = Core.GetWeapon(StatObj)
				if not Weapon then
					Weapon = Core.Setup(StatObj, User, true)
					
					Core.WeaponTick[Weapon] = true
					
					Core.Selected[User] = Core.Selected[User] or {}
					Core.Selected[User][Weapon] = tick()
					if not Core.SelectedHB then
						Core.RunSelected()
					end
				end
				
				Weapon.ReplicatedWindupTime = Time
				Weapon.ReplicatedWindupState = State or false
			else
				warn(User.Name .. " sent an invalid client S2 replication request: WeaponType doesn't exist\n", User, StatObj, Time, State)
			end
		else
			warn(User.Name .. " sent an invalid client S2 replication request: StatObj doesn't exist\n", User, StatObj, Time, State)
		end
	end)
	
	Core.DisableBackpack = {}
	Core.BackpackStateChanged = Instance.new("BindableEvent")
	local StarterGui = game:GetService("StarterGui")
	
	local PrevCoreBackpack
	function Core.SetBackpackDisabled(Key, State)
		if State then
			if not next(Core.DisableBackpack) then
				Core.BackpackStateChanged:Fire(true)
				PrevCoreBackpack = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			end
			
			Core.DisableBackpack[Key] = true
		elseif PrevCoreBackpack ~= nil then
			Core.DisableBackpack[Key] = nil
			
			if not next(Core.DisableBackpack) then
				Core.BackpackStateChanged:Fire(false)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, PrevCoreBackpack)
				PrevCoreBackpack = nil
			end
		end
	end
end