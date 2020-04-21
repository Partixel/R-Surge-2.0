local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local DataStore2 = require(3913891878)

local Players, GroupService, CollectionService = game:GetService("Players"), game:GetService("GroupService"), game:GetService("CollectionService")

local function GetStat(Plr, StatKey)
	return Plr:WaitForChild("S2"):WaitForChild(StatKey)
end

local function CreateStat(Plr, StatKey, Options, S2Folder, leaderstats)
	if not Options.ShouldCreate or Options:ShouldCreate(Plr) then
		local Stat = Instance.new(Options.Type .. "Value")
		Stat.Name = StatKey
		if type(Options.Default) == "function" then
			Stat.Value = Options:Default(Plr)
		else
			Stat.Value = Options.Default
		end
		
		if Options.Save then
			local DataStore = DataStore2(StatKey, Plr)
			
			Stat.Value = DataStore:Get(Stat.Value)
			
			DataStore:BeforeSave(function()
				return Stat.Value
			end)
		end
		
		local ShowStat
		if Options.Show then
			ShowStat = Stat:Clone()
			ShowStat.Name = Options.Show
			
			ShowStat.Value = Options.FormatForDisplay and Options:FormatForDisplay(Stat.Value) or Stat.Value
			
			local MyChange
			Stat:GetPropertyChangedSignal("Value"):Connect(function()
				local Value = Options.FormatForDisplay and Options:FormatForDisplay(Stat.Value) or Stat.Value
				MyChange = Value ~= ShowStat.Value or nil
				ShowStat.Value = Value
			end)
			
			ShowStat:GetPropertyChangedSignal("Value"):Connect(function()
				if MyChange then
					MyChange = nil
				else
					Stat.Value = ShowStat.Value
				end
			end)
		end
		
		Stat.Parent = S2Folder
		
		return ShowStat
	end
end

--[[
	Type = String - The type of Value instance it creates (e.g. "String" creates a "StringValue")
	Show = String/nil - If this is a string it creates a leaderstat with the name of the string to display this stats value
	ShouldCreate = function - If this isn't nil and returns a falsey value then the stat won't be created
	Setup = function - If this exists it will be ran when the game starts to setup the stat
	Default = function/any - If there is no saved value for this stat and this is a function value of the stat will be set to whatever the function returns, else if this is a value it will be set to this
	FormatForDisplay = function - If this function exists it will be ran whenever the leaderstat is updated with the value of the stat. The leaderstat will be set to whatever this returns so you can format the stat to fit the leaderboard
	Save = boolean - If this is true it will save the value of this when the player leaves and load it again when they join
--]]
local Stats = setmetatable({
	Kills = {
		Type = "Int",
		Show = "Kills",
		Default = 0,
		Priority = 100,
	},
	Deaths = {
		Type = "Int",
		Show = "Deaths",
		Default = 0,
		Priority = 90,
	},
	Assists = {
		Type = "Int",
		Show = "Assists",
		Default = 0,
		Priority = 80,
	},
	Healed = {
		Type = "Number",
		Default = 0,
		Priority = 70,
		FormatForDisplay = function(self, Value)
			return math.floor(Value + 0.5)
		end,
	},
	Damaged = {
		Type = "Number",
		Default = 0,
		Priority = 60,
		FormatForDisplay = function(self, Value)
			return math.floor(Value + 0.5)
		end,
	},
	Credits = {
		Type = "Number",
		Default = 0,
		Priority = 50,
		Setup = function(self)
			if self.PerPayday and self.TimeBetweenPaydays then
				local NextPayday = Instance.new("NumberValue")
				NextPayday.Name = "NextPayday"
				NextPayday.Value = tick() + self.TimeBetweenPaydays
				NextPayday.Parent = game:GetService("ReplicatedStorage"):WaitForChild("S2")
				coroutine.wrap(function()
					while wait(self.TimeBetweenPaydays) do
						for _, Plr in ipairs(Players:GetPlayers()) do
							local CreditsStat = GetStat(Plr, "Credits")
							CreditsStat.Value = CreditsStat.Value + self.PerPayday
						end
						NextPayday.Value = tick() + self.TimeBetweenPaydays
					end
				end)()
			end
		end
	},
	Rank = {
		Type = "String",
		Show = "Rank",
		Priority = 40,
		ShouldCreate = function(self)
			return self.GroupId
		end,
		Default = function(self, Plr)
			local Rank = Plr:GetRoleInGroup(self.GroupId)
			if Rank == "Guest" then
				for _, Group in ipairs(GroupService:GetGroupsAsync(Plr.UserId)) do
					if self.Allies[Group.Id] then
						Rank.Value = Group.Name
						if Group.IsPrimary then
							break
						end
					end
				end
				if self.AllyReplacement and self.AllyReplacement[Rank] then
					return self.AllyReplacement[Rank]
				end
			elseif self.RankReplacements and self.RankReplacements[Rank] then
				return self.RankReplacements[Rank]
			end
			
			return Rank
		end,
		Setup = function(self)
			self.Allies = {}
			
			local Pages = GroupService:GetAlliesAsync(self.GroupId)
			while true do
				for a, b in pairs(Pages:GetCurrentPage()) do
					self.Allies[b.Id] = true
				end
				if Pages.IsFinished then
					break
				end
				Pages:AdvanceToNextPageAsync()
			end
		end,
	},
}, Core.Config.LeaderboardOverrides)

for StatKey, Options in pairs(Stats) do
	if rawget(Stats, StatKey) and Core.Config.LeaderboardOverrides[StatKey] then
		Options = setmetatable(Core.Config.LeaderboardOverrides[StatKey], {__index = Options})
		Stats[StatKey] = Options
	end
	
	if Options.Save then
		DataStore2.Combine("PartixelsVeryCoolMasterKey", StatKey .. "V1")
	end
	
	if (not Options.ShouldCreate or Options:ShouldCreate()) and Options.Setup then
		Options:Setup()
	end
end

local function UpdateCombined(Plr, ShowStat, Format, Values)
	ShowStat.Value = Format:gsub("%b{}", Values)
end

local function PlayerAdded(Plr)
	local S2Folder = Plr:FindFirstChild("S2") or Instance.new("Folder")
	S2Folder.Name = "S2"
	S2Folder.Parent = Plr
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	
	local SortedStats = {}
	for StatKey, Options in pairs(Stats) do
		local ShowStat = CreateStat(Plr, StatKey, Options, S2Folder, leaderstats)
		if ShowStat then
			SortedStats[#SortedStats + 1] = {ShowStat, Options.Priority}
		end
	end

	if Core.Config.LeaderboardCombinedStats then
		for Name, CombinedOptions in pairs(Core.Config.LeaderboardCombinedStats) do
			local ShowStat = Instance.new("StringValue")
			ShowStat.Name = Name
			
			local Values = {}
			for Key in string.gmatch(CombinedOptions.Format, "%b{}") do
				local StatKey = Key:sub(2, -2)
				local Stat = GetStat(Plr, StatKey)
				Values[Key] = tostring(Stats[StatKey].FormatForDisplay and Stats[StatKey]:FormatForDisplay(Stat.Value) or Stat.Value)
				Stat:GetPropertyChangedSignal("Value"):Connect(function()
					Values[Key] = tostring(Stats[StatKey].FormatForDisplay and Stats[StatKey]:FormatForDisplay(Stat.Value) or Stat.Value)
					UpdateCombined(Plr, ShowStat, CombinedOptions.Format, Values)
				end)
			end
			UpdateCombined(Plr, ShowStat, CombinedOptions.Format, Values)
			
			SortedStats[#SortedStats + 1] = {ShowStat, CombinedOptions.Priority}
		end
	end
	
	table.sort(SortedStats, function(a, b)
		return a[2] > b[2]
	end)
	
	for _, SortedStat in ipairs(SortedStats) do
		SortedStat[1].Parent = leaderstats
	end
	
	S2Folder.Parent = Plr
	leaderstats.Parent = Plr
end

Players.PlayerAdded:Connect(PlayerAdded)
for _, Plr in ipairs(Players:GetPlayers()) do
	PlayerAdded(Plr)
end

local RemoteKilled = Instance.new("RemoteEvent")
RemoteKilled.Name = "RemoteKilled"
RemoteKilled.Parent = game:GetService("ReplicatedStorage"):WaitForChild("S2")

local Kills = setmetatable({}, {__mode = "k"})
Core.DamageableDied.Event:Connect(function(Damageable)
	local Victim = Players:GetPlayerFromCharacter(Damageable.Parent)
	if Victim then
		local DeathsStat = GetStat(Victim, "Deaths")
		DeathsStat.Value = DeathsStat.Value + 1
	end
	
	if not CollectionService:HasTag(Damageable, "s2nofeed") then
		if not Core.DamageInfos[Damageable] or not Core.DamageInfos[Damageable].LastDamageInfo then
			local DeathInfo = {
				VictimInfos = {
					{
						Damageable = Damageable,
						User = Victim or {
							Name = (Damageable:FindFirstChild("UserName") and Damageable.UserName.Value or Damageable.Parent.Name),
							UserId = Damageable:FindFirstChild("UserId") and Damageable.UserId.Value or nil,
							TeamColor = Damageable:FindFirstChild("TeamColor") and Damageable.TeamColor.Value or nil
						}, 
						NoFeed = CollectionService:HasTag(Damageable, "s2nofeed")
					}
				}
			}
			script.Killed:Fire(DeathInfo)
			RemoteKilled:FireAllClients(DeathInfo)
			
			if Core.Config.SupportLegacyKOs then
				local Creator = Damageable:FindFirstChild("creator")
				if Creator and Creator.Value then
					warn(Damageable.Parent.Name .. " has died to non-S2 damage, please update to using S2s damage system")
					
					local KillsStat = GetStat(Victim, "Kills")
					KillsStat.Value = KillsStat.Value + 1
					
					if Stats.Credits.PerKill then
						local CreditsStat = GetStat(Victim, "Credits")
						CreditsStat.Value = CreditsStat.Value + Stats.Credits.PerKill
					end
				end
			end
		else
			local Killer, WeaponName, TypeName = Core.DamageInfos[Damageable].LastDamageInfo[1], Core.DamageInfos[Damageable].LastDamageInfo[3].Value, Core.DamageInfos[Damageable].LastDamageInfo[4]
			if Kills[Killer] and Kills[Killer][WeaponName .. TypeName] and not Kills[Killer][WeaponName .. TypeName][Damageable] then
				Kills[Killer][WeaponName .. TypeName][Damageable] = Core.DamageInfos[Damageable].LastDamageInfo[2]
			else
				local Killed = {[Damageable] = Core.DamageInfos[Damageable].LastDamageInfo[2]}
				Kills[Killer] = Kills[Killer] or {}
				Kills[Killer][WeaponName .. TypeName] = Killed
				
				wait(0.5)
				
				Kills[Killer][WeaponName .. TypeName] = nil
				if not next(Kills[Killer]) then
					Kills[Killer] = nil
				end
				
				local DeathInfo = {
					VictimInfos = {}, 
					TotalDamage = 0,
					With = WeaponName,
					Type = TypeName,
					Killer = Killer
				}
				
				local Kills = 0
				local Assisters = {}
				for Damageable, Hit in pairs(Killed) do
					if Damageable.Parent then
						if not CollectionService:HasTag(Damageable, "s2nokos") then
							Kills = Kills + 1
						end
						
						DeathInfo.VictimInfos[#DeathInfo.VictimInfos + 1] = {
							Damageable = Damageable,
							User = Players:GetPlayerFromCharacter(Damageable.Parent) or {
								Name = (Damageable:FindFirstChild("UserName") and Damageable.UserName.Value or Damageable.Parent.Name),
								UserId = Damageable:FindFirstChild("UserId") and Damageable.UserId.Value or nil,
								TeamColor = Damageable:FindFirstChild("TeamColor") and Damageable.TeamColor.Value or nil
							},
							NoFeed = CollectionService:HasTag(Damageable, "s2nofeed"),
							Hit = Hit.Name
						}
						
						if Core.DamageInfos[Damageable] then
							for a, b in pairs(Core.DamageInfos[Damageable]) do
								if a ~= "LastDamageInfo" then
									Assisters[a] = (Assisters[a] or 0) + b
								end
							end
						end
					end
				end
				
				DeathInfo.KillerDamage = Assisters[Killer]
				
				local Assister, AssisterDamage
				for a, b in pairs(Assisters) do
					DeathInfo.TotalDamage = DeathInfo.TotalDamage + b
					if not AssisterDamage or b > AssisterDamage then
						Assister = a
						AssisterDamage = b
				    end
				end
				
				if Assister ~= DeathInfo.Killer then
					DeathInfo.Assister, DeathInfo.AssisterDamage = Assister, AssisterDamage
				end
				
				if Kills ~= 0 then
					if DeathInfo.Killer then
						local Killer = type(DeathInfo.Killer) == "table" and DeathInfo.Killer.Owner or DeathInfo.Killer
						if typeof(Killer) == "Instance" then
							local KillsStat = GetStat(Killer, "Kills")
							KillsStat.Value = KillsStat.Value + Kills
							
							if Stats.Credits.PerKill then
								local CreditsStat = GetStat(Victim, "Credits")
								CreditsStat.Value = CreditsStat.Value + Stats.Credits.PerKill * Kills
							end
						end
					end
					
					if DeathInfo.Assister then
						local Assister = type(DeathInfo.Assister) == "table" and DeathInfo.Assister.Owner or DeathInfo.Assister
						if typeof(Assister) == "Instance" then
							
							local AssistsStat = GetStat(Assister, "Assists")
							AssistsStat.Value = AssistsStat.Value + Kills
							
							if Stats.Credits.PerAssist or Stats.Credits.PerKill then
								local CreditsStat = GetStat(Victim, "Credits")
								CreditsStat.Value = CreditsStat.Value + (Stats.Credits.PerAssist or Stats.Credits.PerKill / 2) * Kills
							end
						end
					end
				end
				
				script.Killed:Fire(DeathInfo)
				RemoteKilled:FireAllClients(DeathInfo)
			end
		end
	end
end)

Core.ObjDamaged.Event:Connect(function(Attacker, Hit, WeaponStat, DamageType, Distance, DamageSplits, RelativePosition)
	local TotalDamage = 0
	for _, DamageSplit in ipairs(DamageSplits) do
		if not CollectionService:HasTag(DamageSplit[1], "s2nokos") then
			TotalDamage = TotalDamage + DamageSplit[2]
		end
	end
	
	if TotalDamage ~= 0 then
		if typeof(Attacker) == "Instance" then
			local Type = TotalDamage > 0 and "Damaged" or"Healed"
			local Stat = GetStat(Attacker, Type)
			Stat.Value = Stat.Value + math.floor(TotalDamage * 100 + 0.5) / 100 * (TotalDamage > 0 and 1 or -1)
			
			if Stats.Credits["Per" .. Type] then
				local CreditsStat = GetStat(Attacker, "Credits")
				CreditsStat.Value = CreditsStat.Value + math.abs(TotalDamage) * Stats.Credits["Per" .. Type]
			end
		end
		
		if TotalDamage > 0 then
			for _, DamageSplit in ipairs(DamageSplits) do
				Core.DamageInfos[DamageSplit[1]] = Core.DamageInfos[DamageSplit[1]] or {}
				Core.DamageInfos[DamageSplit[1]][Attacker] = (Core.DamageInfos[DamageSplit[1]][Attacker] or 0) + DamageSplit[2]
				Core.DamageInfos[DamageSplit[1]].LastDamageInfo = {Attacker, Hit, WeaponStat, DamageType, Distance, DamageSplit}
				
				wait(30)
				
				if Core.DamageInfos[DamageSplit[1]] and Core.DamageInfos[DamageSplit[1]][Attacker] then
					Core.DamageInfos[DamageSplit[1]][Attacker] = Core.DamageInfos[DamageSplit[1]][Attacker] - DamageSplit[2]
					if Core.DamageInfos[DamageSplit[1]][Attacker] <= 0 then
						Core.DamageInfos[DamageSplit[1]][Attacker] = nil
						if not next(Core.DamageInfos[DamageSplit[1]]) then
							Core.DamageInfos[DamageSplit[1]] = nil
						end
					end
				end
			end
		end
	end
end)