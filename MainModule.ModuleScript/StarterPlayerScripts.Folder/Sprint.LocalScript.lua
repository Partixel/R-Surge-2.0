local TweenService = game:GetService("TweenService")
local Plr = game:GetService("Players").LocalPlayer

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local KBU = require(Plr:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("KeybindUtil"))
local PU = require(Plr:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("PoseUtil"))

Core.PreventSprint = {}

local AnimationWrapper

local FOVMod, ActSprint, SprintAnimation
function UpdateSprintAnimation(Sprinting, Weapon)
	if Sprinting then
		Weapon = Weapon or Core.Selected[Plr] and next(Core.Selected[Plr])
		local Config = Weapon or Core.Config.WeaponTypeOverrides.All
		if Config[AnimationWrapper.Humanoid.RigType.Name .. "SprintAnimation"] then
			local MySprintAnimation = AnimationWrapper.GetAnimation("Sprint", Config[AnimationWrapper.Humanoid.RigType.Name .. "SprintAnimation"], 5)
			if SprintAnimation and SprintAnimation ~= MySprintAnimation then
				SprintAnimation:Stop()
			end
			
			SprintAnimation = MySprintAnimation
			if not SprintAnimation.AnimationTrack.IsPlaying then
				SprintAnimation.AnimationTrack.Priority = Enum.AnimationPriority.Action
				SprintAnimation:Play()
			end
		end
	elseif SprintAnimation then
		SprintAnimation = SprintAnimation:Stop()
	end
end

function UpdateCamera(Sprinting)
	if Core.ActualSprinting ~= Sprinting then
		local MySprint = {}
		ActSprint = MySprint
		
		Core.PreventCharacterRotation.Sprinting = Sprinting
		Core.ActualSprinting = Sprinting
		
		UpdateSprintAnimation(Sprinting)
		
		if not FOVMod or not FOVMod.Parent then
			FOVMod = Instance.new("NumberValue")
			FOVMod.Name = "FieldOfViewModifier"
			FOVMod.Value = 1
		end
		FOVMod.Parent = workspace.CurrentCamera
		
		if not Sprinting then
			wait(0.1)
			if MySprint ~= ActSprint then
				return
			end
		end
		
		TweenService:Create(FOVMod, TweenInfo.new(0.1), {Value = Sprinting and 80/75 or 1}):Play()
	end
end

function HandleChar(Char)
	AnimationWrapper = require(Char:WaitForChild("S2"):WaitForChild("AnimationWrapper"))
	
	AnimationWrapper.Humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
		if AnimationWrapper.Humanoid.Sit then
			UpdateCamera()
		elseif PU.GetPose("Sprinting") and AnimationWrapper.Humanoid.MoveDirection.magnitude ~= 0 then
			UpdateCamera(true)
		else
			UpdateCamera()
		end
	end)
	
	AnimationWrapper.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if AnimationWrapper.Humanoid.MoveDirection.magnitude == 0 then
			UpdateCamera()
		elseif PU.GetPose("Sprinting") and not AnimationWrapper.Humanoid.Sit and AnimationWrapper.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			UpdateCamera(true)
		else
			UpdateCamera()
		end
	end)
end
HandleChar(Plr.Character or Plr.CharacterAdded:Wait())
Plr.CharacterAdded:Connect(HandleChar)

local WSMod
PU.Watch("Sprinting", "Sprint", function(NPlr, State, Offset)
	if NPlr == Plr then
		local Hum = NPlr.Character and NPlr.Character:FindFirstChildOfClass("Humanoid")
		if Hum then
			if WSMod then
				WSMod:Destroy()
			end
			
			if State then
				local Weapon = Core.Selected[Plr] and next(Core.Selected[Plr])
				
				WSMod = Instance.new("NumberValue")
				WSMod.Name = "WalkSpeedModifier"
				WSMod.Value = Weapon and Weapon.SprintSpeedMultiplier or Core.Config.WeaponTypeOverrides.All.SprintSpeedMultiplier
				WSMod.Parent = Hum
				
				if not Hum.Sit and Hum.MoveDirection.magnitude ~= 0 and Hum:GetState() ~= Enum.HumanoidStateType.Dead then
					UpdateCamera(true)
				else
					UpdateCamera()
				end
			else
				WSMod = nil
				UpdateCamera()
			end
		end
	end
end)

local Debounce, Last
KBU.AddBind{Name = "Sprint", Category = "Surge 2.0", Callback = function(Began, Died)
	if not Died then
		if Began and Debounce then
			return Last
		else
			Last = Began
			if Began then
				if next(Core.PreventSprint) then
					return false
				elseif Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") and Plr.Character:FindFirstChildOfClass("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
					local Weapon = Core.Selected[Plr] and next(Core.Selected[Plr])
					if Weapon then
						if not Weapon.AllowSprint or Weapon.Reloading then
							return false
						end
					elseif not Core.Config.WeaponTypeOverrides.All.AllowSprint then
						return false
					end
					
					PU.SetPose("Sprinting", true)
					PU.SetPose("Crouching", false)
					PU.SetPose("Scoping", false)
					
					Debounce = true
					wait()
					Debounce = false
				end
			else
				Core.PreventCrouch.Sprinting = nil
				PU.SetPose("Sprinting", false)
				
				Debounce = true
				wait()
				Debounce = false
			end
		end
	end
end, Key = Enum.KeyCode.F, PadKey = Enum.KeyCode.ButtonL3, ToggleState = false, CanToggle = true, OffOnDeath = true, NoHandled = true}

Core.Events.AntiSprintReload = Core.ReloadStart.Event:Connect(function(StatObj)
	if Core.ActualSprinting then
		KBU.SetToggle("Sprint", false)
	end
end)

Core.Events.AntiSprintShoot = Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect(function(_, User)
	if User == Plr and Core.ActualSprinting then
		KBU.SetToggle("Sprint", false)
	end
end)

Core.WeaponSelected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon then
		if not Weapon.AllowSprint then
			KBU.SetToggle("Sprint", false)
		elseif Core.ActualSprinting then
			UpdateSprintAnimation(true, Weapon)
		end
	elseif not Core.Config.WeaponTypeOverrides.All.AllowSprint then
		KBU.SetToggle("Sprint", false)
	elseif Core.ActualSprinting then
		UpdateSprintAnimation(true, Weapon)
	end
end)

Core.WeaponDeselected.Event:Connect(function(StatObj)
	if not Core.Config.WeaponTypeOverrides.All.AllowSprint then
		KBU.SetToggle("Sprint", false)
	elseif Core.ActualSprinting then
		UpdateSprintAnimation(true)
	end
end)