local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

local VIPFunc = Instance.new( "RemoteFunction" )

VIPFunc.Name = "VIPFunc"

VIPFunc.Parent = game:GetService( "ReplicatedStorage" )

local VIPEvent = Instance.new( "RemoteEvent" )

VIPEvent.Name = "VIPEvent"

VIPEvent.Parent = game:GetService( "ReplicatedStorage" )

local MarketplaceService = game:GetService( "MarketplaceService" )

function GetColor( Plr )
	
	local Color = Plr:FindFirstChild( "S2Color" )
	
	if Color then Color = Color.Value else Color = Plr.TeamColor end
	
	return Color
	
end

function GetMaterial( Plr )
	
	local Mat = Plr:FindFirstChild( "S2Material" )
	
	if Mat and Mat.Value ~= "" then return Mat.Value end
	
end

local function GetWep( Plr, Char )
	
	Char = Char or Plr.Character
	
	if not Char then return end
	
	return Char:FindFirstChildOfClass( "Tool" )
	
end

local CollectionService = game:GetService( "CollectionService" )

local function ColorGun( Tool, User )
	
	if not User then return end
	
	local Col, Mat = GetColor( User ), GetMaterial( User )
	
	local Descendants = Tool:GetDescendants( )
	
	for a = 1, #Descendants do
		
		if CollectionService:HasTag( Descendants[ a ], "s2color" ) then
			
			if Descendants[ a ]:IsA( "SpecialMesh" ) then
				
				Descendants[ a ].VertexColor = Vector3.new( Col.r, Col.g, Col.b )
				
				Descendants[ a ] = Descendants[ a ].Parent
				
			else
				
				Descendants[ a ].BrickColor = Col
				
			end
			
			if not Descendants[ a ]:FindFirstChild( "OrigMat" ) then
				
				local Mat = Instance.new( "StringValue" )
				
				Mat.Name = "OrigMat"
				
				Mat.Value = tostring( Descendants[ a ].Material ):sub( 15, 100 )
				
				Mat.Parent = Descendants[ a ]
				
			end
			
			if Mat then
				
				Descendants[ a ].Material = Mat
				
			else
				
				Descendants[ a ].Material = Enum.Material[ Descendants[ a ].OrigMat.Value ]
				
			end
			
		end
		
	end
	
end

local function PlayerOwnsAsset( Plr, AssetId )
	
	while not Plr.Parent do wait( ) end
	
	if Plr.UserId < 0 then return true end
	
	if Plr:IsInGroup( 1059575 ) then return true end
	
	local _, Owns = pcall( function ( ) return MarketplaceService:PlayerOwnsAsset( Plr, AssetId ) end )
	
	return Owns
	
end

VIPFunc.OnServerInvoke = function ( Plr, Val )
	
	if Val == nil then
		
		local OwnNeon, OwnCol, OwnSparkles = PlayerOwnsAsset( Plr, 382753196 ), PlayerOwnsAsset( Plr, 382751732 ), PlayerOwnsAsset( Plr, 382816939 )
		
		if OwnSparkles then
			
			local Sparkles = Plr:FindFirstChild( "S2Sparkles" ) or Instance.new( "BoolValue" )
			
			Sparkles.Name = "S2Sparkles"
			
			Sparkles.Value = false
			
			Sparkles.Parent = Plr
			
		end
		
		if OwnCol then
			
			local Color = Plr:FindFirstChild( "S2Color" ) or Instance.new( "BrickColorValue" )
			
			Color.Name = "S2Color"
			
			Color.Value = Plr.TeamColor
			
			Color.Parent = Plr
			
			local CurWep = GetWep( Plr )
			
			if CurWep then
				
				ColorGun( CurWep, Plr )
				
			end
			
		end
		
		return OwnNeon, OwnCol, OwnSparkles
		
	elseif Val == "BuyCol" then
		
		local Id = 382751732
		
		if PlayerOwnsAsset( Plr, Id ) then return true end
		
		MarketplaceService:PromptPurchase( Plr, Id )
		
		local Plyr, AssetId, Bought
		
		repeat
			
			Plyr, AssetId, Bought = MarketplaceService.PromptPurchaseFinished:wait( )
			
		until Plyr == Plr and AssetId == Id
		
		return Bought
		
	elseif Val == "BuyNeon" then
		
		local Id = 382753196
		
		if PlayerOwnsAsset( Plr, Id ) then return true end
		
		MarketplaceService:PromptPurchase( Plr, Id )
		
		local Plyr, AssetId, Bought
		
		repeat
			
			Plyr, AssetId, Bought = MarketplaceService.PromptPurchaseFinished:wait( )
			
		until Plyr == Plr and AssetId == Id
		
		return Bought
		
	elseif Val == "BuySparkles" then
		
		local Id = 382816939
		
		if PlayerOwnsAsset( Plr, Id ) then return true end
		
		MarketplaceService:PromptPurchase( Plr, Id )
		
		local Plyr, AssetId, Bought
		
		repeat
			
			Plyr, AssetId, Bought = MarketplaceService.PromptPurchaseFinished:wait( )
			
		until Plyr == Plr and AssetId == Id
		
		return Bought
		
	end
	
end

VIPEvent.OnServerEvent:Connect( function ( Plr, Val, Chosen )
		
	if Val == "SetNeon" then
		
		local Mat = Plr:FindFirstChild( "S2Material" ) or Instance.new( "StringValue" )
		
		Mat.Name = "S2Material"
		
		Mat.Value = Chosen
		
		Mat.Parent = Plr
		
		local CurWep = GetWep( Plr )
		
		if CurWep then
			
			ColorGun( CurWep, Plr )
			
		end
		
	elseif Val == "SetSparkles" then
		
		local Sparkles = Plr:FindFirstChild( "S2Sparkles" ) or Instance.new( "BoolValue" )
		
		Sparkles.Name = "S2Sparkles"
		
		Sparkles.Value = Chosen
		
		Sparkles.Parent = Plr
		
	elseif Val == "ChosenCol" then
		
		local Color = Plr:FindFirstChild( "S2Color" ) or Instance.new( "BrickColorValue" )
		
		Color.Name = "S2Color"
		
		Color.Value = Chosen
		
		Color.Parent = Plr
		
		local CurWep = GetWep( Plr )
		
		if CurWep then
			
			ColorGun( CurWep, Plr )
			
		end
		
	end
	
end )


---- CHRISTMAS STUFF ----

local Colours = { BrickColor.new( "Bright red" ), BrickColor.new( "Bright green" ), BrickColor.new( "Bright yellow" ), BrickColor.new( "Bright blue" ), BrickColor.new( "Reddish brown" ), BrickColor.new( "Mulberry" ), BrickColor.new( "White" ) }

function HandlePlr( Plr )
	
	if Plr.Character then
		
		Plr.Character.ChildAdded:Connect( function ( Obj )
			
			if Obj:IsA( "Tool" ) then
				
				ColorGun( Obj, Plr )
				
			end
			
		end )
		
	end
	
	Plr.CharacterAdded:Connect( function ( Char )
		
		Char.ChildAdded:Connect( function ( Obj )
			
			if Obj:IsA( "Tool" ) then
				
				ColorGun( Obj, Plr )
				
			end
			
		end )
		
	end )
	
	Core.Visuals.GunColouring = Core.WeaponSelected.Event:Connect( ColorGun )
	
	local Active = Plr:WaitForChild( "Rewards", 60 )
	
	if not Active then return end
	
	Active = Active:WaitForChild( "Christmas Guns" ):WaitForChild( "Active", math.huge )
	
	local Stage = math.random( 1, #Colours )
	
	local Last3 = { }
	
	local Cur
	
	Active:GetPropertyChangedSignal( "Value" ):Connect( function ( )
		
		local MyCur = { }
		
		Cur = MyCur
		
		if Active.Value then
			
			local Mat = Plr:FindFirstChild( "S2Material" ) or Instance.new( "StringValue" )
			
			Mat.Name = "S2Material"
			
			Mat.Value = "Neon"
			
			Mat.Parent = Plr
			
			local Color = Plr:FindFirstChild( "S2Color" ) or Instance.new( "BrickColorValue" )
			
			Color.Name = "S2Color"
			
			Color.Value = Colours[ Stage ]
			
			Color.Parent = Plr
			
			while wait( math.random( 1, 5 ) / 10 ) and MyCur == Cur do
				
				Last3[ 4 ] = Last3[ 3 ]
				
				Last3[ 3 ] = Last3[ 2 ]
				
				Last3[ 2 ] = Last3[ 1 ]
				
				Last3[ 1 ] = Stage
				
				repeat
					
					Stage = math.random( 1, #Colours )
					
				until Last3[ 1 ] ~= Stage and Last3[ 2 ] ~= Stage and Last3[ 3 ] ~= Stage and Last3[ 4 ] ~= Stage
				
				Color.Value = Colours[ Stage ]
				
				local CurWep = GetWep( Plr )
				
				if CurWep then
					
					ColorGun( CurWep, Plr )
					
				end
				
			end
			
		else
			
			local Color = Plr:FindFirstChild( "S2Color" )
			
			if Color then
				
				if ActualCol then
					
					Color.Value = ActualCol
					
				else
					
					Color:Destroy( )
					
				end
				
			end
			
			local Mat = Plr:FindFirstChild( "S2Material" )
			
			if Mat then
				
				if ActualMat then
					
					Mat.Value = ActualMat
					
				else
					
					Mat:Destroy( )
					
				end
				
			end
			
			local CurWep = GetWep( Plr )
			
			if CurWep then
				
				ColorGun( CurWep, Plr )
				
			end
			
		end
		
	end )
	
	if Active.Value then
		
		local MyCur = { }
		
		Cur = MyCur
		
		local Mat = Plr:FindFirstChild( "S2Material" ) or Instance.new( "StringValue" )
		
		Mat.Name = "S2Material"
		
		Mat.Value = "Neon"
		
		Mat.Parent = Plr
		
		local Color = Plr:FindFirstChild( "S2Color" ) or Instance.new( "BrickColorValue" )
		
		Color.Name = "S2Color"
		
		Color.Value = Colours[ Stage ]
		
		Color.Parent = Plr
		
		while wait( math.random( 1, 5 ) / 10 ) and MyCur == Cur do
			
			Last3[ 4 ] = Last3[ 3 ]
			
			Last3[ 3 ] = Last3[ 2 ]
			
			Last3[ 2 ] = Last3[ 1 ]
			
			Last3[ 1 ] = Stage
			
			repeat
				
				Stage = math.random( 1, #Colours )
				
			until Last3[ 1 ] ~= Stage and Last3[ 2 ] ~= Stage and Last3[ 3 ] ~= Stage and Last3[ 4 ] ~= Stage
			
			Color.Value = Colours[ Stage ]
			
			local CurWep = GetWep( Plr )
			
			if CurWep then
				
				ColorGun( CurWep, Plr )
				
			end
			
		end
		
	end
	
end

local Plrs = game:GetService( "Players" ):GetPlayers( )

for a = 1, #Plrs do
	
	HandlePlr( Plrs[ a ] )
	
end

game.Players.PlayerAdded:Connect( HandlePlr )