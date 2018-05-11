local new = Instance.new

function GetArmWelds( Char )
	
	if Char:FindFirstChild( "Torso" ) then
		
		return Char.Torso:FindFirstChild( "Left Shoulder" ), Char.Torso:FindFirstChild( "Right Shoulder" )
		
	else
		
		return Char:FindFirstChild( "LeftUpperArm" ) and Char.LeftUpperArm:FindFirstChild( "LeftShoulder" ), Char:FindFirstChild( "RightUpperArm" ) and Char.RightUpperArm:FindFirstChild( "RightShoulder" ), Char:FindFirstChild( "LeftLowerArm" ) and Char.LeftLowerArm:FindFirstChild( "LeftElbow" ), Char:FindFirstChild( "RightLowerArm" ) and Char.RightLowerArm:FindFirstChild( "RightElbow" )
		
	end
	
end

local Welds = { }

local function UnWeld( Plr, Tool )
	
	for a, b in pairs( Welds ) do
		
		b.Part1 = a.Part1
		
		a:Destroy( )
		
		Welds[ a ] = nil
		
	end
	
end

local function WeldArms( Plr, Tool, CF1, CF2  )
	
	if Plr.Character == nil then return end
	
	local Char = Plr.Character
	
	local LS, RS, LE, RE = GetArmWelds( Char )
	
	if LS then
		
		local Weld = new( "Weld" )
		
		Weld.Name = "ArmWeld"
		
		Weld.Part0 = LS.Part0
		
		Weld.Part1 = LS.Part1
		
		LS.Part1 = nil
		
		--Weld.C0 = LS.C0
		
		Weld.C1 = CF1
		
		Welds[ Weld ] = LS
		
		Weld.Parent = Tool.Handle
		
	end
	
	if RS then
		
		local Weld = new( "Weld" )
		
		Weld.Name = "ArmWeld"
		
		Weld.Part0 = RS.Part0
		
		Weld.Part1 = RS.Part1
		
		RS.Part1 = nil
		
		--Weld.C0 = RS.C0
		
		Weld.C1 = CF2
		
		Welds[ Weld ] = RS
		
		Weld.Parent = Tool.Handle
		
	end
	
	if LE then
		
		local Weld = new( "Weld" )
		
		Weld.Name = "ArmWeld"
		
		Weld.Part0 = LE.Part0
		
		Weld.Part1 = LE.Part1
		
		LE.Part1 = nil
		
		Weld.C0 = LE.C0
		
		Weld.C1 = LE.C1
		
		Welds[ Weld ] = LE
		
		Weld.Parent = Tool.Handle
		
	end
	
	if RE then
		
		local Weld = new( "Weld" )
		
		Weld.Name = "ArmWeld"
		
		Weld.Part0 = RE.Part0
		
		Weld.Part1 = RE.Part1
		
		RE.Part1 = nil
		
		Weld.C0 = RE.C0
		
		Weld.C1 = RE.C1
		
		Welds[ Weld ] = RE
		
		Weld.Parent = Tool.Handle
		
	end
	
end

return function ( Plr, Tool, CF1, CF2 )
	
	Tool.Equipped:Connect( function ( ) WeldArms( Plr, Tool, CF1, CF2 ) end )
	
	Tool.Unequipped:Connect( function ( ) UnWeld( Plr, Tool, CF1, CF2) end )
	
end