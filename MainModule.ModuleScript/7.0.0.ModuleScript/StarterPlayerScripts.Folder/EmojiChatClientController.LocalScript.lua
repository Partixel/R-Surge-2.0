local SuggestedCount = script.Customization.PredictiveResultsCount.Value
if SuggestedCount <= 2 then
	SuggestedCount = 2
elseif SuggestedCount >= 8 then
	SuggestedCount = 8
end
local Maximum_Suggested_Emojis = SuggestedCount
local PredictiveLength = script.Customization.PredictiveTextMinimumLength.Value
if PredictiveLength <= 1 then
	PredictiveLength = 1
end
local Minimum_Suggested_Denotation_Length = PredictiveLength
game.Chat:WaitForChild("ChatModules")
local EmojiList = require(game.Chat.ChatModules:WaitForChild("EmojiList"))
local ChatSettings = require(game.Chat:WaitForChild("ClientChatModules").ChatSettings)
local Chat = game.Players.LocalPlayer.PlayerGui:WaitForChild("Chat")
local BaseFrame = Chat.Frame.ChatBarParentFrame.Frame
local TextBoxHolderFrame = BaseFrame.BoxFrame.Frame
local TextLabel = TextBoxHolderFrame.TextLabel
local TextBox = TextBoxHolderFrame.ChatBar
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TS = game:GetService("TweenService")
local mouse = game.Players.LocalPlayer:GetMouse()

local EmojiCategories = {
	{"Popular", "rbxassetid://1919144344", 0, "rbxassetid://1919143774"},
	{"People", "rbxassetid://1919143194", 0, "rbxassetid://1919142697"},
	{"Nature", "rbxassetid://1919141349", 0, "rbxassetid://1919140927"},
	{"Food", "rbxassetid://1919140366", 0, "rbxassetid://1919139999"},
	{"Activities", "rbxassetid://1919138696", 0, "rbxassetid://1919138375"},
	{"Travel", "rbxassetid://1919146329", 0, "rbxassetid://1919145934"},
	{"Objects", "rbxassetid://1919142217", 0, "rbxassetid://1919141792"},
	{"Symbols", "rbxassetid://1919145441", 0, "rbxassetid://1919145129"},
	{"Flags", "rbxassetid://1919139583", 0, "rbxassetid://1919139197"},
}

local EmojiButton, EmojiScroll, EmojiTray, TabTray, EmojiSelected, TabScroll, WidthValue, HeightValue, OriginalPositions
	
Chat.IgnoreGuiInset = true
Chat.Frame.Position = Chat.Frame.Position + UDim2.new(0, 0, 0, 36)
local ChatFrameOriginalPosition = Chat.Frame.Position
Chat.Frame.Size = UDim2.new(0, math.ceil((Chat.Frame.Size.X.Scale * Chat.AbsoluteSize.X - 14)/30) * 30 + 14, 0, Chat.Frame.Size.Y.Scale * Chat.AbsoluteSize.Y)
local ChatFrameOriginalSize = Chat.Frame.Size

local function CurrentEmojiSection()
	for i, _ in ipairs( EmojiCategories ) do
		if EmojiScroll.CanvasPosition.Y >= math.floor(EmojiCategories[#EmojiCategories - (i - 1)][3] / math.floor(EmojiTray.AbsoluteSize.X/30)) * 30 then
			return EmojiCategories[#EmojiCategories - (i - 1)][1]
		end
	end
end

local function CheckEmojiTabs()
	local CurrentSection = CurrentEmojiSection()
	for i, v in pairs(TabScroll:GetChildren()) do
		if v.Name == CurrentSection or (mouse.X >= v.AbsolutePosition.X and mouse.X <= v.AbsolutePosition.X + v.AbsoluteSize.X and mouse.Y >= v.AbsolutePosition.Y and mouse.Y <= v.AbsolutePosition.Y + v.AbsoluteSize.Y and EmojiTray.Visible) then
			v.Icon.Hover.ImageTransparency = 0
		elseif v.Name ~= CurrentSection then
			v.Icon.Hover.ImageTransparency = 1
		end
	end
end

mouse.Button1Down:Connect(function()
	local x, y = mouse.X, mouse.Y
	if (x < EmojiTray.AbsolutePosition.X or x > EmojiTray.AbsolutePosition.X + EmojiTray.AbsoluteSize.X) or (y < EmojiTray.AbsolutePosition.Y or y > EmojiTray.AbsolutePosition.Y + EmojiTray.AbsoluteSize.Y) then
		EmojiTray.Visible = false
		Chat.Frame.Position = ChatFrameOriginalPosition
		Chat.Frame.Size = ChatFrameOriginalSize
		for _, v in pairs(Chat.Frame:GetChildren()) do
			v.Position = OriginalPositions[v.Name]
			v.UISizeConstraint.MaxSize = Vector2.new(math.huge, math.huge)
		end
		EmojiScroll.CanvasPosition = Vector2.new(0, 0)
		--TextBoxHolderFrame.ChatBar.Position = UDim2.new(0, 0, 0, 0)
		--TextBoxHolderFrame.TextLabel.Position = UDim2.new(0, 0, 0, 0)
		local tween = TS:Create(EmojiSelected, TweenInfo.new(.2), {ImageTransparency = 1})
		tween:Play()
	end
end)

mouse.Move:Connect(function()
	CheckEmojiTabs()
end)

local EscapePatterns = {
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$",
	["\0"] = "%z",
}

local function ShowSuggestedEmojis( complete, pos )
	local str = ""
	for i = 1, #TextBox.Text do
		local c = str.sub(string.reverse(TextBox.Text), i, i)
		str = str..c
		if c == " " then
			str = ""
			break
		elseif c == ":" then
			break
		end
	end
	if str ~= "" and str ~= ":" and string.find(str, ":") ~= nil and string.len(str) >= Minimum_Suggested_Denotation_Length then
		str = string.reverse(str)
		if complete then str = str:sub( 1, -2 ) end
		SuggestedEmojis:ClearAllChildren()
		for i, v in ipairs(EmojiList) do
			if type(v) ~= "string" then
				if string.find(v[1], str:gsub(".", EscapePatterns), nil) ~= nil then
					if complete then
						TextBox.Text = TextBox.Text:sub( 1, pos - 1 ) .. TextBox.Text:sub( pos + 1 )
						TextBox.Text = string.sub(TextBox.Text, 1, #TextBox.Text - string.len(str)).. v[1] .." "
						TextBox.CursorPosition = #TextBox.Text + 1
						
						return
					end
					local copy = false
					for _, item in pairs(SuggestedEmojis:GetChildren()) do
						if item.Emoji.Value == v[2] then
							item.Text = item.Text..", "..v[1]
							copy = true
						end
					end
					if not copy then
						local button = Instance.new("TextButton")
						button.Parent = SuggestedEmojis
						button.Size = UDim2.new(1, 0, 0, 24)
						button.Position = UDim2.new(0, 0, 0, 2 + 26 * (#SuggestedEmojis:GetChildren() - 1))
						button.BorderSizePixel = 0
						button.TextSize = 16
						button.Font = ChatSettings.ChatBarFont
						button.TextXAlignment = Enum.TextXAlignment.Left
						button.BackgroundColor3 = ChatSettings.ChatBarBackGroundColor
						button.TextColor3 = Color3.fromRGB(240, 240, 240)
						button.TextStrokeTransparency = .85
						button.BackgroundTransparency = .6
						button.Text = "    "..v[2].." - "..v[1]
						local value = Instance.new("StringValue")
						value.Name = "Emoji"
						value.Parent = button
						value.Value = v[2]
						local Identifier = Instance.new("StringValue")
						Identifier.Name = "Identifier"
						Identifier.Value = v[1]
						Identifier.Parent = button
						button.MouseButton1Down:Connect(function()
							TextBox.Text = string.sub(TextBox.Text, 1, #TextBox.Text - string.len(str))..Identifier.Value.." "
							SuggestedEmojis:ClearAllChildren()
							TextBox:CaptureFocus()
						end)
						if #SuggestedEmojis:GetChildren() == Maximum_Suggested_Emojis then
							break
						end
					end
				end
			end
		end
	else
		SuggestedEmojis:ClearAllChildren()
	end
end

function CreateUI( )
	local ChatBarFocused = false
	
	OriginalPositions = {}
	
	for _, v in pairs(Chat.Frame:GetChildren()) do
		Instance.new("UISizeConstraint", v)
		OriginalPositions[v.Name] = v.Position
	end
	
	EmojiButton = Instance.new("ImageButton")
	EmojiButton.Name = "EmojiButton"
	EmojiButton.BackgroundTransparency = 1
	EmojiButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
	EmojiButton.Size = UDim2.new(0, 26, 0, 26)
	EmojiButton.Position = UDim2.new(1, -26, 0, -4)
	EmojiButton.Image = "rbxassetid://1839922730"
	EmojiButton.Selectable = false
	EmojiButton.ZIndex = 2
	EmojiButton.Parent = TextBoxHolderFrame
	
	EmojiSelected = Instance.new("ImageLabel")
	EmojiSelected.Name = "EmojiSelected"
	EmojiSelected.BackgroundTransparency = 1
	EmojiSelected.Size = UDim2.new(1, 0, 1, 0)
	EmojiSelected.Position = UDim2.new(0, 0, 0, 0)
	EmojiSelected.Image = "rbxassetid://1839922352"
	EmojiSelected.ImageTransparency = 1
	EmojiSelected.ZIndex = 3
	EmojiSelected.Parent = EmojiButton
	
	EmojiTray = Instance.new("Frame")
	EmojiTray.BackgroundTransparency = 1
	WidthValue = script.Customization.EmojiTrayWidth.Value
	if WidthValue > 1 then
		WidthValue = 1
	elseif WidthValue < .3 then
		WidthValue = .3
	end
	HeightValue = script.Customization.EmojiTrayHeight.Value
	if HeightValue > 5 then
		HeightValue = 5
	elseif HeightValue < 2 then
		HeightValue = 2
	end
	EmojiTray.Size = UDim2.new(0, math.ceil((WidthValue * BaseFrame.AbsoluteSize.X)/30) * 30 - 16, 0, math.ceil((HeightValue * BaseFrame.AbsoluteSize.Y)/30) * 30 + 39)
	EmojiTray.Position = UDim2.new(1, -(math.ceil((WidthValue * BaseFrame.AbsoluteSize.X)/30) * 30 - 16), 1, 2)
	EmojiTray.Visible = false
	EmojiTray.Name = "EmojiTray"
	EmojiTray.Parent = BaseFrame
	
	TabTray = Instance.new("Frame")
	TabTray.Position = UDim2.new(0, 3, 1, -33)
	TabTray.Size = UDim2.new(1, -6, 0, 30)
	TabTray.BackgroundTransparency = 1
	TabTray.Name = "TabTray"
	TabTray.Parent = EmojiTray
	
	local Divider = Instance.new("Frame")
	Divider.BorderSizePixel = 0
	Divider.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
	Divider.Size = UDim2.new(1, -8, 0, 1)
	Divider.Position = UDim2.new(0, 4, 0, -1)
	Divider.ZIndex = 3
	Divider.Name = "Divider"
	Divider.Parent = TabTray
	
	if script.Customization.MatchChatTheme then
		Divider.BackgroundTransparency = .6
		Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end
	
	TabScroll = Instance.new("ScrollingFrame")
	TabScroll.BackgroundTransparency = 1
	TabScroll.Position = UDim2.new(0, 3, 0, 0)
	TabScroll.Size = UDim2.new(1, -6, 0, 30)
	TabScroll.BottomImage = "rbxassetid://1839905743"
	TabScroll.MidImage = "rbxassetid://1839887863"
	TabScroll.TopImage = "rbxassetid://1839906214"
	TabScroll.ScrollBarThickness = 4
	TabScroll.BorderSizePixel = 0
	TabScroll.ZIndex = 2
	TabScroll.CanvasSize = UDim2.new(0, 270, 0, 0)
	TabScroll.Name = "Scroller"
	TabScroll.Parent = TabTray
	
	if TabScroll.CanvasSize.X.Offset <= TabScroll.AbsoluteSize.X then
		EmojiTray.Size = EmojiTray.Size - UDim2.new(0, 0, 0, 4)
		TabTray.Position = TabTray.Position + UDim2.new(0, 0, 0, 4)
	end
	
	for i, v in pairs(EmojiCategories) do
		local button = Instance.new("ImageButton")
		button.Name = v[1]
		button.BackgroundTransparency = 1
		button.Size = UDim2.new(0, 30, 0, 27)
		button.Position = UDim2.new(0, 30 * (i - 1), 0, 0)
		button.ZIndex = 3
		button.Parent = TabScroll
		local Icon = Instance.new("ImageLabel")
		Icon.Name = "Icon"
		Icon.Size = UDim2.new(0, 22, 0, 22)
		Icon.Position = UDim2.new(0, 4, 0, 3)
		Icon.BackgroundTransparency = 1
		Icon.Image = v[2]
		Icon.ZIndex = 3
		Icon.Parent = button
		local Hover = Instance.new("ImageLabel")
		Hover.Name = "Hover"
		Hover.Size = UDim2.new(1, 0, 1, 0)
		Hover.Image = v[4]
		Hover.BackgroundTransparency = 1
		Hover.ImageTransparency = 1
		Hover.ZIndex = 4
		Hover.Parent = Icon
	end
	
	EmojiScroll = Instance.new("ScrollingFrame")
	EmojiScroll.BackgroundTransparency = 1
	EmojiScroll.Position = UDim2.new(0, 3, 0, 3)
	EmojiScroll.Size = UDim2.new(1, -6, 1, -39)
	EmojiScroll.BottomImage = "rbxassetid://1839905743"
	EmojiScroll.MidImage = "rbxassetid://1839887863"
	EmojiScroll.TopImage = "rbxassetid://1839906214"
	EmojiScroll.ScrollBarThickness = 4
	EmojiScroll.BorderSizePixel = 0
	EmojiScroll.ZIndex = 2
	EmojiScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	EmojiScroll.Name = "Scroller"
	EmojiScroll.Parent = EmojiTray
	
	local EmojiGrid = Instance.new("UIGridLayout")
	EmojiGrid.CellPadding = UDim2.new(0, 0, 0, 0)
	EmojiGrid.CellSize = UDim2.new(0, 30, 0, 30)
	EmojiGrid.Parent = EmojiScroll
	
	local EmojiBackground = Instance.new("ImageLabel")
	EmojiBackground.BackgroundTransparency = 1
	EmojiBackground.Size = UDim2.new(1, 0, 1, 0)
	EmojiBackground.Position = UDim2.new(0, 0, 0, 0)
	EmojiBackground.Image = "rbxassetid://1839857362"
	EmojiBackground.ScaleType = "Slice"
	EmojiBackground.SliceCenter = Rect.new(5, 5, 395, 395)
	EmojiBackground.Name = "Background"
	EmojiBackground.Parent = EmojiTray
	
	if script.Customization.MatchChatTheme.Value then
		EmojiBackground.ImageTransparency = .6
		EmojiBackground.ImageColor3 = Color3.new(0, 0, 0)
	else
		local transparencyValue = script.Customization.TransparencyOverwrite.Value
		transparencyValue = math.abs(transparencyValue)
		if transparencyValue > .8 then
			transparencyValue = .8
		elseif transparencyValue < .2 then
			transparencyValue = .2
		end
		EmojiBackground.ImageTransparency = transparencyValue
		EmojiBackground.ImageColor3 = script.Customization.ColorOverwrite.Value
	end
	
	SuggestedEmojis = Instance.new("Frame")
	SuggestedEmojis.Parent = BaseFrame
	SuggestedEmojis.BackgroundTransparency = 1
	SuggestedEmojis.Position = UDim2.new(0, 0, 1, 0)
	SuggestedEmojis.Size = UDim2.new(1, 0, 1, 0)
	SuggestedEmojis.Name = "SuggestedEmojis"
	
	for i, v in ipairs(EmojiList) do
		if type(v) == "string" then
			for j, x in pairs(EmojiCategories) do
				if x[1] == v then
					x[3] = #EmojiScroll:GetChildren() - 1
					break
				end
			end
		elseif i == 2 or v[2] ~= EmojiList[i - 1][2] then
			local button = Instance.new("TextButton")
			button.BackgroundTransparency = 1
			button.ZIndex = 2
			button.TextSize = 14
			button.Text = v[2]
			local Identifier = Instance.new("StringValue")
			Identifier.Name = "Identifier"
			Identifier.Value = v[1]
			Identifier.Parent = button
			button.Parent = EmojiScroll
			button.MouseButton1Down:Connect(function()
				if not UserInputService.TouchEnabled then
					TextLabel.Visible = false
					TextBox.Text = TextBox.Text..v[1].." "
				end
			end)
			button.TouchTap:Connect(function()
				TextLabel.Visible = false
				TextBox.Text = TextBox.Text..v[1].." "
			end)
		end
	end
	
	EmojiScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil((#EmojiScroll:GetChildren() - 1)/math.floor(EmojiScroll.AbsoluteSize.X/30)) * 30)
	
	EmojiScroll.Changed:Connect(function()
		CheckEmojiTabs()
	end)
	
	EmojiButton.MouseButton1Down:Connect(function()
		EmojiTray.Visible = not EmojiTray.Visible
		if EmojiTray.Visible then
			for _, v in pairs(Chat.Frame:GetChildren()) do
				v.Position = UDim2.new(0, math.ceil(v.AbsolutePosition.X - Chat.Frame.AbsolutePosition.X), 0, math.ceil(v.AbsolutePosition.Y - Chat.Frame.AbsolutePosition.Y) + 36)
				v.UISizeConstraint.MaxSize = v.AbsoluteSize
			end
			Chat.Frame.Position = UDim2.new(0, 0, 0, 0)
			Chat.Frame.Size = UDim2.new(1, 0, 1, 0)
			local x = BaseFrame.EmojiTray.TabTray.Scroller.AbsolutePosition --query AbsolutePosition to fix positioning bug
		else
			Chat.Frame.Position = ChatFrameOriginalPosition
			Chat.Frame.Size = ChatFrameOriginalSize
			for _, v in pairs(Chat.Frame:GetChildren()) do
				v.Position = OriginalPositions[v.Name]
				v.UISizeConstraint.MaxSize = Vector2.new(math.huge, math.huge)
			end
			--TextBoxHolderFrame.ChatBar.Position = UDim2.new(0, 0, 0, 0)
			--TextBoxHolderFrame.TextLabel.Position = UDim2.new(0, 0, 0, 0)
		end
	end)
	
	EmojiButton.MouseEnter:Connect(function()
		local tween = TS:Create(EmojiSelected, TweenInfo.new(.2), {ImageTransparency = 0})
		tween:Play()
	end)
	
	EmojiButton.MouseLeave:Connect(function()
		if not EmojiTray.Visible then
			local tween = TS:Create(EmojiSelected, TweenInfo.new(.2), {ImageTransparency = 1})
			tween:Play()
		end
	end)
	
	TextBox.Focused:Connect(function()
		EmojiTray.Visible = false
		Chat.Frame.Position = ChatFrameOriginalPosition
		Chat.Frame.Size = ChatFrameOriginalSize
		for _, v in pairs(Chat.Frame:GetChildren()) do
			v.Position = OriginalPositions[v.Name]
			v.UISizeConstraint.MaxSize = Vector2.new(math.huge, math.huge)
		end
		--TextBoxHolderFrame.ChatBar.Position = UDim2.new(0, 0, 0, 0)
		--TextBoxHolderFrame.TextLabel.Position = UDim2.new(0, 0, 0, 0)
		EmojiScroll.CanvasPosition = Vector2.new(0, 0)
		local tween = TS:Create(EmojiSelected, TweenInfo.new(.2), {ImageTransparency = 1})
		tween:Play()
	end)
	
	for i, v in pairs(EmojiCategories) do
		TabScroll[v[1]].MouseButton1Down:Connect(function()
			EmojiScroll.CanvasPosition = Vector2.new(0, math.floor(v[3] / math.floor(EmojiTray.AbsoluteSize.X/30)) * 30)
			CheckEmojiTabs()
		end)
	end

	TextBox.FocusLost:Connect(function()
		wait()
		SuggestedEmojis:ClearAllChildren()
	end)
	
	TextBox.Focused:Connect(ShowSuggestedEmojis)
	
	local Last = ""
	
	TextBox.Changed:Connect(function(property)
		if property == "Text" then
			local complete, pos
			if #Last < #TextBox.Text then
				for a = 1, #TextBox.Text do
					if Last:sub( a, a ) ~= TextBox.Text:sub( a, a ) then
						complete = TextBox.Text:sub( a, a ) == "	"
						pos = a
						break
					end
				end
			end
			Last = TextBox.Text
			
			ShowSuggestedEmojis( complete, pos )
		end
	end)
	
	BaseFrame.Changed:Connect(function()
		EmojiButton.ImageTransparency = 1 - (1 - BaseFrame.BackgroundTransparency)/.4
	end)
	
end

CreateUI( )

function UpdateChatBar( )
	
	BaseFrame = Chat.Frame.ChatBarParentFrame:WaitForChild( "Frame" )
	TextBoxHolderFrame = BaseFrame.BoxFrame.Frame
	TextLabel = TextBoxHolderFrame.TextLabel
	TextBox = TextBoxHolderFrame.ChatBar
	
	CreateUI( )
	
	BaseFrame.AncestryChanged:Connect( UpdateChatBar )
	
end

BaseFrame.AncestryChanged:Connect( UpdateChatBar )