local ThemeUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))
local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local LocalPlayer = game:GetService("Players").LocalPlayer

local CloseColors = require(script:WaitForChild("CloseColors"))

return {
	RequiresRemote = true,
	ButtonText = "Surge 2.0 VIP",
	Settings = {},
	Owned = {},
	SetupGui = function(self)
		ThemeUtil.BindUpdate(self.Gui, {BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
		
		LocalPlayer:GetPropertyChangedSignal("TeamColor"):Connect(function ()
			if self.Settings then
				self.Tabs[2]:Invalidate()
			end
		end)
		
		self.Remote.OnClientEvent:Connect(function(Data, Settings)
			if type(Data) == "table" then
				self.Owned = Data
				self.Settings = Settings or {}
				if self.Owned[4] and self.Settings[4] then
					Core.Config.WeaponTypeOverrides.All.CursorImage = self.Settings[4]
					Core.CursorImageChanged()
				end
			else
				self.Owned[Data] = true
			end
			self.Tabs[1]:Invalidate()
		end)
	end,
	Tabs = {
		{
			Tab = script:WaitForChild("Gui"):WaitForChild("MainTab"),
			Button = script.Gui:WaitForChild("ColorTab"):WaitForChild("Back"),
			SetupTab = function(self)
				ThemeUtil.BindUpdate(self.Tab.ScrollingFrame, {ScrollBarImageColor3 = "Secondary_BackgroundColor", ScrollBarImageTransparency = "Secondary_BackgroundTransparency"})
				ThemeUtil.BindUpdate(self.Tab.Search, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor"})
				ThemeUtil.BindUpdate({self.Tab.ScrollingFrame.Sparkles.TextButton, self.Tab.ScrollingFrame.Neon.TextButton, self.Tab.ScrollingFrame.Color.TextButton, self.Tab.ScrollingFrame.Color.OpenColorTab, self.Tab.ScrollingFrame.CursorImage.TextButton}, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
				ThemeUtil.BindUpdate({self.Tab.ScrollingFrame.Sparkles.Boolean,self.Tab.ScrollingFrame.Neon.Boolean}, {BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency"})
				ThemeUtil.BindUpdate(self.Tab.ScrollingFrame.CursorImage.String, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor"})
				
				local function Toggle(VIP)
					if self.Options.Owned[VIP] then
						self.Options.Settings[VIP] = not self.Options.Settings[VIP]
						ThemeUtil.BindUpdate(self.Tab.ScrollingFrame[VIP == 1 and "Sparkles" or "Neon"].Boolean, {BackgroundColor3 = self.Options.Settings[VIP] and "Positive_Color3" or "Negative_Color3"})	
						self.Options.Remote:FireServer(VIP, self.Options.Settings[VIP])
					else
						self.Options.Remote:FireServer(VIP)
					end
				end
				
				self.Tab.ScrollingFrame.Sparkles.TextButton.MouseButton1Click:Connect(function() Toggle(1) end)
				self.Tab.ScrollingFrame.Sparkles.Boolean.MouseButton1Click:Connect(function() Toggle(1) end)
				
				self.Tab.ScrollingFrame.Neon.TextButton.MouseButton1Click:Connect(function() Toggle(2) end)
				self.Tab.ScrollingFrame.Neon.Boolean.MouseButton1Click:Connect(function() Toggle(2) end)
				
				local Cur
				self.Tab.ScrollingFrame.CursorImage.String.FocusLost:Connect(function()
					if self.Options.Owned[4] then
						if self.Tab.ScrollingFrame.CursorImage.String.Text == "" then
							self.Tab.ScrollingFrame.CursorImage.String.PlaceholderText = ""
							
							self.Options.Remote:FireServer(4, "")
							Core.Config.WeaponTypeOverrides.All.CursorImage = nil
							Core.CursorImageChanged()
							return
						end
						
						local AssetId = self.Tab.ScrollingFrame.CursorImage.String.Text:lower()
						if AssetId:sub(1,13) == "rbxassetid://" then
							AssetId = tonumber(AssetId:sub(14))
						elseif not tonumber(AssetId) then
							AssetId = nil
						end
						
						if AssetId == nil then
							self.Tab.ScrollingFrame.CursorImage.String.Text = "Invalid Asset ID, it should be just the number"
							local MyCur = {}
							Cur = MyCur
							wait(4)
							self.Tab.ScrollingFrame.CursorImage.String.Text = self.Tab.ScrollingFrame.CursorImage.String.PlaceholderText
							return
						end
						
						local ImageId = script.GetImageId:InvokeServer(AssetId)
						if not ImageId then
							self.Tab.ScrollingFrame.CursorImage.String.Text = "Invalid Asset ID, it is not an image"
							local MyCur = {}
							Cur = MyCur
							wait(4)
							self.Tab.ScrollingFrame.CursorImage.String.Text = self.Tab.ScrollingFrame.CursorImage.String.PlaceholderText
							return
						end
						ImageId = "rbxassetid://" .. ImageId
						
						self.Tab.ScrollingFrame.CursorImage.String.Text = ImageId
						self.Tab.ScrollingFrame.CursorImage.String.PlaceholderText = ImageId
						
						self.Options.Remote:FireServer(4, ImageId)
						Core.Config.WeaponTypeOverrides.All.CursorImage = ImageId
						Core.CursorImageChanged()
					end
				end)
				self.Tab.ScrollingFrame.CursorImage.TextButton.MouseButton1Click:Connect(function()
					if not self.Options.Owned[4] then
						self.Options.Remote:FireServer(4)
					end
				end)
					
				self.Tab.ScrollingFrame.Color.TextButton.MouseButton1Click:Connect(function()
					self.Options.Remote:FireServer(3)
				end)
			end,
			Redraw = function(self)
				if self.Options.Owned[1] then
					self.Tab.ScrollingFrame.Sparkles.Boolean.Visible = true
					self.Tab.ScrollingFrame.Sparkles.TextButton.Size = UDim2.new(1, -40, 1, -10)
					self.Tab.ScrollingFrame.Sparkles.TextButton.Text = "Toggle sparkles for attacks"
					
					ThemeUtil.BindUpdate(self.Tab.ScrollingFrame.Sparkles.Boolean, {BackgroundColor3 = self.Options.Settings[1] and "Positive_Color3" or "Negative_Color3"})	
				else
					self.Tab.ScrollingFrame.Sparkles.Boolean.Visible = false
					self.Tab.ScrollingFrame.Sparkles.TextButton.Size = UDim2.new(1, -10, 1, -10)
					self.Tab.ScrollingFrame.Sparkles.TextButton.Text = "Buy sparkles for attacks"
				end
				
				if self.Options.Owned[2] then
					self.Tab.ScrollingFrame.Neon.Boolean.Visible = true
					self.Tab.ScrollingFrame.Neon.TextButton.Size = UDim2.new(1, -40, 1, -10)
					self.Tab.ScrollingFrame.Neon.TextButton.Text = "Toggle neon colouring"
					
					ThemeUtil.BindUpdate(self.Tab.ScrollingFrame.Neon.Boolean, {BackgroundColor3 = self.Options.Settings[2] and "Positive_Color3" or "Negative_Color3"})	
				else
					self.Tab.ScrollingFrame.Neon.Boolean.Visible = false
					self.Tab.ScrollingFrame.Neon.TextButton.Size = UDim2.new(1, -10, 1, -10)
					self.Tab.ScrollingFrame.Neon.TextButton.Text = "Buy neon colouring"
				end
				
				if self.Options.Owned[4] then
					self.Tab.ScrollingFrame.CursorImage.TextButton.AutoButtonColor = false
					self.Tab.ScrollingFrame.CursorImage.String.Text = Core.Config.WeaponTypeOverrides.All.CursorImage or ""
					self.Tab.ScrollingFrame.CursorImage.String.PlaceholderText = self.Tab.ScrollingFrame.CursorImage.String.Text
					self.Tab.ScrollingFrame.CursorImage.String.Visible = true
					self.Tab.ScrollingFrame.CursorImage.TextButton.Size = UDim2.new(0.5, -12, 1, -10)
					self.Tab.ScrollingFrame.CursorImage.TextButton.Text = "Change gun cursor to this image (Asset ID)"
				else
					self.Tab.ScrollingFrame.CursorImage.TextButton.AutoButtonColor = true
					self.Tab.ScrollingFrame.CursorImage.String.Visible = false
					self.Tab.ScrollingFrame.CursorImage.TextButton.Size = UDim2.new(1, -10, 1, -10)
					self.Tab.ScrollingFrame.CursorImage.TextButton.Text = "Buy customisable gun cursor image"
				end
				
				if self.Options.Owned[3] then
					self.Tab.ScrollingFrame.Color.TextButton.Visible = false
					self.Tab.ScrollingFrame.Color.OpenColorTab.Visible = true
				else
					self.Tab.ScrollingFrame.Color.TextButton.Visible = true
					self.Tab.ScrollingFrame.Color.OpenColorTab.Visible = false
				end
			end
		},
		{
			Tab = script.Gui.ColorTab,
			Button = script.Gui.MainTab:WaitForChild("ScrollingFrame"):WaitForChild("Color"):WaitForChild("OpenColorTab"),
			SetupTab = function(self)
				ThemeUtil.BindUpdate(self.Tab.Back, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
				
				for i = 1, 6 do
					self.Tab:WaitForChild(i).MouseButton1Click:Connect(function()
						self.Options.Settings[3] = self.Options.Settings[3] or {}
						
						local OldButton = self.Tab:FindFirstChild(self.Options.Settings[3][LocalPlayer.TeamColor.Name] or 1)
						ThemeUtil.UnbindUpdate(OldButton, "BorderColor3")
						OldButton.BorderColor3 = OldButton.BackgroundColor3
						
						self.Options.Settings[3][LocalPlayer.TeamColor.Name] = i
						
						ThemeUtil.BindUpdate(self.Tab:FindFirstChild(i), {BorderColor3 = "Selection_Color3"})
						
						self.Options.Remote:FireServer(3, LocalPlayer.TeamColor.Name, i)
					end)
				end
			end,
			Redraw = function(self)
				local Cols = CloseColors(LocalPlayer.TeamColor)
				for i = 1, 6 do
					local Col = self.Tab:FindFirstChild(i)
					if Cols[i] then
						Col.Visible = true
						if i == (self.Options.Settings[3] and self.Options.Settings[3][LocalPlayer.TeamColor.Name] or 1) then
							ThemeUtil.BindUpdate(Col, {BorderColor3 = "Selection_Color3"})
						else
							ThemeUtil.UnbindUpdate(Col, "BorderColor3")
							Col.BorderColor3 = Cols[i].Color
						end
						Col.BackgroundColor3 = Cols[i].Color
					else
						Col.Visible = false
					end
				end
			end
		},
	},
}