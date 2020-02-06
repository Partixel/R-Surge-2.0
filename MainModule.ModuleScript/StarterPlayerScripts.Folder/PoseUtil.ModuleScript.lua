local Players = game:GetService( "Players" )

local SendPose = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "SendPose" )

local Module = { }

local PlrPoses = { }

Players.PlayerRemoving:Connect( function ( Plr )
	
	PlrPoses[ tostring( Plr.UserId ) ] = nil
	
end )

Players.PlayerAdded:Connect( function ( Plr )
	
	Plr.CharacterAdded:Connect( function ( )
		
		PlrPoses[ tostring( Plr.UserId ) ] = nil
		
	end )
	
end )

for _, Plr in ipairs( Players:GetPlayers( ) ) do
	
	Plr.CharacterAdded:Connect( function ( )
		
		PlrPoses[ tostring( Plr.UserId ) ] = nil
		
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
					
					Func( Plr, b[ Pose ][1], t - b[ Pose ][2] )
					
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
	
	SendPose.OnClientEvent:Connect( function ( Plr, Pose, State, Time )
		
		if type( Plr ) == "table" then
			
			PlrPoses = Plr
			
			local t = tick( ) + _G.ServerOffset
			
			for a, b in pairs( PlrPoses ) do
				
				local Plr = game.Players:GetPlayerByUserId( tonumber( a ) )
				
				if Plr then
					
					for c, d in pairs( b ) do
						
						Module.CallWatched( c, Plr, d[1], t - d[2] )
						
					end
					
				end
				
			end
			
			return
			
		end
		
		local UserId = tostring( Plr.UserId )
		
		PlrPoses[ UserId ] = PlrPoses[ UserId ] or { }
		
		PlrPoses[ UserId ][ Pose ] = {State, Time}
		
		Module.CallWatched( Pose, Plr, State, tick( ) + _G.ServerOffset - Time )
		
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
			
			SendPose:FireServer( Pose, State, tick( ) + _G.ServerOffset )
			
		end
		
	end
	
	function Module.GetPose( Pose, Plr )
		
		Plr = Plr or Players.LocalPlayer
		
		local UserId = tostring( Plr.UserId )
		
		return PlrPoses[ UserId ] and PlrPoses[ UserId ][ Pose ]
		
	end
	
end

return Module