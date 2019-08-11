local Players = game:GetService( "Players" )

local DataStore2 = require( 1936396537 )

DataStore2.Combine( "PartixelsVeryCoolMasterKey", "Cursor1" )

local SaveCursor = Instance.new( "RemoteEvent" )

SaveCursor.Name = "SaveCursor"

SaveCursor.OnServerEvent:Connect( function ( Plr, Key, Val )
	
	if type( Key ) == "table" then
		
		DataStore2( "Cursor1", Plr ):Set( next( Key ) and Key or nil )
		
	else
		
		local DS = DataStore2( "Cursor1", Plr ):Get( )
		
		if not DS and not Val then return end
		
		DS = DS or { }
		
		DS[ Key ] = Val
		
		if not next( DS ) then DS = nil end
		
		DataStore2( "Cursor1", Plr ):Set( DS )
		
	end
	
end )

SaveCursor.Parent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )

function PlayerAdded( Plr )
	
	DataStore2( "Cursor1", Plr ):BeforeInitialGet( function ( Data )
		
		for Key, Val in pairs( Data ) do
			
			if type( Val ) == "table" then
				
				Data[ Key ] = Color3.fromRGB( Val[ 1 ], Val[ 2 ], Val[ 3 ] )
				
			end
			
		end
		
		return Data
		
	end )
	
	DataStore2( "Cursor1", Plr ):BeforeSave( function ( Data )
		
		for Key, Val in pairs( Data ) do
			
			if typeof( Val ) == "Color3" then
				
				Data[ Key ] = { Val.r * 255, Val.g * 255, Val.b * 255 }
				
			end
			
		end
		
		return Data
		
	end )
	
	local Settings = DataStore2( "Cursor1", Plr ):Get( )
	
	if Settings then
		
		SaveCursor:FireClient( Plr, Settings )
		
	end
	
end

Players.PlayerAdded:Connect( PlayerAdded )

for _, b in ipairs( Players:GetPlayers( ) ) do
	
	PlayerAdded( b )
	
end

return nil