require(2621701837) -- StringCalculator

return {
	Key = "Performance1",
	SendToClient = true,
	AllowRemoteSet = true,
	BeforeRemoteSet = function(Plr, DataStore, Remote, Setting, Value)
		local Data = DataStore:Get({})
		
		Data[Setting] = Value or false
		return Data
	end,
}