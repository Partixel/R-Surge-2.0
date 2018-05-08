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

local function GetWep( Plr )
	
	if not Plr.Character then return end
	
	local Childs = Plr.Character:GetChildren( )
	
	for a = 1, #Childs do
		
		if Childs[ a ]:IsA( "Tool" ) and Childs[ a ]:FindFirstChild( "GunStat" ) then return Childs[ a ].GunStat end
		
	end
	
end


local function ColorGun( Mod, User )
	
	if not Mod or not Mod.Parent or not User then return end
	
	local Col, Mat = GetColor( User ), GetMaterial( User )
	
	local Descendants = Mod.Parent:GetDescendants( )
	
	for a = 1, #Descendants do
		
		if Descendants[ a ]:IsA( "BasePart" ) and string.find( string.lower( Descendants[ a ].Name ), "color" ) then
			
			Descendants[ a ].BrickColor = Col
			
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

Core.Visuals.GunColouring = Core.WeaponSelected.Event:Connect( ColorGun )

local PlayerOwnsAsset = function ( Plr, AssetId )
	
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