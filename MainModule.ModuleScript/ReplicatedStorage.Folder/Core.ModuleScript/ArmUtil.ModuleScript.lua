local new = Instance.new

local Strs = { { "Left Shoulder", "Left Arm", "Left_Weld" }, { "Right Shoulder", "Right Arm", "Right_Weld" } }

local Strs2 = { { "LeftShoulder", "LeftUpperArm", "Left_Weld" }, { "RightShoulder", "RightUpperArm", "Right_Weld" } }

local function UnWeld( Plr, Tool )
	
	local Character = Plr.Character
	
	if Plr.Character == nil then return end
	
	local Torso = Character:FindFirstChild( "Torso" )
	
	if not Torso then
		
		Torso = Character:FindFirstChild( "UpperTorso" )
		
		for a = 1, 2 do
			
			if Character:FindFirstChild( Strs2[ a ][ 2 ] ) and Character[ Strs2[ a ][ 2 ] ]:FindFirstChild( Strs2[ a ][ 1 ] ) then
				
				Character[ Strs2[ a ][ 2 ] ][ Strs2[ a ][ 1 ] ].Part1 = Character[ Strs2[ a ][ 2 ] ]
				
				if Torso:FindFirstChild( Strs2[ a ][ 3 ] ) then
					
					Torso[ Strs2[ a ][ 3 ] ]:Destroy( )
					
				end
				
			end
			
		end
		
		return
		
	end
	
	if Torso then
		
		for a = 1, 2 do
			
			if Torso:FindFirstChild( Strs[ a ][ 1 ] ) and Character:FindFirstChild( Strs[ a ][ 2 ] ) then
				
				Torso[ Strs[ a ][ 1 ] ].Part1 = Character[ Strs[ a ][ 2 ] ]
				
				if Torso:FindFirstChild( Strs[ a ][ 3 ] ) then
					
					Torso[ Strs[ a ][ 3 ] ]:Destroy( )
					
				end
				
			end
			
		end
		
	end
	
end

local function WeldArms( Plr, Tool, CF1, CF2  )
	
	local Character = Plr.Character
	
	if Character == nil then return end
	
	local Torso = Character:FindFirstChild( "Torso" )
	
	if not Torso then
		
		Torso = Character:FindFirstChild( "UpperTorso" )
		
		for a = 1, 2 do
			
			if ( a == 1 and CF1 ) or ( a == 2 and CF2 ) then
				
				if Character:FindFirstChild( Strs2[ a ][ 2 ] ) and Character[ Strs2[ a ][ 2 ] ]:FindFirstChild( Strs2[ a ][ 1 ] ) then
					
					Character[ Strs2[ a ][ 2 ] ][ Strs2[ a ][ 1 ] ].Part1 = nil
					
					local Weld = new( "Weld" )
					
					Weld.Name = Strs2[ a ][ 3 ]
					
					Weld.Part0 = Torso
					
					Weld.Part1 = Character[ Strs2[ a ][ 2 ] ]
					
					if a == 1 then
						
						Weld.C1 = CF1
						
					else
						
						Weld.C1 = CF2
						
					end
					
					Weld.Parent = Torso
					
				end
				
			end
			
		end
		
		return
		
	end
	
	for a = 1, 2 do
		
		if ( a == 1 and CF1 ) or ( a == 2 and CF2 ) then
			
			if Torso:FindFirstChild( Strs[ a ][ 1 ] ) and Character:FindFirstChild( Strs[ a ][ 2 ] ) then
				
				Torso[ Strs[ a ][ 1 ] ].Part1 = nil
				
				local Weld = new( "Weld" )
				
				Weld.Name = Strs[ a ][ 3 ]
				
				Weld.Part0 = Torso
				
				Weld.Part1 = Character[ Strs[ a ][ 2 ] ]
				
				if a == 1 then
					
					Weld.C1 = CF1
					
				else
					
					Weld.C1 = CF2
					
				end
				
				Weld.Parent = Torso
				
			end
			
		end
		
	end
	
end

local function NewWeld( Plr, Tool, CF1  )
	
	local Character = Plr.Character
	
	if Character == nil then return end
	
	local Torso = Character:FindFirstChild( "Torso" )
	
	if not Torso then
		
		Torso = Character:FindFirstChild( "UpperTorso" )
		
		if Torso:FindFirstChild( Strs[ 2 ][ 1 ] ) and Character:FindFirstChild( Strs[ 2 ][ 2 ] ) then
			
			Torso[ Strs[ 2 ][ 1 ] ].Part1 = nil
			
			local Weld = new( "Weld" )
			
			Weld.Name = Strs[ 2 ][ 3 ]
			
			Weld.Part0 = Torso
			
			Weld.Part1 = Character[ Strs[ 2 ][ 2 ] ]
			
			Weld.C1 = CF1
			
			Weld.Parent = Torso
			
		end
		
		return
		
	end
	
	if Torso:FindFirstChild( Strs[ 1 ][ 1 ] ) and Character:FindFirstChild( Strs[ 1 ][ 2 ] ) then
		
		game["Run Service"].Stepped:Connect( function ( )
			
			if Tool:FindFirstChild( "Handle" ) and Tool.Handle:FindFirstChild( "LeftTarget" ) then
				
				local LocalTarget = ( Torso.CFrame + Torso[ Strs[ 1 ][ 1 ] ].C0.p ):pointToObjectSpace( Tool.Handle.LeftTarget.WorldPosition )
				
				Torso[ Strs[ 1 ][ 1 ] ].Transform = CFrame.new( Vector3.new( ), LocalTarget )
				
			end
			
		end )
		
	end
	
end

return function ( Plr, Tool, CF1, CF2 )
	
	if Tool:WaitForChild( "Handle" ):FindFirstChild( "LeftTarget" ) then
		
		Tool.Equipped:Connect( function ( ) NewWeld( Plr, Tool, CF2 ) end )
		
		return
		
	end
	
	Tool.Equipped:Connect( function ( ) WeldArms( Plr, Tool, CF1, CF2 ) end )
	
	Tool.Unequipped:Connect( function ( ) UnWeld( Plr, Tool, CF1, CF2) end )
	
end