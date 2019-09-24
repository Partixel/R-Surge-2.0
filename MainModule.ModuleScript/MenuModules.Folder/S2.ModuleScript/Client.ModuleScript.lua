local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )
local ThemeUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))
local StringCalculator = require(script:WaitForChild("StringCalculator"))
local CollectionService = game:GetService( "CollectionService" )

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
	ButtonText = "Surge 2.0",
	Settings = {
		{Name = "CharacterAim", Text = "Rotate character towards target", Default = true},
	},
	UpdateCharacterAim = function(self, Val)
		Core.Config.AllowCharacterRotation = Val
	end,
	SavedSettings = {},
	SetupGui = function(self)
		ThemeUtil.BindUpdate(self.Gui, {BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
		
		for _, Setting in ipairs(self.Settings) do
			if self.SavedSettings[Setting.Name] == nil then
				self.SavedSettings[Setting.Name] = Setting.Default
			end
			if self["Update" .. Setting.Name] then
				coroutine.wrap(self["Update" .. Setting.Name])(self, self.SavedSettings[Setting.Name])
			end
		end
		
		self.Remote.OnClientEvent:Connect(function(Settings)
			self.SavedSettings = Settings
			for _, Setting in ipairs(self.Settings) do
				if self.SavedSettings[Setting.Name] == nil then
					self.SavedSettings[Setting.Name] = Setting.Default
				end
				if self["Update" .. Setting.Name] then
					coroutine.wrap(self["Update" .. Setting.Name])(self, self.SavedSettings[Setting.Name])
				end
			end
			
			self.Tabs[1]:Invalidate()
		end)
	end,
	Tabs = {
		{
			Tab = script:WaitForChild("Gui").MainTab,
			SetupTab = function(self)
				ThemeUtil.BindUpdate(self.Tab.ScrollingFrame, {ScrollBarImageColor3 = "Secondary_BackgroundColor", ScrollBarImageTransparency = "Secondary_BackgroundTransparency"})
				ThemeUtil.BindUpdate(self.Tab.Search, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor"})
				
				self.Tab.ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					self.Tab.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.Tab.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
				end)
				
				self.Tab.Search:GetPropertyChangedSignal("Text"):Connect(function()
					self:Invalidate()
				end)
			end,
			Redraw = function(self)
				for _, Obj in ipairs(self.Tab.ScrollingFrame:GetChildren()) do
					if Obj:IsA("Frame") then Obj:Destroy() end
				end
				
				local Txt = self.Tab.Search.Text:lower():gsub(".", EscapePatterns)
				for i, Setting in pairs(self.Options.Settings) do
					if Setting.Text:lower():find(Txt) then
						local Type = typeof(Setting.Default)
						local Inst =  script:FindFirstChild(Type):Clone()
						Inst.TextButton.Text = Setting.Text
						Inst.LayoutOrder = i
						
						ThemeUtil.BindUpdate(Inst.TextButton, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
						
						if Type == "number" then
							Inst.Number.Text = self.Options.SavedSettings[Setting.Name]
							Inst.Number.PlaceholderText = Inst.Number.Text
							ThemeUtil.BindUpdate(Inst.Number, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor"})
							
							Inst.TextButton.AutoButtonColor = false
						elseif Type == "boolean" then
							ThemeUtil.BindUpdate(Inst.Boolean, {BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", BackgroundColor3 = self.Options.SavedSettings[Setting.Name] and "Positive_Color3" or "Negative_Color3"})
						end
						
						for _, Obj in pairs(Inst:GetChildren()) do
							if Type == "boolean" then
								Obj.MouseButton1Click:Connect(function ()
									self.Options.SavedSettings[Setting.Name] = not self.Options.SavedSettings[Setting.Name]
									self.Options.Remote:FireServer(Setting.Name, self.Options.SavedSettings[Setting.Name] or nil)
									if self.Options["Update" .. Setting.Name] then
										coroutine.wrap(self.Options["Update" .. Setting.Name])(self.Options, self.Options.SavedSettings[Setting.Name])
									end
									ThemeUtil.BindUpdate(Inst.Boolean, {BackgroundColor3 = self.Options.SavedSettings[Setting.Name] and "Positive_Color3" or "Negative_Color3"})
								end)
							elseif Obj:IsA("TextBox") then
								Obj.FocusLost:Connect(function()
									if Type == "number" then
										if Inst.Number.Text == "" then
											Inst.Number.Text = Inst.Number.PlaceholderText
											return
										end
										
										local Ran, Num = pcall(StringCalculator, Inst.Number.Text)
										if not Ran then
											Inst.Number.Text = Num:sub(-Num:reverse():find(":") + 2)
										end
										
										if Num then
											if Setting.Min then
												Num = math.max(Num, Setting.Min)
											end
											if Setting.Max then
												Num = math.min(Num, Setting.Max)
											end
											
											Inst.Number.Text = Num
											
											self.Options.SavedSettings[Setting.Name] = Num
											self.Options.Remote:FireServer(Setting.Name, Num)
											if self.Options["Update" .. Setting.Name] then
												coroutine.wrap(self.Options["Update" .. Setting.Name])(self.Options, Num)
											end
										end
									end
								end)
							end
						end
						
						Inst.Parent = self.Tab.ScrollingFrame
					end
				end
			end
		},
	},
}