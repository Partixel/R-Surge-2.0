local Players, ContextActionService, CollectionService = game:GetService("Players"), game:GetService("ContextActionService"), game:GetService("CollectionService")

local Core = {Config = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Config")), IsServer = game:GetService("RunService"):IsServer()}

if not Core.IsServer then
	game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Config").Parent = nil
end

local TimeSync
if not Core.IsServer then
	TimeSync = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("TimeSync"))
end

Core.WeaponTypes = {}
Core.Events = {}
if Core.IsServer then
	local SharedWeaponTypesFolder = game:GetService("ReplicatedStorage"):WaitForChild("S2"):FindFirstChild("SharedWeaponTypes")
	if not SharedWeaponTypesFolder then
		SharedWeaponTypesFolder = Instance.new("Folder")
		SharedWeaponTypesFolder.Name = "SharedWeaponTypes"
		SharedWeaponTypesFolder.Parent = game:GetService("ReplicatedStorage"):FindFirstChild("S2")
	end
	
	local function AddWeaponType(Module)
		local SharedWeaponType
		if Module:FindFirstChild("Shared") then
			local Shared = Module.Shared
			SharedWeaponType = require(Shared)(Core)
			Shared.Name = Module.Name
			Shared.Parent = SharedWeaponTypesFolder
		end
		local WeaponType = SharedWeaponType and setmetatable(require(Module)(Core), {__index = SharedWeaponType}) or require(Module)(Core)
		
		WeaponType.ServerSided = SharedWeaponType == nil or nil
		WeaponType.Events = {}
		WeaponType.AttackEvent = Instance.new("BindableEvent")
		Core.WeaponTypes[Module.Name] = WeaponType
	end
	
	local DefualtWeaponTypes = game:GetService("ServerStorage"):WaitForChild("S2"):WaitForChild("DefaultWeaponTypes")
	DefualtWeaponTypes.ChildAdded:Connect(AddWeaponType)
	for _, Module in ipairs(DefualtWeaponTypes:GetChildren()) do
		AddWeaponType(Module)
	end
else
	function AddWeaponType(Module)
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
end

local Heartbeat = game:GetService("RunService").Heartbeat
function Core.HeartbeatWait(num)
	local t=0
	while t<num do
		t = t + Heartbeat:Wait()
	end
	return t
end

----[[WEAPONS]]----

local WeaponStatFolder
if Core.IsServer then
	WeaponStatFolder = game:GetService("ReplicatedStorage"):FindFirstChild("WeaponStats")
	if not WeaponStatFolder then
		WeaponStatFolder = Instance.new("Folder")
		WeaponStatFolder.Name = "WeaponStats"
		WeaponStatFolder.Parent = game:GetService("ReplicatedStorage")
	end
else
	WeaponStatFolder = game:GetService("ReplicatedStorage"):WaitForChild("WeaponStats")
	WeaponStatFolder.Parent = nil
end

function Core.FindWeaponStat(Obj)
	for Type, _ in pairs(Core.WeaponTypes) do
		local StatObj = Obj:FindFirstChild(Type .. "Stat")
		if StatObj then
			return StatObj
		end
	end
end

function Core.GetWeaponType(StatObj)
	return Core.WeaponTypes[StatObj.Name:sub(1, StatObj.Name:find("Stat") - 1)]
end

function Core.GetWeaponStats(StatObj)
	local Module = WeaponStatFolder:FindFirstChild(StatObj.Value, true)
	
	assert(Module and Module:IsA("ModuleScript"), "Could not get weapon stat for " .. StatObj.Value .. " - " .. tostring(Module))
	
	local WeaponStats = require(Module)
	if not WeaponStats.Loaded then
		local Overrides = Core.Config.WeaponTypeOverrides[WeaponStats.WeaponType or StatObj.Name:sub(1, StatObj.Name:find("Stat") - 1)]
		if Overrides then
			setmetatable(Overrides, {__index = Core.Config.WeaponTypeOverrides.All})
		else
			Overrides = Core.Config.WeaponTypeOverrides.All
		end
		setmetatable(WeaponStats, {__index = Overrides})
		WeaponStats.Loaded = true
	end
	return WeaponStats
end

Core.Weapons = setmetatable({}, {__mode = 'k'})
function Core.GetWeapon(StatObj)
	return Core.Weapons[StatObj]
end

Core.Selected = setmetatable({}, {__mode = 'k'})
Core.WeaponTick = setmetatable({}, {__mode = 'k'})
function Core.UpdateLPlrsTarget()
	local UnitRay = workspace.CurrentCamera:ScreenPointToRay(Core.GetLPlrsInputPos())
	Core.LPlrsTarget = {Core.FindPartOnRayWithIgnoreFunction(Ray.new(UnitRay.Origin, UnitRay.Direction * 5000), Core.IgnoreFunction, {Players.LocalPlayer.Character})}
end

function Core.RunSelected()
	Core.SelectedHB = Heartbeat:Connect(function (Step)
		if Core.IsServer then
			if not next(Core.Selected) then
				Core.SelectedHB:Disconnect()
				Core.SelectedHB = nil
			end
		elseif not Core.Selected[Players.LocalPlayer] then
			Core.SelectedHB:Disconnect()
			Core.SelectedHB = nil
		else
			Core.UpdateLPlrsTarget()
		end
		
		for Weapon, _ in pairs(Core.WeaponTick) do
			if not Core.IsServer and Weapon.Placeholder then
				if Weapon.ReplicatedWindupState ~= nil then
					local Step = Step
					if Weapon.ReplicatedWindupTime then
						Step = TimeSync.GetServerTime() - Weapon.ReplicatedWindupTime
						Weapon.ReplicatedWindupTime = nil
					end
					if Weapon.ReplicatedWindupState then
						if Weapon.WindupTime and Weapon.WindupTime ~= 0 then
							if Weapon.Reloading then
								if Weapon.Windup then
									Core.SetWindup(Weapon, math.max(Weapon.Windup - (Step * 2), 0), true)
								end
							elseif not Weapon.Windup or Weapon.Windup < Weapon.WindupTime then
								Core.SetWindup(Weapon, (Weapon.Windup or 0) + Step, true)
							end
						end
					else
						if Weapon.Windup then
							Core.SetWindup(Weapon, math.max(Weapon.Windup - (Step * 2), 0), true)
						else
							Core.WeaponTick[Weapon] = nil
							Core.DestroyWeapon(Weapon)
						end
					end
				end
			elseif Weapon.MouseDown then
				if Weapon.WindupTime == nil or Weapon.WindupTime == 0 then
					coroutine.wrap(Core.Attack)(Weapon)
				elseif Weapon.Reloading then
					if Weapon.Windup then
						Core.SetWindup(Weapon, math.max(Weapon.Windup - (Step * 2), 0))
					end
				elseif Weapon.Windup and Weapon.Windup >= Weapon.WindupTime then
					coroutine.wrap(Core.Attack)(Weapon)
				else
					Core.SetWindup(Weapon, (Weapon.Windup or 0) + Step)
				end
			else
				local Needed = Weapon.WeaponType.Tick and Weapon.WeaponType.Tick(Weapon, Step)
				
				if Weapon.Windup then
					Needed = true
					Core.SetWindup(Weapon, math.max(Weapon.Windup - (Step * 2), 0))
				end
				
				if Weapon.MaxHoldTime and Weapon.HoldStart then
					if (tick() - Weapon.HoldStart) >= Weapon.MaxHoldTime then
						coroutine.wrap(Core.SetMouseUp)(Weapon)
					else
						Needed = true
					end
				end
				
				if not Weapon.MouseDown and not Needed then
					Core.WeaponTick[Weapon] = nil
				end
			end
		end
	end)
end

local ContentProvider = game:GetService("ContentProvider")
local LuaPreload = function(...) return ContentProvider:PreloadAsync(...) end
function Core.Preload(Weapon)
	local PreloadArray = {}
	
	if Weapon.SelectionSound then
		PreloadArray[#PreloadArray + 1] = Weapon.SelectionSound
	end
	
	local AnimationsToLoad = {"HoldAnimation", "SprintAnimation", "ReloadAnimation", "AtEaseAnimation", "InspectAnimation"}
	for _, Name in ipairs(AnimationsToLoad) do
		if Weapon["R6" .. Name] then
			local R6Animation = Instance.new("Animation")
			R6Animation.AnimationId = "rbxassetid://" .. Weapon["R6" .. Name]
			PreloadArray[#PreloadArray + 1] = R6Animation
		end
		
		if Weapon["R15" .. Name] then
			local R15Animation = Instance.new("Animation")
			R15Animation.AnimationId = "rbxassetid://" .. Weapon["R15" .. Name]
			PreloadArray[#PreloadArray + 1] = R15Animation
		end
	end
	
	if Weapon.WeaponType.Preload then
		Weapon.WeaponType.Preload(Weapon, PreloadArray)
	end
	
	coroutine.wrap(LuaPreload)(PreloadArray)
end

function Core.Setup(StatObj, User)
	local WeaponStats = Core.GetWeaponStats(StatObj)
	
	local Weapon = setmetatable({
		WeaponType = Core.WeaponTypes[WeaponStats.WeaponType] or Core.GetWeaponType(StatObj),
		StatObj = StatObj,
		User = User,
		CurWeaponMode = 1,
	}, {__index = WeaponStats})
	
	Weapon.Events = {
		StatObj.AncestryChanged:Connect(function()
			if not StatObj:IsDescendantOf(game) then
				Core.DestroyWeapon(Weapon)
			end
		end)
	}
	
	if StatObj.Parent and StatObj.Parent:IsA("Tool") then
		Weapon.Events[#Weapon.Events + 1] = StatObj.Parent.Equipped:Connect(function()
			Core.WeaponSelected:Fire(StatObj)
		end)

		Weapon.Events[#Weapon.Events + 1] = StatObj.Parent.Unequipped:Connect(function()
			Core.WeaponDeselected:Fire(StatObj)
		end)
	end
	
	if Weapon.WeaponType.ServerSided or not Core.IsServer then
		if Weapon.WeaponModes then
			Core.SetWeaponMode(Weapon, 1)
		end
		if Weapon.WeaponType.Setup then
			Weapon.WeaponType.Setup(Weapon)
		end
		if not Core.IsServer then
			Core.Preload(Weapon)
		end
	elseif Core.IsServer then
		Weapon.Placeholder = true
		
		if Weapon.WeaponType.PlaceholderSetup then
			Weapon.WeaponType.PlaceholderSetup(Weapon)
		end
	end
	
	Core.Weapons[StatObj] = Weapon
	
	return Weapon
end

function Core.DestroyWeapon(Weapon)
	if Weapon.StatObj then
		Core.WeaponDeselected:Fire(Weapon.StatObj)
		Core.Weapons[Weapon.StatObj] = nil
		Core.WeaponTick[Weapon] = nil
		
		for a, b in pairs(Weapon.Events) do
			Weapon.Events[a]:Disconnect()
		end
		
		local StatObj, Placeholder = Weapon.StatObj, Weapon.Placeholder
		for a, b in pairs(Weapon) do
			Weapon[a] = nil
		end
		
		if not Placeholder then
			if StatObj.Parent then
				StatObj.Parent:Destroy()
			end
			StatObj:Destroy()
		end
	end
end

Core.WeaponSelected = Instance.new("BindableEvent")
Core.WeaponSelected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if not Weapon.Placeholder then
		if not Weapon.LastClick or Weapon.LastClick < tick() + (Weapon.SelectDelay or 0.2) then
			Weapon.LastClick = tick() + (Weapon.SelectDelay or 0.2)
		end
		
		if not Weapon.ReloadWhileUnequipped then
			Weapon.Reloading = nil
		end
		
		Core.Selected[Weapon.User] = Core.Selected[Weapon.User] or {}
		Core.Selected[Weapon.User][Weapon] = tick()
		if not Core.SelectedHB then
			Core.RunSelected()
		end
	
		if Weapon.ReloadDelay then
			ContextActionService:BindAction("Reload", function(Name, State, Input)
				if State == Enum.UserInputState.Begin then
					Core.Reload(Weapon)
				end
			end, true)
			ContextActionService:SetImage("Reload", "rbxassetid://371461853")
		end
	end
	if Weapon.WeaponType.Selected then
		Weapon.WeaponType.Selected(Weapon)
	end
end)

Core.WeaponDeselected = Instance.new("BindableEvent")
Core.WeaponDeselected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if not Weapon.Placeholder then
		if Core.Selected[Weapon.User] then
			Core.Selected[Weapon.User][Weapon] = nil
			if not next(Core.Selected[Weapon.User]) then
				Core.Selected[Weapon.User] = nil
			end
		end
		
		if Weapon.MouseDown then
			Core.EndAttack(Weapon)
		end
		
		if not Weapon.ReloadWhileUnequipped then
			Weapon.Reloading = false
		end
	
		if Weapon.ReloadDelay then
			ContextActionService:UnbindAction("Reload")
		end
		
		if Weapon.Windup then
			Core.SetWindup(Weapon, 0)
		end
	end
	
	if Weapon.HoldStart then
		if not Weapon.Placeholder then
			Core.HoldEnd:Fire(Weapon.StatObj)
		end
		Weapon.HoldStart = nil
	end
	
	if Weapon.WeaponType.Deselected then
		Weapon.WeaponType.Deselected(Weapon)
	end
end)

Core.ReloadStart = Instance.new("BindableEvent")
Core.ReloadStepped = Instance.new("BindableEvent")
Core.ReloadEnd = Instance.new("BindableEvent")
Core.PreventReload = {}
function Core.Reload(Weapon)
	if not next(Core.PreventReload) and Weapon.WeaponType.Reload then
		Weapon.WeaponType.Reload(Weapon)
	end
end
function Core.EmptyAmmo(Weapon)
	if not next(Core.PreventReload) and Weapon.WeaponType.EmptyAmmo then
		Weapon.WeaponType.EmptyAmmo(Weapon)
	end
end

Core.PreventAttack = {}
function Core.CanAttack(Weapon)
	return not Weapon.PreventAttack and not next(Core.PreventAttack) and (typeof(Weapon.User) ~= "Instance" or (Weapon.User.Character and Weapon.User.Character:FindFirstChildOfClass("Humanoid") and Weapon.User.Character:FindFirstChildOfClass("Humanoid").Health > 0))
end

function Core.Attack(Weapon)
	if Core.CanAttack(Weapon) then
		local Ran = Weapon.WeaponType.Attack(Weapon)
		if Weapon.AttackOnMouseUp and not Ran then
			Core.EndAttack(Weapon)
		end
	end
end

Core.AttackEnded = Instance.new("BindableEvent")
function Core.EndAttack(Weapon)
	Weapon.MouseDown = nil
	Weapon.HoldStart = nil
	if Weapon.WeaponType.EndedAttack then
		Weapon.WeaponType.EndAttack(Weapon)
	end
	Core.AttackEnded:Fire(Weapon.StatObj)
end

if not Core.IsServer then
	Core.HoldReplication = script:WaitForChild("HoldReplication")
end

Core.HoldStart = Instance.new("BindableEvent")
Core.HoldEnd = Instance.new("BindableEvent")
function Core.SetMouseDown(Weapon)
	if Weapon.AttackOnMouseUp then
		Weapon.HoldStart = tick()
		if Weapon.HeldDamagePctIncreasePerSecond then
			if Core.IsServer then		
				coroutine.wrap(Core.HandleHoldReplication)(Weapon.User, Weapon.StatObj, tick( ))
			else
				Core.HoldReplication:FireServer(Weapon.StatObj, TimeSync.GetServerTime())
			end
		end
		Core.HoldStart:Fire(Weapon.StatObj)
		if Weapon.MaxHoldTime then
			Core.WeaponTick[Weapon] = true
		end
	else
		Weapon.MouseDown = tick()
		if Weapon.LastClick and Weapon.LastClick < Weapon.MouseDown then
			Weapon.LastClick = nil
		end
		Core.WeaponTick[Weapon] = true
	end
end

function Core.SetMouseUp(Weapon)
	if Weapon.AttackOnMouseUp then
		if Weapon.HoldStart then
			Core.HoldEnd:Fire(Weapon.StatObj)
			if (Weapon.FireOnMaxHold or not Weapon.MaxHoldTime or (tick() - Weapon.HoldStart) < Weapon.MaxHoldTime) and (not Weapon.MinHoldTime or (tick() - Weapon.HoldStart) > Weapon.MinHoldTime) then
				Weapon.MouseDown = tick()
				if Weapon.LastClick and Weapon.LastClick < Weapon.MouseDown then
					Weapon.LastClick = nil
				end
				Core.WeaponTick[Weapon] = true
			else
				Weapon.HoldStart = nil
				if Weapon.HeldDamagePctIncreasePerSecond then
					if Core.IsServer then		
						coroutine.wrap(Core.HandleHoldReplication)(Weapon.User, Weapon.StatObj)
					else
						Core.HoldReplication:FireServer(Weapon.StatObj)
					end
				end
			end
		end
	elseif Weapon.MouseDown then
		Core.EndAttack(Weapon)
	end
end

Core.WindupChanged = Instance.new("BindableEvent")
function Core.SetWindup(Weapon, Value, Placeholder)
	local Started
	if not Weapon.Windup then
		Started = true
	elseif Value == 0 then
		Started = false
	end
	
	if not Placeholder then
		if Weapon.Windup and Value < Weapon.Windup then
			if Weapon.WindupRampingUp then
				Weapon.WindupRampingUp = nil
				if Core.IsServer then		
					coroutine.wrap(Core.HandleWindupReplication)(Weapon.User, Weapon.StatObj, tick())
				else
					Core.WindupReplication:FireServer(Weapon.StatObj, TimeSync.GetServerTime())
				end
			end
		else
			if not Weapon.WindupRampingUp then
				Weapon.WindupRampingUp = true
				if Core.IsServer then		
					coroutine.wrap(Core.HandleWindupReplication)(Weapon.User, Weapon.StatObj, tick(), true)
				else
					Core.WindupReplication:FireServer(Weapon.StatObj, TimeSync.GetServerTime(), true)
				end
			end
		end
	end
	
	Weapon.Windup = Value ~= 0 and Value or nil
	
	Core.WindupChanged:Fire(Weapon.StatObj, Weapon.Windup, Started)
end

function Core.GetWeaponMode(Weapon)
	local Mode = Weapon.WeaponModes[Weapon.CurWeaponMode]
	return Weapon.WeaponType.WeaponModes[Mode] or Mode
end

Core.WeaponModeChanged = Instance.new("BindableEvent")
if not Core.IsServer then
	Core.ReplicateWeaponMode = script:WaitForChild("ReplicateWeaponMode")
end
Core.SetWeaponMode = function(Weapon, Mode)
	for k, _ in pairs(Core.GetWeaponMode(Weapon)) do
		Weapon[k] = nil
	end
		
	Weapon.CurWeaponMode = Mode
	
	for k, v in pairs(Core.GetWeaponMode(Weapon)) do
		Weapon[k] = v
	end

	Core.WeaponModeChanged:Fire(Weapon.StatObj, Mode)
	if not Core.IsServer then
		Core.ReplicateWeaponMode:FireServer(Weapon.StatObj, Mode)
	end
end

----[[RAYCAST]]----

function Core.IgnoreFunction(Part)
    return not CollectionService:HasTag(Part, "nopen") and (not Part.Parent or Part.Name == "HumanoidRootPart" or CollectionService:HasTag(Part, "forcepen") or Part:FindFirstAncestorWhichIsA("Accoutrement") or Part.Transparency >= 1 or (Core.GetValidDamageable(Part) == nil and Part.CanCollide == false) or (Core.GetValidDamageable(Part) and Part:FindFirstAncestorOfClass("Tool"))) or false
end

function Core.FindPartOnRayWithIgnoreFunction(R, IgnoreFunction, Ignore, IgnoreWater)
	local UnitDirection = R.Unit.Direction
	local Hit, Pos, Normal, Material
	while true do
		Hit, Pos, Normal, Material = workspace:FindPartOnRayWithIgnoreList(R, Ignore, false, IgnoreWater == nil and true or IgnoreWater)
		--[[if IgnoreWater == true then
			local Color = BrickColor.Random()
			local C = Instance.new("ConeHandleAdornment")
			C.Adornee = workspace.Terrain
			C.CFrame = CFrame.new(R.Origin, Pos)
			C.Radius = 0.3
			C.Height = 0.3
			C.Color3 = Color.Color
			C.Parent = workspace
			game.Debris:AddItem(C, 10)
			local L = Instance.new("BoxHandleAdornment")
			L.Adornee = workspace.Terrain
			L.CFrame = CFrame.new(R.Origin + (Pos - R.Origin) / 2, Pos)
			L.Size = Vector3.new(.1, .1, (Pos - R.Origin).magnitude)
			L.Color3 = Color.Color
			L.Parent = workspace
			game.Debris:AddItem(L, 10)
		end]]
		if not Hit or not IgnoreFunction(Hit) then
			return Hit, Pos, Normal, Material
		end
		Ignore[#Ignore + 1] = Hit
		R = Ray.new(Pos - UnitDirection * 0.01, UnitDirection * (R.Direction.magnitude - ((Pos - UnitDirection) - R.Origin).magnitude))
	end
end

----[[MISC]]----

function Core.ClosestPoint(Part, Point)
	Point = Part.CFrame:PointToObjectSpace(Point)
    if math.abs(Point.X) > Part.Size.X / 2 then
        return Vector3.new(Part.Size.X / 2 * math.sign(Point.X), math.clamp(Point.Y, -Part.Size.Y / 2, Part.Size.Y / 2), math.clamp(Point.Z, -Part.Size.Z / 2, Part.Size.Z / 2))
    elseif math.abs(Point.Y) > Part.Size.Y / 2 then
        return Vector3.new(math.clamp(Point.X, -Part.Size.X / 2, Part.Size.X / 2), Part.Size.Y / 2 * math.sign(Point.Y), math.clamp(Point.Z, -Part.Size.Z / 2, Part.Size.Z / 2))
    else
        return Vector3.new(math.clamp(Point.X, -Part.Size.X / 2, Part.Size.X / 2), math.clamp(Point.Y, -Part.Size.Y / 2, Part.Size.Y / 2), Part.Size.Z / 2 * math.sign(Point.Z))
    end
end

----[[DAMAGE]]----

function Core.FakeExplosion(Properties, OnHit)
	local Explosion = Instance.new("Explosion")
	Explosion.Visible = false
	for a, b in pairs(Properties) do
		Explosion[a] = b
	end

	Explosion.DestroyJointRadiusPercent = 0
	Explosion.Hit:Connect(OnHit)
	Explosion.Parent = Properties.Parent or workspace
	wait()
end

function Core.StartStun(StatObj, WeaponStats, User, Hit, Damageable)
	if Damageable:IsA("Humanoid") then
		Damageable.PlatformStand = true
		if Damageable.RootPart then Damageable.RootPart.RotVelocity = Vector3.new(10, 0, 0) end

		coroutine.wrap(function()
			for a = 1, 60 do
				wait(0.1)
				
				if Damageable.RootPart then
					Damageable.RootPart.RotVelocity = Vector3.new(0, math.random(-5, 5), 0)
				end
			end

			Damageable.PlatformStand = false
		end)()
	end
end

function Core.StartFireDamage(StatObj, WeaponStats, User, Hit, Damageable, RelativePosition)
	local Doused
	local Fire = Instance.new("Fire" , Hit)
	
	local Event1 = Damageable.ChildAdded:Connect(function(Obj)
		if Obj.Name == "InWater" then
			Doused = true
		end
	end)
	
	local Event2 = Damageable:IsA("Humanoid") and Damageable.Swimming:Connect(function()
		Doused = true
	end)
	
	for i = 1, 20 do
		if Doused then
			break
		end
		
		local Damageable, Damage = Core.DamageHelper(User, Hit, StatObj, WeaponStats.BulletType.DamageType or Core.DamageType.Fire, nil, RelativePosition)
		if not Damageable then break end
		
		wait(0.3)
	end
	
	Fire:Destroy()
	Event1:Disconnect()
	
	if Event2 then Event2:Disconnect() end
end

function Core.DoExplosion(User, WeaponStat, Position, Options)
	local WeaponStats = type(WeaponStat) == "table" and WeaponStat or Core.GetWeapon(WeaponStat)
	local DamageType = Options.DamageType or Core.DamageType.Explosive
	local Type = type(Options.Type) == "function" and Options.Type or Options.Type == "Stun" and Core.StartStun or Options.Type == "Fire" and Core.StartFireDamage
	
	local Damageables = {}
	
	local BlastRadius, JointRadius = Options.BlastRadius, Options.DestroyJointRadiusPercent or 1
	Core.FakeExplosion({Position = Position, Visible = Options.Visible, Parent = Options.Parent, BlastRadius = BlastRadius, BlastPressure = Options.BlastPressure, ExplosionType = Options.ExplosionType}, function(Part, Dist)
		Dist = Dist / BlastRadius
		local Damageable = Core.GetValidDamageable(Part)
		if Damageable then
			if Core.CanDamage(User, Damageable, Part, WeaponStat, Dist) then
				local Damage = Core.CalculateDamageFor(Part, WeaponStat, Dist)
				if not Damageables[Damageable] or Damage > Damageables[Damageable][3] then
					Damageables[Damageable] = {Part, Dist, Damage}
				end
			end
		elseif Core.IsServer and Dist <= JointRadius and not CollectionService:HasTag(Part, "s2_permjoints") then
			-----------------------------------------------------------------check for both parts in range of joints
			Part:BreakJoints()
			--[[Part.CFrame = Part.CFrame + Vector3.new(0, 0.01, 0)-----------------------REMOVE THIS ONCE https://devforum.roblox.com/t/pgs-changing-velocity-of-a-part-doesnt-wake-it/73708 IS FIXED PLAES FASE GSDFG DS GHSE EGFD SSGDF GSFDGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
			Part.Velocity = Part.Velocity + (CFrame.new(Explosion.Position, Part.Position).lookVector * Distance * Explosive * 30)]]
		end
	end)

	if next(Damageables) then
		local EstimatedDamageables = {}
		for Damageable, Info in pairs(Damageables) do
			if Core.IsServer then
				local ClosestPoint = Core.ClosestPoint(Info[1], Position)
				Core.ApplyDamage(User, Info[3] > 0 and Core.GetBottomDamageable(Damageable) or Damageable, Info[1], WeaponStat, DamageType, Info[2], Info[3], ClosestPoint)
				if Type then
					Type(WeaponStat, WeaponStats, User, Info[1], Damageable, ClosestPoint)
				end
			end
			EstimatedDamageables[#EstimatedDamageables + 1] = {Damageable, Info[3]}
		end
		
		return EstimatedDamageables
	end
end

Core.LastDeath = setmetatable({}, {__mode = "k"})
Core.Damageables = setmetatable({}, {__mode = "k"})
Core.DamageableAdded = Instance.new("BindableEvent")
Core.DamageableDied = Instance.new("BindableEvent")
local function AddDamageable(Damageable)
	if not Core.Damageables[Damageable] and (Damageable:IsA("Humanoid") or (Damageable:IsA("DoubleConstrainedValue") and Damageable.Name == "Health")) then
		Core.Damageables[Damageable] = true
		Core.DamageableAdded:Fire(Damageable)
		if Damageable:IsA("Humanoid") then
			Damageable.Died:Connect(function()
				Core.LastDeath[Damageable] = tick()
				Core.DamageableDied:Fire(Damageable)
			end)
		else
			local Ev; Ev = Damageable.Changed:Connect(function()
				if Damageable.Value <= 0 then
					Core.LastDeath[Damageable] = tick()
					Core.DamageableDied:Fire(Damageable)
					Ev:Disconnect( )
				end
			end)
		end
	end
end
workspace.DescendantAdded:Connect(AddDamageable)

for _, Damageable in ipairs(workspace:GetDescendants()) do
	AddDamageable(Damageable)
end

Core.DamageType = {
	Kinetic = "Kinetic",
	Explosive = "Explosive",
	Slash = "Slash",
	Fire = "Fire",
	Electricity = "Electricity",
	Heal = "Heal",
}

function Core.GetTeamInfo(Obj)
	if type(Obj) == "table" or Obj:IsA("Player") then
		return Obj.TeamColor, Obj.Neutral, Obj.Character
	end

	local PlrObj = Players:GetPlayerFromCharacter(Obj.Parent)
	if PlrObj then
		return PlrObj.TeamColor, PlrObj.Neutral, Obj.Parent
	elseif Obj:FindFirstChild("TeamColor") then
		return Obj.TeamColor.Value, Obj:FindFirstChild("Neutral") and Obj.Neutral.Value or false, Obj.Parent
	else
		return BrickColor.White(), not Obj:FindFirstChild("Neutral") and true or Obj.Neutral.Value, Obj.Parent
	end
end

function Core.CheckTeamkill(WeaponStats, P1, P2)
	if WeaponStats.AllowTeamKill then return true end
	
	local TC1, N1, Char1 = Core.GetTeamInfo(P1)
	local TC2, N2, Char2 = Core.GetTeamInfo(P2)
	local TeamKill
	if Char1 == Char2 then
		TeamKill = WeaponStats.AllowSelfDamage
	elseif N1 and N2 then
		TeamKill = WeaponStats.AllowNeutralTeamKill
	elseif (N1 and not N2) or (not N1 and N2) then
		TeamKill = true
	elseif TC1 ~= TC2 then
		TeamKill = true
		for _, Teams in ipairs(Core.Config.AllowTeamKillFor) do
			if Teams[TC1.name] and Teams[TC2.name] then
				TeamKill = false
				break
			end
		end
	end
	
	if WeaponStats.InvertTeamKill then
		return not TeamKill
	else
		return TeamKill
	end
end

function Core.GetTopDamageable(Damageable)
	while Damageable.Parent and (Damageable.Parent:IsA("Humanoid") or Damageable.Parent.Name == "Health") do
		Damageable = Damageable.Parent
	end
	return Damageable
end

function Core.GetBottomDamageable(Damageable)
	local Health = Damageable:FindFirstChild("Health")
	while Health and Health.Value > 0 do
		Damageable, Health = Health, Health:FindFirstChild("Health")
	end
	return Damageable
end

function Core.GetValidDamageable(Obj)
	if Obj and Obj:IsDescendantOf(game) then
		local Damageable = Obj:FindFirstChild("Health") or Obj.Parent:FindFirstChildOfClass("Humanoid") or Obj.Parent:FindFirstChild("Health") or Obj.Parent.Parent:FindFirstChildOfClass("Humanoid") or Obj.Parent.Parent:FindFirstChild("Health")
		
		if Damageable and ((Damageable:IsA("Humanoid") and Damageable.Health > 0) or (Damageable:IsA("DoubleConstrainedValue") and Damageable.Value > 0)) then
			return Damageable
		end
	end
end

function Core.CanDamage(Attacker, Damageable, Hit, WeaponStat, Distance)
	local WeaponStats = type(WeaponStat) == "table" and WeaponStat or Core.GetWeapon(WeaponStat) or Core.GetWeaponStats(WeaponStat)
	return not Core.IgnoreFunction(Hit) and Core.CheckTeamkill(WeaponStats, Attacker, Damageable) and (not Distance or Distance < 1) and not Damageable.Parent:FindFirstChildOfClass("ForceField")
end

function Core.CalculateDamageFor(Hit, WeaponStat, Distance)
	local WeaponStats = type(WeaponStat) == "table" and WeaponStat or Core.GetWeapon(WeaponStat) or Core.GetWeaponStats(WeaponStat)
	local Damage = WeaponStats.Damage
	
	local HitName = Hit.Name:lower()
	
	if HitName:find("head") or HitName == "uppertorso" or CollectionService:HasTag(Hit, "s2headdamage") then
		Damage = Damage * WeaponStats.HeadDamageMultiplier
	elseif HitName:find("leg") or HitName:find("arm") or HitName:find("hand") or HitName:find("foot") or CollectionService:HasTag(Hit, "s2limbdamage") then
		Damage = Damage * WeaponStats.LimbDamageMultiplier
	end
	
	if WeaponStats.HeldDamagePctIncreasePerSecond then
		Damage = Damage + (Damage * math.min(math.max(tick() - WeaponStats.HoldStart - (WeaponStats.MinHoldTime or 0), 0) * WeaponStats.HeldDamagePctIncreasePerSecond, (WeaponStats.MaxHeldDamagePct or math.huge)))
	end

	if Distance then
		if WeaponStats.InvertDistanceModifier then
			Damage = Damage * (1 - Distance) * WeaponStats.DistanceDamageModifier
		else
			Damage = Damage * (1 - Distance * WeaponStats.DistanceDamageModifier)
		end
	end
	
	return Damage * WeaponStats.GlobalDamageMultiplier
end

if not Core.IsServer then
	Core.ClientDamage = script:WaitForChild("ClientDamage")
	Core.ClientDamage.OnClientEvent:Connect(function(DamageSplits, Attacker)
		if type(Attacker) == "string" then
			local TotalDamage, Split = 0, ""
			for i, DamageSplit in ipairs(DamageSplits) do
				TotalDamage = TotalDamage + DamageSplit[2]
				Split = Split .. DamageSplit[1].Name .. ":" .. (math.floor(math.abs(DamageSplit[2]) * 100 + 0.5) / 100) .. (i == #DamageSplits and "" or ", ")
			end
			
			print("You took " .. (math.floor(math.abs(TotalDamage) * 100 + 0.5) / 100) .. (TotalDamage > 0 and " damage" or " healing") .. " from " .. Attacker .. " (" .. Split .. ")")
		else
			local TotalDamage, Split = 0, ""
			for i, DamageSplit in ipairs(DamageSplits) do
				TotalDamage = TotalDamage + DamageSplit[2]
				Split = Split .. DamageSplit[1].Name .. ":" .. (math.floor(math.abs(DamageSplit[2]) * 100 + 0.5) / 100) .. (i == #DamageSplits and "" or ", ")
			end
			local Top = Core.GetTopDamageable(DamageSplits[1][1])
			if Top.Parent then
				Top = Top.Parent
			end
			print("You did " .. (math.floor(math.abs(TotalDamage) * 100 + 0.5) / 100) .. (TotalDamage > 0 and " damage" or " healing") .. " to " .. Top.Name .. " (" .. Split .. ")")
		end
	end)
end
-- returns Damageable if one is found, on server will also do damage
function Core.DamageHelper(Attacker, Hit, WeaponStat, DamageType, Distance, RelativePosition)
	local Damageable = Core.GetValidDamageable(Hit)
	if Damageable and Core.CanDamage(Attacker, Damageable, Hit, WeaponStat, Distance) then
		local Damage = Core.CalculateDamageFor(Hit, WeaponStat, Distance)
		if Core.IsServer then
			Core.ApplyDamage(Attacker, Damage > 0 and Core.GetBottomDamageable(Damageable) or Damageable, Hit, WeaponStat, DamageType, Distance, Damage, RelativePosition)
		end
		return Damageable, Damage
	end
end

----[[PLAYER HANDLING]]----
local function ToolAdded(Plr, Tool)
	local StatObj = Core.FindWeaponStat(Tool)
	if StatObj and not Core.Weapons[StatObj] then
		Core.Setup(StatObj, Plr)
	end
end

function Core.HandlePlr(Plr)
	if Plr.Character then
		for _, Tool in ipairs(Plr.Character:GetChildren()) do
			ToolAdded(Plr, Tool)
		end
	
		Plr.Character.ChildAdded:Connect(function(Tool)
			ToolAdded(Plr, Tool)
		end)
	end
	
	Plr.CharacterAdded:Connect(function(Character)
		for _, Tool in ipairs(Character:GetChildren()) do
			ToolAdded(Plr, Tool)
		end
	
		Character.ChildAdded:Connect(function(Tool)
			ToolAdded(Plr, Tool)
		end)
	end)
end

if Core.IsServer then
	require(game:GetService("ServerStorage"):WaitForChild("S2"):WaitForChild("ServerCore"))(Core, script)
else
	Core.HandlePlr(Players.LocalPlayer)
	
	function Core.HandleServerReplication(User, StatObj, Time, ...)
		Core.WeaponReplication:FireServer(StatObj, Time + TimeSync.ServerOffset, ...)
	end
	
	Core.LPlrsTarget = {}
	function Core.GetLPlrsTarget()
		return nil, Core.LPlrsTarget[2]
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
					Weapon = setmetatable({
						Placeholder = true,
						StatObj = StatObj,
						User = User,
						WeaponType = WeaponType
					}, {__index = Core.GetWeaponStats(StatObj)})
					
					Weapon.Events = {
						StatObj.AncestryChanged:Connect(function()
							if not StatObj:IsDescendantOf(game) then
								Core.DestroyWeapon(Weapon)
							end
						end)
					}
					
					Core.Weapons[StatObj] = Weapon
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

return Core
