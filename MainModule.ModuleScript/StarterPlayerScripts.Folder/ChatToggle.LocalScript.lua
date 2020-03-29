local KeybindUtil = require (game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("KeybindUtil"))
KeybindUtil.AddBind({Name = "Chat", Category = "TRA", Callback = function(Began) 
	if Began then
		require(script.Parent.Parent.ChatScript.ChatMain):ToggleVisibility()
	end
end, Key = Enum.KeyCode.Z, NoHandled = true})