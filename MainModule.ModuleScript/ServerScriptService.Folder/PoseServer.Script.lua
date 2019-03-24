local Players = game:GetService( "Players" )

local SendPose = Instance.new( "RemoteEvent" )

SendPose.Name = "SendPose"

SendPose.Parent = game:GetService( "ReplicatedStorage" )

local PlrPoses = { }

SendPose.OnServerEvent:Connect( function ( Plr, Pose, State )
	
	local UserId = tostring( Plr.UserId )
	
	PlrPoses[ UserId ] = PlrPoses[ UserId ] or { }
	
	PlrPoses[ UserId ][ Pose ] = State
	
	local Plrs = Players:GetPlayers( )
	
	for a = 1, #Plrs do
		
		if Plrs[ a ] ~= Plr then
			
			SendPose:FireClient( Plrs[ a ], Plr, Pose, State )
			
		end
		
	end
	
end )

Players.PlayerAdded:Connect( function ( Plr )
	
	if next( PlrPoses ) then
		
		SendPose:FireClient( Plr, PlrPoses )
		
	end
	
end )