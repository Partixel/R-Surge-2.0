local function Convert(Weld)
	local Motor6d = Instance.new("Motor6D")
	Motor6d.Part0 = Weld.Part0
	Motor6d.Part1 = Weld.Part1
	Motor6d.C0 = Weld.C0
	Motor6d.C1 = Weld.C1
	Motor6d.Name = "RightGrip"
	Motor6d.Parent = Weld.Parent
	
	Weld.Enabled = false
	Weld.Name = "OldRightGrip"
	while Weld.Parent do Weld.AncestryChanged:Wait() end
	
	Motor6d:Destroy()
end

if script.Parent.Parent:WaitForChild("Humanoid").RigType == Enum.HumanoidRigType.R15 then
	local Weld = script.Parent.Parent:WaitForChild("RightHand"):FindFirstChild("RightGrip")
	if Weld and Weld:IsA("Weld") then
		Convert(Weld)
	end
	
	script.Parent.Parent.RightHand.ChildAdded:Connect(function(Obj)
		if Obj.Name == "RightGrip" and Obj:IsA("Weld") then
			Convert(Obj)
		end
	end)
else
	local Weld = script.Parent.Parent:WaitForChild("Right Arm"):FindFirstChild("RightGrip")
	if Weld and Weld:IsA("Weld") then
		Convert(Weld)
	end
	
	script.Parent.Parent:FindFirstChild("Right Arm").ChildAdded:Connect(function(Obj)
		if Obj.Name == "RightGrip" and Obj:IsA("Weld") then
			Convert(Obj)
		end
	end)
end