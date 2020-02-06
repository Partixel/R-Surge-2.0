local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local ThemeUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))
local TweenService = game:GetService("TweenService")

local Menu = require(game:GetService("ReplicatedStorage"):WaitForChild("MenuLib"):WaitForChild("S2"))
local Enabled
Menu:AddSetting{Name = "FloatingDamageDisplay", Text = "Enables/disables the floating damage display", Default = true, Update = function(Options, Val)
	Enabled = Val
end}

Core.Events.FloatingDamage = Core.ClientDamage.OnClientEvent:Connect(function(DamageSplits, Hit, RelativePosition)
	if type(Hit) ~= "string" and Enabled then
		local TotalDamage = 0
		for _, DamageSplit in ipairs(DamageSplits) do
			TotalDamage = TotalDamage + DamageSplit[2]
		end
		
		local Floater = script.DamageFloater:Clone()
		Floater.TextLabel.Text = math.max(math.abs(math.floor(TotalDamage + 0.5)), 1)
		Floater.Adornee = workspace.Terrain
		local X, Y, Z = Hit.Size.X, Hit.Size.Y, Hit.Size.Z
		Floater.StudsOffsetWorldSpace = Vector3.new( Hit.Position.X + (RelativePosition and RelativePosition.X or 0), math.max(Hit.CFrame:PointToWorldSpace(Vector3.new(X, Y, Z)).Y, Hit.CFrame:PointToWorldSpace(Vector3.new(-X, -Y, -Z)).Y) + (RelativePosition and RelativePosition.Z or 0), Hit.Position.Z + (RelativePosition and RelativePosition.Z or 0) )
		Floater.StudsOffset = Vector3.new(0, 0, 0)
		Floater.Size = UDim2.new(0, 0, 0, 0)
		
		ThemeUtil.BindUpdate(Floater.TextLabel, {TextStrokeColor3 = "Inverted_TextColor", TextColor3 = TotalDamage > 0 and "Negative_Color3" or "Positive_Color3"})
		
		local Tween = TweenService:Create(Floater, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {StudsOffset = Vector3.new(0, 0.5, 0), Size = UDim2.new(0, 150, 0.1 + (0.9*math.min(math.abs(TotalDamage), 100)/100), 10 + (20*math.min(math.abs(TotalDamage), 100)/100))})
		TweenService:Create(Floater.TextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
		Tween.Completed:Connect(function(Result)
			if Result == Enum.PlaybackState.Completed then
				local Tween = TweenService:Create(Floater, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {StudsOffset = Vector3.new(0, 2, 0)})
				Tween.Completed:Connect(function(Result)
					if Result == Enum.PlaybackState.Completed then
						local Tween = TweenService:Create(Floater, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {StudsOffset = Vector3.new(0, 3.5, 0)})
						TweenService:Create(Floater.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
						Tween.Completed:Connect(function(Result)
							if Result == Enum.PlaybackState.Completed then
								Floater:Destroy()
							end
						end)
						Tween:Play()
					end
				end)
				Tween:Play()
			end
		end)
		Tween:Play()
		
		Floater.Parent = Hit
	end
end)