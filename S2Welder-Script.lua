local new, inverse = Instance.new, CFrame.new( ).inverse

function Weld( Tool )
	
	if not Tool:FindFirstChild( "GunStat" ) then return end
	
	local Handle = Tool:FindFirstChild( "Handle" )
	
	if not Handle then return end
	
	local Parts = Tool:GetDescendants( )
	
	for a = 1, #Parts do
		
		local Part = Parts[ a ]
		
		if Part:IsA( "BasePart" ) and Part.Parent == Tool then
			
			Part.CustomPhysicalProperties = PhysicalProperties.new( 0, 0, 0, 0, 0 )
			
			Part.CanCollide = false
			
			Part.Anchored = false
			
			if Part.Name ~= "Handle" then
				
				local Weld = new( "Weld" )
				
				Weld.Part0 = Handle
				
				Weld.Part1 = Part
				
				Weld.C1 = inverse( Part.CFrame ) * Handle.CFrame
				
				Weld.Parent = Handle
				
			end
			
		elseif Part:IsA( "Model" ) then
			
			local SubParts = Part:GetChildren( )
			
			local Main = Part.PrimaryPart
			
			for b = 1, #SubParts do
				
				Part = SubParts[ b ]
				
				if Part:IsA( "BasePart" ) then
					
					Part.CustomPhysicalProperties = PhysicalProperties.new( 0, 0, 0, 0, 0 )
					
					Part.CanCollide = false
					
					Part.Anchored = false
					
					if Part.Name ~= "Handle" then
						
						local Weld = new( "Weld" )
						
						Weld.Part1 = Part
						
						if Part == Main then
							
							Weld.Part0 = Handle
							
							Weld.C1 = inverse( Part.CFrame ) * Handle.CFrame
							
							Weld.Parent = Handle
							
						else
							
							Weld.Part0 = Main
							
							Weld.C1 = inverse( Part.CFrame ) * Main.CFrame
							
							Weld.Parent = Main
							
						end
						
					end
					
				end
				
			end
			
		end
		
	end
	
end

plugin:CreateToolbar( "S2 Welder" ):CreateButton( "Weld", "Press me", "" ).Click:Connect( function ( )
	
	local Selection = game.Selection:Get( )
	
	for a = 1, #Selection do
		
		Weld( Selection[ a ] )
		
	end
	
end )