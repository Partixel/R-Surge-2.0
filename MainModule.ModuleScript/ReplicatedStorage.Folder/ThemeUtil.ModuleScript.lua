local ThemeUtil = { }

while not _G.S20Config and wait( ) do end

local BoundUpdates = { }

local ObjBoundUpdates = setmetatable( { }, { __newindex = function ( self, Key, Value )
	
	Key:GetPropertyChangedSignal( "Parent" ):Connect( function ( )
		
		if not Key.Parent then
			
			rawset( self, Key, nil )
			
		end
		
	end )
	
	rawset( self, Key, Value )
	
end } )

function ThemeUtil.BindUpdate( Obj, Properties, Keys )
	
	if type( Properties ) == "function" then
		
		BoundUpdates[ Obj ] = Properties
		
		coroutine.wrap( function( )
			
			local Ran, Error = pcall( Properties )
			
			if not Ran then
				
				warn( "ThemeUtil - Bound Update " .. Obj .. " errored for the initial call\n" .. Error .. "\n" .. debug.traceback( ) )
				
			end
			
		end )( )
		
	else
		
		Properties = type( Properties ) == "table" and Properties or { Properties }
		
		Keys = type( Keys ) == "table" and Keys or type( Keys ) == "function" and Keys or { Keys }
		
		ObjBoundUpdates[ Obj ] = ObjBoundUpdates[ Obj ] or { }
		
		for a = 1, #Properties do
			
			ObjBoundUpdates[ Obj ][ Properties[ a ] ] = Keys
			
		end
		
		for a = 1, #Properties do
			
			if type( Keys ) == "function" then
				
				coroutine.wrap( function( )
					
					local Ran, Error = pcall( Keys, Obj )
					
					if not Ran then
						
						warn( "ThemeUtil - Object Bound Update " .. Obj:GetFullName( ) .. " errored for the initial call for the property '" .. Properties[ a ] .. "'\n" .. Error .. "\n" .. debug.traceback( ) )
						
					end
					
				end )( )
				
			else
				
				local Ran, Error = pcall( function ( ) Obj[ Properties[ a ] ] = ThemeUtil.GetThemeFor( unpack( Keys ) ) end )
				
				if not Ran then
					
					warn( "ThemeUtil - Object Bound Update " .. Obj:GetFullName( ) .. " errored for the initial call for the property '" .. Properties[ a ] .. "'\n" .. Error .. "\n" .. debug.traceback( ) )
					
				end
				
			end
			
		end
		
	end
	
end

function ThemeUtil.UnbindUpdate( Obj, Properties )
	
	if type( Obj ) == "string" then
		
		BoundUpdates[ Obj ] = nil
		
	elseif ObjBoundUpdates[ Obj ] then
		
		Properties = type( Properties ) == "table" and Properties or { Properties }
		
		for a, b in pairs( ObjBoundUpdates[ Obj ] ) do
			
			for c = 1, #Properties do
				
				if Properties[ c ] == a then
					
					ObjBoundUpdates[ Obj ][ a ] = nil
					
					break
					
				end
				
			end
			
		end
		
		if not next( ObjBoundUpdates[ Obj ] ) then
			
			ObjBoundUpdates[ Obj ] = nil
			
		end
		
	end
	
end

function ThemeUtil.UpdateColor( Key, Value )
	
	S2Theme[ Key ] = Value
	
	for a, b in pairs( BoundUpdates ) do
		
		coroutine.wrap( function( )
			
			local Ran, Error = pcall( b, Key, Value )
			
			if not Ran then
				
				warn( "ThemeUtil - Bound Update " .. a .. " errored for '" .. Key .. "'\n" .. Error .. "\n" .. debug.traceback( ) )
				
			end
			
		end )( )
		
	end
	
	for a, b in pairs( ObjBoundUpdates ) do
		
		for c, d in pairs( b ) do
			
			if type( d ) == "function" then
				
				coroutine.wrap( function( )
					
					local Ran, Error = pcall( d, a )
					
					if not Ran then
						
						warn( "ThemeUtil - Object Bound Update " .. a:GetFullName( ) .. " errored for the property '" .. c .. "'\n" .. Error .. "\n" .. debug.traceback( ) )
						
					end
					
				end )( )
				
			else
				
				for e = 1, #d do
					
					if d[ e ] == Key then
						
						local Ran, Error = pcall( function ( ) a[ c ] = Value end )
						
						if not Ran then
							
							warn( "ThemeUtil - Object Bound Update " .. a:GetFullName( ) .. " errored for '" .. d[ e ] .. "' for the property '" .. c .. "\n" .. Error .. "\n" .. debug.traceback( ) )
							
						end
						
					elseif ThemeUtil.Theme[ d[ e ] ] then
						
						break
						
					end
					
				end
				
			end
			
		end
		
	end
	
end

function ThemeUtil.GetThemeFor( ... )
	
	local Keys = { ... }
	
	for a = 1, #Keys do
		
		if ThemeUtil.Theme[ Keys[ a ] ] then
			
			return ThemeUtil.Theme[ Keys[ a ] ]
			
		end
		
	end
	
	error( "ThemeUtil - GetColor failed for key " .. Keys[ 1 ] )
	
end

------------ TODO REMOVE

ThemeUtil.GetColor = ThemeUtil.GetThemeFor

function ThemeUtil.ContrastTextStroke( Obj, Bkg )
	
	local _, _, V = Color3.toHSV( Obj.TextColor3 )
	
	local _, _, V2 = Color3.toHSV( Bkg )
	
	--print( V, V2, math.abs( V2 - V ), Obj.Text )
	
	if Obj.Parent.ImageTransparency >= 1 then
		
		Obj.TextStrokeTransparency = 0
		
		if V > 0.5 then
			
			Obj.TextStrokeColor3 = ThemeUtil.GetThemeFor( "InvertedBackground" )
			
		else
			
			Obj.TextStrokeColor3 = ThemeUtil.GetThemeFor( "Background" )
			
		end
		
	elseif math.abs( V2 - V ) <= 0.25 then
		
		Obj.TextStrokeTransparency = 0
		
		if V2 > 0.5 then
			
			Obj.TextStrokeColor3 = ThemeUtil.GetThemeFor( "InvertedBackground" )
			
		else
			
			Obj.TextStrokeColor3 = ThemeUtil.GetThemeFor( "Background" )
			
		end
		
	else
		
		Obj.TextStrokeTransparency = 1
		
	end
	
end

function ThemeUtil.ApplyBasicTheming( Objs, Subtype, DontInvert )
	
	Objs = type( Objs ) == "table" and Objs or { Objs }
	
	Subtype = Subtype or ""
	
	for a = 1, #Objs do
		
		ThemeUtil.BindUpdate( Objs[ a ], "BackgroundColor3", Subtype .. "Background")
		
		if Objs[ a ]:IsA( "TextButton" ) or Objs[ a ]:IsA( "TextLabel" ) or Objs[ a ]:IsA( "TextBox" ) then
			
			ThemeUtil.BindUpdate( Objs[ a ], "TextColor3", { Subtype .. "TextColor", ( Subtype ~= "Inverted" and "Inverted" or "" ) .. Subtype .. "Background" } )
			
		elseif Objs[ a ]:IsA( "ImageButton" ) or Objs[ a ]:IsA( "ImageLabel" ) then
			
			ThemeUtil.BindUpdate( Objs[ a ], "ImageColor3", { Subtype .. "ImageColor", ( Subtype ~= "Inverted" and "Inverted" or "" ) .. Subtype .. "Background" } )
			
		end
		
	end
	
end

function ThemeUtil.UpdateAll( )
	
	for a, b in pairs( BoundUpdates ) do
		
		coroutine.wrap( function( )
			
			local Ran, Error = pcall( b )
			
			if not Ran then
				
				warn( "ThemeUtil - Bound Update " .. a .. " errored when updating all themes\n" .. Error .. "\n" .. debug.traceback( ) )
				
			end
			
		end )( )
		
	end
	
	for a, b in pairs( ObjBoundUpdates ) do
		
		for c, d in pairs( b ) do
			
			if type( d ) == "function" then
				
				coroutine.wrap( function( )
					
					local Ran, Error = pcall( d, a )
					
					if not Ran then
						
						warn( "ThemeUtil - Object Bound Update " .. a:GetFullName( ) .. " errored when updating all themes\n" .. Error .. "\n" .. debug.traceback( ) )
						
					end
					
				end )( )
				
			else
				
				local Ran, Error = pcall( function ( ) a[ c ] = ThemeUtil.GetThemeFor( unpack( d ) ) end )
				
				if not Ran then
					
					warn( "ThemeUtil - Object Bound Update " .. a:GetFullName( ) .. " errored when updating all themes for the property '" .. c .. "\n" .. Error .. "\n" .. debug.traceback( ) )
					
				end
				
			end
			
		end
		
	end
	
end

ThemeUtil.BaseThemes = { Light = { } }

function ThemeUtil.AddBaseTheme( Name, Inherits )
	
	ThemeUtil.BaseThemes[ Name ] = setmetatable( { }, { __index = ThemeUtil.BaseThemes[ Inherits ] } )
	
end

ThemeUtil.AddBaseTheme( "OLEDLight", "Light" )

ThemeUtil.AddBaseTheme( "Dark", "Light" )

ThemeUtil.AddBaseTheme( "OLEDDark", "Dark" )

ThemeUtil.Theme = { }

function ThemeUtil.SetBaseTheme( NewBase )
	
	if not ThemeUtil.BaseThemes[ NewBase ] then warn( "ThemeUtil - " .. NewBase .. " is not a valid base theme\n" .. debug.traceback( ) ) end
	
	setmetatable( ThemeUtil.Theme, { __index = ThemeUtil.BaseThemes[ NewBase ] } )
	
	ThemeUtil.UpdateAll( )
	
end

ThemeUtil.SetBaseTheme( "Dark" )

function ThemeUtil.AddDefaultColor( Key, Themes )
	
	for a, b in pairs( Themes ) do
		
		ThemeUtil.BaseThemes[ a ][ Key ] = b
		
	end
	
	ThemeUtil.UpdateAll( )
	
end

ThemeUtil.AddDefaultColor( "Background", { Light = Color3.fromRGB( 255, 255, 255 ), Dark = Color3.fromRGB( 46, 46, 46 ), OLEDDark = Color3.fromRGB( 0, 0, 0 ) } )

ThemeUtil.AddDefaultColor( "InvertedBackground", { Light = Color3.fromRGB( 46, 46, 46 ), Dark = Color3.fromRGB( 255, 255, 255 ), OLEDLight = Color3.fromRGB( 0, 0, 0 ) } )

ThemeUtil.AddDefaultColor( "SecondaryBackground", { Light = Color3.fromRGB( 180, 180, 180 ), Dark = Color3.fromRGB( 77, 77, 77 ), OLEDLight = Color3.fromRGB( 255, 255, 255 ), OLEDDark = Color3.fromRGB( 0, 0, 0 ) } )

ThemeUtil.AddDefaultColor( "TextColor", { Light = Color3.fromRGB( 46, 46, 46 ), Dark = Color3.fromRGB( 255, 255, 255 ), OLEDLight = Color3.fromRGB( 0, 0, 0 ) } )

ThemeUtil.AddDefaultColor( "InvertedTextColor", { Light = Color3.fromRGB( 255, 255, 255 ), Dark = Color3.fromRGB( 46, 46, 46 ), OLEDLight = Color3.fromRGB( 255, 255, 255 ), OLEDDark = Color3.fromRGB( 0, 0, 0 ) } )

ThemeUtil.AddDefaultColor( "SecondaryTextColor", { Light = Color3.fromRGB( 100, 100, 100 ), Dark = Color3.fromRGB( 170, 170, 170 ), OLEDLight = Color3.fromRGB( 70, 70, 70 ), OLEDDark = Color3.fromRGB( 200, 200, 200 ) } )

ThemeUtil.AddDefaultColor( "PositiveColor", { Light =  Color3.fromRGB( 0, 150, 0 ) } )

ThemeUtil.AddDefaultColor( "NegativeColor", { Light = Color3.fromRGB( 255, 0, 0 ) } )

ThemeUtil.AddDefaultColor( "ProgressColor", { Light =  Color3.fromRGB( 255, 255, 50 ) } )

ThemeUtil.AddDefaultColor( "SelectionColor", { Light =  Color3.fromRGB( 0, 100, 255 ) } )

if _G.S20Config.DebugTheme then
	
	spawn( function ( )
		
		while wait( ) do
			
			local R, G, B = tick( ) * 10 % 255, 127.5 + math.sin( tick( ) * 0.3 ) * 127.5, 127.5 + math.sin( tick( ) * 0.5 + 10 ) * 127.5
			
			ThemeUtil.UpdateColor( "Background", Color3.fromHSV( R / 255, G / 255, B / 255 ) )
			
			if B / 255 > 0.5 then
				
				ThemeUtil.UpdateColor( "InvertedBackground", Color3.fromRGB( 46, 46, 46 ) )
				
			else
				
				ThemeUtil.UpdateColor( "InvertedBackground", Color3.fromRGB( 255, 255, 255 ) )
				
			end
			
		end
		
	end )
	
end

return ThemeUtil