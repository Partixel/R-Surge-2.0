local UserInputService, CollectionService = game:GetService("UserInputService"), game:GetService("CollectionService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local TimeSync = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("TimeSync"))
local KBU, Core = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("KeybindUtil")), require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local InteractRemote = game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("InteractRemote")

local Interactables = {
	LocalDisabled = {},
	Guis = {},
}

local OpenGui = Instance.new("BindableEvent")
Interactables.OpenGui = OpenGui.Event
local CloseGui = Instance.new("BindableEvent")
Interactables.CloseGui = CloseGui.Event
local MaximiseGui = Instance.new("BindableEvent")
Interactables.MaximiseGui = MaximiseGui.Event
local MinimiseGui = Instance.new("BindableEvent")
Interactables.MinimiseGui = MinimiseGui.Event
local EnableGui = Instance.new("BindableEvent")
Interactables.EnableGui = EnableGui.Event
local StartHold = Instance.new("BindableEvent")
Interactables.StartHold = StartHold.Event
local EndHold = Instance.new("BindableEvent")
Interactables.EndHold = EndHold.Event
local UpdateKey = Instance.new("BindableEvent")
Interactables.UpdateKey = UpdateKey.Event
local UpdateCooldown = Instance.new("BindableEvent")
Interactables.UpdateCooldown = UpdateCooldown.Event
local UpdateProgress = Instance.new("BindableEvent")
Interactables.UpdateProgress = UpdateProgress.Event

local Mouse = LocalPlayer:GetMouse()
local MouseDown, KeyDown
Mouse.Button1Down:Connect(function()
	MouseDown = true
end)

Mouse.Button1Up:Connect(function()
	MouseDown = nil
end)

KBU.AddBind{Name = "Interact", Category = "Surge 2.0", Callback = function(Began, Handled, Died)
	if not Began or not Handled then
		KeyDown = not Died and Began or nil
	end
end, Key = Enum.KeyCode.E, PadKey = Enum.KeyCode.ButtonX, OffOnDeath = true}

KBU.ContextChanged:Connect(function()
	UpdateKey:Fire(KBU.GetKeyInContext("Interact"))
end)

KBU.BindChanged.Event:Connect(function(Name)
	if not Name or Name == "Interact" then
		UpdateKey:Fire(KBU.GetKeyInContext("Interact"))
	end
end)

local function Obscured(Part, Model, Ignore)
	for _, Obj in ipairs(workspace.CurrentCamera:GetPartsObscuringTarget({Part.Position}, {Model, LocalPlayer.Character, Ignore}))do
		if not Core.IgnoreFunction(Obj) then
			return true
		end
	end
end

local function GetSubject()
	local Subject = workspace.CurrentCamera.CameraSubject
	if Subject and Subject:IsA("Humanoid") then
		return Subject.RootPart
	else
		return Subject
	end
end

local function DefaultShouldOpen(InteractObj, Options, LocalPlayer)
	return not Options.Hide and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChildOfClass("Tool")
end

local function GetPart(InteractObj, Options)
	return InteractObj.Parent:IsA("BasePart") and InteractObj.Parent or Options.MainPart or InteractObj.Parent.PrimaryPart
end

local NoOptions = {}
function Interactables.GetOptions(InteractObj)
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

local LastNearest, HoldStart
function Interactables.DestroyGui(InteractObj)
	if Interactables.Guis[InteractObj] then
		Interactables.Guis[InteractObj]:Destroy()
		Interactables.Guis[InteractObj] = nil
	end
	
	if LastNearest == InteractObj then
		LastNearest = nil
		HoldStart = nil
	end
end

local Cooldowns, HBEvent, TagAddedEvent = {}, nil, nil
function StartInteractables()
	HBEvent = game:GetService("RunService").Heartbeat:Connect(function()
		local InteractObjs = CollectionService:GetTagged("S2_Interactable")
		if next(InteractObjs) then
			local Subject, Humanoid = GetSubject(), LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") 
			if Subject and Humanoid and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead and Interactables.Visible ~= false then
				local Nearest, NearestDist, NearestOptions
				if HoldStart and LastNearest:IsDescendantOf(workspace) and not LastNearest:FindFirstChild("Disabled") and not Interactables.LocalDisabled[LastNearest] then
					NearestOptions = Interactables.GetOptions(LastNearest)
					if (GetPart(LastNearest, NearestOptions).Position - Subject.Position).magnitude <= (NearestOptions.Distance or 16) then
						Nearest, NearestDist = LastNearest, -1
					else
						NearestOptions = nil
					end
				end
				
				for _, InteractObj in ipairs(InteractObjs) do
					if InteractObj:IsDescendantOf(workspace) then
						if InteractObj ~= Nearest then
							local Options = Interactables.GetOptions(InteractObj)
							if not Options.CharacterOnly or Subject == Humanoid.RootPart then	
								local InteractPart = GetPart(InteractObj, Options)				
								local Dist = (InteractPart.Position - Subject.Position).magnitude
								if Dist <= (Options.Distance or 16) and select(2, workspace.CurrentCamera:WorldToViewportPoint(InteractPart.Position)) and not Obscured(InteractPart, InteractObj.Parent, Options.Ignore) and (Options.ShouldOpen or DefaultShouldOpen)(InteractObj, Options, LocalPlayer, DefaultShouldOpen) then
									if not InteractObj:FindFirstChild("Disabled") and not Interactables.LocalDisabled[InteractObj] then
										if Mouse.Target and (Mouse.Target == InteractObj.Parent or Mouse.Target:IsDescendantOf(InteractObj.Parent)) then
											Nearest, NearestDist, NearestOptions = InteractObj, -1, Options
										elseif not NearestDist or Dist < NearestDist then
											Nearest, NearestDist, NearestOptions = InteractObj, Dist, Options
										end
									end
									
									if Interactables.Guis[InteractObj] and InteractPart ~= Interactables.Guis[InteractObj].Adornee then
										Interactables.Guis[InteractObj].Adornee = InteractPart
									end
									
									if not Interactables.Guis[InteractObj] or Interactables.Guis[InteractObj].Name == "Destroying" then
										OpenGui:Fire(InteractObj, Interactables.Guis[InteractObj], KBU.GetKeyInContext("Interact"))
									elseif InteractObj:FindFirstChild("Disabled") then
										if Interactables.Guis[InteractObj].Name ~= "Disabled" then
											local CooldownLeft = InteractObj.Disabled.Value == 0 and true or math.ceil(math.max(InteractObj.Disabled.Value - tick() - TimeSync.ServerOffset, 0))
											if CooldownLeft ~= true then
												Cooldowns[InteractObj] = CooldownLeft
											end
											
											MinimiseGui:Fire(InteractObj, Interactables.Guis[InteractObj], CooldownLeft)
											
											Interactables.Guis[InteractObj].Name = "Disabled"
										elseif InteractObj.Disabled.Value ~= 0 then
											local CooldownLeft = math.ceil(math.max(InteractObj.Disabled.Value - tick() - TimeSync.ServerOffset, 0))
											if Cooldowns[InteractObj] ~= CooldownLeft then
												Cooldowns[InteractObj] = CooldownLeft
												
												UpdateCooldown:Fire(InteractObj, Interactables.Guis[InteractObj], CooldownLeft)
											end
										end
									elseif not InteractObj:FindFirstChild("Disabled") and not Interactables.LocalDisabled[InteractObj] and Interactables.Guis[InteractObj].Name == "Disabled" then
										Interactables.Guis[InteractObj].Name = "InteractGui"
										Cooldowns[InteractObj] = nil
										
										EnableGui:Fire(InteractObj, Interactables.Guis[InteractObj], KBU.GetKeyInContext("Interact"))
									end
								elseif Interactables.Guis[InteractObj] and Interactables.Guis[InteractObj].Name ~= "Destroying" then
									Interactables.Guis[InteractObj].Name = "Destroying"
									Cooldowns[InteractObj] = nil
									
									CloseGui:Fire(InteractObj, Interactables.Guis[InteractObj])
								end
							elseif Interactables.Guis[InteractObj] then
								Interactables.Guis[InteractObj]:Destroy()
								Interactables.Guis[InteractObj] = nil
								
								if LastNearest == InteractObj then
									LastNearest = nil
									HoldStart = nil
								end
							end
						end
					else
						Cooldowns[InteractObj] = nil
						
						if Interactables.Guis[InteractObj] then
							Interactables.Guis[InteractObj] = Interactables.Guis[InteractObj]:Destroy()
							
							if LastNearest == InteractObj then
								LastNearest = nil
								HoldStart = nil
							end
						end
					end
				end
				
				if LastNearest ~= Nearest then
					HoldStart = nil
					
					if LastNearest and Interactables.Guis[LastNearest] and Interactables.Guis[LastNearest].Name ~= "Destroying" then
						MinimiseGui:Fire(LastNearest, Interactables.Guis[LastNearest])
					end
					
					if Nearest then
						if not NearestOptions.HoldTime or NearestOptions.HoldTime <= 0 then
							MouseDown, KeyDown = nil, nil
						end
						MaximiseGui:Fire(Nearest, Interactables.Guis[Nearest])
					end
					
					LastNearest = Nearest
				end
				
				if Nearest then
					if HoldStart and not MouseDown and not KeyDown then
						HoldStart = nil
						
						if Interactables.Guis[Nearest].Name ~= "Destroying" then
							EndHold:Fire(Nearest, Interactables.Guis[Nearest])
						end
					end
					
					if not HoldStart and (KeyDown or (MouseDown and Mouse.Target and (Mouse.Target == Nearest.Parent or Mouse.Target:IsDescendantOf(Nearest.Parent)))) then
						HoldStart = tick()
						
						StartHold:Fire(Nearest, Interactables.Guis[Nearest])
					end
					
					if HoldStart then
						local HoldTime = NearestOptions.HoldTime or 0
						if tick() - HoldStart > HoldTime then
							local Cooldown = NearestOptions.Cooldown and NearestOptions.Cooldown > 0 and NearestOptions.Cooldown or nil
							if not Cooldown then
								Interactables.LocalDisabled[Nearest] = true
								
								delay(0.3, function()
									Interactables.LocalDisabled[Nearest] = nil
								end)
							end
							
							Interactables.Guis[Nearest].Name = "Disabled"
							
							EndHold:Fire(Nearest, Interactables.Guis[Nearest], true, Cooldown)
							
							if not NearestOptions.ClientOnly then
								InteractRemote:FireServer(Nearest, TimeSync.GetServerTime(), Subject ~= Humanoid.RootPart and Subject or nil)
							elseif Cooldown then
								local Disabled = Instance.new("NumberValue")
								Disabled.Name = "Disabled"
								Disabled.Value = TimeSync.GetServerTime() + Cooldown
								Disabled.Parent = Nearest
								
								delay(Cooldown, function()
									if Disabled and Disabled.Parent then
										Disabled:Destroy()
									end
								end)
							end
							
							if not Core.IsServer or NearestOptions.ClientOnly then
								Nearest:Fire(LocalPlayer)
							end
							
							HoldStart, MouseDown, KeyDown = nil
						else
							UpdateProgress:Fire(Nearest, Interactables.Guis[Nearest], HoldTime <= 0 and 1 or (math.min(tick() - HoldStart, HoldTime) / HoldTime))
						end
					end
				end
			else
				for InteractObj, InteractGui in pairs(Interactables.Guis) do
					InteractGui.Name = "Destroying"
					CloseGui:Fire(InteractObj, InteractGui)
				end
				Cooldowns, LastNearest, HoldStart = {}, nil, nil
			end
		else
			for InteractObj, InteractGui in pairs(Interactables.Guis) do
				InteractGui.Name = "Destroying"
				CloseGui:Fire(InteractObj, InteractGui)
			end
			Cooldowns, LastNearest, HoldStart = {}, nil, nil
			
			HBEvent = HBEvent:Disconnect()
			TagAddedEvent = CollectionService:GetInstanceAddedSignal("S2_Interactable"):Connect(function()
				StartInteractables()
			end)
		end
	end)
end

if next(CollectionService:GetTagged("S2_Interactable")) then
	StartInteractables()
else
	TagAddedEvent = CollectionService:GetInstanceAddedSignal("S2_Interactable"):Connect(function()
		StartInteractables()
	end)
end

return Interactables