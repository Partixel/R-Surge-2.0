local SetupModel = game:GetService( "ServerScriptService" ):FindFirstChild( "S2" ) or game:GetService( "ServerScriptService" ):FindFirstChild( "S2.0" )

local Config = require( SetupModel and SetupModel:WaitForChild( "Config" ) or game:GetService("ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Config" ) ) or warn( "Update your S2 setup model to the latest version, the config has changed" ) or _G.S20Config

require( game:GetService( "ServerStorage" ):FindFirstChild( "MenuLib" ) and game:GetService( "ServerStorage" ).MenuLib:FindFirstChild( "MainModule" ) or 3717582194 ) -- MenuLib

local LoaderModule = require( game:GetService( "ServerStorage" ):FindFirstChild( "LoaderModule" ) and game:GetService( "ServerStorage" ).LoaderModule:FindFirstChild( "MainModule" ) or 03593768376 )( "S2", Config )

LoaderModule( script:WaitForChild( "ReplicatedStorage" ) )

if SetupModel then
	
	SetupModel.Config.Parent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )
	
	SetupModel:Destroy( )
	
end

LoaderModule( script:WaitForChild( "ServerStorage" ) )

LoaderModule( script:WaitForChild( "ServerScriptService" ) )

LoaderModule( script:WaitForChild( "StarterPlayerScripts" ) )

LoaderModule( script:WaitForChild( "StarterCharacterScripts" ) )

LoaderModule( script:WaitForChild( "StarterGui" ) )

LoaderModule( script:WaitForChild( "MenuModules" ), game:GetService( "ServerStorage" ):WaitForChild( "MenuModules" ) )

local LuaRequire = function ( ... ) return require( ... ) end

coroutine.wrap( LuaRequire )( game:GetService( "ServerStorage" ):FindFirstChild( "MenuLib" ) and game:GetService( "ServerStorage" ).MenuLib:FindFirstChild( "MainModule" ) or 3717582194 ) -- MenuLib

if Config.DebugEnabled ~= false then
	
	coroutine.wrap( LuaRequire )( game:GetService( "ServerStorage" ):FindFirstChild( "DebugUtil" ) and game:GetService( "ServerStorage" ).DebugUtil:FindFirstChild( "MainModule" ) or 953754819 )
	
end

coroutine.wrap( LuaRequire )( game:GetService( "ServerStorage" ):FindFirstChild( "ThemeUtil" ) and game:GetService( "ServerStorage" ).ThemeUtil:FindFirstChild( "MainModule" ) or 2230572960 )

if not game:GetService( "ServerStorage" ):FindFirstChild( "VH_Command_Modules" ) then
	
	local Folder = Instance.new( "Folder" )
	
	Folder.Name = "VH_Command_Modules"
	
	Folder.Parent = game:GetService( "ServerStorage" )
	
end

LoaderModule( script:WaitForChild( "VH_Command_Modules" ), game:GetService( "ServerStorage" ).VH_Command_Modules )

return nil