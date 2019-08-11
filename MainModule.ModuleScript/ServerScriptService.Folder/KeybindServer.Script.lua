local Players = game:GetService( "Players" )

local DataStore2 = require(1936396537)

DataStore2.Combine("PartixelsVeryCoolMasterKey", "Keybind1")

local KeybindRemote = Instance.new( "RemoteEvent" )

KeybindRemote.Name = "KeybindRemote"

KeybindRemote.OnServerEvent:Connect( function ( Plr, Name, Type, Val )
	
	local DataStore = DataStore2( "Keybind1", Plr )
	
	local Data = DataStore:Get( { } )
	
	if Type == nil then
		
		Data[ Name ] = nil
		
		if not next( Data ) then
			
			DataStore:Set( nil )
			
		else
			
			DataStore:Set( Data )
			
		end
		
	else
		
		Data[ Name ] = Data[ Name ] or { }
		
		Data[ Name ][ Type ] = Val
		
		DataStore:Set( Data )
		
	end
	
end )

KeybindRemote.Parent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )

function HandlePlr( Plr )
	
	local DataStore = DataStore2( "Keybind1", Plr )
	
	DataStore:BeforeInitialGet( function ( Data )
		
		for a, b in pairs( Data ) do
			
			for c, d in pairs( b ) do
				
				if type( d ) == "table" then
					
					b[ c ] = Enum[ d[ 1 ] ][ d[ 2 ] ]
					
				end
				
			end
			
		end
		
		return Data
		
	end )
	
	DataStore:BeforeSave( function ( Data )
		
		for a, b in pairs( Data ) do
			
			for c, d in pairs( b ) do
				
				if typeof( d ) == "EnumItem" then
					
					b[ c ] = { tostring( d.EnumType ), d.Name }
					
				end
				
			end
			
		end
		
		return Data
		
	end )
	
	local Binds = DataStore:Get( { } )
	
	if Binds then
		
		KeybindRemote:FireClient( Plr, Binds )
		
	end
	
end

for _, Plr in ipairs( game:GetService( "Players" ):GetPlayers( ) ) do
	
	HandlePlr( Plr )
	
end

game.Players.PlayerAdded:Connect( HandlePlr )