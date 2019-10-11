local Players = game:GetService( "Players" )
local Plr = Players.LocalPlayer

local TweenService = game:GetService( "TweenService" )

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local Root, Neck, R6
function HandleCharacter( Char )
	
	Root, Neck = Char:WaitForChild( "HumanoidRootPart" ), Char:FindFirstChild( "Neck", true )
	
	while not Neck do
		
		wait( )
		
		Neck = Char:FindFirstChild( "Neck", true )
		
	end
	
	while not Char:FindFirstChildOfClass( "Humanoid" ) do
		
		wait( )
		
	end
	
	R6 = Char:FindFirstChildOfClass( "Humanoid" ).RigType == Enum.HumanoidRigType.R6
	
end

HandleCharacter(Plr.Character or Plr.CharacterAdded:Wait())
Plr.CharacterAdded:Connect(HandleCharacter)

local HeadRotRemote = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "HeadRot" )

HeadRotRemote.OnClientEvent:Connect(function(Rotations)
	if Core.EnabledFeatures["HeadRotation"] then
		for _, Rot in ipairs(Rotations) do
			local Neck = Rot[ 1 ].Character and Rot[ 1 ].Character:FindFirstChild( "Neck", true )
			if Neck then
				TweenService:Create( Neck, TweenInfo.new( 1/20, Enum.EasingStyle.Linear ), { C0 = Rot[ 2 ] } ):Play( )
			end
		end
	end
end)

function UpdateHead( )
	if Root and Neck and workspace.CurrentCamera.CameraSubject and workspace.CurrentCamera.CameraSubject:IsA( "Humanoid" ) and workspace.CurrentCamera.CameraSubject.Parent == Plr.Character then
		
		local CameraDirection = Root.CFrame:toObjectSpace( workspace.CurrentCamera.CFrame ).lookVector.unit
		
		if R6 then
			
			Neck.C0 = CFrame.new(Neck.C0.p) * CFrame.Angles(0, -math.asin(CameraDirection.x), 0) * CFrame.Angles(-math.pi/2 + math.asin(CameraDirection.y), 0, math.pi)
			
		else
			
			Neck.C0 = CFrame.new(Neck.C0.p) * CFrame.Angles(math.asin(CameraDirection.y), -math.asin(CameraDirection.x), 0)
			
		end
		
	end
	
	for _, Plr in ipairs( Players:GetPlayers( ) ) do
		
		if Plr.Character and Plr.Character:FindFirstChild( "Head" ) then
			
			local Humanoid = Plr.Character:FindFirstChildOfClass( "Humanoid" )
			
			if Humanoid and Humanoid.Health ~= 0 then
				
				Plr.Character.Head.CanCollide = false
				
			end
			
		end
		
	end

end

local Event
Core.SetFeatureCallback("HeadRotation", function(Enabled)
	if Enabled then
		Event = game:GetService("RunService").Stepped:Connect(UpdateHead)
	elseif Event then
		Event:Disconnect()
		Event = nil
		
		for _, Plr in ipairs(Players:GetPlayers()) do
			local Neck = Plr.Character and Plr.Character:FindFirstChild( "Neck", true )
			if Neck then
				Neck.C0 = Neck.Parent.Name == "Torso" and CFrame.new(Neck.C0.p) * CFrame.Angles(-math.pi/2, 0, math.pi) or CFrame.new(Neck.C0.p)
			end
		end
	end
end)
Core.SetFeatureEnabled("HeadRotation", true, true)

local Menu = require(game:GetService("ReplicatedStorage"):WaitForChild("MenuLib"):WaitForChild("Performance"))
Menu.Settings[#Menu.Settings + 1] = {Name = "HeadRotation", Text = "Head Rotation", Default = true, Update = function(Options, Val)
	Core.SetFeatureEnabled("HeadRotation", Val)
end}

if Menu.SavedSettings and Menu.SavedSettings["HeadRotation"] == nil then
	Menu.SavedSettings["HeadRotation"] = true
end

coroutine.wrap(Menu.Settings[#Menu.Settings].Update)(Menu, Menu.SavedSettings["HeadRotation"])

if Menu.Tabs[1].Invalidate then
	Menu.Tabs[1]:Invalidate()
end

local Last

while wait( 1/20 ) do
	
	if Neck and Last ~= Neck.C0 then
		
		HeadRotRemote:FireServer( Neck.C0 )
		
		Last = Neck.C0
		
	end
	
end