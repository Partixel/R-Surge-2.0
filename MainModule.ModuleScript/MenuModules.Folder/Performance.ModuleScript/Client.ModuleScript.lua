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

local Materials, MaterialsEvent
local SpecialMaterials, SpecialMaterialsEvent
local SpecialMats = {
	[Enum.Material.Neon] = true,
	[Enum.Material.Glass] = true,
	[Enum.Material.ForceField] = true,
}
return {
	RequiresRemote = true,
	AddSetting = function(self, Setting)
		self.Settings[#self.Settings + 1] = Setting
		if self.SavedSettings[Setting.Name] == nil then
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
		
		self:AddSetting{Name = "ShowMaterials", Text = "Show Materials", Default = true, Update = function(Options, Val)
			if Val then
				if Materials then
					MaterialsEvent:Disconnect()
					MaterialsEvent = nil
					for Material, Objs in pairs(Materials) do
						for _, Obj in ipairs(Objs) do
							Obj.Material = Material
						end
					end
					Materials = nil
				end
			else
				Materials = { }
				MaterialsEvent = workspace.DescendantAdded:Connect(function(Obj)
					if Obj:IsA("BasePart") and not SpecialMats[Obj.Material] and not CollectionService:HasTag(Obj, "s2color") and not CollectionService:HasTag(Obj, "s2forcematerial") then
						Materials[Obj.Material] = Materials[Obj.Material] or {}
						Materials[Obj.Material][#Materials[Obj.Material] + 1] = Obj
						Obj.Material = Enum.Material.SmoothPlastic
					end
				end)
				for _, Obj in ipairs(workspace:GetDescendants()) do
					if Obj:IsA( "BasePart" ) and not SpecialMats[Obj.Material] and not CollectionService:HasTag(Obj, "s2color") and not CollectionService:HasTag(Obj, "s2forcematerial") then
						Materials[Obj.Material] = Materials[Obj.Material] or {}
						Materials[Obj.Material][#Materials[Obj.Material] + 1] = Obj
						Obj.Material = Enum.Material.SmoothPlastic
					end
				end
			end
		end}
		
		self:AddSetting{Name = "ShowSpecialMaterials", Text = "Show Special Materials (Neon, Glass, Forcefield)", Default = true, Update = function(Options, Val)
			if Val then
				if SpecialMaterials then
					SpecialMaterialsEvent:Disconnect()
					SpecialMaterialsEvent = nil
					for Material, Objs in pairs(SpecialMaterials) do
						for _, Obj in ipairs(Objs) do
							Obj.Material = Material
						end
					end
					SpecialMaterials = nil
				end
			else
				SpecialMaterials = { }
				SpecialMaterialsEvent = workspace.DescendantAdded:Connect(function(Obj)
					if Obj:IsA("BasePart") and SpecialMats[Obj.Material] and not CollectionService:HasTag(Obj, "s2color") and not CollectionService:HasTag(Obj, "s2forcematerial") then
						SpecialMaterials[Obj.Material] = SpecialMaterials[Obj.Material] or {}
						SpecialMaterials[Obj.Material][#SpecialMaterials[Obj.Material] + 1] = Obj
						Obj.Material = Enum.Material.SmoothPlastic
					end
				end)
				for _, Obj in ipairs(workspace:GetDescendants()) do
					if Obj:IsA( "BasePart" ) and SpecialMats[Obj.Material] and not CollectionService:HasTag(Obj, "s2color") and not CollectionService:HasTag(Obj, "s2forcematerial") then
						SpecialMaterials[Obj.Material] = SpecialMaterials[Obj.Material] or {}
						SpecialMaterials[Obj.Material][#SpecialMaterials[Obj.Material] + 1] = Obj
						Obj.Material = Enum.Material.SmoothPlastic
					end
				end
			end
		end}
		
		for _, Setting in ipairs(self.Settings) do
			if self.SavedSettings[Setting.Name] == nil then
				self.SavedSettings[Setting.Name] = Setting.Default
			end
			if Setting.Update then
				coroutine.wrap(Setting.Update)(self, self.SavedSettings[Setting.Name])
			end
		end
		
		self.Remote.OnClientEvent:Connect(function(Settings)
			self.SavedSettings = Settings
			for _, Setting in ipairs(self.Settings) do
				if self.SavedSettings[Setting.Name] == nil then
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