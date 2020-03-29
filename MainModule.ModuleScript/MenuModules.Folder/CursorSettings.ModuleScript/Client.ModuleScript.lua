local TweenService, HttpService, ThemeUtil = game:GetService("TweenService"), game:GetService("HttpService"), require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))
local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

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

local Keys = {
	{Name = "S2_CursorColor", Text = "Cursor Color"},
	{Name = "S2_CursorTransparency", Text = "Cursor Transparency", Min = 0, Max = 1},
	{Name = "S2_CursorBorder", Text = "Cursor Border Color"},
	{Name = "S2_CursorBorderWidth", Text = "Cursor Border Width"},
	{Name = "S2_CursorWidth", Text = "Cursor Width"},
	{Name = "S2_CursorHeight", Text = "Cursor Height"},
	{Name = "S2_CursorRotation", Text = "Cursor Rotation"},
	{Name = "S2_CursorDistFromCenter", Text = "Distance From Center"},
	{Name = "S2_CursorCenterColor", Text = "Center Color"},
	{Name = "S2_CursorCenterTransparency", Text = "Center Transparency", Min = 0, Max = 1},
	{Name = "S2_CursorCenterBorder", Text = "Center Border Color"},
	{Name = "S2_CursorCenterBorderWidth", Text = "Center Border Width"},
	{Name = "S2_CursorCenterBorderTransparency", Text = "Center Border Transparency", Min = 0, Max = 1},
	{Name = "S2_CursorCenterWidth", Text = "Center Width"},
	{Name = "S2_CursorCenterHeight", Text = "Center Height"},
	{Name = "S2_CursorCenterRotation", Text = "Center Rotation"},
	{Name = "S2_CursorSwapWidthHeight", Text = "Swap Width and Height"},
	{Name = "S2_CursorDynamicMovement", Text = "Show Spread"},
	{Name = "S2_CursorRotate", Text = "Rotate Cursor"},
	{Name = "S2_CursorRotateReload", Text = "Rotate when reloading"},
	{Name = "S2_CursorCenterRotateWith", Text = "Rotate Center with Cursor"},
}

local Presets = {
	["Partixels Preset"] = {
		S2_CursorDistFromCenter = 5,
		S2_CursorBorderWidth = 1,
		S2_CursorSwapWidthHeight = true,
		S2_CursorCenterBorder = Color3.fromRGB(46, 46, 46),
		S2_CursorCenterBorderTransparency = 0,
		S2_CursorCenterWidth = 2,
		S2_CursorBorder = Color3.fromRGB(46, 46, 46),
		S2_CursorDynamicMovement = true,
		S2_CursorHeight = 6,
		S2_CursorCenterRotateWith = true,
		S2_CursorRotation = 0,
		S2_CursorCenterBorderWidth = 1,
		S2_CursorColor = Color3.fromRGB(255, 0, 255),
		S2_CursorCenterTransparency = 0,
		S2_CursorRotateReload = true,
		S2_CursorRotate = true,
		S2_CursorWidth = 2,
		S2_CursorCenterRotation = 0,
		S2_CursorCenterHeight = 2,
		S2_CursorCenterColor = Color3.fromRGB(255, 0, 255),
		S2_CursorTransparency = 0,
	},
	["Peekay's Preset"] = {
		S2_CursorDistFromCenter = 15,
		S2_CursorBorderWidth = 0,
		S2_CursorCenterBorder = Color3.fromRGB(46, 46, 46),
		S2_CursorCenterBorderTransparency = 1,
		S2_CursorCenterWidth = 2,
		S2_CursorBorder = Color3.fromRGB(46, 46, 46),
		S2_CursorDynamicMovement = false,
		S2_CursorHeight = 10,
		S2_CursorCenterRotateWith = false,
		S2_CursorCenterRotation = 0,
		S2_CursorCenterBorderWidth = 0,
		S2_CursorColor = Color3.fromRGB(255, 255, 0),
		S2_CursorCenterTransparency = 0,
		S2_CursorRotateReload = false,
		S2_CursorRotate = false,
		S2_CursorWidth = 2,
		S2_CursorRotation = 0,
		S2_CursorCenterHeight = 2,
		S2_CursorCenterColor = Color3.fromRGB(255, 255, 0),
		S2_CursorTransparency = 0.2
	},	
	["Box in box"] = {
		S2_CursorDistFromCenter = 5,
		S2_CursorBorderWidth = 1,
		S2_CursorSwapWidthHeight = true,
		S2_CursorCenterRotateWith = true,
		S2_CursorCenterBorder = Color3.fromRGB(255, 0, 255),
		S2_CursorCenterBorderTransparency = 0,
		S2_CursorCenterWidth = 4,
		S2_CursorBorder = Color3.fromRGB(46, 46, 46),
		S2_CursorDynamicMovement = true,
		S2_CursorHeight = 6,
		S2_CursorCenterRotation = 0,
		S2_CursorCenterBorderWidth = 2,
		S2_CursorColor = Color3.fromRGB(255, 0, 255),
		S2_CursorCenterTransparency = 1,
		S2_CursorRotateReload = true,
		S2_CursorRotate = true,
		S2_CursorWidth = 2,
		S2_CursorRotation = 0,
		S2_CursorCenterHeight = 4,
		S2_CursorCenterColor = Color3.fromRGB(255, 0, 255),
		S2_CursorTransparency = 0,
	},
	["Diamond boy"] = {
		S2_CursorDistFromCenter = 3,
		S2_CursorBorderWidth = 1,
		S2_CursorSwapWidthHeight = false,
		S2_CursorCenterBorder = Color3.fromRGB(46, 46, 46),
		S2_CursorCenterBorderTransparency = 0,
		S2_CursorCenterWidth = 8,
		S2_CursorBorder = Color3.fromRGB(46, 46, 46),
		S2_CursorDynamicMovement = true,
		S2_CursorHeight = 6,
		S2_CursorCenterRotateWith = true,
		S2_CursorCenterRotation = 45,
		S2_CursorCenterBorderWidth = 1,
		S2_CursorColor = Color3.fromRGB(255, 0, 255),
		S2_CursorCenterTransparency = 0.3,
		S2_CursorRotateReload = true,
		S2_CursorRotate = true,
		S2_CursorWidth = 2,
		S2_CursorRotation = 0,
		S2_CursorCenterHeight = 8,
		S2_CursorCenterColor = Color3.fromRGB(255, 0, 255),
		S2_CursorTransparency = 1,
	},
	["Crosshair with square"] = {
		S2_CursorDistFromCenter = 4,
		S2_CursorBorderWidth = 0,
		S2_CursorSwapWidthHeight = false,
		S2_CursorCenterBorder = Color3.fromRGB(127, 127, 127),
		S2_CursorCenterBorderTransparency = 0,
		S2_CursorCenterWidth = 6,
		S2_CursorBorder = Color3.fromRGB(46, 46, 46),
		S2_CursorDynamicMovement = false,
		S2_CursorHeight = 8,
		S2_CursorCenterRotateWith = true,
		S2_CursorCenterRotation = 0,
		S2_CursorCenterBorderWidth = 2,
		S2_CursorColor = Color3.fromRGB(255, 0, 255),
		S2_CursorCenterTransparency = 1,
		S2_CursorRotateReload = true,
		S2_CursorRotate = true,
		S2_CursorWidth = 2,
		S2_CursorRotation = 0,
		S2_CursorCenterHeight = 6,
		S2_CursorCenterColor = Color3.fromRGB(255, 0, 255),
		S2_CursorTransparency = 0,
	},
	["Dot"] = {
		S2_CursorDistFromCenter = 5, 	
		S2_CursorBorderWidth = 1, 	
		S2_CursorSwapWidthHeight = false, 	
		S2_CursorCenterBorder = Color3.fromRGB( 46, 46, 46 ), 	
		S2_CursorCenterBorderTransparency = 0, 	
		S2_CursorCenterWidth = 5, 	
		S2_CursorBorder = Color3.fromRGB( 46, 46, 46 ), 	
		S2_CursorDynamicMovement = false, 	
		S2_CursorHeight = 6, 	
		S2_CursorCenterRotateWith = false, 	
		S2_CursorCenterRotation = 0, 	
		S2_CursorCenterBorderWidth = 1, 	
		S2_CursorColor = Color3.fromRGB( 255, 255, 255 ), 	
		S2_CursorCenterTransparency = 0, 	
		S2_CursorRotateReload = false, 	
		S2_CursorRotate = false, 	
		S2_CursorWidth = 2, 	
		S2_CursorRotation = 0, 	
		S2_CursorCenterHeight = 5, 	
		S2_CursorCenterColor = Color3.fromRGB( 255, 255, 255 ), 	
		S2_CursorTransparency = 1,	
	}
}

function ExportSettings()
	
	local Export = {}
	
	for a, Setting in ipairs(Keys) do
		
		local Val = ThemeUtil.GetThemeFor(Setting.Name)
		
		if typeof(Val) == "Color3" then
			
			Val = {Val.r * 255, Val.g * 255, Val.b * 255}
			
		end
		
		Export[a] = Val
		
	end
	
	return HttpService:JSONEncode(Export)
	
end

return {
	RequiresRemote = true,
	ButtonText = "Cursor",
	SetupGui = function(self)
		ThemeUtil.BindUpdate(self.Gui, {BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
		
		ThemeUtil.WaitForCategory("S2_Cursor")
		self.Remote.OnClientEvent:Connect(function(Settings)
			for Key, Val in pairs(Settings) do
				ThemeUtil.UpdateThemeFor(Key, Val)
			end
		end)
	end,
	OnOpen = function(self)
		Core.ForceShowCursor = true
		PlayerGui.S2.GunCursor.Center.Visible = true
		game:GetService("UserInputService").MouseIconEnabled = false
		
		if not Core.CursorHeartbeat then
			Core.RunCursorHeartbeat()
		end
	end,
	OnClose = function(self)
		Core.ForceShowCursor = nil
	end,
	Tabs = {
		{
			Tab = script:WaitForChild("Gui"):WaitForChild("SettingsTab"),
			Button = script.Gui:WaitForChild("Settings"),
			OnOpen = function(self)
				ThemeUtil.BindUpdate(self.Button, {BackgroundColor3 = "Selection_Color3", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
			end,
			OnClose = function(self)
				ThemeUtil.BindUpdate(self.Button, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
			end,
			SetupTab = function(self)
				ThemeUtil.BindUpdate(self.Tab.ScrollingFrame, {ScrollBarImageColor3 = "Secondary_BackgroundColor", ScrollBarImageTransparency = "Secondary_BackgroundTransparency"})
				ThemeUtil.BindUpdate(self.Tab.Search, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor"})
				
				self.Tab.ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function ()
					self.Tab.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.Tab.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
				end)
				
				self.Tab.Search:GetPropertyChangedSignal("Text"):Connect(function()
					self:Invalidate()
				end)
				
				function self.UpdateObj(Obj, Val)
					self.Options.Tabs[3]:Invalidate()
					
					if Obj.Name == "number" then
						Obj.Number.Text = Val
						Obj.Number.PlaceholderText = Obj.Number.Text
					elseif Obj.Name == "Color3" then
						Obj.Red.Text, Obj.Green.Text, Obj.Blue.Text = math.floor(Val.r * 255), math.floor(Val.g * 255), math.floor(Val.b * 255)
						Obj.Red.PlaceholderText, Obj.Green.PlaceholderText, Obj.Blue.PlaceholderText = Obj.Red.Text, Obj.Green.Text, Obj.Blue.Text
					elseif Obj.Name == "boolean" then
						ThemeUtil.BindUpdate(Obj.Boolean, {})	
					end
				end
			end,
			Redraw = function(self)
				for _, Obj in ipairs(self.Tab.ScrollingFrame:GetChildren()) do
					
					if Obj:IsA("Frame") then Obj:Destroy() end
					
				end
				
				local Txt = self.Tab.Search.Text:lower():gsub(".", EscapePatterns)
				
				for a, Setting in ipairs(Keys) do
					
					if Setting.Text:lower():find(Txt) then
						
						local b = Setting
						
						local Type = typeof(ThemeUtil.GetThemeFor(b.Name))
						
						local Inst =  script:FindFirstChild(Type):Clone()
						
						ThemeUtil.BindUpdate(Inst.TextButton, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
						
						Inst.TextButton.Text = b.Text
						
						Inst.TextButton.MouseButton1Click:Connect(function ()
							
							self.Options.Remote:FireServer(b.Name)
							
							ThemeUtil.UpdateThemeFor(b.Name)
							
						end)
						
						if Type == "Color3" then
							
							ThemeUtil.BindUpdate(Inst.Display, {BackgroundColor3 = b.Name})
							
							ThemeUtil.BindUpdate({Inst.Blue, Inst.Green, Inst.Red}, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor"})
							
							
						elseif Type == "number" then
							
							ThemeUtil.BindUpdate(Inst.Number, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor"})
							
						elseif Type == "boolean" then
							
							ThemeUtil.BindUpdate(Inst.Boolean, {BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", BackgroundColor3 = ThemeUtil.GetThemeFor(b.Name) and "Positive_Color3" or "Negative_Color3"})
							
						end
						
						Inst.LayoutOrder = a
						
						ThemeUtil.BindUpdate(Inst, {[b.Name] = self.UpdateObj})
						
						for c, d in pairs(Inst:GetChildren()) do
							
							if d.Name == "Boolean" then
								
								d.MouseButton1Click:Connect(function ()
									
									local Val = not ThemeUtil.GetThemeFor(b.Name)
									
									self.Options.Remote:FireServer(b.Name, Val)
									
									ThemeUtil.UpdateThemeFor(b.Name, Val)
									
									ThemeUtil.BindUpdate(Inst.Boolean, {BackgroundColor3 = Val and "Positive_Color3" or "Negative_Color3"})
									
								end)
								
							elseif d:IsA("TextBox") then
								
								d.FocusLost:Connect(function ()
									
									if Type == "number" then
										
										if Inst.Number.Text == "" then
											
											Inst.Number.Text = Inst.Number.PlaceholderText
											
											return
											
										end
										
										local Num = tonumber(Inst.Number.Text)
										
										if Num then
											
											if b.Min then
												
												Num = math.max(Num, b.Min)
												
											end
											
											if b.Max then
												
												Num = math.min(Num, b.Max)
												
											end
											
											self.Options.Remote:FireServer(b.Name, Num)
											
											ThemeUtil.UpdateThemeFor(b.Name, Num)
											
										end
										
									elseif Type == "Color3" then
										
										if Inst.Red.Text == "" then
											
											Inst.Red.Text = Inst.Red.PlaceholderText
											
										end
										
										if Inst.Green.Text == "" then
											
											Inst.Green.Text = Inst.Green.PlaceholderText
											
										end
										
										if Inst.Blue.Text == "" then
											
											Inst.Blue.Text = Inst.Blue.PlaceholderText
											
										end
										
										local r, g, bl = tonumber(Inst.Red.Text), tonumber(Inst.Green.Text), tonumber(Inst.Blue.Text)
										
										if r and g and bl then
											
											if b.Min then
												
												r = math.max(r, b.Min)
												
												g = math.max(g, b.Min)
												
												bl = math.max(bl, b.Min)
												
											end
											
											if b.Max then
												
												r = math.min(r, b.Max)
												
												g = math.min(g, b.Max)
												
												bl = math.min(bl, b.Max)
												
											end
											
											local Col = Color3.fromRGB(r, g, bl)
											
											self.Options.Remote:FireServer(b.Name, Col)
											
											ThemeUtil.UpdateThemeFor(b.Name, Col)
											
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
		{
			Tab = script.Gui:WaitForChild("PresetsTab"),
			Button = script.Gui:WaitForChild("Presets"),
			OnOpen = function(self)
				ThemeUtil.BindUpdate(self.Button, {BackgroundColor3 = "Selection_Color3", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
			end,
			OnClose = function(self)
				ThemeUtil.BindUpdate(self.Button, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
			end,
			SetupTab = function(self)
				ThemeUtil.BindUpdate(self.Tab.Search, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor"})
				
				self.Tab.ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function ()
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
				
				if ("Default"):lower():find(Txt) then
					
					local Preset = script.Preset:Clone()
					
					Preset.Name = "Default" 
					
					Preset.LayoutOrder = 0
					
					ThemeUtil.BindUpdate(Preset.TextButton, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
					
					Preset.TextButton.Text = "Default"
					
					Preset.TextButton.MouseButton1Click:Connect(function ()
						
						self.Options.Remote:FireServer({})
						
						for _, Settings in pairs(Keys) do
							
							ThemeUtil.UpdateThemeFor(Settings.Name)
							
						end
						
					end)
					
					Preset.Parent = self.Tab.ScrollingFrame
					
				end
				
				for Name, Settings in pairs(Presets) do
					
					if Name:lower():find(Txt) then
						
						local Preset = script.Preset:Clone()
						
						Preset.Name = Name
						
						ThemeUtil.BindUpdate(Preset.TextButton, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
						
						Preset.TextButton.Text = Name
						
						Preset.TextButton.MouseButton1Click:Connect(function ()
							
							self.Options.Remote:FireServer(Settings)
							
							for Key, Value in pairs(Settings) do
								
								ThemeUtil.UpdateThemeFor(Key, Value)
								
							end
							
						end)
						
						Preset.Parent = self.Tab.ScrollingFrame
						
					end
					
				end
				
			end
		},
		{
			Tab = script.Gui:WaitForChild("ShareTab"),
			Button = script.Gui:WaitForChild("Share"),
			OnOpen = function(self)
				ThemeUtil.BindUpdate(self.Button, {BackgroundColor3 = "Selection_Color3", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
			end,
			OnClose = function(self)
				ThemeUtil.BindUpdate(self.Button, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
			end,
			SetupTab = function(self)
				ThemeUtil.BindUpdate({self.Tab.Export.Code, self.Tab.Export.TextButton, self.Tab.Import.Code, self.Tab.Import.TextButton}, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
				
				self.Tab.Export.Code:GetPropertyChangedSignal("Text"):Connect(function()
					self.Tab.Export.Code.Text = ExportSettings( )
					self.Tab.Export.Code.CursorPosition = #self.Tab.Export.Code.Text + 1
					self.Tab.Export.Code.SelectionStart = 1
				end)
				
				self.Tab.Export.Code.Focused:Connect(function ()
					self.Tab.Export.Code.CursorPosition = #self.Tab.Export.Code.Text + 1
					self.Tab.Export.Code.SelectionStart = 1
				end)
				
				self.Tab.Import.Code.FocusLost:Connect(function ()
					local Ran, Import = pcall(HttpService.JSONDecode, HttpService, self.Tab.Import.Code.Text)
					
					if Ran and type(Import) == "table" then
						for a, b in ipairs(Import) do
							if type(b) == "table" then
								b = Color3.fromRGB(b[1], b[2], b[3])
								Import[a] = b
							end
							
							ThemeUtil.UpdateThemeFor(Keys[a].Name, b)
							Import[Keys[a].Name] = b
							Import[a] = nil
						end
						
						self.Options.Remote:FireServer(Import)
						self.Tab.Import.Code.Text = "Valid code"
					else
						self.Tab.Import.Code.Text = "Invalid code"
					end
				end)
			end,
			Redraw = function(self)
				self.Tab.Export.Code.Text = ExportSettings( )
			end
		},
	},
}