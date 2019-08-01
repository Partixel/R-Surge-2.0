script.GameAnalytics.Parent = game:GetService( "ServerStorage" )

local function AddObjs( PermPar, Name )
	
	local Objs = script:FindFirstChild( PermPar.Name ):GetChildren( )
	
	for a = 1, #Objs do
		
		if not _G.S20Config[ "Disable" .. Objs[ a ].Name ] and ( Objs[ a ].Name == "VIPGui" or not PermPar:FindFirstChild( Objs[ a ].Name ) ) and ( not Objs[ a ]:IsA( "BaseScript" ) or not Objs[ a ].Disabled ) then
			
			local Child = Objs[ a ]
			
			Child.Parent = PermPar
			
			if Name then
				
				local Plrs = game:GetService( "Players" ):GetPlayers( )
				
				for b = 1, #Plrs do
					
					local TempPar = Name == "Character" and Plrs[ b ].Character or Plrs[ b ]:FindFirstChild( Name )
					
					if TempPar and ( Child.Name == "VIPGui" or not TempPar:FindFirstChild( Child.Name ) ) and ( PermPar.Name ~= "StarterGui" or Plrs[ b ].Character ) then
						
						local Clone = Child:Clone( )
						
						if PermPar.Name == "StarterPlayerScripts" then
							
							if Clone:IsA( "Script" ) or Clone:IsA( "LocalScript" ) then
								
								Clone.Disabled = true
								
							end
							
							script.Move:Clone( ).Parent = Clone
							
						end
						
						Clone.Parent = TempPar
						
					end
					
				end
				
			end
			
		end
		
	end
	
	script:FindFirstChild( PermPar.Name ):Destroy( )
	
end

if game:GetService( "RunService" ):IsStudio( ) and #game:GetService( "Players" ):GetPlayers( ) == 0 then
	
	game:GetService( "Players" ).PlayerAdded:Wait( )
	
end

AddObjs( game:GetService( "StarterPlayer" ):WaitForChild( "StarterPlayerScripts" ), "PlayerGui" )

AddObjs( game:GetService( "StarterPlayer" ):WaitForChild( "StarterCharacterScripts" ), "Character" )

AddObjs( game:GetService( "StarterGui" ), "PlayerGui" )

AddObjs( game:GetService( "ServerScriptService" ) )

AddObjs( game:GetService( "ReplicatedStorage" ) )

local LuaRequire = function ( ... ) return require( ... ) end

if _G.S20Config.DebugEnabled ~= false then
	
	coroutine.wrap( LuaRequire )( game:GetService( "ServerStorage" ):FindFirstChild( "DebugUtil" ) and game:GetService( "ServerStorage" ).DebugUtil:FindFirstChild( "MainModule" ) or 953754819 )
	
end

require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Config" ) )

coroutine.wrap( LuaRequire )( game:GetService( "ReplicatedStorage" ):FindFirstChild( "ThemeUtil" ) or game:GetService( "ServerStorage" ):FindFirstChild( "ThemeUtil" ) and game:GetService( "ServerStorage" ):FindFirstChild( "ThemeUtil" ):FindFirstChild( "MainModule" ) or 2230572960 )

if not game:GetService( "ServerStorage" ):FindFirstChild( "VH_Command_Modules" ) then
	
	local Folder = Instance.new( "Folder" )
	
	Folder.Name = "VH_Command_Modules"
	
	Folder.Parent = game:GetService( "ServerStorage" )
	
end

script.S2.Parent = game:GetService( "ServerStorage" ).VH_Command_Modules

return nil