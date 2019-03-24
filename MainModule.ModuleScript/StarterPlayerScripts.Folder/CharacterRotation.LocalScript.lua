local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

local Plr = game:GetService( "Players" ).LocalPlayer

local Until

Core.PreventCharacterRotation = { }

Core.Visuals.CharacterRotation = Core.ClientVisuals.Event:Connect( function ( StatObj )
	
	if _G.S20Config.AllowCharacterRotation == false then return end
	
	local Weapon = Core.GetWeapon( StatObj )
	
	local HumanoidRootPart, Humanoid = Plr.Character and Plr.Character:FindFirstChild( "HumanoidRootPart" ), Plr.Character and Plr.Character:FindFirstChildOfClass( "Humanoid" )
	
	local ValidState = Humanoid and ( Humanoid:GetState( ) == Enum.HumanoidStateType.FallingDown or Humanoid:GetState( ) == Enum.HumanoidStateType.Flying or Humanoid:GetState( ) == Enum.HumanoidStateType.Freefall or Humanoid:GetState( ) == Enum.HumanoidStateType.Jumping or Humanoid:GetState( ) == Enum.HumanoidStateType.Landed or Humanoid:GetState( ) == Enum.HumanoidStateType.Running or Humanoid:GetState( ) == Enum.HumanoidStateType.RunningNoPhysics or Humanoid:GetState( ) == Enum.HumanoidStateType.StrafingNoPhysics )
	
	if Weapon and HumanoidRootPart and ValidState then
		
		if not Until then
			
			Until = tick( ) + 5
			
			local Event Event = game:GetService( "RunService" ).Heartbeat:Connect( function ( )
				
				if Until < tick( ) or not Core.Selected[ Weapon.User ] or not Core.Selected[ Weapon.User ][ Weapon ] then Event:Disconnect( ) Until = nil return end
				
				if not HumanoidRootPart or HumanoidRootPart.Anchored or ( workspace.CurrentCamera.CoordinateFrame.p - workspace.CurrentCamera.Focus.p ).magnitude <= 0.55 then return end
				
				if next( Core.PreventCharacterRotation ) then return end
				
				ValidState = Humanoid and ( Humanoid:GetState( ) == Enum.HumanoidStateType.FallingDown or Humanoid:GetState( ) == Enum.HumanoidStateType.Flying or Humanoid:GetState( ) == Enum.HumanoidStateType.Freefall or Humanoid:GetState( ) == Enum.HumanoidStateType.Jumping or Humanoid:GetState( ) == Enum.HumanoidStateType.Landed or Humanoid:GetState( ) == Enum.HumanoidStateType.Running or Humanoid:GetState( ) == Enum.HumanoidStateType.RunningNoPhysics or Humanoid:GetState( ) == Enum.HumanoidStateType.StrafingNoPhysics )
				
				if not ValidState then return end
				
				HumanoidRootPart.CFrame = CFrame.new( HumanoidRootPart.Position, Vector3.new( Core.LPlrsTarget[ 2 ].X, HumanoidRootPart.Position.Y, Core.LPlrsTarget[ 2 ].Z ) )
				
			end )
			
		else
			
			Until = tick( ) + 5
			
		end
		
	end
	
end )