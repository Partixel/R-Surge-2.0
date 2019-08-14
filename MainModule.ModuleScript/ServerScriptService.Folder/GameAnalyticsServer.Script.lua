--[[

    NOTE: This script should be in game.ServerScriptService

--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage"):WaitForChild( "S2" )
local ServerStorage = game:GetService("ServerStorage")

--Validate
if not script:IsDescendantOf(game:GetService("ServerScriptService")) then
    error("GameAnalytics: Disabled server. GameAnalyticsServer has to be located in game.ServerScriptService.")
    return
end

-- if not ReplicatedStorage:FindFirstChild("GameAnalyticsSendMessage") then
--     --Create
--     local f = Instance.new("RemoteEvent")
--     f.Name = "GameAnalyticsSendMessage"
--     f.Parent = ReplicatedStorage
-- end

if not ReplicatedStorage:FindFirstChild("GameAnalyticsCommandCenter") then
    --Create
    local f = Instance.new("RemoteEvent")
    f.Name = "GameAnalyticsCommandCenter"
    f.Parent = ReplicatedStorage
end

--Modules
local GameAnalytics = require(ServerStorage:WaitForChild("GameAnalytics"))
local store = require(ServerStorage.GameAnalytics.Store)
local state = require(ServerStorage.GameAnalytics.State)
local LS = game:GetService("LogService")
local MKT = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ProductCache = {}
local ONE_HOUR_IN_SECONDS = 3600
local MaxErrorsPerHour = 10
local ErrorDS = {}
local errorCountCache = {}
local errorCountCacheKeys = {}

spawn(function()
    local currentHour = math.floor(os.time()/3600)
    ErrorDS = store:GetErrorDataStore(currentHour)

    while wait(ONE_HOUR_IN_SECONDS) do
        currentHour = math.floor(os.time()/3600)
        ErrorDS = store:GetErrorDataStore(currentHour)
        errorCountCache = {}
        errorCountCacheKeys = {}
    end
end)

spawn(function()
    while wait(store.AutoSaveData) do
        for _, key in pairs(errorCountCacheKeys) do
            local errorCount = errorCountCache[key]
            local step = errorCount.currentCount - errorCount.countInDS
            errorCountCache[key].countInDS = store:IncrementErrorCount(ErrorDS, key, step)
            errorCountCache[key].currentCount = errorCountCache[key].countInDS
        end
    end
end)

local Pattern_Escape = {

	["("] = "%(",

	[")"] = "%)",

	["."] = "%.",

	["%"] = "%%",

	["+"] = "%+",

	["-"] = "%-",

	["*"] = "%*",

	["?"] = "%?",

	["["] = "%[",

	["]"] = "%]",

	["^"] = "%^",

	["$"] = "%$",

	["\0"] = "%z"

}

-- Makes a string safe for use in string.gsub
local function PatternSafe( Str )

	return Str:gsub( ".", Pattern_Escape )

end

local Filter = { "<Player> took too long to send shot packet%, discarding%! %- %d+%.?%d*", 'Player "<Player>" appears to be spamming remote events%.', 'Animation %b"" failed to load.+', "<Player> has died to non%-S2 damage, please update to using S2s damage system", "Error filtering message: .*" }

--[[

local Actual = { 'TRAD Loader module disabled', 'Image "http://assetgame.roblox.com/asset/?id=" failed to load in "Workspace.<Player>.Humanoid.Clothes": Request failed', 'Image "http://assetgame.roblox.com/asset/?id=1" failed to load in "Workspace.<Player>.Humanoid.Clothes": Request failed', 'Animation "rbxassetid://955877742" failed to load in "Animation.AnimationId": Animation failed to load', 'Animation "rbxassetid://5555" failed to load in "Animation.AnimationId": Animation failed to load', 'Failed to load sound rbxassetid://1544900801: Unable to download sound data', 'Failed to load sound rbxassetid://123353: Unable to download sound data', 'Image "rbxasset://textures/slate/specular.dds" failed to load: File not found', 'Image "rbxasset://textures/slate/diffuse.dds" failed to load: File not found', 'Image "https://assetdelivery.roblox.com/v1/asset?id=" failed to load in "Workspace.<Player>.Humanoid.Clothes": Request failed' }

for _, Act in ipairs( Actual ) do
	local Match
	for _, Fil in ipairs( Filter ) do
		
		if Act:match( Fil ) == Act then
			
			Match = true
			
		end
		
	end
	
	
	if not Match then print( "no match\n" .. Act ) else print( "match\n" .. Act ) end
	
end

]]

local RunService = game:GetService( "RunService" )

local function LogError(message, messageType, Plr)
	
    --Validate
    if not state.ReportErrors or RunService:IsStudio( ) then
        return
    end
	
    if messageType ~= Enum.MessageType.MessageError and messageType ~= Enum.MessageType.MessageWarning then
        return
    end

    local m = message
	
	for _, Plr in ipairs( game:GetService( "Players" ):GetPlayers( ) ) do
		
		m = m:gsub( PatternSafe( Plr.Name ), "<Player>" )	
		
	end
	
	if m:find( "%[CLIENT%] [%d%w]+:5: attempt to index field 'Character' %(a nil value%)" ) then
		
		spawn( function ( ) print( Plr.Name .. " is exploiting! Don't say anything in-game so that they don't realise we're onto them" ) end )
		
	end
	
	for _, Fil in ipairs( Filter ) do
		
		if m:match( Fil ) == m then
			
			return
			
		end
		
	end
	
    if #m > 8192 then
        m = string.sub(m, 1, 8192)
    end

    local key = m
    if #key > 50 then
        key = string.sub(key, 1, 50)
    end

    if errorCountCache[key] == nil then
        errorCountCacheKeys[#errorCountCacheKeys + 1] = key
        errorCountCache[key] = {}
        errorCountCache[key].countInDS = 0
        errorCountCache[key].currentCount = 0
    end

    -- don't report error if limit has been exceeded
    if errorCountCache[key].currentCount > MaxErrorsPerHour then
        return
    end
	
	spawn( function( ) print( "Logging " .. messageType.Name:gsub( "Message", "" ):lower( ) .. " - " .. message ) end )
	
    --Report (use nil for playerId as real player id is not available)
    GameAnalytics:addErrorEvent(nil, {
        severity = GameAnalytics.EGAErrorSeverity[ messageType.Name:gsub( "Message", "" ):lower( ) ],
        message = m
    })

    -- increment error count
    errorCountCache[key].currentCount = errorCountCache[key].currentCount + 1
end

local ClientLog = Instance.new( "RemoteEvent" )

ClientLog.Name = "ClientLog"

ClientLog.OnServerEvent:Connect( function ( Plr, m, mt ) LogError( m, mt, Plr ) end )

ClientLog.Parent = ReplicatedStorage

--Error Logging
LS.MessageOut:Connect( LogError )

for _, Log in ipairs( LS:GetLogHistory( ) ) do
	
	LogError( Log.message, Log.messageType )
	
end

--Record Gamepasses. NOTE: This doesn't record gamepass purchases if a player buys it from the website
MKT.PromptGamePassPurchaseFinished:Connect(function(Player, ID, Purchased)

    --Validate
    if not state.AutomaticSendBusinessEvents then
        return
    end

    --Validate
    if not Purchased then return end

    --Variables
    local GamepassInfo = ProductCache[ID]

    --Cache
    if not GamepassInfo then

        --Get
        GamepassInfo = MKT:GetProductInfo(ID, Enum.InfoType.GamePass)
        ProductCache[ID] = GamepassInfo
    end

    GameAnalytics:addBusinessEvent(Player.UserId, {
        amount = GamepassInfo.PriceInRobux,
        itemType = "Gamepass",
        itemId = GamepassInfo.Name
    })
end)
--[[
-- Fire for players already in game
for _, Player in pairs(Players:GetPlayers()) do
    GameAnalytics:PlayerJoined(Player)
end

-- New Players
Players.PlayerAdded:Connect(function(Player)
    local joinData = Player:GetJoinData()
    local teleportData = joinData.TeleportData
    local gaData = nil
    if teleportData then
        gaData = teleportData.gameanalyticsData and teleportData.gameanalyticsData[tostring(Player.UserId)]
    end
    GameAnalytics:PlayerJoined(Player, gaData)
end)

-- Players leaving
Players.PlayerRemoving:Connect(function(Player)
    GameAnalytics:PlayerRemoved(Player)
end)]]