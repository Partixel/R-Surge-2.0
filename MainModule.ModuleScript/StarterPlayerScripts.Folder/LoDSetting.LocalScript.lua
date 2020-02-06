local LoD = game:GetService("ReplicatedStorage"):WaitForChild("CustomLoD")
if LoD then
	local Meshes = setmetatable({}, {__mode = "k"})
	
	for _, Obj in ipairs(workspace:GetDescendants()) do
		if Obj:IsA("MeshPart") or Obj:IsA("SpecialMesh") then
			local LoDObj = LoD:FindFirstChild(Obj.Name)
			if LoDObj then
				Meshes[Obj] = LoDObj
			end
		end
	end
	
	workspace.DescendantAdded:Connect(function(Obj)
		if Obj:IsA("MeshPart") or Obj:IsA("SpecialMesh") then
			local LoDObj = LoD:FindFirstChild(Obj.Name)
			if LoDObj then
				Meshes[Obj] = LoDObj
			end
		end
	end)
	
	local Menu = require(game:GetService("ReplicatedStorage"):WaitForChild("MenuLib"):WaitForChild("Performance"))
	Menu:AddSetting{Name = "LoD", Text = "Mesh Level of Detail (1-5)", Default = 5, Update = function(Options, Val)
		for Obj, LoDObj in pairs(Meshes) do
			if Obj:IsA("SpecialMesh") then
				
			end
		end
	end}
end