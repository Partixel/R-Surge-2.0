local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local VIPFunc = Instance.new( "RemoteFunction" )

VIPFunc.Name = "VIPFunc"

VIPFunc.Parent = game:GetService( "ReplicatedStorage" ).S2

local VIPEvent = Instance.new( "RemoteEvent" )

VIPEvent.Name = "VIPEvent"

VIPEvent.Parent = game:GetService( "ReplicatedStorage" ).S2

local MarketplaceService = game:GetService( "MarketplaceService" )

function GetColor( Plr )
	
	local S2Folder = Plr:FindFirstChild( "S2" )
	
	if not S2Folder then return Plr.TeamColor end
	
	local Color = S2Folder:FindFirstChild( "VIPColor" )
	
	if Color then Color = Color.Value else Color = Plr.TeamColor end
	
	return Color
	
end

function GetMaterial( Plr )
	
	local S2Folder = Plr:FindFirstChild( "S2" )
	
	if not S2Folder then return end
	
	local Mat = S2Folder:FindFirstChild( "VIPMaterial" )
	
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
	
	for _, Obj in ipairs( Tool:GetDescendants( ) ) do
		
		if CollectionService:HasTag( Obj, "s2color" ) then
			
			if Obj:IsA( "SpecialMesh" ) then
				
				Obj.VertexColor = Vector3.new( Col.r, Col.g, Col.b )
				
				Obj = Obj.Parent
				
			else
				
				Obj.BrickColor = Col
				
			end
			
			if not Obj:FindFirstChild( "OrigMat" ) then
				
				local Mat = Instance.new( "StringValue" )
				
				Mat.Name = "OrigMat"
				
				Mat.Value = tostring( Obj.Material ):sub( 15, 100 )
				
				Mat.Parent = Obj
				
			end
			
			if Mat then
				
				Obj.Material = Mat
				
			else
				
				Obj.Material = Enum.Material[ Obj.OrigMat.Value ]
				
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
			
			local Sparkles = Plr:FindFirstChild( "VIPSparkles" ) or Instance.new( "BoolValue" )
			
			Sparkles.Name = "VIPSparkles"
			
			Sparkles.Value = false
			
			Sparkles.Parent = Plr
			
		end
		
		if OwnCol then
			
			local Color = Plr:FindFirstChild( "VIPColor" ) or Instance.new( "BrickColorValue" )
			
			Color.Name = "VIPColor"
			
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
		
		local S2Folder = Plr:FindFirstChild( "S2" ) or Instance.new( "Folder" )
		
		S2Folder.Name = "S2"
		
		S2Folder.Parent = Plr
		
		local Mat = S2Folder:FindFirstChild( "VIPMaterial" ) or Instance.new( "StringValue" )
		
		Mat.Name = "VIPMaterial"
		
		Mat.Value = Chosen
		
		Mat.Parent = S2Folder
		
		local CurWep = GetWep( Plr )
		
		if CurWep then
			
			ColorGun( CurWep, Plr )
			
		end
		
	elseif Val == "SetSparkles" then
		
		local S2Folder = Plr:FindFirstChild( "S2" ) or Instance.new( "Folder" )
		
		S2Folder.Name = "S2"
		
		S2Folder.Parent = Plr
		
		local Sparkles = S2Folder:FindFirstChild( "VIPSparkles" ) or Instance.new( "BoolValue" )
		
		Sparkles.Name = "VIPSparkles"
		
		Sparkles.Value = Chosen
		
		Sparkles.Parent = S2Folder
		
	elseif Val == "ChosenCol" then
		
		local S2Folder = Plr:FindFirstChild( "S2" ) or Instance.new( "Folder" )
		
		S2Folder.Name = "S2"
		
		S2Folder.Parent = Plr
		
		local Color = S2Folder:FindFirstChild( "VIPColor" ) or Instance.new( "BrickColorValue" )
		
		Color.Name = "VIPColor"
		
		Color.Value = Chosen
		
		Color.Parent = S2Folder
		
		local CurWep = GetWep( Plr )
		
		if CurWep then
			
			ColorGun( CurWep, Plr )
			
		end
		
	end
	
end )

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
	
end

for _, Plr in ipairs( game:GetService( "Players" ):GetPlayers( ) ) do
	
	HandlePlr( Plr )
	
end

game.Players.PlayerAdded:Connect( HandlePlr )