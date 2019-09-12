--Variables
--local GameAnalyticsSendMessage = game:GetService("ReplicatedStorage"):WaitForChild("GameAnalyticsSendMessage")

--Services
local GS = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage"):WaitForChild("S2")
local Postie = require(ReplicatedStorage:WaitForChild("Postie"))

--Functions
local function getPlatform()

    if (GS:IsTenFootInterface()) then
        return "Console"
    elseif (UIS.TouchEnabled and not UIS.MouseEnabled) then
        return "Mobile"
    else
        return "Desktop"
    end
end

--Filtering
Postie.SetCallback("getPlatform", getPlatform);

-- debug stuff
--GameAnalyticsSendMessage.OnClientEvent:Connect(function(chatProperties)
--    game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", chatProperties)
--end)

local ClientLog = ReplicatedStorage:WaitForChild( "ClientLog" )

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

local Filter = { 'TRAD Loader module disabled', 'Image %b"" failed to load.+', 'Animation %b"" failed to load.+', 'Failed to load sound.+', "Infinite yield possible on %b''", "Mesh Manager: http request failed, contentid: %b'', exception: HttpError: Timedout", "ContentProvider:PreloadAsync%(%) failed for .*", "Something unexpectedly tried to set the parent of.+", "SolidModelContentProvider failed to process.+", 'Mode 6 failed: "Android version is too old to activate Vulkan"' }

local errorCountCache = {}
local errorCountCacheKeys = {}
local MaxErrorsPerHour = 10

function LogError(message, messageType)
	
    if messageType ~= Enum.MessageType.MessageError and messageType ~= Enum.MessageType.MessageWarning then
        return
    end
	
    local m = message
	
	for _, Plr in ipairs( game:GetService( "Players" ):GetPlayers( ) ) do
		
		m = m:gsub( PatternSafe( Plr.Name ), "<Player>" )	
		
	end
	
	for _, Fil in ipairs( Filter ) do
		
		if m:match( Fil ) == m then
			
			return
			
		end
		
	end
	
	m = "[CLIENT] " .. m
	
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
	
    --Report (use nil for playerId as real player id is not available)
    ClientLog:FireServer( m, messageType )

    -- increment error count
    errorCountCache[key].currentCount = errorCountCache[key].currentCount + 1
end

--Error Logging
game:GetService( "LogService" ).MessageOut:Connect( LogError )

for _, Log in ipairs( game:GetService( "LogService" ):GetLogHistory( ) ) do
	
	LogError( Log.message, Log.messageType )
	
end