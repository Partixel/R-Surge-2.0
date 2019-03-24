require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Config" ) )

local LuaRequire = function ( ... ) return require( ... ) end

coroutine.wrap( LuaRequire )( script.Parent:WaitForChild( "PoseUtil" ) )

coroutine.wrap( LuaRequire )( script.Parent:WaitForChild( "KeybindUtil" ) )