return {
	Key = "Keybind1",
	DefaultValue = {},
	SendToClient = true,
	AllowRemoteSet = true,
	BeforeRemoteSet = function(Plr, DataStore, Remote, Name, Type, Val)
		local Data = DataStore:Get({})
		
		if Type == nil then
			Data[ Name ] = nil
			return next(Data) and Data or nil
		else
			Data[ Name ] = Data[ Name ] or {}
			Data[ Name ][ Type ] = Val
			return Data
		end
	end,
	BeforeInitialGet = function(Plr, Data)
		for a, b in pairs(Data) do
			for c, d in pairs(b) do
				if type(d) == "table" then
					b[ c ] = Enum[ d[ 1 ] ][ d[ 2 ] ]
				end
			end
		end
		return Data
	end,
	BeforeSave = function(Plr, Data)
		for a, b in pairs(Data) do
			for c, d in pairs(b) do
				if typeof(d) == "EnumItem" then
					b[ c ] = { tostring(d.EnumType), d.Name }
				end
			end
		end
		return Data
	end
}