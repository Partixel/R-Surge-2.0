--[[Options (All of the following are optional)
	Name = String = The name that shows above the GUI
	Ignore = Instance = This model/part will be ignored when checking if the interactable is obscured
	MainPart = Instance = This part will be used for the display when in a model instead of the models MainPart
	HoldTime = Number = How long this has to be held for
	Distance = Number = How close you have to be to see/interact
	Cooldown = Number = How long before you can interact with this again
	CharacterOnly = Boolean = Will only show if your camera is focused on your character (stops e.g. drones from using the interactable)
	Hide = Boolean = Will prevent the GUI from showing and close it if already shown
	Disabled = Number = Prevents the GUI from being selected. If value is 0 then GUI will show infinity symbol, else GUI will assume value is the time until it is next enabled, e.g. TimeSync.GetServerTime() + 5 will count down from 5. This is used by the Cooldown option.
	MinXSize = Int = The size in pixels of the GUI when it's not selected
	MaxXSize = Int = The size in pixels of the GUI when it's selected
	ExtraYSize = Int = The extra space in pixels for use by devs that want to add custom information (e.g. gun stats, descriptions, images, etc)
	StudsOffset = Vector3 = The StudsOffset of the BilboardGui
	Font = Enum.Font = The font that you want the text to use 
	ProgressColor = Color3 = The color of the Progress outline
	SpriteSheet = String = Assetid:// of your custom sprite sheet (sprites must be 83 pixels tall and wide, with a 1 pixel gap around it and must be 1024x1024 in total
	SpriteRotation = Int = Rotation of the SpriteSheet
	ClientOnly = Boolean = Prevents the interactable sending it's interaction to the server (use this if the interactable is only used on the client to save networking)
	ShouldOpen = function(InteractObj, Options, LocalPlayer, DefaultShouldOpen) end -- return true if the InteractGui should open
	CustomGui = Boolean = If your interactable has a custom gui, use this to hide the default GUI
	CustomFrame = Instance = The value of this is cloned into the extra space in the GUI when it's first opened (can include scripts if you want it dynamic!)
								The frame must be Size (1, 0, 1, 0) Position (0, 0, 0, 0) and you must use ExtraYSize to set the size in pixels of your custom frame.
--]]
local TweenService = game:GetService("TweenService")

local TimeSync = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("TimeSync"))
local ThemeUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))
local Interactables = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("InteractClient"))

local Sprites = {"rbxassetid://1648362548"} --, "rbxassetid://1673809362", "rbxassetid://1673772742", "rbxassetid://1673763277", "rbxassetid://1673087472", "rbxassetid://1672808384", "rbxassetid://1672748980"}
-- rbxassetid://1673824521 - TRAngle
-- rbxassetid://1673800273 -- Trifatty
local SpriteConfig = {Diamater = 83, Padding = 1, Count = 144}
local Rows = math.sqrt(SpriteConfig.Count) ;
function GetOffset(Num)
	Num = math.floor(Num) % SpriteConfig.Count
	return ((SpriteConfig.Diamater + SpriteConfig.Padding * 2) * (math.floor(Num % Rows))) + SpriteConfig.Padding, ((SpriteConfig.Diamater + SpriteConfig.Padding * 2) * math.floor(Num / Rows)) + SpriteConfig.Padding
end
local ZeroOffset = Vector2.new(GetOffset(0))

local function IsMyGui(Options)
	return not Options or not Options.CustomGui
end

Interactables.OpenGui:Connect(function(InteractObj, Gui, Key)
	local Options = Interactables.GetOptions(InteractObj)
	if IsMyGui(Options) then
		if not Gui or not Gui.Parent then
			Gui = script.InteractGui:Clone()
			if Options.ProgressColor then
				Gui.Progress.ImageColor3 = Options.ProgressColor
			else
				ThemeUtil.BindUpdate(Gui.Progress, {ImageColor3 = "Positive_Color3"})
			end
			
			if Options.StudsOffset then
				Gui.StudsOffset = Options.StudsOffset
			end
			
			if Options.Name or Options.ExtraYSize then
				Gui.Back.ImageRectOffset = Vector2.new(936, 977.5)
				Gui.Back.ImageRectSize = Vector2.new(83, 41.5)
			end
			
			ThemeUtil.BindUpdate(Gui.KeyBack.KeyText, {BackgroundColor3 = "Primary_BackgroundColor", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
			ThemeUtil.BindUpdate(Gui.Back, {ImageColor3 = "Primary_BackgroundColor", ImageTransparency = "Primary_BackgroundTransparency"})
			ThemeUtil.BindUpdate(Gui.NameBack, {BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
			ThemeUtil.BindUpdate(Gui.NameBack.NameText, {TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
			
			local Rotate = Options.SpriteRotation or 0
			Gui.Back.Rotation = 90 * Rotate
			Gui.KeyBack.Rotation = 90 * Rotate
			Gui.KeyBack.KeyText.Rotation = -90 * Rotate
			Gui.Progress.Rotation = 90 * Rotate
			
			local Chosen = Options.SpriteSheet or Sprites[1]
			Gui.Back.Image = Chosen
			Gui.KeyBack.Image = Chosen
			Gui.Progress.Image = Chosen
			
			Gui.Enabled = true
			
			if Options.Font then
				Gui.NameBack.NameText.Font = Options.Font
				Gui.KeyBack.KeyText.Font = Options.Font
			end
			
			Gui.KeyBack.MouseButton1Down:Connect(function()
				Interactables.ClickingOn = InteractObj
			end)
			
			Interactables.Guis[InteractObj] = Gui
		end
		
		Gui.Adornee = InteractObj.Parent
		Gui.Progress.ImageRectOffset = ZeroOffset
		
		ThemeUtil.BindUpdate(Gui.KeyBack, {ImageColor3 = (InteractObj:FindFirstChild("Disabled") or Interactables.LocalDisabled[InteractObj]) and "Positive_Color3" or "Secondary_BackgroundColor", ImageTransparency = "Secondary_BackgroundTransparency"})
		
		if InteractObj:FindFirstChild("Disabled")  then
			Gui.KeyBack.KeyText.Text = InteractObj.Disabled.Value == 0 and "∞" or math.ceil(math.max(InteractObj.Disabled.Value - tick() - TimeSync.ServerOffset, 0))
		elseif Interactables.LocalDisabled[InteractObj] then
			Gui.KeyBack.KeyText.Text = "1"
		else
			Gui.KeyBack.KeyText.Text = Key
		end
		
		local MaxXSize = Options.MaxXSize or 75
		local MinXSize = Options.MinXSize or 50
		local NameSize = (Options.Name and 25 or 0)
		local ExtraYSize = NameSize + (Options.ExtraYSize or 0)
		local Ratio = MaxXSize / (MaxXSize + ExtraYSize * 2)
		Gui.Back.Position = UDim2.new(0.5, 0, 0.5 + ((Options.Name or Options.ExtraYSize) and (Ratio / 4) or 0), 0)
		Gui.Back.Size = UDim2.new(1, 0, Ratio / ((Options.Name or Options.ExtraYSize) and 2 or 1), 0)
		Gui.Progress.Size = UDim2.new(1, 0, Ratio, 0)
		Gui.KeyBack.Size = UDim2.new(1, 0, Ratio, 0)
		Gui.NameBack.NameText.Size = UDim2.new(1, -10, NameSize / (MaxXSize / Ratio * 0.5), 0)
		Gui.NameBack.AddonFrame.Position = UDim2.new(0.5, 0, NameSize / (MaxXSize / Ratio * 0.5), 0)
		Gui.NameBack.AddonFrame.Size = UDim2.new(1, 0, (ExtraYSize - NameSize) / (MaxXSize / Ratio * 0.5), 0)
		
		if Options.CustomFrame then
			Options.CustomFrame:Clone().Parent = Gui.NameBack.AddonFrame
		end
		
		Gui.Name = "InteractGui"
		Gui.Parent = script.Parent
		
		TweenService:Create(Gui, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0, MinXSize, 0, MinXSize / Ratio)}):Play()
	end
end)

Interactables.CloseGui:Connect(function(InteractObj, Gui)
	local Options = Interactables.GetOptions(InteractObj)
	if IsMyGui(Options) then
		local Tween = TweenService:Create(Gui, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)})
		Tween.Completed:Connect(function(State)
			if State == Enum.PlaybackState.Completed then
				Interactables.DestroyGui(InteractObj)
			end
		end)
		Tween:Play()
	end
end)

Interactables.EnableGui:Connect(function(InteractObj, Gui, Key)
	local Options = Interactables.GetOptions(InteractObj)
	if IsMyGui(Options) then
		local OldCol = Gui.KeyBack.ImageColor3
		ThemeUtil.BindUpdate(Gui.KeyBack, {ImageColor3 = "Secondary_BackgroundColor"})
		Gui.KeyBack.ImageColor3 = OldCol
		Gui.KeyBack.KeyText.Text = Key
		
		TweenService:Create(Gui.KeyBack, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {ImageColor3 = ThemeUtil.GetThemeFor("Secondary_BackgroundColor")}):Play()
	end
end)

Interactables.MaximiseGui:Connect(function(InteractObj, Gui)
	local Options = Interactables.GetOptions(InteractObj)
	if IsMyGui(Options) then
		Gui.Progress.ImageRectOffset = ZeroOffset
		Gui.Back.Visible = true
		Gui.Progress.Visible = true
		
		if Options.Name then
			Gui.NameBack.NameText.Text = Options.Name
		end
		
		local MaxXSize = Options.MaxXSize or 75
		local ExtraYSize = (Options.Name and 25 or 0) + (Options.ExtraYSize or 0)
		
		local Ratio = MaxXSize / (MaxXSize + ExtraYSize * 2)
		if Ratio ~= 1 then
			Gui.NameBack.Visible = true
			ThemeUtil.BindUpdate(Gui.NameBack, {BackgroundTransparency = "Primary_BackgroundTransparency"})
			Gui.NameBack.BackgroundTransparency = 1
			
			TweenService:Create(Gui.NameBack, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0.5, 0), BackgroundTransparency = ThemeUtil.GetThemeFor("Primary_BackgroundTransparency")}):Play()
		end
		
		ThemeUtil.BindUpdate(Gui.Back, {ImageTransparency = "Primary_BackgroundTransparency"})
		Gui.Back.ImageTransparency = 1
		
		TweenService:Create(Gui.Back, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {ImageTransparency = ThemeUtil.GetThemeFor("Primary_BackgroundTransparency")}):Play()
		TweenService:Create(Gui.KeyBack, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0.85, 0, Ratio * 0.85, 0)}):Play()
		TweenService:Create(Gui, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0, MaxXSize, 0, MaxXSize / Ratio)}):Play()
	end
end)

Interactables.MinimiseGui:Connect(function(InteractObj, Gui, CooldownLeft)
	local Options = Interactables.GetOptions(InteractObj)
	if IsMyGui(Options) then
		if CooldownLeft then
			local OldCol = Gui.KeyBack.ImageColor3
			ThemeUtil.BindUpdate(Gui.KeyBack, {ImageColor3 = "Positive_Color3"})
			Gui.KeyBack.ImageColor3 = OldCol
			Gui.KeyBack.KeyText.Text = CooldownLeft == true and "∞" or CooldownLeft
			
			TweenService:Create(Gui.KeyBack, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {ImageColor3 = ThemeUtil.GetThemeFor("Positive_Color3")}):Play()
		end
		
		local MaxXSize = Options.MaxXSize or 75
		local ExtraYSize = (Options.Name and 25 or 0) + (Options.ExtraYSize or 0)
		
		local Ratio = MaxXSize / (MaxXSize + ExtraYSize * 2)
		if Ratio ~= 1 then
			TweenService:Create(Gui.NameBack, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}):Play()
		end
		
		local Tween = TweenService:Create(Gui.KeyBack, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, Ratio, 0)})
		Tween.Completed:Connect(function(State)
			if State == Enum.PlaybackState.Completed and Gui and Gui.Name ~= "Destroying" then
				ThemeUtil.UnbindUpdate({Gui.Back, Gui.NameBack}, {"ImageTransparency"})
				
				Gui.Back.Visible = false
				Gui.Progress.Visible = false
				Gui.NameBack.Visible = false
				Gui.Progress.ImageRectOffset = ZeroOffset
			end
		end)
		TweenService:Create(Gui.Back, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {ImageTransparency = 1}):Play()
		Tween:Play()
		
		local MinXSize = Options.MinXSize or 50
		TweenService:Create(Gui, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0, MinXSize, 0, MinXSize / Ratio)}):Play()
	end
end)

Interactables.StartHold:Connect(function(InteractObj, Gui)
	local Options = Interactables.GetOptions(InteractObj)
	if IsMyGui(Options) then
		TweenService:Create(Gui.Progress, TweenInfo.new(0), {ImageTransparency = 0}):Play()
	end
end)

Interactables.EndHold:Connect(function(InteractObj, Gui, Completed, Cooldown)
	local Options = Interactables.GetOptions(InteractObj)
	if IsMyGui(Options) then
		if Completed then
			Gui.Progress.ImageRectOffset = Vector2.new(GetOffset(SpriteConfig.Count - 1))
			Gui.KeyBack.KeyText.Text = Cooldown and math.ceil(Cooldown) or "1"
			
			local OldCol = Gui.KeyBack.ImageColor3
			ThemeUtil.BindUpdate(Gui.KeyBack, {ImageColor3 = "Positive_Color3"})
			Gui.KeyBack.ImageColor3 = OldCol
			
			TweenService:Create(Gui.KeyBack, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {ImageColor3 = ThemeUtil.GetThemeFor("Positive_Color3")}):Play()
		else
			TweenService:Create(Gui.Progress, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {ImageTransparency = 1}):Play()
		end
	end
end)

Interactables.UpdateProgress:Connect(function(InteractObj, Gui, Perc)
	local Options = Interactables.GetOptions(InteractObj)
	if IsMyGui(Options) then
		Gui.Progress.ImageRectOffset = Vector2.new(GetOffset(math.min(Perc * SpriteConfig.Count, SpriteConfig.Count - 1)))
	end
end)

Interactables.UpdateCooldown:Connect(function(InteractObj, Gui, CooldownLeft)
	local Options = Interactables.GetOptions(InteractObj)
	if IsMyGui(Options) then
		Gui.KeyBack.KeyText.Text = CooldownLeft
	end
end)

Interactables.UpdateKey:Connect(function(Key)
	for InteractObj, InteractGui in pairs(Interactables.Guis) do
		local Options = Interactables.GetOptions(InteractObj)
		if IsMyGui(Options) and not tonumber(InteractGui.KeyBack.KeyText.Text) and InteractGui.KeyBack.KeyText.Text ~= "∞" then
			InteractGui.KeyBack.KeyText.Text = Key
		end 
	end
end)