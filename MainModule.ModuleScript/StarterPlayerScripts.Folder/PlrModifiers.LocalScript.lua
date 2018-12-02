function ApplyModifier( Obj, Property, Normals, Events, First )
	
	local Modifier, PropertyMod = 1, Property .. "Modifier"
	
	local Kids = Obj:GetChildren( )
	
	for a = 1, #Kids do
		
		if Kids[ a ].Name == PropertyMod then
			
			Modifier = Modifier * Kids[ a ].Value
			
			if First then
				
				Kids[ a ]:GetPropertyChangedSignal( "Value" ):Connect( function ( )
					
					ApplyModifier( Obj, Property, Normals, Events )
					
				end )
				
			end
			
		end
		
	end
	
	if Events[ Property ] then
		
		Events[ Property ]:Disconnect( )
		
	end
	
	Obj[ Property ] = Normals[ Property ] * Modifier
	
	Events[ Property ] = Obj:GetPropertyChangedSignal( Property ):Connect( function ( )
		
		Normals[ Property ] = Obj[ Property ]
		
		ApplyModifier( Obj, Property, Normals, Events )
		
	end )
	
end

function HandleProperties( Obj, Properties )
	
	local Normals, Events = { }, { }
	
	for a = 1, #Properties do
		
		Normals[ Properties[ a ] ] = Obj[ Properties[ a ] ]
		
		ApplyModifier( Obj, Properties[ a ], Normals, Events, true )
		
	end
	
	Obj.ChildAdded:Connect( function ( Child )
		
		local Property = Child.Name:sub( 1, -9 )
		
		if Child.Name:sub( -8 ) == "Modifier" and Normals[ Property ] then
			
			Child:GetPropertyChangedSignal( "Value" ):Connect( function ( )
				
				ApplyModifier( Obj, Property, Normals, Events )
				
			end )
			
			ApplyModifier( Obj, Property, Normals, Events )
			
		end
		
	end )
	
	Obj.ChildRemoved:Connect( function ( Child )
		
		if Child.Name:sub( -8 ) == "Modifier" and Normals[ Child.Name:sub( 1, -9 ) ] then
			
			ApplyModifier( Obj, Child.Name:sub( 1, -9 ), Normals, Events )
			
		end
		
	end )
	
end

function HandleChar( Char )
	print(Char)
	local Hum = Char:FindFirstChildOfClass( "Humanoid" )
	
	while not Hum do
		
		local Obj = Char.ChildAdded:wait( )
		
		if Obj:IsA( "Humanoid" ) then Hum = Obj end
		
	end
	
	HandleProperties( Hum, { "MaxHealth", "WalkSpeed", "JumpPower" } )
	
end

HandleChar( game:GetService( "Players" ).LocalPlayer.Character or game:GetService( "Players" ).LocalPlayer.CharacterAdded:wait( ) )

game:GetService( "Players" ).LocalPlayer.CharacterAdded:Connect( HandleChar )

workspace:GetPropertyChangedSignal( "CurrentCamera" ):Connect( function ( )
	
	HandleProperties( workspace.CurrentCamera, { "FieldOfView" } )
	
end )

HandleProperties( workspace.CurrentCamera, { "FieldOfView" } )