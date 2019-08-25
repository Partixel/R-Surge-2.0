return {
	Key = "Cursor1",
	SendToClient = true,
	AllowRemoteSet = true,
	BeforeRemoteSet = function(Plr, DataStore, Key, Val)
		if type( Key ) == "table" then
			return next( Key ) and Key or nil
		else
			local DS = DataStore:Get( )
			if not DS and not Val then return end
			
			DS = DS or { }
			DS[ Key ] = Val
			if not next( DS ) then DS = nil end
			
			return DS
		end
	end,
	BeforeInitialGet = function(Plr, Data)
		for Key, Val in pairs( Data ) do
			if type( Val ) == "table" then
				Data[ Key ] = Color3.fromRGB( Val[ 1 ], Val[ 2 ], Val[ 3 ] )
			end
		end
		return Data
	end,
	BeforeSave = function(Plr, Data)
		for Key, Val in pairs( Data ) do
			if typeof( Val ) == "Color3" then
				Data[ Key ] = { Val.r * 255, Val.g * 255, Val.b * 255 }
			end
		end
		return Data
	end
}