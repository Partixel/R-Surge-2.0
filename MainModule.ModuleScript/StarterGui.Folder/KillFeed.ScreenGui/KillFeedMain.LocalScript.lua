local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local ThemeUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))
local Menu = require(game:GetService("ReplicatedStorage"):WaitForChild("MenuLib"):WaitForChild("S2"))

local VictimTypes = {Head = {"rbxassetid://1693819171", "Negative_Color3"}, NewHead = {"rbxassetid://1693819171", "Negative_Color3"}}
-- Need suicide dmgtype
local DmgTypes = {Kinetic = "rbxassetid://4263457339", Explosive = "rbxassetid://4263473278", Slash = "rbxassetid://4263464121", Fire = "rbxassetid://4263480827", Electricity = "rbxassetid://4263484727"}

Menu:AddSetting{Name = "KillFeed", Text = "Enables/disables the killfeed", Default = true, Update = function(Options, Val)
	script.Parent.Container.Visible = Val
end}

local function PctStr(Num, Decimals)
	-- Needs percentage as a value between 0 - 100 (multiply the decimal by 100)
	Decimals = Decimals or 0
	local Min = 0.1 ^ Decimals
	return string.format("%." .. Decimals .. "f", Num > 0 and Num < Min and Min or Num > 100 - Min and Num < 100 and 100 - Min or Num)
end

local function UpdateContrastTextStroke(Obj)
	if ThemeUtil.GetThemeFor("Primary_BackgroundTransparency") > 0.9 then
		Obj.TextStrokeColor3 = ThemeUtil.GetThemeFor("Inverted_TextColor")
	else
		ThemeUtil.ContrastTextStroke(Obj, ThemeUtil.GetThemeFor("Primary_BackgroundColor"))
	end
end

local function Scale(Feed)
	local Y = math.ceil((workspace.CurrentCamera.ViewportSize.Y * 0.02) / 2) * 2
	
	Feed.Size = UDim2.new(0, 1000, 0, Y)
	
	Feed.Type.Size = UDim2.new(0, Y, 0, Y)
	
	Feed.RightFrame.Container.BackgroundMiddle.Size = UDim2.new(1, 0, 1, -Y)
	Feed.RightFrame.Container.BackgroundBottom.Size = UDim2.new(1, 0, 0, Y / 2)
	Feed.RightFrame.Container.BackgroundTop.Size = UDim2.new(1, 0, 0, Y / 2)
	for _, VictimFrame in ipairs(Feed.RightFrame.Container.List:GetChildren()) do
		if VictimFrame:IsA("Frame") then
			VictimFrame.Size = UDim2.new(VictimFrame.Size.X.Scale, VictimFrame.Size.X.Offset, VictimFrame.Size.Y.Scale, Y)
		end
	end
	
	Feed.LeftFrame.Container.BackgroundMiddle.Size = UDim2.new(1, 0, 1, -Y)
	Feed.LeftFrame.Container.BackgroundBottom.Size = UDim2.new(1, 0, 0, Y / 2)
	Feed.LeftFrame.Container.BackgroundTop.Size = UDim2.new(1, 0, 0, Y / 2)
	for _, KillerFrame in ipairs(Feed.LeftFrame.Container.List:GetChildren()) do
		if KillerFrame:IsA("Frame") then
			KillerFrame.Size = UDim2.new(KillerFrame.Size.X.Scale, KillerFrame.Size.X.Offset, KillerFrame.Size.Y.Scale, Y)
		end
	end
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	for _, Feed in ipairs(script.Parent.Container:GetChildren()) do
		if Feed:IsA("Frame") then
			Scale(Feed)
		end
	end
end)

local function AutoSizeText(TextLabel)
	TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		TextLabel.Size = UDim2.new(TextLabel.Size.X.Scale, TextService:GetTextSize(TextLabel.Text, TextLabel.AbsoluteSize.Y, Enum.Font.SourceSansBold, Vector2.new(1000, TextLabel.AbsoluteSize.Y)).X, TextLabel.Size.Y.Scale, TextLabel.Size.Y.Offset)
	end)
	TextLabel:GetPropertyChangedSignal("Text"):Connect(function()
		TextLabel.Size = UDim2.new(TextLabel.Size.X.Scale, TextService:GetTextSize(TextLabel.Text, TextLabel.AbsoluteSize.Y, Enum.Font.SourceSansBold, Vector2.new(1000, TextLabel.AbsoluteSize.Y)).X, TextLabel.Size.Y.Scale, TextLabel.Size.Y.Offset)
	end)
end

local function AutoSizeFrame(Frame)
	Frame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Frame.Size = UDim2.new(Frame.Size.X.Scale, Frame.UIListLayout.AbsoluteContentSize.X, Frame.Size.Y.Scale, Frame.Size.Y.Offset)
	end)
end

local function UpdateCorners(Feed)
	if #Feed.RightFrame.Container.List:GetChildren() > 3 then
		if Feed.UIListLayout.VerticalAlignment ~= Enum.VerticalAlignment.Bottom then
			Feed.RightFrame.Container.BackgroundBottom.ImageRectOffset = Vector2.new(936, 977.5)
			Feed.RightFrame.Container.BackgroundBottom.ImageRectSize = Vector2.new(83, 41.5)
			Feed.RightFrame.Container.BackgroundBottom.SliceCenter = Rect.new(41.5, 41.5, 41.5, 41.5)
		else
			Feed.RightFrame.Container.BackgroundBottom.ImageRectOffset = Vector2.new(977.5, 977.5)
			Feed.RightFrame.Container.BackgroundBottom.ImageRectSize = Vector2.new(41.5, 41.5)
			Feed.RightFrame.Container.BackgroundBottom.SliceCenter = Rect.new(0, 41.5, 0, 41.5)
		end
		
		if Feed.UIListLayout.VerticalAlignment ~= Enum.VerticalAlignment.Top then
			Feed.RightFrame.Container.BackgroundTop.ImageRectOffset = Vector2.new(936, 936)
			Feed.RightFrame.Container.BackgroundTop.ImageRectSize = Vector2.new(83, 41.5)
			Feed.RightFrame.Container.BackgroundTop.SliceCenter = Rect.new(41.5, 41.5, 41.5, 41.5)
		else
			Feed.RightFrame.Container.BackgroundTop.ImageRectOffset = Vector2.new(977.5, 936)
			Feed.RightFrame.Container.BackgroundTop.ImageRectSize = Vector2.new(41.5, 41.5)
			Feed.RightFrame.Container.BackgroundTop.SliceCenter = Rect.new(0, 41.5, 0, 41.5)
		end
	else
		Feed.RightFrame.Container.BackgroundBottom.ImageRectOffset = Vector2.new(977.5, 977.5)
		Feed.RightFrame.Container.BackgroundBottom.ImageRectSize = Vector2.new(41.5, 41.5)
		Feed.RightFrame.Container.BackgroundBottom.SliceCenter = Rect.new(0, 41.5, 0, 41.5)
		
		Feed.RightFrame.Container.BackgroundTop.ImageRectOffset = Vector2.new(977.5, 936)
		Feed.RightFrame.Container.BackgroundTop.ImageRectSize = Vector2.new(41.5, 41.5)
		Feed.RightFrame.Container.BackgroundTop.SliceCenter = Rect.new(0, 41.5, 0, 41.5)
	end
	
	if #Feed.LeftFrame.Container.List:GetChildren() > 3 then
		if Feed.UIListLayout.VerticalAlignment ~= Enum.VerticalAlignment.Bottom then
			Feed.LeftFrame.Container.BackgroundBottom.ImageRectOffset = Vector2.new(936, 977.5)
			Feed.LeftFrame.Container.BackgroundBottom.ImageRectSize = Vector2.new(83, 41.5)
			Feed.LeftFrame.Container.BackgroundBottom.SliceCenter = Rect.new(41.5, 41.5, 41.5, 41.5)
		else
			Feed.LeftFrame.Container.BackgroundBottom.ImageRectOffset = Vector2.new(936, 977.5)
			Feed.LeftFrame.Container.BackgroundBottom.ImageRectSize = Vector2.new(41.5, 41.5)
			Feed.LeftFrame.Container.BackgroundBottom.SliceCenter = Rect.new(41.5, 41.5, 41.5, 41.5)
		end
		
		if Feed.UIListLayout.VerticalAlignment ~= Enum.VerticalAlignment.Top then
			Feed.LeftFrame.Container.BackgroundTop.ImageRectOffset = Vector2.new(936, 936)
			Feed.LeftFrame.Container.BackgroundTop.ImageRectSize = Vector2.new(83, 41.5)
			Feed.LeftFrame.Container.BackgroundTop.SliceCenter = Rect.new(41.5, 41.5, 41.5, 41.5)
		else
			Feed.LeftFrame.Container.BackgroundTop.ImageRectOffset = Vector2.new(936, 936)
			Feed.LeftFrame.Container.BackgroundTop.ImageRectSize = Vector2.new(41.5, 41.5)
			Feed.LeftFrame.Container.BackgroundTop.SliceCenter = Rect.new(41.5, 41.5, 41.5, 41.5)
		end
	else
		Feed.LeftFrame.Container.BackgroundBottom.ImageRectOffset = Vector2.new(936, 977.5)
		Feed.LeftFrame.Container.BackgroundBottom.ImageRectSize = Vector2.new(41.5, 41.5)
		Feed.LeftFrame.Container.BackgroundBottom.SliceCenter = Rect.new(41.5, 41.5, 41.5, 41.5)
		
		Feed.LeftFrame.Container.BackgroundTop.ImageRectOffset = Vector2.new(936, 936)
		Feed.LeftFrame.Container.BackgroundTop.ImageRectSize = Vector2.new(41.5, 41.5)
		Feed.LeftFrame.Container.BackgroundTop.SliceCenter = Rect.new(41.5, 41.5, 41.5, 41.5)
	end
end

local Zero = UDim2.new(0, 0, 0, 0)
local CurLayoutOrder = 0
local function UpdateLayoutOrder()
	local Direction = script.Parent.Container.UIListLayout.VerticalAlignment == Enum.VerticalAlignment.Bottom and 1 or -1
	
	local Feeds = script.Parent.Container:GetChildren()
	CurLayoutOrder = math.abs(CurLayoutOrder) * Direction
	for _, Feed in ipairs(Feeds) do
		if Feed:IsA("Frame") then
			Feed.UIListLayout.VerticalAlignment = script.Parent.Container.UIListLayout.VerticalAlignment
			Feed.LayoutOrder = math.abs(Feed.LayoutOrder) * Direction
			UpdateCorners(Feed)
		end
	end
end
script.Parent.Container.UIListLayout:GetPropertyChangedSignal("VerticalAlignment"):Connect(UpdateLayoutOrder)
UpdateLayoutOrder()

game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("RemoteKilled").OnClientEvent:Connect(function(DeathInfo)
	if script.Parent.Container.Visible then
		local NewFeed = script.Feed:Clone()
		
		for _, Info in ipairs(DeathInfo.VictimInfos) do
			if not Info.NoFeed then
				local VictimFrame = script.Victim:Clone()
				
				VictimFrame.Name = "Victim" .. #NewFeed.RightFrame.Container.List:GetChildren() - 1
				VictimFrame.LayoutOrder = #NewFeed.RightFrame.Container.List:GetChildren() - 1
				
				AutoSizeFrame(VictimFrame)
				AutoSizeText(VictimFrame.VictimName)
				AutoSizeText(VictimFrame.Distance)
				
				VictimFrame.VictimName.Text = Info.User.Name
				VictimFrame.VictimName.TextColor3 = Info.User.TeamColor and Info.User.TeamColor.Color or ThemeUtil.GetThemeFor("Primary_TextColor")
				
				local Type = VictimTypes[Info.ExtraInformation.HitName]
				if Type then
					VictimFrame.VictimType.Image = Type[1]
					if typeof(Type[2]) == "Color3" then
						VictimFrame.VictimType.ImageColor3 = Type[2]
					else
						ThemeUtil.BindUpdate(VictimFrame.VictimType, {ImageColor3 = Type[2]})
					end
				else
					VictimFrame.VictimType:Destroy()
				end
				print(Info.ExtraInformation.StartPosition, Info.ExtraInformation.RelativeEndPosition, Info.ExtraInformation.Hit)
				if Info.ExtraInformation.StartPosition and Info.ExtraInformation.RelativeEndPosition and Info.ExtraInformation.Hit then
					VictimFrame.Distance.Text = math.ceil((Info.ExtraInformation.StartPosition - Info.ExtraInformation.Hit.CFrame:PointToWorldSpace(Info.ExtraInformation.RelativeEndPosition)).magnitude * 10) / 10
					
					ThemeUtil.BindUpdate(VictimFrame.Distance, {TextColor3 = "Negative_Color3", TextTransparency = "Primary_TextTransparency", Primary_BackgroundTransparency = UpdateContrastTextStroke})
				else
					VictimFrame.Distance:Destroy()
				end
				
				ThemeUtil.BindUpdate(VictimFrame.VictimName, {TextTransparency = "Primary_TextTransparency", Primary_BackgroundTransparency = UpdateContrastTextStroke})
				
				VictimFrame.Parent = NewFeed.RightFrame.Container.List
			end
		end
		
		if #NewFeed.RightFrame.Container.List:GetChildren() > 2 then
			NewFeed.RightFrame.Container.List.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				NewFeed.RightFrame.Container.Size = UDim2.new(0, NewFeed.RightFrame.Container.List.UIListLayout.AbsoluteContentSize.X + 10, 1, 0)
				
				local MaxX = math.max(NewFeed.RightFrame.Container.Size.X.Offset, NewFeed.LeftFrame.Container.Size.X.Offset)
				NewFeed.RightFrame.Size = UDim2.new(0, MaxX, 0, NewFeed.RightFrame.Container.List.UIListLayout.AbsoluteContentSize.Y)
				NewFeed.LeftFrame.Size = UDim2.new(0, MaxX, 0, NewFeed.LeftFrame.Container.List.UIListLayout.AbsoluteContentSize.Y)
			end)
			
			NewFeed.LeftFrame.Container.List.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				NewFeed.LeftFrame.Container.Size = UDim2.new(0, NewFeed.LeftFrame.Container.List.UIListLayout.AbsoluteContentSize.X + 10, 1, 0)
				
				local MaxX = math.max(NewFeed.RightFrame.Container.Size.X.Offset, NewFeed.LeftFrame.Container.Size.X.Offset)
				NewFeed.RightFrame.Size = UDim2.new(0, MaxX, 0, NewFeed.RightFrame.Container.List.UIListLayout.AbsoluteContentSize.Y)
				NewFeed.LeftFrame.Size = UDim2.new(0, MaxX, 0, NewFeed.LeftFrame.Container.List.UIListLayout.AbsoluteContentSize.Y)
			end)
			
			local OpenTween
			NewFeed.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if OpenTween then
					OpenTween.Completed:Wait()
				end
				
				TweenService:Create(NewFeed, TweenInfo.new(0, Enum.EasingStyle.Quad), {Size = UDim2.new(0, NewFeed.UIListLayout.AbsoluteContentSize.X, 0, NewFeed.UIListLayout.AbsoluteContentSize.Y)}):Play()
			end)
			
			NewFeed.Type.Image = DmgTypes[DeathInfo.Type or "Suicide"] or DmgTypes["Kinetic"]
			
			local KillerFrame = script.Killer:Clone()
			
			KillerFrame.Name = "Killer"
			KillerFrame.LayoutOrder = 1
			
			AutoSizeFrame(KillerFrame)
			AutoSizeText(KillerFrame.KillerName)
			
			KillerFrame.KillerName.Text = DeathInfo.Killer and DeathInfo.Killer.Name or NewFeed["Victim1"].VictimName.Text
			KillerFrame.KillerName.TextColor3 = DeathInfo.Killer and DeathInfo.Killer.TeamColor and DeathInfo.Killer.TeamColor.Color or NewFeed["Victim1"].VictimName.TextColor3
			
			ThemeUtil.BindUpdate(KillerFrame.KillerName, {TextTransparency = "Primary_TextTransparency", Primary_BackgroundTransparency = UpdateContrastTextStroke})
			ThemeUtil.BindUpdate(KillerFrame.Percent, {TextColor3 = "Negative_Color3", TextTransparency = "Primary_TextTransparency", Primary_BackgroundTransparency = UpdateContrastTextStroke})
			
			if DeathInfo.Assister then
				NewFeed.LeftFrame.Container.BackgroundBottom.ImageRectOffset = Vector2.new(936, 977.5)
				NewFeed.LeftFrame.Container.BackgroundBottom.ImageRectSize = Vector2.new(83, 41.5)
				NewFeed.LeftFrame.Container.BackgroundBottom.SliceCenter = Rect.new(41.5, 41.5, 41.5, 41.5)
				
				AutoSizeText(KillerFrame.Percent)
				
--				UDim2.new(0, X, 0.6, 0)
--				local Assister = script.Assister:Clone()
--				ThemeUtil.BindUpdate(Assister, {ImageColor3 = "Primary_BackgroundColor", ImageTransparency = "Primary_BackgroundTransparency"})
--				ThemeUtil.BindUpdate(Assister.Frame, {BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
--				Assister.AssisterName.Text = DeathInfo.Assister.Name
--				Assister.AssisterName.TextColor3 = DeathInfo.Assister.TeamColor and DeathInfo.Assister.TeamColor.Color or ThemeUtil.GetThemeFor("Primary_TextColor")
--				ThemeUtil.BindUpdate(Assister.AssisterName, {Primary_BackgroundTransparency = UpdateContrastTextStroke})
--				Assister.AssisterPct.Text = PctStr(DeathInfo.AssisterDamage / DeathInfo.TotalDamage * 100, 0) .. "%"
--				if Core.Config.KillFeedVerticalAlign == "Bottom" then
--					Assister.Frame.Position = UDim2.new(1, 0, 0.25, 0)
--					Assister.Position = UDim2.new(1, 0, 0, 0)
--				end
--				Assister.Parent = NewFeed.Killer
--				local KillPct = script.KillerPct:Clone()
--				KillPct.Text = PctStr(DeathInfo.KillerDamage / DeathInfo.TotalDamage * 100, 0) .. "%"
--				KillPct.Parent = NewFeed.Killer
			else
				KillerFrame.Percent:Destroy()
			end
			
			KillerFrame.Parent = NewFeed.LeftFrame.Container.List
			
			ThemeUtil.BindUpdate(NewFeed.Type, {ImageColor3 = "Primary_TextColor", ImageTransparency = "Primary_TextTransparency", BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
			ThemeUtil.BindUpdate({NewFeed.LeftFrame.Container.BackgroundMiddle, NewFeed.RightFrame.Container.BackgroundMiddle}, {BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
			ThemeUtil.BindUpdate({NewFeed.LeftFrame.Container.BackgroundBottom, NewFeed.LeftFrame.Container.BackgroundTop, NewFeed.RightFrame.Container.BackgroundBottom, NewFeed.RightFrame.Container.BackgroundTop}, {ImageColor3 = "Primary_BackgroundColor", ImageTransparency = "Primary_BackgroundTransparency"})
--			ThemeUtil.BindUpdate(NewFeed.Killer.KillerName, {Primary_BackgroundTransparency = UpdateContrastTextStroke})
			
			CurLayoutOrder = CurLayoutOrder + (script.Parent.Container.UIListLayout.VerticalAlignment == Enum.VerticalAlignment.Bottom and 1 or -1)
			NewFeed.LayoutOrder = CurLayoutOrder
			
			UpdateCorners(NewFeed)
			Scale(NewFeed)
			
			local Size = NewFeed.Size
			NewFeed.Size = Zero
			
			NewFeed.Parent = script.Parent.Container
			
			OpenTween = TweenService:Create(NewFeed, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = Size})
			OpenTween:Play()
			OpenTween.Completed:Wait()
			OpenTween = nil
			
			wait(5)
			
			local Tween = TweenService:Create(NewFeed, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = Zero})
			Tween.Completed:Connect(function(State)
				NewFeed:Destroy()
			end)
			Tween:Play()
		end
	end
end)