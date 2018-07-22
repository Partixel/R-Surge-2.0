return function ( Main, ModFolder, VH_Events )
	
	local ReplicatedStorage	= game:GetService( 'ReplicatedStorage' )
	
	local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ) )
	
	while not _G.S20Config do wait( ) end
	
	local AtEase = ReplicatedStorage:FindFirstChild( "AtEase" ) or Instance.new( "BoolValue" )
	
	AtEase.Value = _G.S20Config.AllowAtEase ~= false
	
	AtEase.Name = "AtEase"
	
	AtEase.Parent = ReplicatedStorage
	
	local Sprint = ReplicatedStorage:FindFirstChild( "Sprint" ) or Instance.new( "BoolValue" )
	
	Sprint.Value = _G.S20Config.AllowSprinting ~= false
	
	Sprint.Name = "Sprint"
	
	Sprint.Parent = ReplicatedStorage
	
	local Crouch = ReplicatedStorage:FindFirstChild( "Crouch" ) or Instance.new( "BoolValue" )
	
	Crouch.Value =_G.S20Config.AllowCrouching ~= false
	
	Crouch.Name = "Crouch"
	
	Crouch.Parent = ReplicatedStorage
	
	local Salute = ReplicatedStorage:FindFirstChild( "Salute" ) or Instance.new( "BoolValue" )
	
	Salute.Value = _G.S20Config.AllowSalute ~= false
	
	Salute.Name = "Salute"
	
	Salute.Parent = ReplicatedStorage
	
	local CharacterRotation = ReplicatedStorage:FindFirstChild( "CharacterRotation" ) or Instance.new( "BoolValue" )
	
	CharacterRotation.Value = _G.S20Config.AllowCharacterRotation ~= false
	
	CharacterRotation.Name = "CharacterRotation"
	
	CharacterRotation.Parent = ReplicatedStorage
	
	local Surrender = ReplicatedStorage:FindFirstChild( "Surrender" ) or Instance.new( "BoolValue" )
	
	Surrender.Value = _G.S20Config.AllowSurrender ~= false
	
	Surrender.Name = "Surrender"
	
	Surrender.Parent = ReplicatedStorage
	
	local BaseTheme = ReplicatedStorage:FindFirstChild( "BaseTheme" ) or Instance.new( "StringValue" )
	
	BaseTheme.Value = "Dark"
	
	BaseTheme.Name = "BaseTheme"
	
	BaseTheme.Parent = ReplicatedStorage
	
	VH_Events:WaitForChild( "Destroyed" ).Event:Connect( function ( Update )
		
		if not Update then
			
			AtEase:Destroy( )
			
			Sprint:Destroy( )
			
			Crouch:Destroy( )
			
			Salute:Destroy( )
			
			CharacterRotation:Destroy( )
			
			Surrender:Destroy( )
			
			return
			
		end
		
	end )
	
	Main.Commands[ 'TeamKill' ] = {
		
		Alias = { 'teamkill', "tk" },
		
		Description = 'Toggle teamkill on/off',
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			_G.S20Config.AllowTeamKill = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ 'Sprint' ] = {
		
		Alias = { 'sprint' },
		
		Description = 'Toggle sprint on/off',
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			_G.S20Config.AllowSprinting = Args[ 1 ]
			
			ReplicatedStorage.Sprint.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ 'Crouch' ] = {
		
		Alias = { 'crouch' },
		
		Description = 'Toggle crouch on/off',
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			_G.S20Config.AllowCrouching = Args[ 1 ]
			
			ReplicatedStorage.Crouch.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ 'AtEase' ] = {
		
		Alias = { 'atease' },
		
		Description = 'Toggle at ease on/off',
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			_G.S20Config.AllowAtEase = Args[ 1 ]
			
			ReplicatedStorage.AtEase.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ 'Salute' ] = {
		
		Alias = { 'salute' },
		
		Description = 'Toggle salute on/off',
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			_G.S20Config.AllowSalute = Args[ 1 ]
			
			ReplicatedStorage.Salute.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ 'CharacterRotation' ] = {
		
		Alias = { 'characterrotation' },
		
		Description = 'Toggle Character Rotation on/off',
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			_G.S20Config.AllowCharacterRotation = Args[ 1 ]
			
			ReplicatedStorage.CharacterRotation.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ 'Surrender' ] = {
		
		Alias = { 'surrender' },
		
		Description = 'Toggle surrender on/off',
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			_G.S20Config.AllowSurrender = Args[ 1 ]
			
			ReplicatedStorage.Surrender.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands.SetBaseTheme = {
		
		Alias = { "setbasetheme", "basetheme" },
		
		Description = "Sets the base theme",
		
		Category = "Theme",
		
		CanRun = "$debugger",
		
		ArgTypes = { { Func = function ( self, Strings, Plr )
			
			local String = table.remove( Strings, 1 )
			
			if String == Main.TargetLib.ValidChar then return "Light" end
			
			String = String:lower( )
			
			for a, b in pairs( ThemeUtil.BaseThemes ) do
				
				if String:find( a:lower( ):sub( 1, String:len( ) ) ) then
					
					return a
					
				end
				
			end
			
			return nil, false
			
		end, Required = true, Name = "base_theme" } },
		
		Callback = function ( self, Plr, Cmd, Args, NextCmds, Silent )
			
			BaseTheme.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
end