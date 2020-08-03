local TweenService, ThemeUtil = game:GetService("TweenService"), require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))
local KBU = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("KeybindUtil"))

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

return {
	RequiresRemote = true,
	ButtonText = "Keybinds",
	SetupGui = function(self)
		ThemeUtil.BindUpdate(self.Gui, {BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
		
		self.Remote.OnClientEvent:Connect(function(Binds)
			KBU.SavedBinds = Binds
			KBU.BindChanged:Fire()
		end)
		
		KBU.BindChanged.Event:Connect(function(Name, Type, Value)
			if Type then
				self.Remote:FireServer(Name, Type ~= "Default" and Type or nil, Value)
			end
		end)
	end,
	OnClose = function(self)
		KBU.Rebinding = nil
	end,
	Tabs = {
		{
			Tab = script:WaitForChild("Gui").MainTab,
			SetupTab = function(self)
				ThemeUtil.BindUpdate(self.Tab.ScrollingFrame, {ScrollBarImageColor3 = "Secondary_BackgroundColor", ScrollBarImageTransparency = "Secondary_BackgroundTransparency"})
				ThemeUtil.BindUpdate({self.Tab.Search, self.Tab.Context.Gamepad, self.Tab.Context.Keyboard, self.Tab.Context:FindFirstChild("Name"), self.Tab.Context.Toggle}, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency"})
				ThemeUtil.BindUpdate({self.Tab.Search, self.Tab.Context.Gamepad, self.Tab.Context.Keyboard, self.Tab.Context:FindFirstChild("Name"), self.Tab.Context.Toggle}, {TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
				ThemeUtil.BindUpdate(self.Tab.Search, {PlaceholderColor3 = "Secondary_TextColor"})
				
				self.Tab.ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					self.Tab.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.Tab.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
					
					if self.Tab.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y > self.Tab.ScrollingFrame.AbsoluteSize.Y then
						self.Tab.Context.Size = UDim2.new(1, -15, 0, 25)
					else
						self.Tab.Context.Size = UDim2.new(1, -10, 0, 25)
					end
				end)
				
				self.Tab.Search:GetPropertyChangedSignal("Text"):Connect(function()
					self:Invalidate()
				end)
				
				KBU.BindAdded.Event:Connect(function()
					self:Invalidate()
				end)
				
				KBU.BindChanged.Event:Connect(function(Name)
					if not KBU.GetBind(Name) or not self.Tab.ScrollingFrame:FindFirstChild(Name, true) then
						self:Invalidate()
					end
				end)
			end,
			Hide = {},
			Redraw = function(self)
				for _, Obj in ipairs(self.Tab.ScrollingFrame:GetChildren()) do
					if Obj:IsA("Frame") or Obj:IsA("TextButton") then Obj:Destroy() end
				end
				local Txt = self.Tab.Search.Text:lower():gsub(".", EscapePatterns)
				local Categories = {}
				
				for _, Bind in pairs(KBU.Binds) do
					if Bind.Name:lower():find(Txt) and not Bind.NonRebindable then
						local Base = script.Base:Clone()
						Base.Name = Bind.Name
						Base.Main.Text = Bind.Name
						
						local Category = Bind.Category or "Uncategorised"
						Categories[Category] = Categories[Category] or {}
						Categories[Category][#Categories[Category] + 1] = Base
						
						ThemeUtil.BindUpdate({Base.Gamepad, Base.Keyboard, Base.Main, Base.Toggle}, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
						
						Base.Main.MouseButton1Click:Connect(function ()
							KBU.Defaults(Bind.Name)
							KBU.WriteToObj(Base.Keyboard, Bind.Key)
							KBU.WriteToObj(Base.Gamepad, Bind.PadKey)
							KBU.WriteToObj(Base.Toggle, Bind.ToggleState or false)
						end)
						
						KBU.WriteToObj(Base.Keyboard, Bind.Key)
						
						Base.Keyboard.MouseButton1Click:Connect(function ()
							KBU.Rebind(Bind.Name, Enum.UserInputType.Keyboard, Base.Keyboard)
							KBU.WriteToObj(Base.Keyboard, Bind.Key)
						end)
						
						KBU.WriteToObj(Base.Gamepad, Bind.PadKey)
						
						Base.Gamepad.MouseButton1Click:Connect(function ()
							KBU.Rebind(Bind.Name, Enum.UserInputType.Gamepad1, Base.Gamepad)
							KBU.WriteToObj(Base.Gamepad, Bind.PadKey)
						end)
						
						if Bind.CanToggle then
							KBU.WriteToObj(Base.Toggle, Bind.ToggleState or false)
							
							Base.Toggle.MouseButton1Click:Connect(function ()
								KBU.Rebind(Bind.Name, "Toggle", Base.Toggle)
								KBU.WriteToObj(Base.Toggle, Bind.ToggleState or false)
							end)
						else
							Base.Toggle.Visible = false
						end
					end
				end
				
				for a, b in pairs(Categories) do
					local Cat = script.Category:Clone()
					Cat.Name = a
					Cat.Button.OpenIndicator.Text = not self.Hide[a] and  "Λ" or "V"
					Cat.Button.TitleText.Text = a
					Cat.Button.MouseButton1Click:Connect(function ()
						self.Hide[a] = not self.Hide[a]
						TweenService:Create(Cat, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = UDim2.new(1, 0, 0, self.Hide[a] and Cat.Button.Size.Y.Offset or Cat.UIListLayout.AbsoluteContentSize.Y)}):Play()
						Cat.Button.OpenIndicator.Text = not self.Hide[a] and  "Λ" or "V"
					end)
					
					ThemeUtil.BindUpdate({Cat.Button.BarL, Cat.Button.BarR, Cat.Button.BarR2}, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency"})
					ThemeUtil.BindUpdate({Cat.Button.OpenIndicator, Cat.Button.TitleText}, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
					
					Cat.Parent = self.Tab.ScrollingFrame
					
					for _, Obj in ipairs(b) do
						Obj.Parent = Cat
					end
					
					Cat.Size = UDim2.new(1, 0, 0, self.Hide[a] and Cat.Button.Size.Y.Offset or Cat.UIListLayout.AbsoluteContentSize.Y)
				end
			end
		},
	},
}