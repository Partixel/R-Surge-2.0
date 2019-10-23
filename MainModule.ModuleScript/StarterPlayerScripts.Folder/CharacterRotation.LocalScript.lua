local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local Plr = game:GetService("Players").LocalPlayer

Core.PreventCharacterRotation = { }

local Event, Until
function UpdateCharacterRotation(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon then
		local HumanoidRootPart, Humanoid = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart"), Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid")
		if HumanoidRootPart and Humanoid and (Humanoid:GetState() == Enum.HumanoidStateType.FallingDown or Humanoid:GetState() == Enum.HumanoidStateType.Flying or Humanoid:GetState() == Enum.HumanoidStateType.Freefall or Humanoid:GetState() == Enum.HumanoidStateType.Jumping or Humanoid:GetState() == Enum.HumanoidStateType.Landed or Humanoid:GetState() == Enum.HumanoidStateType.Running or Humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics or Humanoid:GetState() == Enum.HumanoidStateType.StrafingNoPhysics) then
			if not Until then
				Until = tick() + 5
				
				local SteppedEvent SteppedEvent = game:GetService("RunService").Stepped:Connect(function()
					if not Event or not HumanoidRootPart.Parent or not Humanoid.Parent or Until < tick() or not Core.Selected[Weapon.User] or not Core.Selected[Weapon.User][Weapon] then
						SteppedEvent:Disconnect()
						Until = nil
					elseif not HumanoidRootPart.Anchored and (workspace.CurrentCamera.CoordinateFrame.p - workspace.CurrentCamera.Focus.p).magnitude > 0.55 and not next(Core.PreventCharacterRotation) and (Humanoid:GetState() == Enum.HumanoidStateType.FallingDown or Humanoid:GetState() == Enum.HumanoidStateType.Flying or Humanoid:GetState() == Enum.HumanoidStateType.Freefall or Humanoid:GetState() == Enum.HumanoidStateType.Jumping or Humanoid:GetState() == Enum.HumanoidStateType.Landed or Humanoid:GetState() == Enum.HumanoidStateType.Running or Humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics or Humanoid:GetState() == Enum.HumanoidStateType.StrafingNoPhysics) then
						HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, Vector3.new(Core.LPlrsTarget[ 2 ].X, HumanoidRootPart.Position.Y, Core.LPlrsTarget[ 2 ].Z))
					end
				end)
			else
				Until = tick() + 5
			end
		end
	end
end

local Menu = require(game:GetService("ReplicatedStorage"):WaitForChild("MenuLib"):WaitForChild("S2"))
Menu:AddSetting{Name = "CharacterAim", Text = "Rotate character towards target", Default = true, Update = function(Options, Val)
	if Val then
		if not Event then
			Event = Core.ClientVisuals.Event:Connect(UpdateCharacterRotation)
		end
	elseif Event then
		Event:Disconnect()
		Event = nil
	end
end}