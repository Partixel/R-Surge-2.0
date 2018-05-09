return function ( Main, ModFolder, VH_Events )
	
	local ReplicatedStorage = game:GetService( "ReplicatedStorage" )
	
	while not _G.S20Config do wait( ) end
	
	local PoseUtil = require( ReplicatedStorage:WaitForChild( "PoseUtil" ) )
	
	local KeybindUtil = require( ReplicatedStorage:WaitForChild( "KeybindUtil" ) )
	
	_G.S20Config.AllowSprinting = ReplicatedStorage:WaitForChild( "Sprint" ).Value
	
	_G.S20Config.AllowCrouching = ReplicatedStorage:WaitForChild( "Crouch" ).Value
	
	_G.S20Config.AllowAtEase = ReplicatedStorage:WaitForChild( "AtEase" ).Value
	
	_G.S20Config.AllowSalute = ReplicatedStorage:WaitForChild( "Salute" ).Value
	
	_G.S20Config.AllowCharacterRotation = ReplicatedStorage:WaitForChild( "CharacterRotation" ).Value
	
	_G.S20Config.AllowSurrender = ReplicatedStorage:WaitForChild( "Surrender" ).Value
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.Sprint.Changed:Connect( function( Value )
		
		_G.S20Config.AllowSprinting = Value
		
		if not Value then
			
			PoseUtil.SetPose( "Sprinting", false )
			
		end
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.Crouch.Changed:Connect( function( Value )
		
		_G.S20Config.AllowCrouching = Value
		
		if not Value then
			
			PoseUtil.SetPose( "Crouching", false )
			
		end
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.AtEase.Changed:Connect( function( Value )
		
		_G.S20Config.AllowAtEase = Value
		
		if not Value then
			
			KeybindUtil.SetToggle( "s2_AtEase", false )
			
		end
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.Surrender.Changed:Connect( function( Value )
		
		_G.S20Config.AllowSurrender = Value
		
		if not Value then
			
			KeybindUtil.SetToggle( "s2_Surrender", false )
			
		end
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.CharacterRotation.Changed:Connect( function( Value )
		
		_G.S20Config.AllowCharacterRotation = Value
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.Salute.Changed:Connect( function( Value )
		
		_G.S20Config.AllowSalute = Value
		
		if not Value then
			
			KeybindUtil.SetToggle( "s2_Salute", false )
			
		end
		
	end )

end