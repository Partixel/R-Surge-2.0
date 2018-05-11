local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

local Plr = game:GetService( "Players" ).LocalPlayer

local Until

Core.Visuals.CharacterRotation = Core.ClientVisuals.Event:Connect( function ( StatObj )
	
	if _G.S20Config.AllowCharacterRotation == false then return end
	
	local Weapon = Core.GetWeapon( StatObj )
	
	local HumanoidRootPart, Humanoid = Plr.Character and Plr.Character:FindFirstChild( "HumanoidRootPart" ), Plr.Character and Plr.Character:FindFirstChildOfClass( "Humanoid" )
	
	if Weapon and HumanoidRootPart and Humanoid and Humanoid:GetState( ) ~= Enum.HumanoidStateType.Dead and not Humanoid.Sit then
		
		if not Until then
			
			Until = tick( ) + 5
			
			local Event Event = game:GetService( "RunService" ).Heartbeat:Connect( function ( )
				
				if Until < tick( ) or not Weapon.Selected then Event:Disconnect( ) Until = nil return end
				
				if not HumanoidRootPart or ( workspace.CurrentCamera.CoordinateFrame.p - workspace.CurrentCamera.Focus.p ).magnitude <= 0.55 then return end
				
				HumanoidRootPart.CFrame = CFrame.new( HumanoidRootPart.Position, Vector3.new( Core.LPlrsTarget[ 2 ].X, HumanoidRootPart.Position.Y, Core.LPlrsTarget[ 2 ].Z ) )
				
			end )
			
		else
			
			Until = tick( ) + 5
			
		end
		
	end
	
end )