function HandlePart( Part )
	
	local Event Event = Part:GetPropertyChangedSignal( "LocalTransparencyModifier" ):Connect( function ( )
		
		if not Part:IsDescendantOf( script.Parent ) then Event:Disconnect( ) return end
		
		local c1 = Part.CFrame * CFrame.new(Part.Size.X / 2, Part.Size.Y / 2, Part.Size.Z / 2)
		local c2 = Part.CFrame * CFrame.new(-Part.Size.X / 2, Part.Size.Y / 2, Part.Size.Z / 2)
		local c3 = Part.CFrame * CFrame.new(-Part.Size.X / 2, -Part.Size.Y / 2, Part.Size.Z / 2)
		local c4 = Part.CFrame * CFrame.new(-Part.Size.X / 2, -Part.Size.Y / 2, -Part.Size.Z / 2)
		local c5 = Part.CFrame * CFrame.new(Part.Size.X / 2, -Part.Size.Y / 2, -Part.Size.Z / 2)
		local c6 = Part.CFrame * CFrame.new(Part.Size.X / 2, Part.Size.Y / 2, -Part.Size.Z / 2)
		local c7 = Part.CFrame * CFrame.new(Part.Size.X / 2, -Part.Size.Y / 2, Part.Size.Z / 2)
		local c8 = Part.CFrame * CFrame.new(-Part.Size.X / 2, Part.Size.Y / 2, -Part.Size.Z / 2)
		
		if math.max( c1.Y, c2.Y, c3.Y, c4.Y, c5.Y, c6.Y, c7.Y, c8.Y ) - 0.15 < workspace.CurrentCamera.Focus.Y then
			
			Part.LocalTransparencyModifier = 0
			
		end
		
	end )
	
end

script.Parent.DescendantAdded:Connect( function ( Obj )
	
	if Obj:IsA( "BasePart" ) then
		
		HandlePart( Obj )
		
	end
	
end )

local Kids = script.Parent:GetDescendants( )

for a = 1, #Kids do
	
	if Kids[ a ]:IsA( "BasePart" ) then
		
		HandlePart( Kids[ a ] )
		
	end
	
end