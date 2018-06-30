if script.Parent.Name ~= "PlayerScripts" then
	
	wait( )
	
	script.Parent = script.Parent.Parent:WaitForChild( "PlayerScripts" )
	
end

local Plr = game:GetService( "Players" ).LocalPlayer

local TweenService = game:GetService( "TweenService" )

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

local KBU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )

local PU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "PoseUtil" ) )

local AnimationA = {
	Left = {
		CFrame.new(-1, -1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
		CFrame.new(-0.5, 1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0)
	},
	Right = {
		CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
		CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0)
	}
}

local AnimationB = {
	Left = {
		CFrame.new(-1, -1.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
		CFrame.new(-0.5, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0) * CFrame.Angles(math.rad(20), 0, math.rad(-90))
	},
	Right = {
		CFrame.new(1, 0, -0.6, 0, 0, 1, 0, 1, 0, -1, -0, -0) * CFrame.Angles(math.rad(2), math.rad(20), 0),
		CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0)
	}
}

local WSMod, JPMod

function lerp(a, b, t)
    return a * (1-t) + (b*t)
end

PU.Watch( "Crouching", "Crouch", function ( NPlr, State, Offset )
	
	if NPlr == Plr then
		
		local Hum = NPlr.Character and NPlr.Character:FindFirstChild( "Humanoid" )
		
		if Hum then
			
			if WSMod then WSMod:Destroy( ) end
			
			if JPMod then JPMod:Destroy( ) end
			
			if State then
				
				WSMod = Instance.new( "NumberValue" )
				
				WSMod.Name = "WalkSpeedModifier"
				
				WSMod.Value = _G.S20Config.CrouchSpeedMultiplier or 0.9
				
				JPMod = Instance.new( "NumberValue" )
				
				JPMod.Name = "JumpPowerModifier"
				
				JPMod.Value = _G.S20Config.CrouchJumpPowerMultiplier or 0.6
				
				WSMod.Parent = Hum
				
				JPMod.Parent = Hum
				
			else
				
				WSMod, JPMod = nil, nil
				
			end
			
		end
		
	end
	
	if NPlr.Character then
		
		local Torso = NPlr.Character:FindFirstChild("Torso")
		
		local Hum = NPlr.Character:FindFirstChild( "Humanoid" )
		
		if Torso and Hum then
			
			local Time
			
			local LeftHip = Torso:FindFirstChild("Left Hip")
			
			if LeftHip then
				
				local TargetA, TargetB = State and AnimationB.Left[ 1 ] or AnimationA.Left[ 1 ], State and AnimationB.Left[ 2 ] or AnimationA.Left[ 2 ]
				
				Time =  LeftHip.C0:toObjectSpace( TargetA ).p.magnitude
				
				local Perc = math.min( Offset / Time, 1 )
				
				LeftHip.C0, LeftHip.C1 = LeftHip.C0:lerp( TargetA, Perc ), LeftHip.C1:lerp( TargetB, Perc )
				
				if Perc < 1 then
					
					TweenService:Create( LeftHip, TweenInfo.new( Time - Offset ), { C0 = TargetA, C1 = TargetB } ):Play( )
					
				end
				
			end
			
			local RightHip = Torso:FindFirstChild("Right Hip")
			
			if RightHip then
				
				local TargetA, TargetB = State and AnimationB.Right[ 1 ] or AnimationA.Right[ 1 ], State and AnimationB.Right[ 2 ] or AnimationA.Right[ 2 ]
				
				Time = Time or RightHip.C0:toObjectSpace( TargetA ).p.magnitude
				
				local Perc = math.min( Offset / Time, 1 )
				
				RightHip.C0, RightHip.C1 = RightHip.C0:lerp( TargetA, Perc ), RightHip.C1:lerp( TargetB, Perc )
				
				if Perc < 1 then
					
					TweenService:Create( RightHip, TweenInfo.new( Time - Offset ), { C0 = TargetA, C1 = TargetB } ):Play( )
					
				end
				
			end
			
			local Perc = math.min( Offset / ( Time or 1 ), 1 )
			
			Hum.HipHeight = lerp( Hum.HipHeight, State and -1 or 0, Perc )
			
			if Perc < 1 then
				
				TweenService:Create( Hum, TweenInfo.new( ( Time or 1 ) - Offset ), { HipHeight = State and -1 or 0 } ):Play( )
				
			end
			
		end
		
	end
	
end )

Core.PreventCrouch = { }

function Prevented( )
	
	local Found = false
	
	for a, b in pairs( Core.PreventCrouch ) do
		
		Found = true
		
		break
		
	end
	
	return Found
	
end

KBU.AddBind{ Name = "s2_Crouch", Callback = function ( Began, Died )
	
	if Died then return end
	
	if Prevented( ) then return false end
	
	if Began then
		
		local Weapon = Core.GetSelectedWeapon( Plr )
		
		if _G.S20Config.AllowCrouching == false then
			
			if not Weapon or Weapon.GunStats.PreventCrouch ~= false then return false end
			
		end
		
		if Weapon and Weapon.GunStats.PreventCrouch then return false end
		
		PU.SetPose( "Crouching", true )
		
	else
		
		PU.SetPose( "Crouching", false )
		
	end
	
end, Key = Enum.KeyCode.C, PadKey = Enum.KeyCode.ButtonL3, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true }

Core.WeaponSelected.Event:Connect( function ( StatObj, User )
	
	if not StatObj then return end
	
	local GunStats = Core.GetGunStats( StatObj )
	
	if GunStats.PreventCrouch then KBU.SetToggle( "s2_Crouch", false ) end
	
	if _G.S20Config.AllowCrouching == false and GunStats.PreventCrouch ~= false then
		
		KBU.SetToggle( "s2_Crouch", false )
		
	end
	
end )

Core.WeaponDeselected.Event:Connect( function ( StatObj, User )
	
	if _G.S20Config.AllowCrouching == false then KBU.SetToggle( "s2_Crouch", false ) end
	
end )