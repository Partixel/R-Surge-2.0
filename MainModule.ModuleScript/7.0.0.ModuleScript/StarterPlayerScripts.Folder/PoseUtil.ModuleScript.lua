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

local TimeSync = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("TimeSync"))

local Watching = { }

function Module.Watch( Pose, Key, Func )
	
	Watching[ Pose ] = Watching[ Pose ] or { }
	
	Watching[ Pose ][ Key ] = Func
	
	local t
	
	for a, b in pairs( PlrPoses ) do
		
		if b[ Pose ] then
			
			if not t then t = TimeSync.GetServerTime() end
			
			local Plr = game.Players:GetPlayerByUserId( tonumber( a ) )
			
			if Plr then
				if not b[ Pose ][2] then warn(Pose, Plr, b[ Pose ][1], b[ Pose ][2]) error"SCREENSHOT ABOVE AND SHOW PARTIXEL" end
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
		
		local t = TimeSync.GetServerTime()
		
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
	if not Time then warn(Pose, Plr, State, Time) error"SCREENSHOT ABOVE AND SHOW PARTIXEL" end
	Module.CallWatched( Pose, Plr, State, TimeSync.GetServerTime() - Time )
	
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
		
		SendPose:FireServer( Pose, State, TimeSync.GetServerTime() )
		
	end
	
end

function Module.GetPose( Pose, Plr )
	
	Plr = Plr or Players.LocalPlayer
	
	local UserId = tostring( Plr.UserId )
	
	return PlrPoses[ UserId ] and PlrPoses[ UserId ][ Pose ]
	
end

return Module