local Players = game:GetService( "Players" )

local SendPose = Instance.new( "RemoteEvent" )

SendPose.Name = "SendPose"

SendPose.Parent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )

local PlrPoses = { }

SendPose.OnServerEvent:Connect( function ( Plr, Pose, State, Time )
	
	local UserId = tostring( Plr.UserId )
	
	PlrPoses[ UserId ] = PlrPoses[ UserId ] or { }
	
	PlrPoses[ UserId ][ Pose ] = { State, Time }
	
	for _, OPlr in ipairs( Players:GetPlayers( ) )  do
		
		if OPlr ~= Plr then
			
			SendPose:FireClient( OPlr, Plr, Pose, State, Time )
			
		end
		
	end
	
end )

Players.PlayerRemoving:Connect( function ( Plr )
	
	PlrPoses[ tostring( Plr.UserId ) ] = nil
	
end )

Players.PlayerAdded:Connect( function ( Plr )
	
	Plr.CharacterAdded:Connect( function ( )
		
		PlrPoses[ tostring( Plr.UserId ) ] = nil
		
	end )
	
	if next( PlrPoses ) then
		
		SendPose:FireClient( Plr, PlrPoses )
		
	end
	
end )

for _, Plr in ipairs( Players:GetPlayers( ) ) do
	
	Plr.CharacterAdded:Connect( function ( )
		
		PlrPoses[ tostring( Plr.UserId ) ] = nil
		
	end )
	
end