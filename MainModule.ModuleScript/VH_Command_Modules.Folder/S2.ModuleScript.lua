local ReplicatedStorage	= game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ):WaitForChild( "ThemeUtil" ) )

return function ( Main, ModFolder, VH_Events )
	
	local AtEase = ReplicatedStorage:FindFirstChild( "AtEase" ) or Instance.new( "BoolValue" )
	
	AtEase.Value = Core.Config.AllowAtEase ~= false
	
	AtEase.Name = "AtEase"
	
	AtEase.Parent = ReplicatedStorage
	
	local Sprint = ReplicatedStorage:FindFirstChild( "Sprint" ) or Instance.new( "BoolValue" )
	
	Sprint.Value = Core.Config.AllowSprinting ~= false
	
	Sprint.Name = "Sprint"
	
	Sprint.Parent = ReplicatedStorage
	
	local Crouch = ReplicatedStorage:FindFirstChild( "Crouch" ) or Instance.new( "BoolValue" )
	
	Crouch.Value =Core.Config.AllowCrouching ~= false
	
	Crouch.Name = "Crouch"
	
	Crouch.Parent = ReplicatedStorage
	
	local Salute = ReplicatedStorage:FindFirstChild( "Salute" ) or Instance.new( "BoolValue" )
	
	Salute.Value = Core.Config.AllowSalute ~= false
	
	Salute.Name = "Salute"
	
	Salute.Parent = ReplicatedStorage
	
	local CharacterRotation = ReplicatedStorage:FindFirstChild( "CharacterRotation" ) or Instance.new( "BoolValue" )
	
	CharacterRotation.Value = Core.Config.AllowCharacterRotation ~= false
	
	CharacterRotation.Name = "CharacterRotation"
	
	CharacterRotation.Parent = ReplicatedStorage
	
	local Surrender = ReplicatedStorage:FindFirstChild( "Surrender" ) or Instance.new( "BoolValue" )
	
	Surrender.Value = Core.Config.AllowSurrender ~= false
	
	Surrender.Name = "Surrender"
	
	Surrender.Parent = ReplicatedStorage
	
	local TeamKill = ReplicatedStorage:FindFirstChild( "TeamKill" ) or Instance.new( "BoolValue" )
	
	TeamKill.Value = Core.Config.AllowTeamKill == true
	
	TeamKill.Name = "TeamKill"
	
	TeamKill.Parent = ReplicatedStorage
	
	VH_Events:WaitForChild( "Destroyed" ).Event:Connect( function ( Update )
		
		if not Update then
			
			AtEase:Destroy( )
			
			Sprint:Destroy( )
			
			Crouch:Destroy( )
			
			Salute:Destroy( )
			
			CharacterRotation:Destroy( )
			
			Surrender:Destroy( )
			
			TeamKill:Destroy( )
			
			return
			
		end
		
	end )
	
	Main.Commands[ "Sprint" ] = {
		
		Alias = { "sprint" },
		
		Description = "Toggle sprint on/off",
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			Core.Config.AllowSprinting = Args[ 1 ]
			
			Sprint.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ "Crouch" ] = {
		
		Alias = { "crouch" },
		
		Description = "Toggle crouch on/off",
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			Core.Config.AllowCrouching = Args[ 1 ]
			
			Crouch.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ "AtEase" ] = {
		
		Alias = { "atease" },
		
		Description = "Toggle at ease on/off",
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			Core.Config.AllowAtEase = Args[ 1 ]
			
			AtEase.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ "Salute" ] = {
		
		Alias = { "salute" },
		
		Description = "Toggle salute on/off",
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			Core.Config.AllowSalute = Args[ 1 ]
			
			Salute.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ "CharacterRotation" ] = {
		
		Alias = { "characterrotation" },
		
		Description = "Toggle Character Rotation on/off",
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			Core.Config.AllowCharacterRotation = Args[ 1 ]
			
			CharacterRotation.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ "Surrender" ] = {
		
		Alias = { "surrender" },
		
		Description = "Toggle surrender on/off",
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			Core.Config.AllowSurrender = Args[ 1 ]
			
			Surrender.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Main.Commands[ "TeamKill" ] = {
		
		Alias = { "teamkill" },
		
		Description = "Toggle team kill on/off",
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			Core.Config.AllowTeamKill = Args[ 1 ]
			
			TeamKill.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
end