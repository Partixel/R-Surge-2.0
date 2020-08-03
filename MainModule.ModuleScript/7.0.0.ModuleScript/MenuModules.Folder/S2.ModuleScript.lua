return {
	Key = "S2Settings1",
	SendToClient = true,
	AllowRemoteSet = true,
	BeforeRemoteSet = function(Plr, DataStore, Remote, Setting, Value)
		local Data = DataStore:Get({})
		
		Data[Setting] = Value or false
		return Data
	end,
}