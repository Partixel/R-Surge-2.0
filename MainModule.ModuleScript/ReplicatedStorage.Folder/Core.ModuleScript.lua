local Players, ContextActionService, CollectionService = game:GetService("Players"), game:GetService("ContextActionService"), game:GetService("CollectionService")

local Core = {Config = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Config")) or _G.S20Config, IsServer = game:GetService("RunService"):IsServer()}

if Core.IsServer then
	local ClientSync = Instance.new("RemoteFunction")
	ClientSync.Name = "ClientSync"
	ClientSync.Parent = script
	ClientSync.OnServerInvoke = function(Plr, ClientTime)
		return tick()
	end
else
	local ClientSync = script:WaitForChild("ClientSync")
	coroutine.wrap(function()
		while true do
			local StartTime = tick()
			
			local ServerTime = ClientSync:InvokeServer(StartTime)
			
			local ClientTime = tick()
			_G.ServerOffset = ServerTime + (ClientTime - StartTime) / 2 - ClientTime
			
			wait(30)
		end
	end)()
end

Core.WeaponTypes = {}
Core.Events = {}

function AddWeaponType(Module)
	local WeaponType = require(Module)(Core)
	WeaponType.Events = {}
	WeaponType.AttackEvent = Instance.new("BindableEvent")
	Core.WeaponTypes[Module.Name] = WeaponType
end

script.DefaultWeaponTypes.ChildAdded:Connect(AddWeaponType)
for _, Module in ipairs(script:WaitForChild("DefaultWeaponTypes"):GetChildren()) do
	AddWeaponType(Module)
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
		WeaponStatFolder.Name = "WeaponStats"
	end
else
	WeaponStatFolder = game:GetService("ReplicatedStorage"):WaitForChild("WeaponStats")
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
	return Core.WeaponTypes[StatObj.Name:sub(1, -5)]
end

function Core.GetWeaponStats(StatObj)
	return require(WeaponStatFolder:FindFirstChild(StatObj.Value, true))
end

Core.Weapons = setmetatable({}, {__mode = 'k'})
function Core.GetWeapon(StatObj)
	return Core.Weapons[StatObj]
end

Core.Selected = setmetatable({}, {__mode = 'k'})
Core.WeaponTick = setmetatable({}, {__mode = 'k'})
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
			local UnitRay = Players.LocalPlayer:GetMouse().UnitRay
			Core.LPlrsTarget = {Core.FindPartOnRayWithIgnoreFunction(Ray.new(UnitRay.Origin, UnitRay.Direction * 5000), Core.IgnoreFunction, {Players.LocalPlayer.Character})}
		end
		
		for Weapon, _ in pairs(Core.WeaponTick) do
			if Weapon.MouseDown then
				if Weapon.WindupTime == nil or Weapon.WindupTime == 0 then
					Core.Attack(Weapon)
				elseif Weapon.Reloading then
					if Weapon.Windup or Weapon.WindupSound then
						Core.SetWindup(Weapon, math.max(Weapon.Windup - (Step * 2), 0))
					end
				elseif Weapon.Windup and Weapon.Windup >= Weapon.WindupTime then
					Core.Attack(Weapon)
				else
					Core.SetWindup(Weapon, (Weapon.Windup or 0) + Step)
				end
			else
				local Needed = Weapon.WeaponType.Tick and Weapon.WeaponType.Tick(Weapon, Step)
				
				if Weapon.Windup then
					Needed = true
					Core.SetWindup(Weapon, math.max(Weapon.Windup - (Step * 2), 0))
				end
				
				if not Needed then
					Core.WeaponTick[Weapon] = nil
				end
			end
		end
	end)
end

function Core.Setup(StatObj, User)
	local Weapon = setmetatable({
		WeaponType = Core.GetWeaponType(StatObj),
		StatObj = StatObj,
		User = User,
		CurWeaponMode = 1,
	}, {__index = Core.GetWeaponStats(StatObj)})
	
	if Weapon.WeaponModes then
		Core.SetWeaponMode(Weapon, 1)
	end
	Weapon.Events = {
		StatObj.AncestryChanged:Connect(function()
			if not StatObj:IsDescendantOf(game) then
				Core.DestroyWeapon(Weapon)
			end
		end)
	}
	
	Weapon.WeaponType.Setup(Weapon)
	Core.Weapons[StatObj] = Weapon
	
	if StatObj.Parent and StatObj.Parent:IsA("Tool") then
		Weapon.Events[#Weapon.Events + 1] = StatObj.Parent.Equipped:Connect(function()
			Core.WeaponSelected:Fire(StatObj)
		end)

		Weapon.Events[#Weapon.Events + 1] = StatObj.Parent.Unequipped:Connect(function()
			Core.WeaponDeselected:Fire(StatObj)
		end)
	end
	
	return Weapon
end

function Core.DestroyWeapon(Weapon)
	if Weapon.StatObj then
		Core.WeaponDeselected:Fire(Weapon.StatObj)
		Core.Weapons[Weapon.StatObj] = nil
	
		for a, b in pairs(Weapon.Events) do
			Weapon.Events[a]:Disconnect()
		end
		
		local StatObj = Weapon.StatObj
		for a, b in pairs(Weapon) do
			Weapon[a] = nil
		end
	
		if StatObj.Parent then
			StatObj.Parent:Destroy()
		end
		StatObj:Destroy()
	end
end

Core.WeaponSelected = Instance.new("BindableEvent")
Core.WeaponSelected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if not Weapon.ServerPlaceholder then
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
	if not Weapon.ServerPlaceholder then
		if Core.Selected[Weapon.User] then
			Core.Selected[Weapon.User][Weapon] = nil
			if not next(Core.Selected[Weapon.User]) then
				Core.Selected[Weapon.User] = nil
			end
		end
		
		Core.WeaponTick[Weapon] = nil
		Weapon.MouseDown = nil
		
		if not Weapon.ReloadWhileUnequipped then
			Weapon.Reloading = nil
		end
	
		if Weapon.ReloadDelay then
			ContextActionService:UnbindAction("Reload")
		end
		
		if Weapon.Windup then
			Core.SetWindup(Weapon, 0)
		end
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

Core.PreventAttack = {}
function Core.CanAttack(Weapon)
	return not Weapon.PreventAttack and not (next(Core.PreventAttack) or (typeof(Weapon.User) == "Instance" and Weapon.User:IsA("Player") and not Weapon.User.Character) or (Weapon.User.Character and Weapon.User.Character:FindFirstChild("Humanoid") and Weapon.User.Character.Humanoid:GetState() == Enum.HumanoidStateType.Dead))
end

function Core.Attack(Weapon)
	if Core.CanAttack(Weapon) then
		Weapon.WeaponType.Attack(Weapon)
	end
end

Core.AttackEnded = Instance.new("BindableEvent")
function Core.EndAttack(Weapon)
	Weapon.MouseDown = nil
	if not Weapon.WeaponType then
		print(Weapon)
		print(Weapon.StatObj)
	end
	if Weapon.WeaponType.EndedAttack then
		Weapon.WeaponType.EndAttack(Weapon)
	end
	Core.AttackEnded:Fire(Weapon.StatObj)
end

function Core.SetMouseDown(Weapon)
	Weapon.MouseDown = tick()
	if Weapon.LastClick and Weapon.LastClick < Weapon.MouseDown then
		Weapon.LastClick = nil
	end
	Core.WeaponTick[Weapon] = true
end

Core.WindupChanged = Instance.new("BindableEvent")
function Core.SetWindup(Weapon, Value)
	local Started = not Weapon.Windup
	Weapon.Windup = Value ~= 0 and Value or nil
	Core.WindupChanged:Fire(Weapon.StatObj, Weapon.Windup, Started)
end

function Core.GetWeaponMode(Weapon)
	local Mode = Weapon.WeaponModes[Weapon.CurWeaponMode]
	return Weapon.WeaponType.WeaponModes[Mode] or Mode
end

Core.WeaponModeChanged = Instance.new("BindableEvent")
if Core.IsServer then
	Core.ReplicateWeaponMode = Instance.new("RemoteEvent")
	Core.ReplicateWeaponMode.Name = "ReplicateWeaponMode"
	Core.ReplicateWeaponMode.OnServerEvent:Connect(function(Plr, StatObj, Mode)
		Core.SetWeaponMode(Core.GetWeapon(StatObj), Mode)
	end)
	Core.ReplicateWeaponMode.Parent = script
else
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
    return not CollectionService:HasTag(Part, "nopen") and (not Part or not Part.Parent or CollectionService:HasTag(Part, "forcepen") or Part.Parent:IsA("Accoutrement") or Part.Transparency >= 1 or (Core.GetValidDamageable(Part) == nil and Part.CanCollide == false)) or false

end

function Core.FindPartOnRayWithIgnoreFunction(R, IgnoreFunction, Ignore, IgnoreWater)
	local UnitDirection = R.Unit.Direction
	local Hit, Pos, Normal, Material
	while true do
		Hit, Pos, Normal, Material = workspace:FindPartOnRayWithIgnoreList(R, Ignore, false, IgnoreWater == nil and true or IgnoreWater)
		if not Hit or not IgnoreFunction(Hit) then
			return Hit, Pos, Normal, Material
		end
		
		Ignore[#Ignore + 1] = Hit
		R = Ray.new(Pos - UnitDirection, UnitDirection * (R.Direction.magnitude - ((Pos - UnitDirection) - R.Origin).magnitude))
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

function Core.StartFireDamage(StatObj, WeaponStats, User, Hit, Damageable)
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
		
		local Damageable, Damage = Core.DamageHelper(User, Hit, StatObj, WeaponStats.BulletType.DamageType or Core.DamageType.Fire, 0)
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
	local Type = type(Options.Type) == "function" and Options.Type or Options.Type == "Stun" and Core.BulletTypes or Options.Type == "Fire" and Core.StartFireDamage
	
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
		elseif Core.IsServer and Dist <= JointRadius then
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
				Core.ApplyDamage(User, Info[3] > 0 and Core.GetBottomDamageable(Damageable) or Damageable, Info[1], WeaponStat, DamageType, Info[2], Info[3])
				if Type then
					Type(WeaponStat, WeaponStats, User, Info[1], Damageable)
				end
			end
			EstimatedDamageables[#EstimatedDamageables + 1] = {Damageable, Info[3]}
		end
		
		return EstimatedDamageables
	end
end

Core.Damageables = setmetatable({}, {__mode = "k"})
Core.DamageableAdded = Instance.new("BindableEvent")
workspace.DescendantAdded:Connect(function(Obj)
	if not Core.Damageables[Obj] and (Obj:IsA("Humanoid") or (Obj:IsA("DoubleConstrainedValue") and Obj.Name == "Health")) then
		Core.Damageables[Obj] = true
		Core.DamageableAdded:Fire(Obj)
	end
end)

for _, Obj in ipairs(workspace:GetDescendants()) do
	if not Core.Damageables[Obj] and (Obj:IsA("Humanoid") or (Obj:IsA("DoubleConstrainedValue") and Obj.Name == "Health")) then
		Core.Damageables[Obj] = true
		Core.DamageableAdded:Fire(Obj)
	end
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
	if type(Obj) == "table" then
		return Obj.TeamColor, Obj.Neutral, Obj.Character
	elseif Obj:IsA("Player") then
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

function Core.CheckTeamkill(P1, P2, AllowTeamKill, InvertTeamKill)
	if (AllowTeamKill == nil and Core.Config.AllowTeamKill) or AllowTeamKill then return true end
	
	local TC1, N1, Char1 = Core.GetTeamInfo(P1)
	local TC2, N2, Char2 = Core.GetTeamInfo(P2)
	local TeamKill
	if Char1 == Char2 then
		TeamKill = Core.Config.AllowSelfDamage
	elseif N1 and N2 then
		TeamKill = Core.Config.AllowNeutralTeamKill
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
	
	if InvertTeamKill then
		return not TeamKill
	else
		return TeamKill
	end
end

function Core.GetTopDamageable(Damageable)
	while Damageable.Parent:IsA("Humanoid") or Damageable.Parent.Name == "Health" do
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

function Core.GetValidDamageable(Obj, Top)
	if Obj and Obj:IsDescendantOf(game) then
		local Damageable = Obj:FindFirstChild("Health") or Obj.Parent:FindFirstChildOfClass("Humanoid") or Obj.Parent:FindFirstChild("Health") or Obj.Parent.Parent:FindFirstChildOfClass("Humanoid") or Obj.Parent.Parent:FindFirstChild("Health")
		
		if Damageable and ((Damageable:IsA("Humanoid") and Damageable.Health > 0) or (Damageable:IsA("DoubleConstrainedValue") and Damageable.Value > 0)) then
			return Damageable
		end
	end
end

function Core.CanDamage(Attacker, Damageable, Hit, WeaponStat, Distance)
	local WeaponStats = type(WeaponStat) == "table" and WeaponStat or Core.GetWeapon(WeaponStat) or Core.GetWeaponStats(WeaponStat)
	return not Core.IgnoreFunction(Hit) and Core.CheckTeamkill(Attacker, Damageable, WeaponStats.AllowTeamKill, WeaponStats.InvertTeamKill) and (not Distance or Distance < 1) and not Damageable.Parent:FindFirstChildOfClass("ForceField")
end

function Core.CalculateDamageFor(Hit, WeaponStat, Distance)
	local WeaponStats = type(WeaponStat) == "table" and WeaponStat or Core.GetWeapon(WeaponStat) or Core.GetWeaponStats(WeaponStat)
	local Damage = WeaponStats.Damage
	
	local HitName = Hit.Name:lower()
	if HitName:find("head") or HitName == "uppertorso" or CollectionService:HasTag(Hit, "s2headdamage") then
		print(Damage, WeaponStats.HeadDamageMultiplier or Core.Config.HeadDamageMultiplier)
		Damage = Damage * (WeaponStats.HeadDamageMultiplier or Core.Config.HeadDamageMultiplier)
	elseif HitName:find("leg") or HitName:find("arm") or HitName:find("hand") or HitName:find("foot") or CollectionService:HasTag(Hit, "s2limbdamage") then
		Damage = Damage * (WeaponStats.LimbDamageMultiplier or Core.Config.LimbDamageMultiplier)
	end

	if Distance then
		if WeaponStats.InvertDistanceModifier or (WeaponStats.InvertDistanceModifier ~= false and Core.Config.InvertDistanceModifier) then
			Damage = Damage * (1 - Distance) * ((WeaponStats.DistanceDamageModifier or WeaponStats.DistanceModifier) or Core.Config.DistanceDamageModifier or 1)
		else
			Damage = Damage * (1 - Distance * ((WeaponStats.DistanceDamageModifier or WeaponStats.DistanceModifier) or Core.Config.DistanceDamageModifier or 1))
		end
	end
	
	return Damage
end

if Core.IsServer then
	local ClientDamage = Instance.new("RemoteEvent")
	ClientDamage.Name = "ClientDamage"
	ClientDamage.OnServerEvent:Connect(function(Attacker, Time, Hit, WeaponStat, DamageType, Distance)
		if tick() - Time > 1 then
			warn(Attacker.Name .. " took too long to send shot packet, discarding! - " .. (tick() - Time))
		else
			Core.DamageHelper(Attacker, Hit, WeaponStat, DamageType, Distance)
		end
	end)
	ClientDamage.Parent = script
	--Attacker, Hit, WeaponStat, DamageType, Distance, DamageSplits{Damageable, Damage}
	Core.ObjDamaged = Instance.new("BindableEvent")
	Core.DamageInfos = setmetatable({}, {__mode = "k"})
	function Core.ApplyDamage(Attacker, Damageable, Hit, WeaponStat, DamageType, Distance, Dmg, DamageSplits, RemainingDamage, DamageSplits)
		local WeaponStats = type(WeaponStat) == "table" and WeaponStat or Core.GetWeapon(WeaponStat) or Core.GetWeaponStats(WeaponStat)
		local Damage = Dmg * (RemainingDamage or 1)
		
		local Resistance = 1
		if Damageable:FindFirstChild("Resistances") then
			for _, ResistanceObj in ipairs(Damageable.Resistances:GetChildren()) do
				if ResistanceObj.Name == WeaponStat.Value or ResistanceObj.Name == DamageType or ResistanceObj.Name == "All" then
					Resistance = Resistance * ResistanceObj.Value
				end
			end
		end
		Resistance = Resistance * (WeaponStats.Resistances and WeaponStats.Resistances[DamageType] or Core.Config.Resistances and Core.Config.Resistances[DamageType] or 1)
		Damage = Damage * Resistance * (WeaponStats.GlobalDamageMultiplier or Core.Config.GlobalDamageMultiplier or 1)
		
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
					Core.ApplyDamage(Attacker, NextDamageable, Hit, WeaponStat, DamageType, Distance, Dmg, DamageSplits, (RemainingDamage or 1) - (Damage / Dmg))
				end
			else
				local NextDamageable = Damageable:FindFirstChild("Health")
				
				if NextDamageable and NextDamageable.Value > 0 and not CollectionService:HasTag(NextDamageable, "s2norecursivedamage") then
					Core.ApplyDamage(Attacker, NextDamageable, Hit, WeaponStat, DamageType, Distance, Dmg, DamageSplits, (RemainingDamage or 1) - (Damage / Dmg))
				end
			end
		end
		
		if First and next(DamageSplits) then
			if Players:GetPlayerFromCharacter(Damageable.Parent) then
				ClientDamage:FireClient(Players:GetPlayerFromCharacter(Core.GetTopDamageable(Damageable).Parent), DamageSplits, Attacker.Name)
			end
			
			if typeof(Attacker) == "Instance" then
				ClientDamage:FireClient(Attacker, DamageSplits)
			end
			
			Core.ObjDamaged:Fire(Attacker, Hit, WeaponStat, DamageType, Distance, DamageSplits)
		end
	end
else
	Core.ClientDamage = script:WaitForChild("ClientDamage")
	Core.ClientDamage.OnClientEvent:Connect(function(DamageSplits, Attacker)
		if Attacker then
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
			
			print("You did " .. (math.floor(math.abs(TotalDamage) * 100 + 0.5) / 100) .. (TotalDamage > 0 and " damage" or " healing") .. " to " .. Core.GetTopDamageable(DamageSplits[1][1]).Parent.Name .. " (" .. Split .. ")")
		end
	end)
end
-- returns Damageable if one is found, on server will also do damage
function Core.DamageHelper(Attacker, Hit, WeaponStat, DamageType, Distance)
	local Damageable = Core.GetValidDamageable(Hit)
	if Damageable and Core.CanDamage(Attacker, Damageable, Hit, WeaponStat, Distance) then
		local Damage = Core.CalculateDamageFor(Hit, WeaponStat, Distance)
		if Core.IsServer then
			Core.ApplyDamage(Attacker, Damage > 0 and Core.GetBottomDamageable(Damageable) or Damageable, Hit, WeaponStat, DamageType, Distance, Damage)
		end
		return Damageable, Damage
	end
end

local function ToolAdded(Plr, Tool)
	local StatObj = Core.FindWeaponStat(Tool)
	if StatObj and not Core.Weapons[StatObj] then
		if Core.IsServer then
			local Weapon = setmetatable({
				ServerPlaceholder = true,
				StatObj = StatObj,
				User = Plr,
				WeaponType = Core.GetWeaponType(StatObj),
				CurWeaponMode = 1,
			}, {__index = Core.GetWeaponStats(StatObj)})
			Core.Weapons[StatObj] = Weapon
			Tool.Equipped:Connect(function()
				Core.WeaponSelected:Fire(StatObj)
			end)
			Tool.Unequipped:Connect(function()
				Core.WeaponDeselected:Fire(StatObj)
			end)
		else
			Core.Setup(StatObj, Plr)
		end
	end
end

local function HandlePlr(Plr)
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
	Players.PlayerAdded:Connect(HandlePlr)
	for _, Plr in ipairs(Players:GetPlayers()) do
		HandlePlr(Plr)
	end

	Core.HandleServerReplication = function(User, StatObj, Time, ...)
		if StatObj and StatObj.Parent then
			local Weapon = Core.GetWeapon(StatObj)
			if Weapon then
				if tick() - Time > 0.6 then
					warn(User.Name .. " took too long to send shot packet, discarding! - "  .. (tick() - Time))
				else
					Weapon.WeaponType.HandleServerReplication(Weapon, User, ...)
				end
			else
				warn(tostring(User) .. " sent an invalid server S2 replication request: Weapon doesn't exist\n", User, StatObj, Time, ...)
			end
		else
			warn(tostring(User) .. " sent an invalid server S2 replication request: StatObj doesn't exist\n", User, StatObj, Time, ...)
		end
	end
	
	Core.WeaponReplication = Instance.new("RemoteEvent")
	Core.WeaponReplication.Name = "WeaponReplication"
	Core.WeaponReplication.OnServerEvent:Connect(Core.HandleServerReplication)
	Core.WeaponReplication.Parent = script
else
	HandlePlr(Players.LocalPlayer)
	
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
				warn(tostring(User) .. " sent an invalid client S2 replication request: WeaponType doesn't exist\n", User, StatObj, ...)
			end
		else
			warn(tostring(User) .. " sent an invalid client S2 replication request: StatObj doesn't exist\n", User, StatObj, ...)
		end
	end)
end

return Core
