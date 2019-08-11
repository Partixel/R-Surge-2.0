local PlaceName = game:GetService( "MarketplaceService" ):GetProductInfo( game.PlaceId ).Name:gsub( "%b()", "" ):gsub("%b[]", "" ):gsub("^%s*(.+)%s*$", "%1") 

local PlaceAcronym = PlaceName:sub( 1, 1 ):upper( ) .. PlaceName:sub( 2 ):gsub( ".", { a = "", e = "", i = "", o = "", u = "" } ):gsub( " (.?)", function ( a ) return a:upper( ) end )

local settings = {
    EnableInfoLog = false,
    EnableVerboseLog = false,
    AutomaticSendBusinessEvents = false,
    ReportErrors = true,
    Build = ( game.PlaceId .. "-" .. PlaceAcronym ):sub( 1, 32 ),
    AvailableCustomDimensions01 = {},
    AvailableCustomDimensions02 = {},
    AvailableCustomDimensions03 = {},
    AvailableResourceCurrencies = {},
    AvailableResourceItemTypes = {},
    GameKey = "ceaa735b117b730b61600cc72482a965",
    SecretKey = "051deda672e8fdf529ef0058de918fe9cf74de85"
}

return settings
