local NoOptions = {}
local function GetOptions(InteractObj)
	if InteractObj:FindFirstChild("Options") then
		local Ran, Options = pcall(require, InteractObj.Options)
		if Ran then
			return Options
		else
			error("Interactables Options errored - " .. InteractObj:GetFullName() .. "\n" .. Options)
		end
	else
		return NoOptions
	end
end

local function GetPart(InteractObj, Options)
	return InteractObj.Parent:IsA("BasePart") and InteractObj.Parent or Options.MainPart or InteractObj.Parent.PrimaryPart
end

local InteractRemote = Instance.new("RemoteEvent")
InteractRemote.Name = "InteractRemote"
InteractRemote.OnServerEvent:Connect(function(Plr, InteractObj, Start, Subject)
	if InteractObj then
		local Humanoid = Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid")
		Subject = Subject or (Humanoid and Humanoid.RootPart)
		
		local Options = GetOptions(InteractObj)
		if Options.CharacterOny and Subject ~= Humanoid.RootPart then
			warn(Plr.Name .. " tried to trigger a character only Interactable")
		elseif not InteractObj:FindFirstChild("Disabled") and Humanoid and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead and Subject and Subject:IsDescendantOf(Plr.Character) and (GetPart(InteractObj, Options).Position - Subject.Position).magnitude <= (Options.Distance or 16) then
			if Options.Cooldown and Options.Cooldown > 0 then
				local Disabled = Instance.new("NumberValue")
				Disabled.Name = "Disabled"
				Disabled.Value = Start + Options.Cooldown
				Disabled.Parent = InteractObj
				
				delay(Options.Cooldown, function()
					if Disabled and Disabled.Parent then
						Disabled:Destroy()
					end
				end)
			end
			
			InteractObj:Fire(Plr)
		else
			warn(Plr.Name .. " tried to trigger an Interactable while it was disabled, they were dead or they were out of range")
		end
	else
		warn(Plr.Name .. " tried to trigger a non-existant Interactable")
	end
end)
InteractRemote.Parent = game:GetService("ReplicatedStorage"):WaitForChild("S2")