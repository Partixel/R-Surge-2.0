local Players = game:GetService( "Players" )

local SaveBind = Instance.new( "RemoteEvent" )

SaveBind.Name = "SaveBind"

SaveBind.Parent = game:GetService( "ReplicatedStorage" )

local GetSavedBinds = Instance.new( "RemoteFunction" )

GetSavedBinds.Name = "GetSavedBinds"

GetSavedBinds.Parent = game:GetService( "ReplicatedStorage" )

local DataStore2 = require(1936396537)

DataStore2.Combine("PartixelsVeryCoolMasterKey", "Keybind1")

SaveBind.OnServerEvent:Connect( function ( Plr, Name, Type, Val )
	
	local DataStore = DataStore2( "Keybind1", Plr )
	
	local Data = DataStore:Get( { } )
	
	if Type == nil then
		
		Data[ Name ] = nil
		
		if not next( Data ) then
			
			DataStore:Set( nil )
			
		end
		
	else
		
		Data[ Name ] = Data[ Name ] or { }
		
		Data[ Name ][ Type ] = Val
		
		DataStore:Set( Data )
		
	end
	
end )

GetSavedBinds.OnServerInvoke = function ( Plr )
	
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
	
	return DataStore:Get( { } )
	
end