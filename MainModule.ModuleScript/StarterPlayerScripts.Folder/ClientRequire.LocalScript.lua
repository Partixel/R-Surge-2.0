if script.Parent.Name ~= "PlayerScripts" then
	
	wait( )
	
	script.Parent = script.Parent.Parent:WaitForChild( "PlayerScripts" )
	
end

require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Config" ) )

local LuaRequire = function ( ... ) return require( ... ) end

coroutine.wrap( LuaRequire )( game:GetService( "ReplicatedStorage" ):WaitForChild( "PoseUtil" ) )

coroutine.wrap( LuaRequire )( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )