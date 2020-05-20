local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))

function GetAngle(CFrameA, VectorB)
	local Projected = (CFrameA * CFrame.Angles(0, math.rad(90), 0)):PointToObjectSpace(VectorB)
	local Angle = math.deg(math.atan2(Projected.Z, Projected.X))
	if Angle < 0 then
		return 360 + Angle
	else
		return Angle
	end
end

local MinY = 0.5

local DamageEvent
local function ConnectDamageEvent()
	DamageEvent = Core.ClientDamage.OnClientEvent:Connect(function(DamageSplits, Str, ExtraInformation)
		if type(Str) == "string" and ExtraInformation.StartPosition then
			local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if HumanoidRootPart then
				local TotalDamage = 0
				for _, DamageSplit in ipairs(DamageSplits) do
					TotalDamage = TotalDamage + DamageSplit[2]
				end
				
				local DamageVisual = script.Container:Clone()
				local DmgPerc = math.min(TotalDamage / 100, 1)
				DamageVisual.Size = UDim2.new((MinY + MinY * DmgPerc * 2) * 0.76, 0, MinY + MinY * DmgPerc * 2, 0)
						
				local DamageAngle = GetAngle(CFrame.new(HumanoidRootPart.CFrame.p, HumanoidRootPart.CFrame.p + workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1)), ExtraInformation.StartPosition)
				DamageVisual.Rotation = DamageAngle
				DamageVisual.ImageLabel.ImageTransparency = 1
				
				DamageVisual.Parent = script.Parent
				
				TweenService:Create(DamageVisual.ImageLabel, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
				
				wait(0.1)
				
				local Tween = TweenService:Create(DamageVisual.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 1})
				Tween:Play()
				Tween.Completed:Wait()
				
				DamageVisual:Destroy()
			end
		end
	end)
end

local Menu = require(game:GetService("ReplicatedStorage"):WaitForChild("MenuLib"):WaitForChild("S2"))
Menu:AddSetting{Name = "DirectionalDamageIndicator", Text = "Enables/disables the directional damage indicator", Default = true, Update = function(Options, Val)
	if Val then
		if not DamageEvent then
			ConnectDamageEvent()
		end
	elseif DamageEvent then
		DamageEvent = DamageEvent:Disconnect()
	end
end}