local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

function GetArmWelds( Char )
	
	if Char:FindFirstChild( "Torso" ) then
		
		return Char.Torso:FindFirstChild( "Left Shoulder" ), Char.Torso:FindFirstChild( "Right Shoulder" )
		
	else
		
		return Char:FindFirstChild( "LeftUpperArm" ) and Char.LeftUpperArm:FindFirstChild( "LeftShoulder" ), Char:FindFirstChild( "RightUpperArm" ) and Char.RightUpperArm:FindFirstChild( "RightShoulder" ), Char:FindFirstChild( "LeftLowerArm" ) and Char.LeftLowerArm:FindFirstChild( "LeftElbow" ), Char:FindFirstChild( "RightLowerArm" ) and Char.RightLowerArm:FindFirstChild( "RightElbow" )
		
	end
	
end

local Welds = setmetatable( { }, { __mode = "k" } )

local function UnWeld( Plr, Tool )
	
	if Welds[ Plr ] then
	
		for a, b in pairs( Welds[ Plr ] ) do
			
			b.Part1 = a.Part1
			
			a:Destroy( )
			
		end
		
		Welds[ Plr ] = nil
		
	end
	
end

local function WeldArms( Plr, Tool, CF1, CF2  )
	
	if Plr.Character == nil then return end
	
	local Char = Plr.Character
	
	local LS, RS, LE, RE = GetArmWelds( Char )
	
	Welds[ Plr ] = { }
	
	if LS then
		
		local Weld = Instance.new( "Weld" )
		
		Weld.Name = "ArmWeld"
		
		Weld.Part0 = LS.Part0
		
		Weld.Part1 = LS.Part1
		
		LS.Part1 = nil
		
		--Weld.C0 = LS.C0
		
		Weld.C1 = CF1
		
		Welds[ Plr ][ Weld ] = LS
		
		Weld.Parent = LS.Parent
		
	end
	
	if RS then
		
		local Weld = Instance.new( "Weld" )
		
		Weld.Name = "ArmWeld"
		
		Weld.Part0 = RS.Part0
		
		Weld.Part1 = RS.Part1
		
		RS.Part1 = nil
		
		--Weld.C0 = RS.C0
		
		Weld.C1 = CF2
		
		Welds[ Plr ][ Weld ] = RS
		
		Weld.Parent = RS.Parent
		
	end
	
	if LE then
		
		local Weld = Instance.new( "Weld" )
		
		Weld.Name = "ArmWeld"
		
		Weld.Part0 = LE.Part0
		
		Weld.Part1 = LE.Part1
		
		LE.Part1 = nil
		
		Weld.C0 = LE.C0
		
		Weld.C1 = LE.C1
		
		Welds[ Plr ][ Weld ] = LE
		
		Weld.Parent = LE.Parent
		
	end
	
	if RE then
		
		local Weld = Instance.new( "Weld" )
		
		Weld.Name = "ArmWeld"
		
		Weld.Part0 = RE.Part0
		
		Weld.Part1 = RE.Part1
		
		RE.Part1 = nil
		
		Weld.C0 = RE.C0
		
		Weld.C1 = RE.C1
		
		Welds[ Plr ][ Weld ] = RE
		
		Weld.Parent = RE.Parent
		
	end
	
end

local function NewWeld( Plr, Tool, CF1 )
	
	local Char = Plr.Character
	
	if Char == nil then return end
	
	local LS, RS, LE, RE = GetArmWelds( Char )
	
	local Weld = Instance.new( "Weld" )
	
	Weld.Name = "ArmWeld"
	
	Weld.Part0 = LS.Part0
	
	Weld.Part1 = LS.Part1
	
	LS.Part1 = nil
	
	Weld.C0 = LS.C0
	
	Weld.C1 = LS.C1
	
	Weld.Parent = LS.Parent
	
	local Orig = Weld.C0
	
	game["Run Service"].Stepped:Connect( function ( )
		
		if Tool:FindFirstChild( "Handle" ) and Tool.Handle:FindFirstChild( "LeftTarget" ) then
			
			Weld.C0 = CFrame.new( Orig.p, Orig.p + LS.Part0.CFrame:pointToObjectSpace( Tool.Handle.LeftTarget.WorldPosition ) ) CFrame.Angles( Orig:ToEulerAnglesXYZ( ) )
			
		end
		
	end )
	
end

Core.WeaponSelected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon then
		local LeftWeld, RightWeld = Weapon.LeftWeld, Weapon.RightWeld
		if LeftWeld or RightWeld then
			WeldArms(Weapon.User, StatObj.Parent, LeftWeld, RightWeld)
		end
	end
end)

Core.WeaponDeselected.Event:Connect(function(StatObj)
	local Weapon = Core.GetWeapon(StatObj)
	if Weapon and (Weapon.LeftWeld or Weapon.RightWeld) then
		UnWeld(Weapon.User, StatObj.Parent)
	end
end)