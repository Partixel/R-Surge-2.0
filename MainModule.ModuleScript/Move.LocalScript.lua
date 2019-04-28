if game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):FindFirstChild( script.Parent.Name ) then
	
	wait( )
	
	script.Parent:Destroy( )
	
	return
	
end

local Clone = script.Parent:Clone( )

Clone.Move:Destroy( )

Clone.Parent = game:GetService( "Players" ).LocalPlayer.PlayerScripts

if Clone:IsA( "Script" ) or Clone:IsA( "LocalScript" ) then
	
	Clone.Disabled = false
	
end

wait( )

script.Parent:Destroy( )