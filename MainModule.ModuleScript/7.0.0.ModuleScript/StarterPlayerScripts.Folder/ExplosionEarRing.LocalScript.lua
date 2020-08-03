local LocalPlayer = game:GetService("Players").LocalPlayer

local CurCC
workspace.DescendantAdded:Connect(function(Explosion)
	if Explosion:IsA("Explosion") and Explosion.Visible and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - Explosion.Position).magnitude < Explosion.BlastRadius then
		local Dist = math.min(1.4 - (LocalPlayer.Character.HumanoidRootPart.Position - Explosion.Position).magnitude / (Explosion.BlastRadius + 10), 1)
		
		local Sound = Instance.new("Sound")
		Sound.SoundId = "rbxassetid://3262620486"
		Sound.Volume = 2
		Sound.TimePosition = 6.9 - (5 * Dist) + 1
		Sound.Ended:Connect(function() Sound:Destroy() end)
		Sound.Parent = workspace.CurrentCamera
		Sound:Play()
		
		local CC = workspace.CurrentCamera:FindFirstChild("S2CC") or Instance.new("ColorCorrectionEffect")
		CC.Name = "S2CC"
		CC.Contrast = Dist
		CC.Saturation = -Dist
		CC.Brightness = Dist
		CC.Enabled = true
		CC.Parent = workspace.CurrentCamera
		
		local LocalCC = tick()
		CurCC = LocalCC
		for i = 5 - ( 5 * Dist ), 5 do
			if LocalCC ~= CurCC then return end
			CC.Brightness = 1 - i / 8
			wait()
		end
		
		wait(3)
		
		for i = 30 - ( 30 * Dist ), 30 do
			if LocalCC ~= CurCC then return end
			CC.Contrast = 1 - i / 30
			CC.Saturation = i / 30 - 1
			CC.Brightness = 0.375 - i / 80
			wait()
		end
		
		if LocalCC ~= CurCC then return end
		
		CC.Contrast = 0
		CC.Saturation = 0
		CC.Enabled = false
	end
end)