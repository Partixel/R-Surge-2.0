require( script.Parent.Config )

script.Parent.Config.Parent = game:GetService( "ReplicatedStorage" )

if game:GetService( "ServerStorage" ):FindFirstChild( "S2" ) and game:GetService( "ServerStorage" ).S2:FindFirstChild( "MainModule" ) then
	
	require( game:GetService( "ServerStorage" ).S2.MainModule )
	
else
	
	require( 543865777 )
	
end

script.Parent:Destroy( )