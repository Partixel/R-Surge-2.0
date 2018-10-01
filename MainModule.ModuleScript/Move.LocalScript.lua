wait( )

if game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):FindFirstChild( script.Parent.Name ) then
	
	script.Parent:Destroy( )
	
	return
	
end

script.Parent.Parent = game:GetService( "Players" ).LocalPlayer.PlayerScripts

script.Parent.Disabled = false

script:Destroy( )