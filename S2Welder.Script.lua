local new, inverse = Instance.new, CFrame.new( ).inverse

function Weld( Tool )
	
	if not Tool:FindFirstChild( "GunStat" ) then return end
	
	local Handle = Tool:FindFirstChild( "Handle" )
	
	if not Handle then return end
	
	for _, Weld in ipairs( Handle:GetChildren( ) ) do
		if Weld:IsA( "Weld" ) then Weld:Destroy( ) end
	end
	
	for _, Obj in ipairs( Tool:GetDescendants( ) ) do
		
		if Obj:IsA( "BasePart" ) and Obj.Parent == Tool then
			
			Obj.CustomPhysicalProperties = PhysicalProperties.new( 0, 0, 0, 0, 0 )
			
			Obj.CanCollide = false
			
			Obj.Anchored = false
			
			if Obj.Name ~= "Handle" then
				
				local Weld = new( "Weld" )
				
				Weld.Part0 = Handle
				
				Weld.Part1 = Obj
				
				Weld.C1 = inverse( Obj.CFrame ) * Handle.CFrame
				
				Weld.Parent = Handle
				
			end
			
		elseif Obj:IsA( "Model" ) then
			
			local Main = Obj.PrimaryPart
			
			for _, Inst in ipairs( Obj:GetChildren( ) ) do
				
				if Inst:IsA( "BasePart" ) then
					
					Inst.CustomPhysicalProperties = PhysicalProperties.new( 0, 0, 0, 0, 0 )
					
					Inst.CanCollide = false
					
					Inst.Anchored = false
					
					if Inst.Name ~= "Handle" then
						
						local Weld = new( "Weld" )
						
						Weld.Part1 = Inst
						
						if Inst == Main then
							
							Weld.Part0 = Handle
							
							Weld.C1 = inverse( Inst.CFrame ) * Handle.CFrame
							
							Weld.Parent = Handle
							
						else
							
							Weld.Part0 = Main
							
							Weld.C1 = inverse( Inst.CFrame ) * Main.CFrame
							
							Weld.Parent = Main
							
						end
						
					end
					
				end
				
			end
			
		end
		
	end
	
end

plugin:CreateToolbar( "S2 Welder" ):CreateButton( "Weld", "Press me", "" ).Click:Connect( function ( )
	
	for _, Obj in ipairs( game.Selection:Get( ) ) do
		
		Weld( Obj )
		
	end
	
end )