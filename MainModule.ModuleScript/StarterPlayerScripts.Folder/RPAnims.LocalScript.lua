local StarterGui = game:GetService("StarterGui")
local LocalPlayer = game:GetService("Players").LocalPlayer

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local KBU = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("KeybindUtil"))
local PU = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("PoseUtil"))

local AnimationWrapper
function Spawned(Char)
	AnimationWrapper = require(Char:WaitForChild("S2"):WaitForChild("AnimationWrapper"))
end
LocalPlayer.CharacterAdded:Connect(Spawned)
Spawned(LocalPlayer.Character)

local InspectAnimation

local SurrenderAnimation
KBU.AddBind{Name = "Surrender", Category = "Surge 2.0", Callback = function(Began, Died)
	if Died then
		Core.PreventSprint["Surrender"] = nil
		Core.PreventCrouch["Surrender"] = nil
		
		Core.SetBackpackDisabled("Surrender", false)
		
		SurrenderAnimation = nil
	elseif Began then
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("BackpackItem") or Core.Config.AllowSurrender == false or not Core.Config[AnimationWrapper.Humanoid.RigType.Name .. "SurrenderAnimation"] then
			return false
		end
		
		Core.SetBackpackDisabled("Surrender", true)
		
		KBU.SetToggle("Salute", false)
		KBU.SetToggle("At_ease", false)
		KBU.SetToggle("Crouch", false)
		if InspectAnimation and InspectAnimation.AnimationTrack.IsPlaying then
			InspectAnimation:Stop()
		end
		
		PU.SetPose("Crouching", true)
		
		Core.PreventSprint["Surrender"] = true
		Core.PreventCrouch["Surrender"] = true
		
		SurrenderAnimation = AnimationWrapper.GetAnimation("Surrender", Core.Config[AnimationWrapper.Humanoid.RigType.Name .. "SurrenderAnimation"], 15)
		SurrenderAnimation.AnimationTrack.Priority = Enum.AnimationPriority.Action
		SurrenderAnimation:Play()
	else
		return true
	end
end, Key = Enum.KeyCode.U, ToggleState = true, OffOnDeath = true, NoHandled = true}

local SDebounce, SLast, SaluteAnimation
KBU.AddBind{Name = "Salute", Category = "Surge 2.0", Callback = function(Began, Died)
	if not Died then
		if Began and SDebounce then
			return SLast
		else
			SLast = Began
			if Began then
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
					if SurrenderAnimation or not Core.Config.AllowSalute or not Core.Config[AnimationWrapper.Humanoid.RigType.Name .. "SaluteAnimation"] then
						return false
					end
					
					KBU.SetToggle("At_ease", false)
					
					SaluteAnimation = AnimationWrapper.GetAnimation("Salute", Core.Config[AnimationWrapper.Humanoid.RigType.Name .. "SaluteAnimation"], 10)
					SaluteAnimation.AnimationTrack.Priority = Enum.AnimationPriority.Action
					SaluteAnimation:Play()
					
					SDebounce = true
					
					wait()
					
					SDebounce = false
				end
			elseif SaluteAnimation then
				SaluteAnimation = SaluteAnimation:Stop()
				
				SDebounce = true
				
				wait()
				
				SDebounce = false
			end
		end
	end
end, Key = Enum.KeyCode.T, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true}

local Debounce
KBU.AddBind{Name = "Inspect", Category = "Surge 2.0", Callback = function(Began, Died)
	if not Died and Began then
		if Debounce then
			return false
		else
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
				local Weapon = Core.Selected[LocalPlayer] and next(Core.Selected[LocalPlayer])
				if Weapon then
					if not Weapon.AllowInspect or Weapon.Reloading then
						return false
					end
				else
					return false
				end
				
				if not Weapon[AnimationWrapper.Humanoid.RigType.Name .. "InspectAnimation"] then
					return false
				end
				
				KBU.SetToggle("At_ease", false)
				
				InspectAnimation = AnimationWrapper.GetAnimation("Inspect", Weapon[AnimationWrapper.Humanoid.RigType.Name .. "InspectAnimation"], 10)
				InspectAnimation.AnimationTrack.Priority = Enum.AnimationPriority.Action
				InspectAnimation:Play(0.4)
				
				Debounce = true
				
				wait()
				
				Debounce = false
			end
		end
	end
end, Key = Enum.KeyCode.G, NoHandled = true}

local ADebounce, ALast, AtEaseAnimation
local function UpdateAtEaseAnimation(AtEasing, Weapon)
	if AtEasing then
		local Config = Weapon or Core.Config.WeaponTypeOverrides.All
		if Config[AnimationWrapper.Humanoid.RigType.Name .. "AtEaseAnimation"] then
			local MyAtEaseAnimation = AnimationWrapper.GetAnimation("AtEase", Config[AnimationWrapper.Humanoid.RigType.Name .. "AtEaseAnimation"], 10)
			
			if AtEaseAnimation and AtEaseAnimation ~= MyAtEaseAnimation then
				AtEaseAnimation:Stop()
			end
			
			AtEaseAnimation = MyAtEaseAnimation
			
			if not AtEaseAnimation.AnimationTrack.IsPlaying then
				AtEaseAnimation.AnimationTrack.Priority = Enum.AnimationPriority.Action
				AtEaseAnimation:Play()
			end
		end
	elseif AtEaseAnimation then
		AtEaseAnimation = AtEaseAnimation:Stop()
	end
end

KBU.AddBind{Name = "At_ease", Category = "Surge 2.0", Callback = function(Began, Died)
	if not Died then
		if Began and ADebounce then
			return ALast
		else
			ALast = Began
			if Began then
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
					local Weapon = Core.Selected[LocalPlayer] and next(Core.Selected[LocalPlayer])
					if Weapon then
						if not Weapon.AllowAtEase or Weapon.Reloading then
							return false
						end
					elseif not Core.Config.WeaponTypeOverrides.All.AllowAtEase then
						return false
					end
					
					if not (Weapon or Core.Config.WeaponTypeOverrides.All)[AnimationWrapper.Humanoid.RigType.Name .. "AtEaseAnimation"] then
						return false
					end
					
					KBU.SetToggle("Salute", false)
					if InspectAnimation and InspectAnimation.AnimationTrack.IsPlaying then
						InspectAnimation:Stop()
					end
					
					UpdateAtEaseAnimation(true, Weapon)
					
					ADebounce = true
					
					wait()
					
					ADebounce = false
				end
			elseif AtEaseAnimation then
				UpdateAtEaseAnimation()
				
				ADebounce = true
				
				wait()
				
				ADebounce = false
			end
		end
	end
end, Key = Enum.KeyCode.Y, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true}

Core.Events.AntiInspectReload = Core.ReloadStart.Event:Connect(function(StatObj, Delay)
	if InspectAnimation and InspectAnimation.AnimationTrack.IsPlaying then
		InspectAnimation:Stop()
	end
end)

Core.Events.AntiRPShoot = Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect(function(_, User)
	if User == LocalPlayer then
		if AtEaseAnimation then
			KBU.SetToggle("At_ease", false)
		end
		
		if InspectAnimation and InspectAnimation.AnimationTrack.IsPlaying then
			InspectAnimation:Stop()
		end
	end
end)

Core.WeaponSelected.Event:Connect(function(StatObj)
	if InspectAnimation and InspectAnimation.AnimationTrack.IsPlaying then
		InspectAnimation:Stop()
	end
	
	local Weapon = Core.GetWeapon(StatObj)
	if not Weapon.AllowAtEase then
		KBU.SetToggle("At_ease", false)
	elseif AtEaseAnimation then
		UpdateAtEaseAnimation(true, Weapon)
	end
end)

Core.WeaponDeselected.Event:Connect(function(StatObj)
	if InspectAnimation and InspectAnimation.AnimationTrack.IsPlaying then
		InspectAnimation:Stop()
	end
	
	if not Core.Config.WeaponTypeOverrides.All.AllowAtEase then
		KBU.SetToggle("At_ease", false)
	elseif AtEaseAnimation then
		UpdateAtEaseAnimation(true)
	end
end)