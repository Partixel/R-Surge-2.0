local EmojiList = require(script.Parent.EmojiList)

local function Run(ChatService)
	local function EmojiSwap(speakerName, messageObject, channelName)
		messageObject.Message = string.gsub(messageObject.Message, "(:[%w_]+:)", function (a) return EmojiList[a] or a end, math.abs(game.ServerScriptService.S2.EmojiChatController.Configuration.EmojiLimitPerMessage.Value))
	end
	
	ChatService:RegisterFilterMessageFunction("EmojiSwap", EmojiSwap)
end

return Run