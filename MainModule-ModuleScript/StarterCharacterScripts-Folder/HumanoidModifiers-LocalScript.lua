local Hum = script.Parent:FindFirstChildOfClass( "Humanoid" )

while not Hum do wait( ) Hum = script.Parent:FindFirstChildOfClass( "Humanoid" ) end

local Types = { MaxHealthModifier = "MaxHealth", WalkSpeedModifier = "WalkSpeed", JumpPowerModifier = "JumpPower" }

local Normals = { }

for a, b in pairs( Types ) do
	
	Normals[ a ] = Hum[ b ]
	
end

local Event, Changed

local function ApplyModifier( Name )
	
	local Modifier = 1
	
	local Kids = Hum:GetChildren( )
	
	for a = 1, #Kids do
		
		if Kids[ a ].Name == Name then
			
			Modifier = Modifier * Kids[ a ].Value
			
		end
		
	end
	
	Event:Disconnect( )
	
	Hum[ Types[ Name ] ] = Normals[ Name ] * Modifier
	
	Event = Hum.Changed:Connect( Changed )
	
end

function Changed( Property )
	
	for a, b in pairs( Types ) do
		
		if Property == b then
			
			Normals[ a ] = Hum[ Property ]
			
			ApplyModifier( a )
			
			break
			
		end
		
	end
	
end

Event = Hum.Changed:Connect( Changed )

Hum.ChildAdded:Connect( function ( Obj )
	
	if Types[ Obj.Name ] then
		
		ApplyModifier( Obj.Name )
		
	end
	
end )

Hum.ChildRemoved:Connect( function ( Obj )
	
	if Types[ Obj.Name ] then
		
		ApplyModifier( Obj.Name )
		
	end
	
end )