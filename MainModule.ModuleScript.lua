local SetupModel = game:GetService( "ServerScriptService" ):FindFirstChild( "S2.0" )

local Config

if SetupModel then
	
	Config = SetupModel:FindFirstChild( "Config" )
	
	require( SetupModel.Config )
	
end

require( game:GetService( "ServerStorage" ):FindFirstChild( "MenuLib" ) and game:GetService( "ServerStorage" ).MenuLib:FindFirstChild( "MainModule" ) or 3717582194 ) -- MenuLib

local LoaderModule = require( game:GetService( "ServerStorage" ):FindFirstChild( "LoaderModule" ) and game:GetService( "ServerStorage" ).LoaderModule:FindFirstChild( "MainModule" ) or 03593768376 )( "S2", _G.S20Config )

LoaderModule( script:WaitForChild( "ReplicatedStorage" ) )

LoaderModule( script:WaitForChild( "ServerStorage" ) )

LoaderModule( script:WaitForChild( "ServerScriptService" ) )

LoaderModule( script:WaitForChild( "StarterPlayerScripts" ) )

LoaderModule( script:WaitForChild( "StarterCharacterScripts" ) )

LoaderModule( script:WaitForChild( "StarterGui" ) )

LoaderModule( script:WaitForChild( "MenuModules" ), game:GetService( "ServerStorage" ):WaitForChild( "MenuModules" ) )

if SetupModel then
	
	Config.Parent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )
	
	SetupModel:Destroy( )
	
end

local LuaRequire = function ( ... ) return require( ... ) end

coroutine.wrap( LuaRequire )( game:GetService( "ServerStorage" ):FindFirstChild( "MenuLib" ) and game:GetService( "ServerStorage" ).MenuLib:FindFirstChild( "MainModule" ) or 3717582194 ) -- MenuLib

if _G.S20Config.DebugEnabled ~= false then
	
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