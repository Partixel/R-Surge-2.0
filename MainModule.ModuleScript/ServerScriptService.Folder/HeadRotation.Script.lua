local UpdateRate = 1/20

local HeadRotRemote = Instance.new( "RemoteEvent" )

HeadRotRemote.Name = "HeadRot"

local Mode = { __mode = "k" }

local Discluded, Rotations = setmetatable( { }, Mode ), setmetatable( { }, Mode )

HeadRotRemote.OnServerEvent:Connect( function ( Plr, Rotation, Disclude )
	
	Rotations[ Plr ] = Rotation
	
	Discluded[ Plr ] = Disclude
	
end )

HeadRotRemote.Parent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )

local Players = game:GetService( "Players" )

local CollectionService = game:GetService( "CollectionService" )

function HandleCharacter( Character )
	
	local OldHead = Character:WaitForChild( "Head" )
	
	local NewHead = OldHead:Clone( )
	
	CollectionService:AddTag( OldHead, "forcepen" )
	
	CollectionService:AddTag( NewHead, "nopen" )
	
	CollectionService:AddTag( NewHead, "s2headdamage" )
	
	NewHead:ClearAllChildren( )
	
	NewHead.Massless = true
	
	NewHead.Transparency = 1
	
	local OldWeld = Character:FindFirstChild( "Neck", true )
	
	while not OldWeld do OldWeld = Character:FindFirstChild( "Neck", true ) end
	
	local NewWeld = OldWeld:Clone( )
	
	NewWeld.Part1 = NewHead
	
	NewWeld.Name = "NewNeck"
	
	NewHead.Name = "NewHead"
	
	NewHead.Parent = OldHead.Parent
	
	NewWeld.Parent = OldWeld.Parent
	
end

function PlayerAdded( Plr )
	
	HandleCharacter( Plr.Character or Plr.CharacterAdded:Wait( ) )
	
	Plr.CharacterAdded:Connect( HandleCharacter )
	
end

Players.PlayerAdded:Connect( PlayerAdded )

for _, Plr in ipairs( Players:GetPlayers( ) ) do
	
	PlayerAdded( Plr )
	
end

while wait( UpdateRate ) do
	
	if next( Rotations ) then
		
		local Rots
		
		for _, Plr in ipairs( Players:GetPlayers( ) ) do
			
			if not Discluded[ Plr ] then
				
				if Rotations[ Plr ] then
					
					local Rots = { }
					
					for b, c in pairs( Rotations ) do
						
						if b ~= Plr then
							
							Rots[ #Rots + 1 ] = { b, c }
							
						end
						
					end
					
					if next( Rots ) then
						
						HeadRotRemote:FireClient( Plr, Rots )
						
					end
					
				else
					
					if not Rots then
						
						Rots = { }
						
						for b, c in pairs( Rotations ) do
							
							Rots[ #Rots + 1 ] = { b, c }
							
						end
						
					end
					
					HeadRotRemote:FireClient( Plr, Rots )
					
				end
				
			end
			
		end
		
		Rotations = setmetatable( { }, Mode )
		
	end
	
end