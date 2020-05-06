local Handled = setmetatable({}, {__mode = "k"})
function HandlePart(Part)
	if Part:IsA("BasePart") and (Part.Name:lower():find("leg") or Part.Name:lower():find("arm") or Part.Name == "LeftHand" or Part.Name == "RightHand" or Part.Name == "LeftFoot" or Part.Name == "RightFoot") then
		Handled[Part] = true
		local Event Event = Part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			if Part:IsDescendantOf(script.Parent.Parent) then
				Part.LocalTransparencyModifier = 0
			else
				Event:Disconnect()
			end
		end)
	end
end

script.Parent.Parent.DescendantAdded:Connect(function(Obj)
	if not Handled[Obj] then
		HandlePart(Obj)
	end
end)
for _, Obj in ipairs(script.Parent.Parent:GetDescendants()) do
	if not Handled[Obj] then
		HandlePart(Obj)
	end
end