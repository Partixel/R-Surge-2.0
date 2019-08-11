local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local Players, GroupService, CollectionService = game:GetService( "Players" ), game:GetService( "GroupService" ), game:GetService( "CollectionService" )

local DataStore2 = require( 1936396537 )

DataStore2.Combine( "PartixelsVeryCoolMasterKey", "Credits" )

local RemoteKilled = Instance.new( "RemoteEvent" )

RemoteKilled.Name = "RemoteKilled"

RemoteKilled.Parent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )

if _G.S20Config.CountTeam then
	
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

local function OnDeath( Damageable )
	
	local Victim = game:GetService( "Players" ):GetPlayerFromCharacter( Damageable.Parent )
	
	if Victim then
		
		local WOs = Victim:FindFirstChild( "WOs", true )
		
		if WOs then WOs.Value = WOs.Value + 1 end
		
	end
	
	if not Core.DamageInfos[ Damageable ] and not CollectionService:HasTag( Damageable, "s2nofeed" ) then
		
		local DeathInfo = { VictimInfos = { { Damageable = Damageable, User = Victim or  { Name = ( Damageable:FindFirstChild( "UserName" ) and Damageable.UserName.Value or Damageable.Parent.Name ), UserId = Damageable:FindFirstChild( "UserId" ) and Damageable.UserId.Value or nil, TeamColor = Damageable:FindFirstChild( "TeamColor" ) and Damageable.TeamColor.Value or nil }, NoFeed = CollectionService:HasTag( Damageable, "s2nofeed" ) } } }
		
		script.Killed:Fire( DeathInfo )
		
		RemoteKilled:FireAllClients( DeathInfo )
		
		if _G.S20Config.SupportLegacyKOs then
			
			local Creator = Damageable:FindFirstChild( "creator" )
			
			if Creator and Creator.Value then
				
				warn( Damageable.Parent.Name .. " has died to non-S2 damage, please update to using S2s damage system" )
				
				Creator.Value:WaitForChild( "leaderstats" ):WaitForChild( "KOs" ).Value = Creator.Value.leaderstats.KOs.Value + 1
				
				if _G.S20Config.CreditsPerKill then
					
					local Credits = Creator.Value:FindFirstChild( "Credits", true )
					
					if Credits then Credits.Value = math.floor( Credits.Value + _G.S20Config.CreditsPerKill, 0 ) end
					
				end
				
			end
			
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

Core.ObjDamaged.Event:Connect( function ( User, Damageable, Amount, PrevHealth )
	
	if typeof( User ) == "Instance" and ( _G.S20Config.CreditsPerKill or _G.S20Config.CreditsPerHeal ) and not CollectionService:HasTag( Damageable, "s2nokos" ) then
		
		local Credits = User:FindFirstChild( "Credits", true )
		
		if Credits then
			
			Credits.Value = math.floor( Credits.Value + math.abs( Amount ) * ( ( Amount > 0 and _G.S20Config.CreditsPerDamage or _G.S20Config.CreditsPerHeal ) or 0 ), 0 )
			
		end
		
	end
	
end )

Core.KilledEvents[ "Leaderboard" ] = function ( Damageables, Killer, WeaponName, TypeName )
	
	local DeathInfo = { VictimInfos = { }, TotalDamage = 0, With = WeaponName, Type = TypeName, Killer = Killer }
	
	local KOs = 0
	
	local Assisters = { }
	
	for Damageable, Hit in pairs( Damageables ) do
		
		if Damageable.Parent then
			
			if not CollectionService:HasTag( Damageable, "s2nokos" ) then KOs = KOs + 1 end
			
			DeathInfo.VictimInfos[ #DeathInfo.VictimInfos + 1 ] = { Damageable = Damageable, User = game:GetService( "Players" ):GetPlayerFromCharacter( Damageable.Parent ) or { Name = ( Damageable:FindFirstChild( "UserName" ) and Damageable.UserName.Value or Damageable.Parent.Name ), UserId = Damageable:FindFirstChild( "UserId" ) and Damageable.UserId.Value or nil, TeamColor = Damageable:FindFirstChild( "TeamColor" ) and Damageable.TeamColor.Value or nil }, NoFeed = CollectionService:HasTag( Damageable, "s2nofeed" ), Hit = Hit }
			
			if Core.DamageInfos[ Damageable ] then
				
				for a, b in pairs( Core.DamageInfos[ Damageable ] ) do
					
					Assisters[ a ] = ( Assisters[ a ] or 0 ) + b
					
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
	
	if _G.S20Config.ShowAssists and Assister ~= DeathInfo.Killer then
		
		DeathInfo.Assister, DeathInfo.AssisterDamage = Assister, AssisterDamage
		
	end
	
	if KOs ~= 0 then
		
		if DeathInfo.Killer then
			
			if typeof( DeathInfo.Killer ) == "Instance" then
				
				DeathInfo.Killer:WaitForChild( "leaderstats" ):WaitForChild( "KOs" ).Value = DeathInfo.Killer.leaderstats.KOs.Value + KOs
				
				if _G.S20Config.CreditsPerKill then
					
					local Credits = DeathInfo.Killer:FindFirstChild( "Credits", true )
					
					if Credits then Credits.Value = math.floor( Credits.Value + KOs * _G.S20Config.CreditsPerKill, 0 ) end
					
				end
				
			end
			
		end
		
		if DeathInfo.Assister then
			
			if typeof( DeathInfo.Assister ) == "Instance" then
				
				DeathInfo.Assister:WaitForChild( "leaderstats" ):WaitForChild( "Assists" ).Value = DeathInfo.Assister.leaderstats.Assists.Value + KOs
				
				if _G.S20Config.CreditsPerKill then
					
					local Credits = DeathInfo.Assister:FindFirstChild( "Credits", true )
					
					if Credits then Credits.Value = math.floor( Credits.Value + KOs * ( _G.S20Config.CreditsPerAssist or _G.S20Config.CreditsPerKill / 2 ), 0 ) end
					
				end
				
			end
			
		end
		
	end
	
	script.Killed:Fire( DeathInfo )
	
	RemoteKilled:FireAllClients( DeathInfo )
		
end

local Allies

if _G.S20Config.RankGroupId then
	
	Allies = { }
	
	local Pages = GroupService:GetAlliesAsync( _G.S20Config.RankGroupId )
	
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

local function PlayerAdded( Plr )
	
	local leaderstats = Instance.new( "IntValue" )
	
	leaderstats.Name = "leaderstats"
	
	local KOs = Instance.new( "IntValue" )
	
	KOs.Parent = leaderstats
	
	KOs.Name = "KOs"
	
	local Assists = Instance.new( "IntValue" )
	
	Assists.Parent = _G.S20Config.ShowAssists and leaderstats or Plr
	
	Assists.Name = "Assists"
	
	local WOs = Instance.new( "IntValue" )
	
	WOs.Parent = _G.S20Config.ShowWOs and leaderstats or Plr
	
	WOs.Name = "WOs"
	
	if _G.S20Config.RankGroupId ~= nil then
		
		local Rank = Instance.new( "StringValue" )
		
		Rank.Parent = leaderstats
		
		Rank.Name = "Rank"
		
		Rank.Value = Plr:GetRoleInGroup( _G.S20Config.RankGroupId )
		
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
	
	Credits.Parent = _G.S20Config.ShowCredits and leaderstats or Plr
	
	Credits.Name = "Credits"
	
	Credits.Value = _G.S20Config.SaveCredits and DataStore2( "Credits", Plr ):Get( ) or _G.S20Config.DefaultCredits or 0
	
	if _G.S20Config.SaveCredits then
		
		DataStore2( "Credits", Plr ):BeforeSave( function ( )
			
			return Credits.Value
			
		end )
		
	end
	
	if _G.S20Config.CreditsPerPayday and _G.S20Config.CreditsPerPayday ~= 0 and _G.S20Config.PaydayDelay and _G.S20Config.PaydayDelay > 0 then
		
		spawn( function ( )
			
			while wait( _G.S20Config.PaydayDelay ) do
				
				Credits.Value = Credits.Value + _G.S20Config.CreditsPerPayday
				
			end
			
		end )
		
	end
	
	leaderstats.Parent = Plr
	
end

game:GetService( "Players" ).PlayerAdded:Connect( PlayerAdded )

for _, Plr in ipairs( game:GetService( "Players" ):GetPlayers( ) ) do
	
	PlayerAdded( Plr )
	
end