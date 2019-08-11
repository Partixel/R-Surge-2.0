local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ):WaitForChild( "ThemeUtil" ) )

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local TweenService, HttpService = game:GetService( "TweenService" ), game:GetService( "HttpService" )

local SaveCursor = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "SaveCursor" )

ThemeUtil.BindUpdate( script.Parent.Frame, { BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency" } )

ThemeUtil.BindUpdate( script.Parent.Frame.Main, { ScrollBarImageColor3 = "Secondary_BackgroundColor", ScrollBarImageTransparency = "Secondary_BackgroundTransparency" } )

ThemeUtil.BindUpdate( script.Parent.Frame.Search, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor" } )

ThemeUtil.BindUpdate( { script.Parent.Frame.Export.Code, script.Parent.Frame.Export.TextButton, script.Parent.Frame.Import.Code, script.Parent.Frame.Import.TextButton }, { BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )

script.Parent.Frame.Main.UIListLayout:GetPropertyChangedSignal( "AbsoluteContentSize" ):Connect( function ( )
	
	script.Parent.Frame.Main.CanvasSize = UDim2.new( 0, 0, 0, script.Parent.Frame.Main.UIListLayout.AbsoluteContentSize.Y )
	
end )

local EscapePatterns = {
	
	[ "(" ] = "%(",
		
	[ ")" ] = "%)",
	
	[ "." ] = "%.",
	
	[ "%" ] = "%%",
	
	[ "+" ] = "%+",
	
	[ "-" ] = "%-",
	
	[ "*" ] = "%*",
	
	[ "?" ] = "%?",
	
	[ "[" ] = "%[",
	
	[ "]" ] = "%]",
	
	[ "^" ] = "%^",
	
	[ "$" ] = "%$",
	
	[ "\0" ] = "%z"
	
	
}

local Hide = { }

local Keys = {
	
	{ Name = "S2_CursorColor", Text = "Cursor Color" },
	
	{ Name = "S2_CursorTransparency", Text = "Cursor Transparency", Min = 0, Max = 1 },
	
	{ Name = "S2_CursorBorder", Text = "Cursor Border Color" },
	
	{ Name = "S2_CursorBorderWidth", Text = "Cursor Border Width" },
	
	{ Name = "S2_CursorWidth", Text = "Cursor Width" },
	
	{ Name = "S2_CursorHeight", Text = "Cursor Height" },
	
	{ Name = "S2_CursorRotation", Text = "Cursor Rotation" },
	
	{ Name = "S2_CursorDistFromCenter", Text = "Distance From Center" },
	
	{ Name = "S2_CursorCenterColor", Text = "Center Color" },
	
	{ Name = "S2_CursorCenterTransparency", Text = "Center Transparency", Min = 0, Max = 1 },
	
	{ Name = "S2_CursorCenterBorder", Text = "Center Border Color" },
	
	{ Name = "S2_CursorCenterBorderWidth", Text = "Center Border Width" },
	
	{ Name = "S2_CursorCenterBorderTransparency", Text = "Center Border Transparency", Min = 0, Max = 1 },
	
	{ Name = "S2_CursorCenterWidth", Text = "Center Width" },
	
	{ Name = "S2_CursorCenterHeight", Text = "Center Height" },
	
	{ Name = "S2_CursorCenterRotation", Text = "Center Rotation" },
	
	{ Name = "S2_CursorSwapWidthHeight", Text = "Swap Width and Height" },
	
	{ Name = "S2_CursorDynamicMovement", Text = "Show Spread" },
	
	{ Name = "S2_CursorRotate", Text = "Rotate Cursor" },
	
	{ Name = "S2_CursorRotateReload", Text = "Rotate when reloading" },
	
	{ Name = "S2_CursorCenterRotateWith", Text = "Rotate Center with Cursor" }
}



local Presets = {
	
	[ "Partixels Preset" ] = { 
		
		S2_CursorDistFromCenter = 5,
		
		S2_CursorBorderWidth = 1,
		
		S2_CursorSwapWidthHeight = true,
		
		S2_CursorCenterRotateWith = true,
		
		S2_CursorCenterBorder = Color3.fromRGB( 255, 0, 255 ),
		
		S2_CursorCenterBorderTransparency = 0,
		
		S2_CursorCenterWidth = 4,
		
		S2_CursorBorder = Color3.fromRGB( 46, 46, 46 ),
		
		S2_CursorDynamicMovement = true,
		
		S2_CursorHeight = 6,
		
		S2_CursorCenterRotation = 0,
		
		S2_CursorCenterBorderWidth = 2,
		
		S2_CursorColor = Color3.fromRGB( 255, 0, 255 ),
		
		S2_CursorCenterTransparency = 1,
		
		S2_CursorRotateReload = true,
		
		S2_CursorRotate = true,
		
		S2_CursorWidth = 2,
		
		S2_CursorRotation = 0,
		
		S2_CursorCenterHeight = 4,
		
		S2_CursorCenterColor = Color3.fromRGB( 255, 0, 255 ),
		
		S2_CursorTransparency = 0

	},
	
	[ "Diamond boy" ] = { 
		
		S2_CursorDistFromCenter = 3,
		
		S2_CursorBorderWidth = 1,
		
		S2_CursorSwapWidthHeight = false,
		
		S2_CursorCenterBorder = Color3.fromRGB( 46, 46, 46 ),
		
		S2_CursorCenterBorderTransparency = 0,
		
		S2_CursorCenterWidth = 8,
		
		S2_CursorBorder = Color3.fromRGB( 46, 46, 46 ),
		
		S2_CursorDynamicMovement = true,
		
		S2_CursorHeight = 6,
		
		S2_CursorCenterRotateWith = true,
		
		S2_CursorCenterRotation = 45,
		
		S2_CursorCenterBorderWidth = 1,
		
		S2_CursorColor = Color3.fromRGB( 255, 0, 255 ),
		
		S2_CursorCenterTransparency = 0.3,
		
		S2_CursorRotateReload = true,
		
		S2_CursorRotate = true,
		
		S2_CursorWidth = 2,
		
		S2_CursorRotation = 0,
		
		S2_CursorCenterHeight = 8,
		
		S2_CursorCenterColor = Color3.fromRGB( 255, 0, 255 ),
		
		S2_CursorTransparency = 1
		
	},
	
	[ "Crosshair with square" ] = { 
	
		S2_CursorDistFromCenter = 4,
	
		S2_CursorBorderWidth = 0,
	
		S2_CursorSwapWidthHeight = false,
	
		S2_CursorCenterBorder = Color3.fromRGB( 127, 127, 127 ),
	
		S2_CursorCenterBorderTransparency = 0,
	
		S2_CursorCenterWidth = 6,
	
		S2_CursorBorder = Color3.fromRGB( 46, 46, 46 ),
	
		S2_CursorDynamicMovement = false,
	
		S2_CursorHeight = 8,
	
		S2_CursorCenterRotateWith = true,
	
		S2_CursorCenterRotation = 0,
	
		S2_CursorCenterBorderWidth = 2,
	
		S2_CursorColor = Color3.fromRGB( 255, 0, 255 ),
	
		S2_CursorCenterTransparency = 1,
	
		S2_CursorRotateReload = true,
	
		S2_CursorRotate = true,
	
		S2_CursorWidth = 2,
	
		S2_CursorRotation = 0,
	
		S2_CursorCenterHeight = 6,
	
		S2_CursorCenterColor = Color3.fromRGB( 255, 0, 255 ),
	
		S2_CursorTransparency = 0
	
	}
	
}

function ExportSettings( )
	
	local Export = { }
	
	for a, Setting in ipairs( Keys ) do
		
		local Val = ThemeUtil.GetThemeFor( Setting.Name )
		
		if typeof( Val ) == "Color3" then
			
			Val = { Val.r * 255, Val.g * 255, Val.b * 255 }
			
		end
		
		Export[ a ] = Val
		
	end
	
	return HttpService:JSONEncode( Export )
	
end

local Invalid, InvalidShare, InvalidPresets = true, true, true

local SettingsVisible, ShareVisible, PresetsVisible = true, false, false

function UpdateGui( Gui, Val )
	
	if ShareVisible then
		
		script.Parent.Frame.Export.Code.Text = ExportSettings( )
		
	else
		
		InvalidShare = true
		
	end
	
	if Gui.Name == "number" then
		
		Gui.Number.Text = Val
		
		Gui.Number.PlaceholderText = Gui.Number.Text
		
	elseif Gui.Name == "Color3" then
		
		Gui.Red.Text, Gui.Green.Text, Gui.Blue.Text = math.floor( Val.r * 255 ), math.floor( Val.g * 255 ), math.floor( Val.b * 255 )
		
		Gui.Red.PlaceholderText, Gui.Green.PlaceholderText, Gui.Blue.PlaceholderText = Gui.Red.Text, Gui.Green.Text, Gui.Blue.Text
		
	elseif Gui.Name == "boolean" then
		
		ThemeUtil.BindUpdate( Gui.Boolean, { BackgroundColor3 = Val and "Positive_Color3" or "Negative_Color3" } )
				
	end
	
end

function Redraw( )
	
	for _, Obj in ipairs( script.Parent.Frame.Main:GetChildren( ) ) do
		
		if Obj:IsA( "Frame" ) then Obj:Destroy( ) end
		
	end
	
	local Txt = script.Parent.Frame.Search.Text:lower( ):gsub( ".", EscapePatterns )
	
	for a, Setting in ipairs( Keys ) do
		
		if Setting.Text:lower( ):find( Txt ) then
			
			local b = Setting
			
			local Type = typeof( ThemeUtil.GetThemeFor( b.Name ) )
			
			local Gui =  script:FindFirstChild( Type ):Clone( )
			
			ThemeUtil.BindUpdate( Gui.TextButton, { BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
			
			Gui.TextButton.Text = b.Text
			
			Gui.TextButton.MouseButton1Click:Connect( function ( )
				
				SaveCursor:FireServer( b.Name )
				
				ThemeUtil.UpdateThemeFor( b.Name )
				
			end )
			
			if Type == "Color3" then
				
				ThemeUtil.BindUpdate( Gui.Display, { BackgroundColor3 = b.Name } )
				
				ThemeUtil.BindUpdate( { Gui.Blue, Gui.Green, Gui.Red }, { BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor" } )
				
				
			elseif Type == "number" then
				
				ThemeUtil.BindUpdate( Gui.Number, { BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor" } )
				
			elseif Type == "boolean" then
				
				ThemeUtil.BindUpdate( Gui.Boolean, { BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency" } )
				
			end
			
			Gui.LayoutOrder = a
			
			ThemeUtil.BindUpdate( Gui, { [ b.Name ] = UpdateGui } )
			
			for c, d in pairs( Gui:GetChildren( ) ) do
				
				if d.Name == "Boolean" then
					
					d.MouseButton1Click:Connect( function ( )
						
						local Val = not ThemeUtil.GetThemeFor( b.Name )
						
						SaveCursor:FireServer( b.Name, Val )
						
						ThemeUtil.UpdateThemeFor( b.Name, Val )
						
					end )
					
				elseif d ~= Gui.TextButton and d:IsA( "TextBox" ) then
					
					d.FocusLost:Connect( function ( )
						
						if Type == "number" then
							
							if Gui.Number.Text == "" then
								
								Gui.Number.Text = Gui.Number.PlaceholderText
								
								return
								
							end
							
							local Num = tonumber( Gui.Number.Text )
							
							if Num then
								
								if b.Min then
									
									Num = math.max( Num, b.Min )
									
								end
								
								if b.Max then
									
									Num = math.min( Num, b.Max )
									
								end
								
								SaveCursor:FireServer( b.Name, Num )
								
								ThemeUtil.UpdateThemeFor( b.Name, Num )
								
							end
							
						elseif Type == "Color3" then
							
							if Gui.Red.Text == "" then
								
								Gui.Red.Text = Gui.Red.PlaceholderText
								
							end
							
							if Gui.Green.Text == "" then
								
								Gui.Green.Text = Gui.Green.PlaceholderText
								
							end
							
							if Gui.Blue.Text == "" then
								
								Gui.Blue.Text = Gui.Blue.PlaceholderText
								
							end
							
							local r, g, bl = tonumber( Gui.Red.Text ), tonumber( Gui.Green.Text ), tonumber( Gui.Blue.Text )
							
							if r and g and bl then
								
								if b.Min then
									
									r = math.max( r, b.Min )
									
									g = math.max( g, b.Min )
									
									bl = math.max( bl, b.Min )
									
								end
								
								if b.Max then
									
									r = math.min( r, b.Max )
									
									g = math.min( g, b.Max )
									
									bl = math.min( bl, b.Max )
									
								end
								
								local Col = Color3.fromRGB( r, g, bl )
								
								SaveCursor:FireServer( b.Name, Col )
								
								ThemeUtil.UpdateThemeFor( b.Name, Col )
								
							end
							
						end
						
					end )
					
				end
				
			end
			
			Gui.Parent = script.Parent.Frame.Main
			
		end
		
	end
	
end

function RedrawPresets( )
	
	for _, Obj in ipairs( script.Parent.Frame.Presets:GetChildren( ) ) do
		
		if Obj:IsA( "TextButton" ) then Obj:Destroy( ) end
		
	end
	
	local Txt = script.Parent.Frame.Search.Text:lower( ):gsub( ".", EscapePatterns )
	
	if ( "Default" ):lower( ):find( Txt ) then
		
		local Preset = script.Preset:Clone( )
		
		Preset.Name = "Default" 
		
		Preset.LayoutOrder = 0
		
		ThemeUtil.BindUpdate( Preset.TextButton, { BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
		
		Preset.TextButton.Text = "Default"
		
		Preset.TextButton.MouseButton1Click:Connect( function ( )
			
			SaveCursor:FireServer( { } )
			
			for _, Settings in pairs( Keys ) do
				
				ThemeUtil.UpdateThemeFor( Settings.Name )
				
			end
			
		end )
		
		Preset.Parent = script.Parent.Frame.Presets
		
	end
	
	for Name, Settings in pairs( Presets ) do
		
		if Name:lower( ):find( Txt ) then
			
			local Preset = script.Preset:Clone( )
			
			Preset.Name = Name
			
			ThemeUtil.BindUpdate( Preset.TextButton, { BackgroundColor3 = "Secondary_BackgroundColor", BorderColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
			
			Preset.TextButton.Text = Name
			
			Preset.TextButton.MouseButton1Click:Connect( function ( )
				
				SaveCursor:FireServer( Settings )
				
				for Key, Value in pairs( Settings ) do
					
					ThemeUtil.UpdateThemeFor( Key, Value )
					
				end
				
			end )
			
			Preset.Parent = script.Parent.Frame.Presets
			
		end
		
	end
	
end

ThemeUtil.BindUpdate( script.Parent.Frame.Settings, { BackgroundColor3 = "Selection_Color3", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )

ThemeUtil.BindUpdate( script.Parent.Frame.Share, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )

script.Parent.Frame.Settings.MouseButton1Click:Connect( function ( )
	
	if not SettingsVisible then
		
		SettingsVisible = true
		
		PresetsVisible = false
		
		ShareVisible = false
		
		ThemeUtil.BindUpdate( script.Parent.Frame.Settings, { BackgroundColor3 = "Selection_Color3", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
		
		ThemeUtil.BindUpdate( { script.Parent.Frame.Share, script.Parent.Frame.Preset }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
		
		script.Parent.Frame.Main.Visible = true
		
		script.Parent.Frame.Search.Visible = true
		
		script.Parent.Frame.Search.Text = ""
		
		script.Parent.Frame.Export.Visible = false
		
		script.Parent.Frame.Import.Visible = false
		
		script.Parent.Frame.Presets.Visible = false
		
		if Invalid then Redraw( ) Invalid = nil end
		
	end
	
end )

script.Parent.Frame.Preset.MouseButton1Click:Connect( function ( )
	
	if not PresetsVisible then
		
		local Settings = { }
		
		for _, Key in ipairs( Keys ) do
			
			Settings[ Key.Name ] = ThemeUtil.GetThemeFor( Key.Name )
			
		end
		
		PresetsVisible = true
		
		SettingsVisible = false
		
		ShareVisible = false
		
		ThemeUtil.BindUpdate( script.Parent.Frame.Preset, { BackgroundColor3 = "Selection_Color3", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
		
		ThemeUtil.BindUpdate( { script.Parent.Frame.Settings, script.Parent.Frame.Share }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
		
		script.Parent.Frame.Export.Visible = false
		
		script.Parent.Frame.Import.Visible = false
		
		script.Parent.Frame.Main.Visible = false
		
		script.Parent.Frame.Search.Visible = true
		
		script.Parent.Frame.Search.Text = ""
		
		script.Parent.Frame.Presets.Visible = true
		
		if InvalidPresets then RedrawPresets( ) InvalidPresets = nil end
		
	end
	
end )

script.Parent.Frame.Share.MouseButton1Click:Connect( function ( )
	
	if not ShareVisible then
		
		ShareVisible = true
		
		PresetsVisible = false
		
		SettingsVisible = false
		
		ThemeUtil.BindUpdate( script.Parent.Frame.Share, { BackgroundColor3 = "Selection_Color3", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
		
		ThemeUtil.BindUpdate( { script.Parent.Frame.Settings, script.Parent.Frame.Preset }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
		
		script.Parent.Frame.Export.Visible = true
		
		script.Parent.Frame.Import.Visible = true
		
		script.Parent.Frame.Main.Visible = false
		
		script.Parent.Frame.Search.Visible = false
		
		script.Parent.Frame.Presets.Visible = false
		
		if InvalidShare then
			
			script.Parent.Frame.Export.Code.Text = ExportSettings( )
			
			InvalidShare = nil
			
		end
		
	end
	
end )

--[[script.Parent.Frame.Export.Code.Focused:Connect( function ( )
	
	script.Parent.Frame.Export.Code.CursorPosition = #script.Parent.Frame.Export.Code.Text
	
	script.Parent.Frame.Export.Code.SelectionStart = 1
	
end )]]

script.Parent.Frame.Import.Code.FocusLost:Connect( function ( )
	
	local Ran, Import = pcall( HttpService.JSONDecode, HttpService, script.Parent.Frame.Import.Code.Text )
	
	if Ran then
		
		for a, b in ipairs( Import ) do
			
			if type( b ) == "table" then
				
				Import[ a ] = Color3.fromRGB( b[ 1 ], b[ 2 ], b[ 3 ] )
				
			end
			
			ThemeUtil.UpdateThemeFor( Keys[ a ].Name, b )
			
			Import[ Keys[ a ].Name ] = b
			
			Import[ a ] = nil
			
		end
		
		SaveCursor:FireServer( Import )
		
		script.Parent.Frame.Import.Code.Text = ""
		
	end
	
end )

script.Parent.Frame.Search:GetPropertyChangedSignal( "Text" ):Connect( function ( )
	
	if script.Parent.Frame.Visible then
		
		if SettingsVisible then
			
			Redraw( )
			
		elseif PresetsVisible then
			
			RedrawPresets( )
			
		end
		
	else
		
		Invalid = true
		
	end
	
end )

ThemeUtil.WaitForCategory( "S2_Cursor" )

SaveCursor.OnClientEvent:Connect( function ( Settings )
	
	for Key, Val in pairs( Settings ) do
		
		ThemeUtil.UpdateThemeFor( Key, Val )
		
	end
	
end )

if script.Parent:FindFirstChild( "Toggle" ) then
	
	local function HandleTransparency( Obj, Transparency )
		
		Obj.BackgroundTransparency = Transparency
		
		if Transparency > 0.9 then
			
			ThemeUtil.BindUpdate( Obj, { TextColor3 = script.Parent.Open.Value and "Selection_Color3" or "Primary_BackgroundColor" } )
			
			Obj.TextStrokeTransparency = 0
			
		else
			
			ThemeUtil.BindUpdate( Obj, { TextColor3 = "Primary_TextColor" } )
			
			Obj.TextStrokeTransparency = 1
			
		end
		
	end
	
	ThemeUtil.BindUpdate( script.Parent.Toggle, { TextTransparency = "Primary_TextTransparency", TextStrokeColor3 = "Primary_TextColor", Primary_BackgroundTransparency = HandleTransparency } )
	
	local function ToggleGui( )
		
		if script.Parent.Open.Value and _G.OpenPxlGui then
			
			_G.OpenPxlGui.Value = false
			
		end
		
		if script.Parent.Open.Value then
			
			_G.OpenPxlGui = script.Parent.Open
			
			Core.ForceShowCursor = true
			
			script.Parent.Parent.GunCursor.Center.Visible = true
			
			game:GetService( "UserInputService" ).MouseIconEnabled = false
			
			if not Core.CursorHeartbeat then
				
				Core.RunCursorHeartbeat( )
				
			end
			
			if Invalid then Redraw( ) Invalid = nil end
			
			script.Parent.Frame.Visible = true
			
			TweenService:Create( script.Parent.Frame, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Position = UDim2.new( 0.05, 0, 0.43, 0 ), Size = UDim2.new( 0.3, 0, 0.4, 0 ) } ):Play( )
			
			ThemeUtil.BindUpdate( script.Parent.Toggle, { BackgroundColor3 = script.Parent.Open.Value and "Selection_Color3" or "Primary_BackgroundColor" } )
			
		else
			
			_G.OpenPxlGui = nil
			
			Core.ForceShowCursor = nil
			
			local Tween = TweenService:Create( script.Parent.Frame, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Position = script.Parent.Toggle.Position, Size = script.Parent.Toggle.Size } )
			
			Tween.Completed:Connect( function ( State )
				
				if State == Enum.PlaybackState.Completed then
					
					script.Parent.Frame.Visible = false
					
				end
				
			end )
			
			Tween:Play( )
			
			ThemeUtil.BindUpdate( script.Parent.Toggle, { BackgroundColor3 = script.Parent.Open.Value and "Selection_Color3" or "Primary_BackgroundColor" } )
			
		end
		
	end
	
	script.Parent.Toggle.MouseButton1Click:Connect( function ( )
		
		script.Parent.Open.Value = not script.Parent.Open.Value
		
	end )
	
	script.Parent.Open:GetPropertyChangedSignal( "Value" ):Connect( ToggleGui )
	
	ToggleGui( )
	
else
	
	script.Parent.Frame.Visible = true
	
	script.Parent.Frame:GetPropertyChangedSignal( "Visible" ):Connect( function ( )
		
		if script.Parent.Frame.Visible and Invalid then
			
			Redraw( )
			
		end
		
	end )
	
	Redraw( )
	
end