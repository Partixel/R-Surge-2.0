local HeadRotRemote = Instance.new( "RemoteEvent" )

HeadRotRemote.Name = "HeadRot"

local Mode = { __mode = "k" }

local Rotations = setmetatable( { }, Mode )

HeadRotRemote.OnServerEvent:Connect( function ( Plr, Rotation )
	
	Rotations[ Plr ] = Rotation
	
end )

HeadRotRemote.Parent = game:GetService( "ReplicatedStorage" )

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
	
	if not Plr.Character then Plr.CharacterAdded:Wait( ) end
	
	HandleCharacter( Plr.Character )
	
	Plr.CharacterAdded:Connect( HandleCharacter )
	
end

Players.PlayerAdded:Connect( PlayerAdded )

local Plrs = Players:GetPlayers( )

for a = 1, #Plrs do
	
	PlayerAdded( Plrs[ a ] )
	
end

while wait( 1/30 ) do
	
	if next( Rotations ) then
		
		local Plrs = Players:GetPlayers( )
		
		local Rots
		
		for a = 1, #Plrs do
			
			if Rotations[ Plrs[ a ] ] then
				
				local Rots = { }
				
				for b, c in pairs( Rotations ) do
					
					if b ~= Plrs[ a ] then
						
						Rots[ #Rots + 1 ] = { b, c }
						
					end
					
				end
				
				if next( Rots ) then
					
					HeadRotRemote:FireClient( Plrs[ a ], Rots )
					
				end
				
			else
				
				if not Rots then
					
					Rots = { }
					
					for b, c in pairs( Rotations ) do
						
						Rots[ #Rots + 1 ] = { b, c }
						
					end
					
				end
				
				HeadRotRemote:FireClient( Plrs[ a ], Rots )
				
			end
			
		end
		
		Rotations = setmetatable( { }, Mode )
		
	end
	
end