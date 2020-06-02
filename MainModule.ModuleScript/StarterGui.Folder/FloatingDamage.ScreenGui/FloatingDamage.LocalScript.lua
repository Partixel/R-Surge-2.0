local TweenService = game:GetService("TweenService")

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local ThemeUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))

local function UpdateGradientType(Obj, Color)
	Obj.Color = ColorSequence.new(Obj.Color.Keypoints[1].Value, Color)
end

local function UpdateGradientMain(Obj, Color)
	Obj.Color = ColorSequence.new(Color, Obj.Color.Keypoints[2].Value)
end

local DamageEvent
local function ConnectDamageEvent()
	DamageEvent = Core.ClientDamage.OnClientEvent:Connect(function(DamageSplits, ExtraInformation)
		if type(ExtraInformation) ~= "string" then
			local TotalDamage = 0
			for _, DamageSplit in ipairs(DamageSplits) do
				TotalDamage = TotalDamage + DamageSplit[2]
			end
			
			local Pos = workspace.CurrentCamera:WorldToScreenPoint(Vector3.new(ExtraInformation.Hit.Position.X + (ExtraInformation.RelativeEndPosition and ExtraInformation.RelativeEndPosition.X or 0), math.max(ExtraInformation.Hit.CFrame:PointToWorldSpace(Vector3.new(ExtraInformation.Hit.Size.X, ExtraInformation.Hit.Size.Y, ExtraInformation.Hit.Size.Z)).Y, ExtraInformation.Hit.CFrame:PointToWorldSpace(Vector3.new(-ExtraInformation.Hit.Size.X, -ExtraInformation.Hit.Size.Y, -ExtraInformation.Hit.Size.Z)).Y) + (ExtraInformation.RelativeEndPosition and ExtraInformation.RelativeEndPosition.Z or 0), ExtraInformation.Hit.Position.Z + (ExtraInformation.RelativeEndPosition and ExtraInformation.RelativeEndPosition.Z or 0)))
			Pos = UDim2.new(0, Pos.X, 0, Pos.Y)
			
			local Floater = script.Floater:Clone()
			Floater.Text = math.max(math.abs(math.floor(TotalDamage + 0.5)), 1)
			Floater.Stroke.Text = Floater.Text
			Floater.Position = Pos
			Floater.Size = UDim2.new(0, 0, 0, 0)
			
			ThemeUtil.BindUpdate(Floater.UIGradient, {[TotalDamage > 0 and "Negative_Color3" or "Positive_Color3"] = UpdateGradientType, Inverted_TextColor = UpdateGradientMain})
			ThemeUtil.BindUpdate(Floater.Stroke, {TextStrokeColor3 = "Inverted_TextColor"})
			
			local OffsetPos, Dist, Size = Vector2.new(math.random(0, 1) == 0 and -1 or 1, math.random(-60, 60) / 100).Unit, math.random(50, 80), math.min(math.abs(TotalDamage), 100) / 4000
			
			local Tween = TweenService:Create(Floater, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = Pos + UDim2.new(0, OffsetPos.X * Dist, 0, OffsetPos.Y * Dist), Size = UDim2.new(0.01 + Size, 0, 0.01 + Size, 0), TextTransparency = 0})
			TweenService:Create(Floater.Stroke, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
			Tween.Completed:Connect(function(Result)
				if Result == Enum.PlaybackState.Completed then
					wait(0.05)
					
					local Tween = TweenService:Create(Floater, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = Pos + UDim2.new(0, OffsetPos.X * (Dist * 1.25), 0, OffsetPos.Y * (Dist * 1.25)), Size = UDim2.new(0.005 + Size, 0, 0.005 + Size, 0), TextTransparency = 1})
					TweenService:Create(Floater.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
					Tween.Completed:Connect(function(Result)
						if Result == Enum.PlaybackState.Completed then
							Floater:Destroy()
						end
					end)
					Tween:Play()
				end
			end)
			Tween:Play()
			Floater.Parent = script.Parent.MainFrame
		end
	end)
end

local Menu = require(game:GetService("ReplicatedStorage"):WaitForChild("MenuLib"):WaitForChild("S2"))
Menu:AddSetting{Name = "FloatingDamageDisplay", Text = "Enables/disables the floating damage display", Default = true, Update = function(Options, Val)
	if Val then
		if not DamageEvent then
			ConnectDamageEvent()
		end
	elseif DamageEvent then
		DamageEvent = DamageEvent:Disconnect()
	end
end}