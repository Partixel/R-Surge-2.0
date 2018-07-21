local Handled = setmetatable( { }, { __mode = "k" } )

function HandlePart( Part )
	
	if Part:IsA( "BasePart" ) and ( Part.Name:lower( ):find( "leg" ) or Part.Name:lower( ):find( "arm" ) or Part.Name == "LeftHand" or Part.Name == "RightHand" or Part.Name == "LeftFoot" or Part.Name == "RightFoot" ) then
		
		Handled[ Part ] = true
		
		local Event Event = Part:GetPropertyChangedSignal( "LocalTransparencyModifier" ):Connect( function ( )
			
			if not Part:IsDescendantOf( script.Parent ) then Event:Disconnect( ) return end
			
			Part.LocalTransparencyModifier = 0
			
		end )
		
	end
	
end

script.Parent.DescendantAdded:Connect( function ( Obj )
	
	if not Handled[ Obj ] then
		
		HandlePart( Obj )
		
	end
	
end )

local Kids = script.Parent:GetDescendants( )

for a = 1, #Kids do
	
	if not Handled[ Kids[ a ] ] then
		
		HandlePart( Kids[ a ] )
		
	end
	
end