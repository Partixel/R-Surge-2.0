local Module = { }

local RunService = game:GetService( "RunService" )

local Players = game:GetService( "Players" )

local PlrPoses = { }

Players.PlayerRemoving:Connect( function ( Plr )
	
	PlrPoses[ tostring( Plr.UserId ) ] = nil
	
end )

Players.PlayerAdded:Connect( function ( Plr )
	
	Plr.CharacterAdded:Connect( function ( )
		
		PlrPoses[ tostring( Plr.UserId ) ] = nil
		
	end )
	
end )

local Plrs = Players:GetPlayers( )

for a = 1, #Plrs do
	
	Plrs[ a ].CharacterAdded:Connect( function ( )
		
		PlrPoses[ tostring( Plrs[ a ].UserId ) ] = nil
		
	end )
	
end

if game["Run Service"]:IsClient( ) then
	
	repeat wait( ) until _G.ServerOffset
	
	local Watching = { }
	
	function Module.Watch( Pose, Key, Func )
		
		Watching[ Pose ] = Watching[ Pose ] or { }
		
		Watching[ Pose ][ Key ] = Func
		
		local t
		
		for a, b in pairs( PlrPoses ) do
			
			if b[ Pose ] then
				
				if not t then t = tick( ) + _G.ServerOffset end
				
				local Plr = game.Players:GetPlayerByUserId( tonumber( a ) )
				
				if Plr then
					
					Func( Plr, b[ Pose ].State, t - b[ Pose ].Time )
					
				end
				
			end
			
		end
		
	end
	
	function Module.CallWatched( Pose, Plr, State, Offset )
		
		if Watching[ Pose ] then
			
			for a, b in pairs( Watching[ Pose ] ) do
				
				b( Plr, State, Offset )
				
			end
			
		end
		
	end
	
	script.SendPose.OnClientEvent:Connect( function ( Plr, Pose, State )
		
		if type( Plr ) == "table" then
			
			PlrPoses = Plr
			
			local t = tick( ) + _G.ServerOffset
			
			for a, b in pairs( PlrPoses ) do
				
				local Plr = game.Players:GetPlayerByUserId( tonumber( a ) )
				
				if Plr then
					
					for c, d in pairs( b ) do
						
						Module.CallWatched( c, Plr, d.State, t - d.Time )
						
					end
					
				end
				
			end
			
			return
			
		end
		
		local UserId = tostring( Plr.UserId )
		
		PlrPoses[ UserId ] = PlrPoses[ UserId ] or { }
		
		PlrPoses[ UserId ][ Pose ] = State
		
		Module.CallWatched( Pose, Plr, State.State, tick( ) + _G.ServerOffset - State.Time )
		
	end )
	
	function Module.SetPose( Pose, State, Plr, NoRep )
		
		State = State or nil
		
		Plr = Plr or Players.LocalPlayer
		
		local UserId = tostring( Plr.UserId )
		
		if ( State == nil and ( PlrPoses[ UserId ] == nil or PlrPoses[ UserId ][ Pose ] == nil ) ) or ( PlrPoses[ UserId ] and PlrPoses[ UserId ][ Pose ] == State ) then return end
		
		PlrPoses[ UserId ] = PlrPoses[ UserId ] or { }
		
		PlrPoses[ UserId ][ Pose ] = State 
		
		if not NoRep then
			
			Module.CallWatched( Pose, Plr, State, 0 )
			
			if not RunService:IsServer( ) then
				
				script.SendPose:FireServer( Pose, { State = State, Time = tick( ) + _G.ServerOffset } )
				
			end
			
		end
		
	end
	
	function Module.GetPose( Pose, Plr )
		
		Plr = Plr or Players.LocalPlayer
		
		local UserId = tostring( Plr.UserId )
		
		return PlrPoses[ UserId ] and PlrPoses[ UserId ][ Pose ]
		
	end
	
end

if game["Run Service"]:IsServer( ) then
	
	script.SendPose.OnServerEvent:Connect( function ( Plr, Pose, State )
		
		local UserId = tostring( Plr.UserId )
		
		PlrPoses[ UserId ] = PlrPoses[ UserId ] or { }
		
		PlrPoses[ UserId ][ Pose ] = State
		
		local Plrs = Players:GetPlayers( )
		
		for a = 1, #Plrs do
			
			if Plrs[ a ] ~= Plr then
				
				script.SendPose:FireClient( Plrs[ a ], Plr, Pose, State )
				
			end
			
		end
		
	end )
	
	Players.PlayerAdded:Connect( function ( Plr )
		
		if next( PlrPoses ) then
			
			script.SendPose:FireClient( Plr, PlrPoses )
			
		end
		
	end )
	
end

return Module