local InteractRemote = Instance.new( "RemoteEvent" )

InteractRemote.Name = "InteractRemote"

InteractRemote.OnServerEvent:Connect( function ( Plr, InteractObj, Start, Subject )
	
	if not InteractObj then return end
	
	local Humanoid = Plr.Character and Plr.Character:FindFirstChildOfClass( "Humanoid" )
	
	Subject = Subject or ( Humanoid and Humanoid.RootPart )
	
	if InteractObj:FindFirstChild( "CharacterOny" ) and Subject ~= Humanoid.RootPart then return end
	
	if not InteractObj:FindFirstChild( "Disabled" ) and Humanoid and Humanoid:GetState( ) ~= Enum.HumanoidStateType.Dead and Subject and Subject:IsDescendantOf( Plr.Character ) and ( (InteractObj.Parent:IsA("BasePart") and InteractObj.Parent or InteractObj:FindFirstChild("MainPart") and InteractObj.MainPart.Value or InteractObj.Parent.PrimaryPart).Position - Subject.Position ).magnitude <= ( InteractObj:FindFirstChild( "Distance" ) and InteractObj.Distance.Value or 16 ) then
		
		if InteractObj:FindFirstChild( "Cooldown" ) and InteractObj.Cooldown.Value > 0 then
			
			local Disabled = Instance.new( "NumberValue" )
			
			Disabled.Name = "Disabled"
			
			Disabled.Value = Start + InteractObj.Cooldown.Value
			
			Disabled.Parent = InteractObj
			
			delay( InteractObj.Cooldown.Value, function ( )
				
				if Disabled and Disabled.Parent then
					
					Disabled:Destroy( )
					
				end
				
			end )
			
		end
			
		InteractObj:Fire( Plr )
		
	end
	
end )

InteractRemote.Parent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )