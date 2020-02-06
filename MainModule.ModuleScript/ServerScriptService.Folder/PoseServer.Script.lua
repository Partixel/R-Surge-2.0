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

Players.PlayerAdded:Connect( function ( Plr )
	
	if next( PlrPoses ) then
		
		SendPose:FireClient( Plr, PlrPoses )
		
	end
	
end )