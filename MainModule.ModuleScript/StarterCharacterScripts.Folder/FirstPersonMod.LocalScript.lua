function HandlePart( Part )
	
	local Event Event = Part:GetPropertyChangedSignal( "LocalTransparencyModifier" ):Connect( function ( )
		
		if not Part:IsDescendantOf( script.Parent ) then Event:Disconnect( ) return end
		
		Part.LocalTransparencyModifier = 0
		
	end )
	
end

local Handled = setmetatable( { }, { __mode = "k" } )

script.Parent.DescendantAdded:Connect( function ( Obj )
	
	if not Handled[ Obj ] and Obj:IsA( "BasePart" ) and ( Obj.Name:lower( ):find( "leg" ) or Obj.Name:lower( ):find( "arm" ) ) then
		
		Handled[ Obj ] = true
		
		HandlePart( Obj )
		
	end
	
end )

local Kids = script.Parent:GetDescendants( )

for a = 1, #Kids do
	
	if not Handled[ Kids[ a ] ] and Kids[ a ]:IsA( "BasePart" ) and ( Kids[ a ].Name:lower( ):find( "leg" ) or Kids[ a ].Name:lower( ):find( "arm" ) ) then
		
		Handled[ Kids[ a ] ] = true
		
		HandlePart( Kids[ a ] )
		
	end
	
end