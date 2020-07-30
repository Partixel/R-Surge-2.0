local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))

local UpdateRate = 1/20

local Event
local HeadRotRemote = game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("HeadRot")
HeadRotRemote.OnClientEvent:Connect(function(Rotations)
	if Event then
		for _, Rot in ipairs(Rotations) do
			local Neck = Rot[1].Character and Rot[1].Character:FindFirstChild("Neck", true)
			if Neck then
				TweenService:Create(Neck, TweenInfo.new(UpdateRate, Enum.EasingStyle.Linear), {C0 = Rot[2]}):Play()
			end
		end
	end
end)

local Root, Neck, R6
function HandleCharacter(Char)
	Root, Neck = Char:WaitForChild("HumanoidRootPart"), Char:FindFirstChild("Neck", true)
	while not Neck do
		wait()
		Neck = Char:FindFirstChild("Neck", true)
	end
	while not Char:FindFirstChildOfClass("Humanoid") do
		wait()
	end
	R6 = Char:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6
end
HandleCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(HandleCharacter)

function UpdateHead()
	if Root and Neck and workspace.CurrentCamera.CameraSubject and workspace.CurrentCamera.CameraSubject:IsA("Humanoid") and workspace.CurrentCamera.CameraSubject.Parent == LocalPlayer.Character then
		local CameraDirection = Root.CFrame:toObjectSpace(workspace.CurrentCamera.CFrame).lookVector.unit
		if R6 then
			Neck.C0 = CFrame.new(Neck.C0.p) * CFrame.Angles(0, -math.asin(CameraDirection.x), 0) * CFrame.Angles(-math.pi/2 + math.asin(CameraDirection.y), 0, math.pi)
		else
			Neck.C0 = CFrame.new(Neck.C0.p) * CFrame.Angles(math.asin(CameraDirection.y), -math.asin(CameraDirection.x), 0)
		end
	end
	for _, Player in ipairs(Players:GetPlayers()) do
		if Player.Character and Player.Character:FindFirstChild("Head") then
			local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
			if Humanoid and Humanoid.Health ~= 0 then
				Player.Character.Head.CanCollide = false
			end
		end
	end
end

local Menu = require(game:GetService("ReplicatedStorage"):WaitForChild("MenuLib"):WaitForChild("Performance"))
Menu:AddSetting{Name = "HeadRotation", Text = "Head Rotation", Default = true, Update = function(Options, Val)
	if Val then
		if not Event then
			Event = game:GetService("RunService").Stepped:Connect(UpdateHead)
		end
	elseif Event then
		Event:Disconnect()
		Event = nil
		for _, LocalPlayer in ipairs(Players:GetPlayers()) do
			local Neck = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Neck", true)
			if Neck then
				Neck.C0 = Neck.Parent.Name == "Torso" and CFrame.new(Neck.C0.p) * CFrame.Angles(-math.pi/2, 0, math.pi) or CFrame.new(Neck.C0.p)
			end
		end
	end
end}

local Last
while wait(UpdateRate) do
	if Neck and Last ~= Neck.C0 then
		HeadRotRemote:FireServer(Neck.C0, not Event or nil)
		Last = Neck.C0
	end
end