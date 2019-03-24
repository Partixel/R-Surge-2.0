wait( )

if game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):FindFirstChild( script.Parent.Name ) then
	
	script.Parent:Destroy( )
	
	return
	
end

script.Parent.Parent = game:GetService( "Players" ).LocalPlayer.PlayerScripts

if script.Parent:IsA( "Script" ) or script.Parent:IsA( "LocalScript" ) then
	
	script.Parent.Disabled = false
	
end

script:Destroy( )