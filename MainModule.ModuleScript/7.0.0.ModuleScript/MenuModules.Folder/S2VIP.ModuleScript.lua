local MarketplaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService( "CollectionService" )
local HttpService = game:GetService("HttpService")

local CloseColors = require(script:WaitForChild("Client"):WaitForChild("CloseColors"))

local VIPs = {{7166243, 382816939}, {7166248, 382753196}, {7166253, 382751732}, {7171209}}

local OwnedCache = setmetatable({}, {__mode = "k"})
local function PlayerOwnsAsset(Plr, VIP)
	if OwnedCache[Plr] and OwnedCache[Plr][VIP] then return true end
	
	while not Plr.Parent do wait( ) end
	
	if Plr.UserId < 0 or Plr:IsInGroup(1059575) then
		OwnedCache[Plr] = OwnedCache[Plr] or {}
		OwnedCache[Plr][VIP] = true
		return true
	end
	
	for i, AssetId in ipairs(VIPs[VIP]) do
		if (i ~= 1 and i == #VIPs[VIP] and MarketplaceService.PlayerOwnsAsset or MarketplaceService.UserOwnsGamePassAsync)(MarketplaceService, i ~= 1 and i == #VIPs[VIP] and Plr or Plr.UserId, AssetId) then
			OwnedCache[Plr] = OwnedCache[Plr] or {}
			OwnedCache[Plr][VIP] = true
			return true
		end
	end
end

local function PromptPurchase(Plr, VIP)
	if PlayerOwnsAsset(Plr, VIP) then return true end
	
	MarketplaceService:PromptGamePassPurchase(Plr, VIPs[VIP][1])
	
	local Plyr, AssetId, Bought
	repeat
		Plyr, AssetId, Bought = MarketplaceService.PromptGamePassPurchaseFinished:Wait()
	until Plyr == Plr and AssetId == VIPs[VIP][1]
	
	if Bought then
		OwnedCache[Plr] = OwnedCache[Plr] or {}
		OwnedCache[Plr][VIP] = true
		return true
	end
end

function GetColor( Plr )
	local S2Folder = Plr:FindFirstChild( "S2" )
	if not S2Folder then return Plr.TeamColor end
	local Color = S2Folder:FindFirstChild( "VIPColor" )
	return Color and Color.Value or Plr.TeamColor
end

function GetNeon( Plr )
	local S2Folder = Plr:FindFirstChild( "S2" )
	if not S2Folder then return end
	local Neon = S2Folder:FindFirstChild( "VIPNeon" )
	return Neon and Neon.Value
end

local function ColorTool( Tool, User )
	if not User then return end
	
	local Col, Neon = GetColor( User ), GetNeon( User )
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
			
			if Neon then
				Obj.Material = Enum.Material.Neon
			else
				Obj.Material = Enum.Material[ Obj.OrigMat.Value ]
			end
		end
	end
end

local Cache = {}
script:WaitForChild("Client"):WaitForChild("GetImageId").OnServerInvoke = function(Plr, AssetId)
	if Cache[AssetId] then return Cache[AssetId] end
	
	if MarketplaceService:GetProductInfo(AssetId).AssetTypeId == 1 then
		Cache[AssetId] = AssetId
		return AssetId
	end
	
	local Original = MarketplaceService:GetProductInfo(AssetId)
	
	local Info
	while not Info or Info.AssetTypeId ~= 1 or Info.Creator.Id ~= Original.Creator.Id do
		Info = MarketplaceService:GetProductInfo((Info and Info.AssetId or AssetId) - 1)
	end
	return Info.AssetId
end

return {
	Key = "S2VIP1",
	SendToClient = true,
	AllowRemoteSet = true,
	BeforeSave = function(Plr, Data)
		if Data then
			for i = 1, 4 do
				Data[i] = Data[i] or nil
			end
		end
		return Data
	end,
	BeforeRemoteSet = function(Plr, DataStore, Remote, VIP, Enabled, Color)
		if Enabled ~= nil and PlayerOwnsAsset(Plr, VIP) then
			local Data = DataStore:Get({})
			if VIP == 3 then
				Data[VIP] = Data[VIP] or {}
				Data[VIP][Enabled] = Color
			elseif VIP == 4 and Enabled == "" then
				Data[VIP] = nil
			else
				Data[VIP] = Enabled
			end
			
			if VIP ~= 4 then
				local S2Folder = Plr:FindFirstChild("S2") or Instance.new("Folder")
				S2Folder.Name = "S2"
				S2Folder.Parent = Plr
				
				local VIPObj = S2Folder:FindFirstChild("VIP" .. (VIP == 1 and "Sparkles" or VIP == 2 and "Neon" or "Color")) or VIP == 3 and Instance.new("BrickColorValue") or Instance.new("BoolValue")
				VIPObj.Name = "VIP" .. ( VIP == 1 and "Sparkles" or VIP == 2 and "Neon" or "Color" )
				VIPObj.Value = VIP == 3 and CloseColors(Plr.TeamColor)[Color] or Enabled
				
				VIPObj.Parent = S2Folder
			end
			
			if (VIP == 2 or VIP == 3) and Plr.Character then
				local CurWep = Plr.Character:FindFirstChildOfClass( "Tool" )
				if CurWep then
					ColorTool( CurWep, Plr )
				end
			end
			return Data
		elseif PromptPurchase(Plr, VIP) then
			Remote:FireClient(Plr, VIP)
		end
	end,
	BeforeSendToClient = function(Plr, Data)
		if Data then
			for VIP = 1, 3 do
				if Data[VIP] then
					local S2Folder = Plr:FindFirstChild("S2") or Instance.new("Folder")
					S2Folder.Name = "S2"
					S2Folder.Parent = Plr
					
					local VIPObj = S2Folder:FindFirstChild("VIP" .. (VIP == 1 and "Sparkles" or VIP == 2 and "Neon" or "Color")) or VIP == 3 and Instance.new("BrickColorValue") or Instance.new("BoolValue")
					VIPObj.Name = "VIP" .. ( VIP == 1 and "Sparkles" or VIP == 2 and "Neon" or "Color" )
					VIPObj.Value = VIP == 3 and CloseColors(Plr.TeamColor)[Data[VIP][Plr.TeamColor.Name] or 1] or Data[VIP]
					
					VIPObj.Parent = S2Folder
					
					if VIP ~= 1 and Plr.Character then
						local CurWep = Plr.Character:FindFirstChildOfClass( "Tool" )
						if CurWep then
							ColorTool( CurWep, Plr )
						end
					end
				end
			end
		end
		
		return {PlayerOwnsAsset(Plr, 1), PlayerOwnsAsset(Plr, 2), PlayerOwnsAsset(Plr, 3), PlayerOwnsAsset(Plr, 4)}, Data
	end,
	SetupPlayer = function(Plr, DataStore)
		Plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
			local Data = DataStore:Get()
			if Data and Data[3] then
				local VIPObj = Plr:FindFirstChild("S2") and Plr:FindFirstChild("S2"):FindFirstChild("VIPColor")
				if VIPObj then
					VIPObj.Value = CloseColors(Plr.TeamColor)[Data[3] and Data[3][Plr.TeamColor.Name] or 1]
				end
			end
			
			local CurWep = Plr.Character and Plr.Character:FindFirstChildOfClass( "Tool" )
			if CurWep then
				ColorTool( CurWep, Plr )
			end
		end)
		
		if Plr.Character then
			Plr.Character.ChildAdded:Connect( function ( Obj )
				if Obj:IsA( "Tool" ) then
					ColorTool( Obj, Plr )
				end
			end )
		end
		
		Plr.CharacterAdded:Connect( function ( Char )
			Char.ChildAdded:Connect( function ( Obj )
				if Obj:IsA( "Tool" ) then
					ColorTool( Obj, Plr )
				end
			end )
		end )
	end,
}