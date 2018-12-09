local Plr = game:GetService( "Players" ).LocalPlayer

local TweenService = game:GetService( "TweenService" )

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

local KBU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )

local PU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "PoseUtil" ) )

local Animation = { CFrame.new( 0, -0.5, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0 ) * CFrame.Angles( 0, math.rad( 5 ), math.rad( 15 ) ), CFrame.new( 0, -0.5, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0 ) }

function lerp(a, b, t)
    return a * (1-t) + (b*t)
end

function GetDifference( C1, C2 )
	
	return ( Vector3.new( C1:toEulerAnglesXYZ( ) ) - Vector3.new( C2:toEulerAnglesXYZ( ) ) ).magnitude
	
end

PU.Watch( "Inspecting", "Inpsect", function ( NPlr, State, Offset )
	
	if NPlr == Plr then
		
		local Neck = NPlr.Character and NPlr.Character:FindFirstChild( "Torso" ) and NPlr.Character.Torso:FindFirstChild( "Neck" )
		
		if Neck then
			
			local Target = State and Animation[ 1 ] or Animation[ 2 ]
			
			local Time = GetDifference( Neck.C1, Target ) --Neck.C1:toObjectSpace( Target ).p.magnitude
			print(Time)
			local Perc = math.min( Offset / Time, 1 )
			
			Neck.C1 = Neck.C1:lerp( Target, Perc )
			
			TweenService:Create( Neck, TweenInfo.new( Time - Offset ), { C1 = Target } ):Play( )
			
		end
		
	end
	
end )

KBU.AddBind( "Inspect", function ( Began, Died )
	
	if Died then return end
	
	if Began then
		
		local Weapon = Core.GetSelectedWeapon( Plr )
		
		if _G.S20Config.AllowInspecting == false or not Weapon or Weapon.AllowInspecting == false then return false end
		
		PU.SetPose( "Inspecting", true )
		
	else
		
		PU.SetPose( "Inspecting", false )
		
	end
	
end, Enum.KeyCode.E, Enum.KeyCode.ButtonL3, nil, true, true, true, nil, true )

Core.WeaponSelected.Event:Connect( function ( StatObj, User )
	
	KBU.SetToggle( "Inspect", false )
	
end )

Core.WeaponDeselected.Event:Connect( function ( StatObj, User )
	
	KBU.SetToggle( "Inspect", false )
	
end )