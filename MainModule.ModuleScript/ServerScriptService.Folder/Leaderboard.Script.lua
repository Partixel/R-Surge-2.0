local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local Players, GroupService, CollectionService = game:GetService( "Players" ), game:GetService( "GroupService" ), game:GetService( "CollectionService" )

local DataStore2 = require( 3913891878 )

DataStore2.Combine( "PartixelsVeryCoolMasterKey", "Credits" )

local RemoteKilled = Instance.new( "RemoteEvent" )

RemoteKilled.Name = "RemoteKilled"

RemoteKilled.Parent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )

if Core.Config.TeamCounts then
	
	local Teams = game:GetService( "Teams" )
	
	for _, Team in ipairs( Teams:GetTeams( ) ) do
		
		local Name = Team.Name
		
		Team.Name = Name .. " - " .. #Team:GetPlayers( )
		
		local Obj = Instance.new( "ObjectValue" )
		
		Obj.Name = "S2_" .. Name
		
		Obj.Value = Team
		
		Obj.Parent = Teams
		
		Team.PlayerAdded:Connect( function ( )
			
			Team.Name = Name .. " - " .. #Team:GetPlayers( )
			
		end )
		
		Team.PlayerRemoved:Connect( function ( )
			
			Team.Name = Name .. " - " .. #Team:GetPlayers( )
			
		end )
		
		Players.PlayerRemoving:Connect( function ( )
			
			Team.Name = Name .. " - " .. #Team:GetPlayers( )
			
		end )
		
	end
	
end

local Kills = setmetatable( { }, { __mode = "k" } )

local function OnDeath( Damageable )
	
	local Victim = game:GetService( "Players" ):GetPlayerFromCharacter( Damageable.Parent )
	
	if Victim then
		
		local WOs = Victim:FindFirstChild( "WOs", true )
		
		if WOs then WOs.Value = WOs.Value + 1 end
		
	end
	
	if not CollectionService:HasTag( Damageable, "s2nofeed" ) then
		
		if not Core.DamageInfos[ Damageable ] or not Core.DamageInfos[ Damageable ].LastDamageInfo then
			
			local DeathInfo = { VictimInfos = { { Damageable = Damageable, User = Victim or  { Name = ( Damageable:FindFirstChild( "UserName" ) and Damageable.UserName.Value or Damageable.Parent.Name ), UserId = Damageable:FindFirstChild( "UserId" ) and Damageable.UserId.Value or nil, TeamColor = Damageable:FindFirstChild( "TeamColor" ) and Damageable.TeamColor.Value or nil }, NoFeed = CollectionService:HasTag( Damageable, "s2nofeed" ) } } }
			
			script.Killed:Fire( DeathInfo )
			
			RemoteKilled:FireAllClients( DeathInfo )
			
			if Core.Config.SupportLegacyKOs then
				
				local Creator = Damageable:FindFirstChild( "creator" )
				
				if Creator and Creator.Value then
					
					warn( Damageable.Parent.Name .. " has died to non-S2 damage, please update to using S2s damage system" )
					
					Creator.Value:WaitForChild( "leaderstats" ):WaitForChild( "KOs" ).Value = Creator.Value.leaderstats.KOs.Value + 1
					
					if Core.Config.CreditsPerKill then
						
						local Credits = Creator.Value:FindFirstChild( "Credits", true )
						
						if Credits then Credits.Value = math.floor( Credits.Value + Core.Config.CreditsPerKill, 0 ) end
						
					end
					
				end
				
			end
			
		else
			
			local Killer, WeaponName, TypeName = Core.DamageInfos[ Damageable ].LastDamageInfo[1], Core.DamageInfos[ Damageable ].LastDamageInfo[3].Value, Core.DamageInfos[ Damageable ].LastDamageInfo[4]
			
			if Kills[ Killer ] and Kills[ Killer ][ WeaponName .. TypeName ] and not Kills[ Killer ][ WeaponName .. TypeName ][ Damageable ] then
				
				Kills[ Killer ][ WeaponName .. TypeName ][ Damageable ] = Core.DamageInfos[ Damageable ].LastDamageInfo[2]
				
				return
				
			end
			
			local Killed = { [ Damageable ] = Core.DamageInfos[ Damageable ].LastDamageInfo[2] }
			
			Kills[ Killer ] = Kills[ Killer ] or { }
			
			Kills[ Killer ][ WeaponName .. TypeName ] = Killed
			
			wait( 0.5 )
			
			Kills[ Killer ][ WeaponName .. TypeName ] = nil
			
			if not next( Kills[ Killer ] ) then
				
				Kills[ Killer ] = nil
				
			end
			
			local DeathInfo = { VictimInfos = { }, TotalDamage = 0, With = WeaponName, Type = TypeName, Killer = Killer }
			
			local KOs = 0
			
			local Assisters = { }
			
			for Damageable, Hit in pairs( Killed ) do
				
				if Damageable.Parent then
					
					if not CollectionService:HasTag( Damageable, "s2nokos" ) then KOs = KOs + 1 end
					
					DeathInfo.VictimInfos[ #DeathInfo.VictimInfos + 1 ] = { Damageable = Damageable, User = game:GetService( "Players" ):GetPlayerFromCharacter( Damageable.Parent ) or { Name = ( Damageable:FindFirstChild( "UserName" ) and Damageable.UserName.Value or Damageable.Parent.Name ), UserId = Damageable:FindFirstChild( "UserId" ) and Damageable.UserId.Value or nil, TeamColor = Damageable:FindFirstChild( "TeamColor" ) and Damageable.TeamColor.Value or nil }, NoFeed = CollectionService:HasTag( Damageable, "s2nofeed" ), Hit = Hit }
					
					if Core.DamageInfos[ Damageable ] then
						
						for a, b in pairs( Core.DamageInfos[ Damageable ] ) do
							
							if a ~= "LastDamageInfo" then
								
								Assisters[ a ] = ( Assisters[ a ] or 0 ) + b
								
							end
							
						end
						
					end
					
				end
				
			end
			
			DeathInfo.KillerDamage = Assisters[ Killer ]
			
			local Assister, AssisterDamage
			
			for a, b in pairs( Assisters ) do
				
				DeathInfo.TotalDamage = DeathInfo.TotalDamage + b
				
				if not AssisterDamage or b > AssisterDamage then
					
					Assister = a
					
					AssisterDamage = b
					
			    end
				
			end
			
			if Core.Config.ShowAssists and Assister ~= DeathInfo.Killer then
				
				DeathInfo.Assister, DeathInfo.AssisterDamage = Assister, AssisterDamage
				
			end
			
			if KOs ~= 0 then
				
				if DeathInfo.Killer then
					
					if typeof( DeathInfo.Killer ) == "Instance" then
						
						DeathInfo.Killer:WaitForChild( "leaderstats" ):WaitForChild( "KOs" ).Value = DeathInfo.Killer.leaderstats.KOs.Value + KOs
						
						if Core.Config.CreditsPerKill then
							
							local Credits = DeathInfo.Killer:FindFirstChild( "Credits", true )
							
							if Credits then Credits.Value = math.floor( Credits.Value + KOs * Core.Config.CreditsPerKill, 0 ) end
							
						end
						
					end
					
				end
				
				if DeathInfo.Assister then
					
					if typeof( DeathInfo.Assister ) == "Instance" then
						
						DeathInfo.Assister:WaitForChild( "leaderstats" ):WaitForChild( "Assists" ).Value = DeathInfo.Assister.leaderstats.Assists.Value + KOs
						
						if Core.Config.CreditsPerKill then
							
							local Credits = DeathInfo.Assister:FindFirstChild( "Credits", true )
							
							if Credits then Credits.Value = math.floor( Credits.Value + KOs * ( Core.Config.CreditsPerAssist or Core.Config.CreditsPerKill / 2 ), 0 ) end
							
						end
						
					end
					
				end
				
			end
			
			script.Killed:Fire( DeathInfo )
			
			RemoteKilled:FireAllClients( DeathInfo )
			
		end
		
	end
	
end

Core.DamageableAdded.Event:Connect( function ( Damageable )
	
	if Damageable:IsA( "Humanoid" ) then
		
		Damageable.Died:Connect( function ( )
			
			OnDeath( Damageable )
			
		end )
		
	else
		
		local Ev; Ev = Damageable.Changed:Connect( function ( )
			
			if Damageable.Value <= 0 then
				
				OnDeath( Damageable )
				
				Ev:Disconnect( )
				
			end
			
		end )
		
	end
	
end )

for a, b in pairs( Core.Damageables ) do
	
	if a:IsA( "Humanoid" ) then
		
		a.Died:Connect( function ( )
			
			OnDeath( a )
			
		end )
		
	else
		
		local Ev; Ev = a.Changed:Connect( function ( )
			
			if a.Value <= 0 then
				
				OnDeath( a )
				
				Ev:Disconnect( )
				
			end
			
		end )
		
	end
	
end

Core.ObjDamaged.Event:Connect(function(Attacker, Hit, WeaponStat, DamageType, Distance, DamageSplits)
	local TotalDamage = 0
	for _, DamageSplit in ipairs(DamageSplits) do
		if not CollectionService:HasTag(DamageSplit[1], "s2nokos") then
			TotalDamage = TotalDamage + DamageSplit[2]
		end
	end
	
	if typeof(Attacker) == "Instance" and Attacker:FindFirstChild("leaderstats") then
		local Stat = TotalDamage > 0 and Attacker.leaderstats:FindFirstChild("Damaged") or Attacker.leaderstats:FindFirstChild("Healed")
		if Stat then
			Stat.Value = Stat.Value + math.floor(TotalDamage * 100 + 0.5) / 100 * (TotalDamage > 0 and 1 or -1)
		end
		
		if (Core.Config.CreditsPerDamage and TotalDamage > 0) or (Core.Config.CreditsPerHeal and TotalDamage < 0) then
			local Credits = Attacker:FindFirstChild("Credits", true)
			if Credits then
				Credits.Value = math.floor(Credits.Value + math.abs(TotalDamage) * (TotalDamage > 0 and Core.Config.CreditsPerDamage or Core.Config.CreditsPerHeal), 0)
			end
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
end)

local Allies

if Core.Config.RankGroupId then
	
	Allies = { }
	
	local Pages = GroupService:GetAlliesAsync( Core.Config.RankGroupId )
	
	while true do
		
		for a, b in pairs( Pages:GetCurrentPage( ) ) do
			
			Allies[ b.Id ] = true
			
		end
		
		if Pages.IsFinished then
			
			break
			
		end
		
		Pages:AdvanceToNextPageAsync( )
		
	end
	
	Pages = nil
	
end

if Core.Config.CreditsPerPayday and Core.Config.CreditsPerPayday ~= 0 and Core.Config.PaydayDelay and Core.Config.PaydayDelay > 0 then
	
	coroutine.wrap( function ( )
		
		while wait( Core.Config.PaydayDelay ) do
			
			for _, Plr in ipairs( Players:GetPlayers( ) ) do
				
				local Credits = Core.Config.ShowCredits and ( Plr:FindFirstChild( "leaderstats" ) and Plr.leaderstats:FindFirstChild( "Credits" ) ) or Plr:FindFirstChild( "Credits" )
				
				if Credits then
					
					Credits.Value = Credits.Value + Core.Config.CreditsPerPayday
					
				end
				
			end
			
		end
		
	end )( )
	
end

local function PlayerAdded( Plr )
	
	local leaderstats = Instance.new( "IntValue" )
	
	leaderstats.Name = "leaderstats"
	
	local KOs = Instance.new( "IntValue" )
	
	KOs.Parent = leaderstats
	
	KOs.Name = "KOs"
	
	local Assists = Instance.new( "IntValue" )
	
	Assists.Parent = Core.Config.ShowAssists and leaderstats or Plr
	
	Assists.Name = "Assists"
	
	local WOs = Instance.new( "IntValue" )
	
	WOs.Parent = Core.Config.ShowWOs and leaderstats or Plr
	
	WOs.Name = "WOs"
	
	if Core.Config.RankGroupId ~= nil then
		
		local Rank = Instance.new( "StringValue", leaderstats )
		
		Rank.Name = "Rank"
		
		Rank.Value = Plr:GetRoleInGroup( Core.Config.RankGroupId )
		
		if Rank.Value == "Guest" then
			
			for _, Group in ipairs( GroupService:GetGroupsAsync( Plr.UserId ) ) do
				
				if Allies[ Group.Id ] then
					
					Rank.Value = Group.Name
					
					if Group.IsPrimary then
						
						break
						
					end
					
				end
				
			end
			
		end
		
	end
	
	local Credits = Instance.new( "IntValue" )
	
	Credits.Name = "Credits"
	
	Credits.Value = Core.Config.SaveCredits and DataStore2( "Credits", Plr ):Get( ) or Core.Config.DefaultCredits or 0
	
	if Core.Config.SaveCredits then
		
		DataStore2( "Credits", Plr ):BeforeSave( function ( )
			
			return Credits.Value
			
		end )
		
	end
	
	Credits.Parent = Core.Config.ShowCredits and leaderstats or Plr
	
	if Core.Config.ShowDamaged then
		
		local Damage = Instance.new( "NumberValue", leaderstats )
		
		Damage.Name = "Damaged"
		
	end
	
	if Core.Config.ShowHealed then
		
		local Damage = Instance.new( "NumberValue", leaderstats )
		
		Damage.Name = "Healed"
		
	end
	
	leaderstats.Parent = Plr
	
end

game:GetService( "Players" ).PlayerAdded:Connect( PlayerAdded )

for _, Plr in ipairs( game:GetService( "Players" ):GetPlayers( ) ) do
	
	PlayerAdded( Plr )
	
end