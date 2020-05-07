local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local Plr = game:GetService( "Players" ).LocalPlayer

local StarterGui = game:GetService( "StarterGui" )

local KBU = require( Plr:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "KeybindUtil" ) )

local PU = require( Plr:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "PoseUtil" ) )

local RPAnims = { [ Enum.HumanoidRigType.R6 ] = { "rbxassetid://580605334", "rbxassetid://1173354695" }, [ Enum.HumanoidRigType.R15 ] = { "rbxassetid://2225371665", "rbxassetid://2225382014" } }

local AnimationWrapper

local Salute, Surrender

function Spawned(Char)
	Char.ChildAdded:Connect(function(Obj)
		if Obj:IsA("BackpackItem") then
			if Salute then
				KBU.SetToggle("Salute", false)
			end
			if Surrender then
				KBU.SetToggle("Surrender", false)
			end
		end
	end)
	
	AnimationWrapper = require(Char:WaitForChild("S2"):WaitForChild("AnimationWrapper"))
	
	local SaluteAnim = Instance.new( "Animation" )
	
	SaluteAnim.AnimationId = RPAnims[ AnimationWrapper.Humanoid.RigType ][ 1 ]
	
	Salute = AnimationWrapper.Humanoid:LoadAnimation( SaluteAnim )
	
	local SurrenderAnim = Instance.new( "Animation" )
	
	SurrenderAnim.AnimationId = RPAnims[ AnimationWrapper.Humanoid.RigType ][ 2 ]
	
	Surrender = AnimationWrapper.Humanoid:LoadAnimation( SurrenderAnim )
	
end

Spawned( Plr.Character or Plr.CharacterAdded:Wait( ) )

Plr.CharacterAdded:Connect( Spawned )

local Surrendered

local SDebounce, SLast

KBU.AddBind{ Name = "Salute", Category = "Surge 2.0", Callback = function ( Began, Died )
	
	if Died then return end
	
	if not Salute then return false end
	
	if Began and SDebounce then return SLast end
	
	SLast = Began
	
	if Began then
		
		if Plr.Character and Plr.Character:FindFirstChildWhichIsA( "BackpackItem" ) or Core.Config.AllowSalute == false or SDebounce or Surrendered ~= nil then return false end
		
		KBU.SetToggle( "At_ease", false )
		
		KBU.SetToggle( "Surrender", false )
		
		Salute:Play( )
		
		SDebounce = true
		
		wait( )
		
		SDebounce = false
		
	else
		
		Salute:Stop( )
		
		SDebounce = true
		
		wait( )
		
		SDebounce = false
		
	end
	
end, Key = Enum.KeyCode.T, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true }

local ADebounce, ALast, AtEaseAnimation
local function UpdateAtEaseAnimation(AtEasing, Weapon)
	if AtEasing then
		local Config = Weapon or Core.Config.WeaponTypeOverrides.All
		if Config[AnimationWrapper.Humanoid.RigType.Name .. "AtEaseAnimation"] then
			local MyAtEaseAnimation = AnimationWrapper.GetAnimation("AtEaseAnim", Config[AnimationWrapper.Humanoid.RigType.Name .. "AtEaseAnimation"], 5)
			if AtEaseAnimation and AtEaseAnimation ~= MyAtEaseAnimation then
				AtEaseAnimation:Stop()
			end
			
			AtEaseAnimation = MyAtEaseAnimation
			if not AtEaseAnimation.AnimationTrack.IsPlaying then
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
				if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") and Plr.Character:FindFirstChildOfClass("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
					local Weapon = Core.Selected[Plr] and next(Core.Selected[Plr])
					if Weapon then
						if not Weapon.AllowAtEase or Weapon.Reloading then
							return false
						end
					elseif not Core.Config.WeaponTypeOverrides.All.AllowAtEase then
						return false
					end
				
					KBU.SetToggle("Salute", false)
					KBU.SetToggle("Surrender", false)
					
					UpdateAtEaseAnimation(true, Weapon)
					
					ADebounce = true
					wait()
					ADebounce = false
				end
			else
				UpdateAtEaseAnimation()
				
				ADebounce = true
				wait()
				ADebounce = false
			end
		end
	end
end, Key = Enum.KeyCode.Y, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true}

KBU.AddBind{ Name = "Surrender", Category = "Surge 2.0", Callback = function ( Began, Died )
	
	if Died then
		
		Core.PreventSprint[ "Surrender" ] = nil
		
		Core.PreventCrouch[ "Surrender" ] = nil
		
		Core.SetBackpackDisabled("Surrender", false)
		
		Surrendered = nil
		
		return
		
	end
	
	if not Surrender then
		
		Core.PreventSprint[ "Surrender" ] = nil
		
		Core.PreventCrouch[ "Surrender" ] = nil
		
		return false
		
	end
	
	if Surrendered ~= nil then return true end
	
	if Began then
		
		if Plr.Character and Plr.Character:FindFirstChildWhichIsA( "BackpackItem" ) or Core.Config.AllowSurrender == false then return false end
		
		Core.SetBackpackDisabled("Surrender", true)
		
		KBU.SetToggle( "Salute", false )
		
		KBU.SetToggle( "At_ease", false )
		
		KBU.SetToggle( "Crouch", false )
		
		PU.SetPose( "Crouching", true )
		
		Core.PreventSprint[ "Surrender" ] = true
		
		Core.PreventCrouch[ "Surrender" ] = true
		
		Surrender:Play( )
		
	end
	
end, Key = Enum.KeyCode.U, ToggleState = true, OffOnDeath = true, NoHandled = true }

Core.Events.AntiAtEaseShoot = Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect(function(_, User)
	if User == Plr and AtEaseAnimation then
		KBU.SetToggle("At_ease", false)
	end
end)

Core.WeaponSelected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon then
		if not Weapon.AllowAtEase then
			KBU.SetToggle("At_ease", false)
		elseif AtEaseAnimation then
			UpdateAtEaseAnimation(true, Weapon)
		end
	elseif not Core.Config.WeaponTypeOverrides.All.AllowAtEase then
		KBU.SetToggle("At_ease", false)
	elseif AtEaseAnimation then
		UpdateAtEaseAnimation(true, Weapon)
	end
end)

Core.WeaponDeselected.Event:Connect(function(StatObj)
	if not Core.Config.WeaponTypeOverrides.All.AllowAtEase then
		KBU.SetToggle("At_ease", false)
	elseif AtEaseAnimation then
		UpdateAtEaseAnimation(true)
	end
end)