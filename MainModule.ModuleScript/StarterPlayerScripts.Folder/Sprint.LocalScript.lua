local Plr = game:GetService( "Players" ).LocalPlayer

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

local KBU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )

local PU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "PoseUtil" ) )

local TweenService = game:GetService( "TweenService" )

function UpdateCamera( Sprinting )
	
	if Core.ActualSprinting ~= Sprinting then
		
		Core.PreventReload.Sprinting = Sprinting
		
		Core.PreventCharacterRotation.Sprinting = Sprinting
		
		local Weapon = Core.GetSelectedWeapon( Plr )
		
		if Weapon and Weapon.Reloading then
			
			Weapon.Reloading = false
			
		end
		
		Core.ActualSprinting = Sprinting
		
		TweenService:Create( workspace.CurrentCamera, TweenInfo.new( 0.1 ), { FieldOfView = workspace.CurrentCamera.FieldOfView + ( Sprinting and 5 or -5 ) } ):Play( )
		
	end
	
end

function HandleChar( Char )
	
	local Hum = Char:WaitForChild( "Humanoid" )
	
	Hum:GetPropertyChangedSignal( "Sit" ):Connect( function ( )
		
		if Hum.Sit then
			
			UpdateCamera( )
		
		elseif PU.GetPose( "Sprinting" ) and Hum.MoveDirection.magnitude ~= 0 then
			
			UpdateCamera( true )
			
		else
			
			UpdateCamera( )
			
		end
		
	end )
	
	Hum.StateChanged:Connect( function ( OldState, State )
		
		if State == Enum.HumanoidStateType.Jumping or State == Enum.HumanoidStateType.Freefall or State == Enum.HumanoidStateType.FallingDown then
			
			KBU.SetToggle( "s2_Sprint", false )
			
		end
		
	end )
	
	Hum:GetPropertyChangedSignal( "MoveDirection" ):Connect( function ( )
		
		if Hum.MoveDirection.magnitude == 0 then
			
			UpdateCamera( )
			
		elseif PU.GetPose( "Sprinting" ) and not Hum.Sit and Hum:GetState( ) ~= Enum.HumanoidStateType.Dead then
			
			UpdateCamera( true )
			
		else
			
			UpdateCamera( )
			
		end
		
	end )
	
end

repeat wait ( ) until Plr.Character

HandleChar( Plr.Character )

Plr.CharacterAdded:Connect( HandleChar )

local WSMod

PU.Watch( "Sprinting", "Sprint", function ( NPlr, State, Offset )
	
	if NPlr == Plr then
		
		local Hum = NPlr.Character and NPlr.Character:FindFirstChildOfClass( "Humanoid" )
		
		if Hum then
			
			if WSMod then WSMod:Destroy( ) end
			
			if State then
				
				WSMod = Instance.new( "NumberValue" )
				
				WSMod.Name = "WalkSpeedModifier"
				
				WSMod.Value = _G.S20Config.SprintSpeedMultiplier or 1.35
				
				WSMod.Parent = Hum
				
				if not Hum.Sit and Hum.MoveDirection.magnitude ~= 0 and Hum:GetState( ) ~= Enum.HumanoidStateType.Dead then
					
					UpdateCamera( true )
					
				else
					
					UpdateCamera( )
					
				end
				
			else
				
				WSMod = nil
				
				UpdateCamera( )
				
			end
			
		end
		
	end
	
end )

Core.PreventSprint = { }

KBU.AddBind{ Name = "s2_Sprint", Callback = function ( Began, Died )
	
	if Died then return end
	
	if next( Core.PreventSprint ) then return false end
	
	if Began then
		
		local State = Plr.Character and Plr.Character:FindFirstChildOfClass( "Humanoid" ) and Plr.Character:FindFirstChildOfClass( "Humanoid" ):GetState( )
		
		if State ~= Enum.HumanoidStateType.Dead and State ~= Enum.HumanoidStateType.Jumping and State ~= Enum.HumanoidStateType.Freefall and State ~= Enum.HumanoidStateType.FallingDown then
			
			local Weapon = Core.GetSelectedWeapon( Plr )
			
			if _G.S20Config.AllowSprinting == false then
				
				if not Weapon or Weapon.GunStats.PreventSprint ~= false then return false end
				
			end
			
			if Weapon and Weapon.GunStats.PreventSprint then return false end
			
			Core.PreventCrouch.Sprinting = true
			
			--Core.PreventFire.Sprinting = true
			
			PU.SetPose( "Sprinting", true )
			
			PU.SetPose( "Crouching", false )
			
			PU.SetPose( "Scoping", false )
			
		end
		
	else
		
		Core.PreventCrouch.Sprinting = nil
		
		--Core.PreventFire.Sprinting = nil
		
		PU.SetPose( "Sprinting", false )
		
	end
	
end, Key = Enum.KeyCode.F, PadKey = Enum.KeyCode.ButtonL3, ToggleState = false, CanToggle = true, OffOnDeath = true, NoHandled = true }

Core.Visuals.AntiSprintShoot = Core.ClientVisuals.Event:Connect( function ( )
	
	if Core.ActualSprinting then KBU.SetToggle( "s2_Sprint", false ) end
	
end )

Core.WeaponSelected.Event:Connect( function ( StatObj, User )
	
	if not StatObj then return end
	
	local GunStats = Core.GetGunStats( StatObj )
	
	if GunStats.PreventSprint then KBU.SetToggle( "s2_Sprint", false ) end
	
	if _G.S20Config.AllowSprinting == false and GunStats.PreventSprint ~= false then KBU.SetToggle( "s2_Sprint", false ) end
	
end )

Core.WeaponDeselected.Event:Connect( function ( StatObj, User )
	
	if _G.S20Config.AllowSprinting == false then KBU.SetToggle( "s2_Sprint", false ) end
	
end )