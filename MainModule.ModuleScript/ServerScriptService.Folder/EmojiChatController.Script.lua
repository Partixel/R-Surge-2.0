local ChatModules = game.Chat:WaitForChild("ChatModules")
local IS = game:GetService("InsertService")

function InitialLoad()
	script.EmojiList:Clone().Parent = game.StarterPlayer.StarterPlayerScripts.S2.EmojiChatClientController
	script.EmojiList.Parent = ChatModules
	script.EmojiReplace.Parent = ChatModules
	print("Emoji Chat Suite v1.5.1 by FearMeIAmLag has loaded")
end

if script.Configuration.UpdateAutomatically.Value and script.Parent.Name == "ServerScriptService" then
	local model = IS:LoadAsset(1842605067)
	if model and model["Emoji Chat Suite"].EmojiChatController.Configuration.LastUpdated.Value > script.Configuration.LastUpdated.Value then
		model = model["Emoji Chat Suite"]
		for _, v in pairs(script.Configuration:GetChildren()) do
			if model.EmojiChatController.Configuration:FindFirstChild(v.Name) then
				model.EmojiChatController.Configuration[v.Name].Value = v.Value
			end
		end
		for _, v in pairs(game.StarterPlayer.StarterPlayerScripts.EmojiChatClientController.Customization:GetChildren()) do
			if model.EmojiChatClientController.Customization:FindFirstChild(v.Name) then
				model.EmojiChatClientController.Customization[v.Name] = v.Value
			end
		end
		if script.Configuration.UseCustomEmojiList.Value then
			model.EmojiChatController.EmojiList:Destroy()
			script.EmojiList:Clone().Parent = model.EmojiChatController
		end
		if game.StarterPlayer.StarterPlayerScripts:FindFirstChild("EmojiChatClientController") then
			game.StarterPlayer.StarterPlayerScripts.EmojiChatClientController:Destroy()
		end
		model.EmojiChatClientController.Parent = game.StarterPlayer.StarterPlayerScripts
		model.EmojiChatController.Parent = game.ServerScriptService
		model:Destroy()
		script:Destroy()
	else
		InitialLoad()
	end
else
	InitialLoad()
end