local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )
local ThemeUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))
local StringCalculator = require(script:WaitForChild("StringCalculator"))
local CollectionService = game:GetService( "CollectionService" )
local LocalPlayer = game:GetService("Players").LocalPlayer

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

local Plrs, TeamEvent, AddedEvent, RemovedEvent
local function HandleTeam()
	if Plrs then
		for Plr, Info in ipairs(Plrs) do
			for Humanoid, DisplayDistanceType in pairs(Info[2]) do
				Humanoid.DisplayDistanceType = DisplayDistanceType
			end
			
			Info[1]:Disconnect()
			Plrs[Plr] = nil
		end
		
		AddedEvent:Disconnect()
		RemovedEvent:Disconnect()
	end
	
	Plrs = {}
	
	for _, Plr in ipairs(LocalPlayer.Team:GetPlayers()) do
		if Plr ~= LocalPlayer then
			local PlrTable = setmetatable({nil, setmetatable({}, {__mode = "k"})}, {__mode = "k"})
			Plrs[Plr] = PlrTable
			if Plr.Character then
				PlrTable[2][Plr.Character:WaitForChild("Humanoid")] = Plr.Character.Humanoid.DisplayDistanceType
				Plr.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end
			
			PlrTable[1] = Plr.CharacterAdded:Connect(function(Char)
				PlrTable[2][Char:WaitForChild("Humanoid")] = Char.Humanoid.DisplayDistanceType
				Char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end)
		end
	end
	
	AddedEvent = LocalPlayer.Team.PlayerAdded:Connect(function(Plr)
		local PlrTable = setmetatable({nil, setmetatable({}, {__mode = "k"})}, {__mode = "k"})
		Plrs[Plr] = PlrTable
		if Plr.Character then
			PlrTable[2][Plr.Character:WaitForChild("Humanoid")] = Plr.Character.Humanoid.DisplayDistanceType
			Plr.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
		
		PlrTable[1] = Plr.CharacterAdded:Connect(function(Char)
			PlrTable[2][Char:WaitForChild("Humanoid")] = Char.Humanoid.DisplayDistanceType
			Char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end)
	end)
	
	RemovedEvent = LocalPlayer.Team.PlayerRemoved:Connect(function(Plr)
		if Plr ~= LocalPlayer then
			for Humanoid, DisplayDistanceType in pairs(Plrs[Plr][2]) do
				Humanoid.DisplayDistanceType = DisplayDistanceType
			end
			
			Plrs[Plr][1]:Disconnect()
			Plrs[Plr] = nil
		end
	end)
end
return {
	RequiresRemote = true,
	ButtonText = "Surge 2.0",
	AddSetting = function(self, Setting)
		self.Settings[#self.Settings + 1] = Setting
		if self.SavedSettings[Setting.Name] == nil or type(self.SavedSettings[Setting.Name]) ~= type(Setting.Default) then
			self.SavedSettings[Setting.Name] = Setting.Default
		end
		
		coroutine.wrap(Setting.Update)(self, self.SavedSettings[Setting.Name])
		
		if self.Tabs[1].Invalidate then
			self.Tabs[1]:Invalidate()
		end
	end,
	Settings = {},
	SavedSettings = {},
	SetupGui = function(self)
		ThemeUtil.BindUpdate(self.Gui, {BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
		
		self:AddSetting{Name = "ShowFriendlyNames", Text = "Show Team Character Names", Default = true, Update = function(Options, Val)
			if Val then
				if Plrs then
					for Plr, Info in pairs(Plrs) do
						for Humanoid, DisplayDistanceType in pairs(Info[2]) do
							Humanoid.DisplayDistanceType = DisplayDistanceType
						end
						
						Info[1]:Disconnect()
					end
					
					Plrs = nil
					
					TeamEvent, AddedEvent, RemovedEvent = TeamEvent:Disconnect(), AddedEvent:Disconnect(), RemovedEvent:Disconnect()
				end
			elseif not Plrs then
				TeamEvent = LocalPlayer:GetPropertyChangedSignal("Team"):Connect(HandleTeam)
				HandleTeam()
			end
		end}
		
		for _, Setting in ipairs(self.Settings) do
			if self.SavedSettings[Setting.Name] == nil or type(self.SavedSettings[Setting.Name]) ~= type(Setting.Default) then
				self.SavedSettings[Setting.Name] = Setting.Default
			end
			if Setting.Update then
				coroutine.wrap(Setting.Update)(self, self.SavedSettings[Setting.Name])
			end
		end
		
		self.Remote.OnClientEvent:Connect(function(Settings)
			self.SavedSettings = Settings
			for _, Setting in ipairs(self.Settings) do
				if self.SavedSettings[Setting.Name] == nil or type(self.SavedSettings[Setting.Name]) ~= type(Setting.Default) then
					self.SavedSettings[Setting.Name] = Setting.Default
				end
				if Setting.Update then
					coroutine.wrap(Setting.Update)(self, self.SavedSettings[Setting.Name])
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
				table.sort(self.Options.Settings, function(a,b)
					return a.Name < b.Name
				end)
				for i, Setting in pairs(self.Options.Settings) do
					if Setting.Text:lower():find(Txt) then
						local Type = typeof(Setting.Default)
						local Inst =  script:FindFirstChild(Type):Clone()
						Inst.TextButton.Text = Setting.Text
						Inst.LayoutOrder = i
						
						ThemeUtil.BindUpdate(Inst.TextButton, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})
						
						if Type == "number" then
							print(Setting.Name, self.Options.SavedSettings[Setting.Name], Setting.Default)
							Inst.Number.Text = self.Options.SavedSettings[Setting.Name]
							Inst.Number.PlaceholderText = Inst.Number.Text
							ThemeUtil.BindUpdate(Inst.Number, {BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor"})
						elseif Type == "boolean" then
							ThemeUtil.BindUpdate(Inst.Boolean, {BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", BackgroundColor3 = self.Options.SavedSettings[Setting.Name] and "Positive_Color3" or "Negative_Color3"})
						end
						
						for _, Obj in pairs(Inst:GetChildren()) do
							if Obj.Name == "TextButton" then
								Obj.MouseButton1Click:Connect(function ()
									if Type == "boolean" then
										if self.Options.SavedSettings[Setting.Name] ~= Setting.Default then
											self.Options.SavedSettings[Setting.Name] = Setting.Default
											self.Options.Remote:FireServer(Setting.Name, nil)
											if Setting.Update then
												coroutine.wrap(Setting.Update)(self.Options, self.Options.SavedSettings[Setting.Name])
											end
											ThemeUtil.BindUpdate(Inst.Boolean, {BackgroundColor3 = self.Options.SavedSettings[Setting.Name] and "Positive_Color3" or "Negative_Color3"})
										end
									elseif Type == "number" then
										if self.Options.SavedSettings[Setting.Name] ~= Setting.Default then
											Inst.Number.Text = Setting.Default
											Inst.Number.PlaceholderText = Setting.Default
											
											self.Options.SavedSettings[Setting.Name] = Setting.Default
											self.Options.Remote:FireServer(Setting.Name, nil)
											if Setting.Update then
												coroutine.wrap(Setting.Update)(self.Options, Setting.Default)
											end
										end
									end
								end)
							elseif Type == "boolean" then
								Obj.MouseButton1Click:Connect(function ()
									self.Options.SavedSettings[Setting.Name] = not self.Options.SavedSettings[Setting.Name]
									self.Options.Remote:FireServer(Setting.Name, self.Options.SavedSettings[Setting.Name])
									if Setting.Update then
										coroutine.wrap(Setting.Update)(self.Options, self.Options.SavedSettings[Setting.Name])
									end
									ThemeUtil.BindUpdate(Inst.Boolean, {BackgroundColor3 = self.Options.SavedSettings[Setting.Name] and "Positive_Color3" or "Negative_Color3"})
								end)
							elseif Type == "number" then
								Obj.FocusLost:Connect(function()
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
										Inst.Number.PlaceholderText = Num
										
										self.Options.SavedSettings[Setting.Name] = Num
										self.Options.Remote:FireServer(Setting.Name, Num)
										if Setting.Update then
											coroutine.wrap(Setting.Update)(self.Options, Num)
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