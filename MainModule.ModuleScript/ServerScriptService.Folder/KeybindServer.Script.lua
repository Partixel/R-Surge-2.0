local Players = game:GetService( "Players" )

local SaveBind = Instance.new( "RemoteEvent" )

SaveBind.Name = "SaveBind"

SaveBind.Parent = game:GetService( "ReplicatedStorage" )

local GetSavedBinds = Instance.new( "RemoteFunction" )

GetSavedBinds.Name = "GetSavedBinds"

GetSavedBinds.Parent = game:GetService( "ReplicatedStorage" )

local Ran, DataStore = pcall( game:GetService( "DataStoreService" ).GetDataStore, game:GetService( "DataStoreService" ), "KeybindUtilV2" )

if not Ran or type( DataStore ) ~= "userdata" or not pcall( function ( ) DataStore:GetAsync( "Test" ) end ) then
	
	DataStore = { GetAsync = function ( ) end, SetAsync = function ( ) end, UpdateAsync = function ( ) end, OnUpdate = function ( ) end }
	
end

local function SerialiseEnum( Val )
	
	if typeof( Val ) ~= "EnumItem" then return Val end
	
	return { tostring( Val.EnumType ), Val.Name }
	
end

local function DeserialiseEnum( Val )
	
	if type( Val ) ~= "table" then
		
		return Val
		
	end
	
	return Enum[ Val[ 1 ] ][ Val[ 2 ] ]
	
end

local SavedBinds = { }

Players.PlayerRemoving:Connect( function ( Plr )
	
	if SavedBinds[ Plr ] ~= nil then
		
		if SavedBinds[ Plr ] then
			
			DataStore:SetAsync( tostring( Plr.UserId ), SavedBinds[ Plr ] )
			
		else
			
			DataStore:RemoveAsync( tostring( Plr.UserId ) )
			
		end
		
		SavedBinds[ Plr ] = nil
		
	end
	
	SavedBinds[ Plr ] = nil
	
end )

game:BindToClose( function ( )
	
	local Plrs = Players:GetPlayers( )
	
	for a = 1, #Plrs do
		
		if SavedBinds[ Plrs[ a ] ] ~= nil then
			
			if SavedBinds[ Plrs[ a ] ] then
				
				DataStore:SetAsync( tostring( Plrs[ a ].UserId ), SavedBinds[ Plrs[ a ] ] )
				
			else
				
				DataStore:RemoveAsync( tostring( Plrs[ a ].UserId ) )
			
			end
			
			SavedBinds[ Plrs[ a ] ] = nil
			
		end
		
	end
	
end )

SaveBind.OnServerEvent:Connect( function ( Plr, Name, Type, Val )
	
	SavedBinds[ Plr ] = DataStore:GetAsync( tostring( Plr.UserId ) ) or { }
	
	if Type == nil then
		
		SavedBinds[ Plr ][ Name ] = nil
		
		local Found = false
		
		for a, b in pairs( SavedBinds[ Plr ] ) do Found = true break end
		
		if not Found then SavedBinds[ Plr ] = false end
		
		return
		
	end
	
	SavedBinds[ Plr ][ Name ] = SavedBinds[ Plr ][ Name ] or { }
	
	SavedBinds[ Plr ][ Name ][ Type ] = SerialiseEnum( Val )
	
end )

GetSavedBinds.OnServerInvoke = function ( Plr )
	
	local Tmp = DataStore:GetAsync( tostring( Plr.UserId ) ) or { }
	
	local Binds = { }
	
	for a, b in pairs( Tmp ) do
		
		Binds[ a ] = { }
		
		for c, d in pairs( b ) do
			
			Binds[ a ][ c ] = DeserialiseEnum( d )
			
		end
		
	end
	
	return Binds
	
end