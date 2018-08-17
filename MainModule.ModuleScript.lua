local function AddObjs( PermPar, Name )
	
	local Objs = script:FindFirstChild( PermPar.Name ):GetChildren( )
	
	for a = 1, #Objs do
		
		if not _G.S20Config[ "Disable" .. Objs[ a ].Name ] and not PermPar:FindFirstChild( Objs[ a ].Name ) then
			
			local Child = Objs[ a ]
			
			Child.Parent = PermPar
			
			if Name then
				
				local Plrs = game:GetService( "Players" ):GetPlayers( )
				
				for b = 1, #Plrs do
					
					local TempPar = Name == "Character" and Plrs[ b ].Character or Plrs[ b ]:FindFirstChild( Name )
					
					local Check2 = true
					
					if Name == "PlayerGui" then Check2 = Plrs[ b ].Character end
					
					if TempPar and Check2 and not TempPar:FindFirstChild( Child.Name ) then
						
						Child:Clone( ).Parent = TempPar
						
					end
					
				end
				
			end
			
		end
		
	end
	
	script:FindFirstChild( PermPar.Name ):Destroy( )
	
end

AddObjs( game:GetService( "StarterPlayer" ):WaitForChild( "StarterPlayerScripts" ), "Backpack" )

AddObjs( game:GetService( "StarterPlayer" ):WaitForChild( "StarterCharacterScripts" ), "Character" )

AddObjs( game:GetService( "StarterGui" ), "PlayerGui" )

AddObjs( game:GetService( "ServerScriptService" ) )

AddObjs( game:GetService( "ReplicatedStorage" ) )

local LuaRequire = function ( ... ) return require( ... ) end

if _G.S20Config.DebugEnabled ~= false then
	
	require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )
	
	coroutine.wrap( LuaRequire )( game:GetService( "ServerStorage" ):FindFirstChild( "DebugUtil" ) and game:GetService( "ServerStorage" ).DebugUtil:FindFirstChild( "MainModule" ) or 953754819 )
	
end

require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Config" ) )

coroutine.wrap( LuaRequire )( ( game:GetService( "ServerStorage" ):FindFirstChild( "ThemeUtil" ) or { } ).MainModule or 2230572960 )

coroutine.wrap( LuaRequire )( game:GetService( "ReplicatedStorage" ):WaitForChild( "PoseUtil" ) )

coroutine.wrap( LuaRequire )( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )

if not game:GetService( "ServerStorage" ):FindFirstChild( "VH_Command_Modules" ) then
	
	local Folder = Instance.new( "Folder" )
	
	Folder.Name = "VH_Command_Modules"
	
	Folder.Parent = game:GetService( "ServerStorage" )
	
end

script.S2.Parent = game:GetService( "ServerStorage" ).VH_Command_Modules

return nil