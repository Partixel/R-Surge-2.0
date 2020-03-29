local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ):WaitForChild( "ThemeUtil" ) )

local Full, Mid, None = { [ "full" ] = true, [ "1" ] = true, [ "f" ] = true }, { [ "mid" ] = true, [ "middle" ] = true, [ "0.5" ] = true, [ "m" ] = true }, { [ "none" ] = true, [ "0" ] = true, [ "n" ] = true }

return function ( Main, ModFolder, VH_Events )
	
	local SwordFloat = ModFolder:FindFirstChild( "SwordFloat" ) or Instance.new( "StringValue" )
	
	SwordFloat.Value = "full"
	
	SwordFloat.Name = "SwordFloat"
	
	SwordFloat.Parent = ModFolder
	
	Main.Commands[ "SetFloat" ] = {
		
		Alias = { "setfloat", { "float", Args = { "full" } }, { "midfloat", Args = { "mid" } }, { "nofloat", Args = { "none" } } },
		
		Description = "Changes float to either 'full', 'mid' or 'none'",
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = function ( self, Strings, Plr )
			
			local String = table.remove( Strings, 1 ):lower( )
			
			return ( String == Main.TargetLib.ValidChar or Full[ String ] ) and "full" or Mid[ String ] and "mid" or None[ String ] and "none" or nil
			
		end, Name = "easy_normal_hard", Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			SwordFloat.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	local AtEase = ModFolder:FindFirstChild( "AtEase" ) or Instance.new( "BoolValue" )
	
	AtEase.Value = Core.Config.AllowAtEase ~= false
	
	AtEase.Name = "AtEase"
	
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
	
	AtEase.Parent = ModFolder
	
	local Tools = ModFolder:FindFirstChild( "Tools" ) or Instance.new( "BoolValue" )
	
	Tools.Value = Core.Config.AllowSprinting ~= false
	
	Tools.Name = "Tools"
	
	Main.Commands[ "Tools" ] = {
		
		Alias = { Main.TargetLib.AliasTypes.Toggle(1, "tools")},
		
		Description = "Enable/disables the ability to use tools",
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true, Default = Main.TargetLib.Defaults.Toggle, ToggleValue = function() return Tools.Value end} },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			Tools.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	Tools.Parent = ModFolder
	
	local Sprint = ModFolder:FindFirstChild( "Sprint" ) or Instance.new( "BoolValue" )
	
	Sprint.Value = Core.Config.AllowSprinting ~= false
	
	Sprint.Name = "Sprint"
	
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
	
	Sprint.Parent = ModFolder
	
	local Crouch = ModFolder:FindFirstChild( "Crouch" ) or Instance.new( "BoolValue" )
	
	Crouch.Value =Core.Config.AllowCrouching ~= false
	
	Crouch.Name = "Crouch"
	
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
	
	Crouch.Parent = ModFolder
	
	local Salute = ModFolder:FindFirstChild( "Salute" ) or Instance.new( "BoolValue" )
	
	Salute.Value = Core.Config.AllowSalute ~= false
	
	Salute.Name = "Salute"
	
	Salute.Parent = ModFolder
	
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
	
	local Surrender = ModFolder:FindFirstChild( "Surrender" ) or Instance.new( "BoolValue" )
	
	Surrender.Value = Core.Config.AllowSurrender ~= false
	
	Surrender.Name = "Surrender"
	
	Surrender.Parent = ModFolder
	
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
	
	local TeamKill = ModFolder:FindFirstChild( "TeamKill" ) or Instance.new( "BoolValue" )
	
	TeamKill.Value = Core.Config.WeaponTypeOverrides.All.AllowTeamKill == true
	
	TeamKill.Name = "TeamKill"
	
	TeamKill.Parent = ModFolder
	
	Main.Commands[ "TeamKill" ] = {
		
		Alias = { "teamkill" },
		
		Description = "Toggle team kill on/off",
		
		Category = "Training",
		
		CanRun = "$admin",	
		
		ArgTypes = { { Func = Main.TargetLib.ArgTypes.Boolean, Required = true } },
			
		Callback = function ( self, objPlayer, strCmd, Args, NextCmds, Silent )	
			
			Core.Config.WeaponTypeOverrides.All.AllowTeamKill = Args[ 1 ]
			
			TeamKill.Value = Args[ 1 ]
			
			return true
			
		end
		
	}
	
	VH_Events:WaitForChild( "Destroyed" ).Event:Connect( function ( Update )
		
		if not Update then
			
			AtEase:Destroy( )
			
			Sprint:Destroy( )
			
			Crouch:Destroy( )
			
			Salute:Destroy( )
			
			Surrender:Destroy( )
			
			TeamKill:Destroy( )
			
			SwordFloat:Destroy( )
						
			return
			
		end
		
	end )
	
end