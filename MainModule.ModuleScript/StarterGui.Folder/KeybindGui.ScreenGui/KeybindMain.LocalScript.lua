local KBU = require( game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):WaitForChild( "KeybindUtil" ) )

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ) )

local TweenService = game:GetService( "TweenService" )

ThemeUtil.BindUpdate( script.Parent.KeybindFrame, { BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency" } )

ThemeUtil.BindUpdate( script.Parent.KeybindFrame.Main, { ScrollBarImageColor3 = "Secondary_BackgroundColor", ScrollBarImageTransparency = "Secondary_BackgroundTransparency" } )

ThemeUtil.BindUpdate( { script.Parent.KeybindFrame.Search, script.Parent.KeybindFrame.Context.Gamepad, script.Parent.KeybindFrame.Context.Keyboard, script.Parent.KeybindFrame.Context:FindFirstChild( "Name" ), script.Parent.KeybindFrame.Context.Toggle }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency" } )

ThemeUtil.BindUpdate( { script.Parent.KeybindFrame.Search, script.Parent.KeybindFrame.Context.Gamepad, script.Parent.KeybindFrame.Context.Keyboard, script.Parent.KeybindFrame.Context:FindFirstChild( "Name" ), script.Parent.KeybindFrame.Context.Toggle }, { TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )

ThemeUtil.BindUpdate( script.Parent.KeybindFrame.Search, { PlaceholderColor3 = "Secondary_TextColor" } )

script.Parent.KeybindFrame.Main.UIListLayout:GetPropertyChangedSignal( "AbsoluteContentSize" ):Connect( function ( )
	
	script.Parent.KeybindFrame.Main.CanvasSize = UDim2.new( 0, 0, 0, script.Parent.KeybindFrame.Main.UIListLayout.AbsoluteContentSize.Y )
	
	if script.Parent.KeybindFrame.Main.UIListLayout.AbsoluteContentSize.Y > script.Parent.KeybindFrame.Main.AbsoluteSize.Y then
		
		script.Parent.KeybindFrame.Context.Size = UDim2.new( 1, -5, 0, 40 )
		
	else
		
		script.Parent.KeybindFrame.Context.Size = UDim2.new( 1, 0, 0, 40 )
		
	end
	
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

function Redraw( )
	
	local Old = script.Parent.KeybindFrame.Main:GetChildren( )
	
	for a = 1, #Old do
		
		if Old[ a ]:IsA( "Frame" ) or Old[ a ]:IsA( "TextButton" ) then Old[ a ]:Destroy( ) end
		
	end
	
	local Binds = KBU.GetBinds( )
	
	local Txt = script.Parent.KeybindFrame.Search.Text:lower( ):gsub( ".", EscapePatterns )
	
	local Categories = { }
	
	for a = 1, #Binds do
		
		if Binds[ a ].Name:lower( ):find( Txt ) and not Binds[ a ].NonRebindable then
			
			local Category = Binds[ a ].Category or "Uncategorised"
			
			Categories[ Category ] = Categories[ Category ] or { }
			
			local Base = script.Parent.KeybindFrame.Base:Clone( )
			
			Base.Name = Binds[ a ].Name
			
			Categories[ Category ][ #Categories[ Category ] + 1 ] = Base
			
			Base.Visible = true
			
			ThemeUtil.BindUpdate( { Base.Gamepad, Base.Keyboard, Base.Main, Base.Toggle }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
			
			Base.Main.Text = Binds[ a ].Name
			
			Base.Main.MouseButton1Click:Connect( function ( )
				
				KBU.Defaults( Binds[ a ].Name )
				
				KBU.WriteToObj( Base.Keyboard, Binds[ a ].Key )
				
				KBU.WriteToObj( Base.Gamepad, Binds[ a ].PadKey )
				
				KBU.WriteToObj( Base.Toggle, Binds[ a ].ToggleState or false )
				
			end )
			
			KBU.WriteToObj( Base.Keyboard, Binds[ a ].Key )
			
			Base.Keyboard.MouseButton1Click:Connect( function ( )
				
				KBU.Rebind( Binds[ a ].Name, Enum.UserInputType.Keyboard, Base.Keyboard )
				
				KBU.WriteToObj( Base.Keyboard, Binds[ a ].Key )
				
			end )
			
			KBU.WriteToObj( Base.Gamepad, Binds[ a ].PadKey )
			
			Base.Gamepad.MouseButton1Click:Connect( function ( )
				
				KBU.Rebind( Binds[ a ].Name, Enum.UserInputType.Gamepad1, Base.Gamepad )
				
				KBU.WriteToObj( Base.Gamepad, Binds[ a ].PadKey )
				
			end )
			
			if Binds[ a ].CanToggle then
				
				KBU.WriteToObj( Base.Toggle, Binds[ a ].ToggleState or false )
				
				Base.Toggle.MouseButton1Click:Connect( function ( )
					
					KBU.Rebind( Binds[ a ].Name, "Toggle", Base.Toggle )
					
					KBU.WriteToObj( Base.Toggle, Binds[ a ].ToggleState or false )
					
				end )
				
			else
				
				Base.Toggle.Visible = false
				
			end
			
		end
		
	end
	
	for a, b in pairs( Categories ) do
		
		local Cat = script.Parent.KeybindFrame.Category:Clone( )
		
		ThemeUtil.BindUpdate( { Cat.Button.BarL, Cat.Button.BarR, Cat.Button.BarR2 }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency" } )
		
		ThemeUtil.BindUpdate( { Cat.Button.OpenIndicator, Cat.Button.TitleText }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
		
		Cat.Visible = true
		
		Cat.Name = a
		
		Cat.Button.OpenIndicator.Text = not Hide[ a ] and  "Λ" or "V"
		
		Cat.Button.TitleText.Text = a
		
		Cat.Button.MouseButton1Click:Connect( function ( )
			
			Hide[ a ] = not Hide[ a ]
			
			TweenService:Create( Cat, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Size = UDim2.new( 1, 0, 0, Hide[ a ] and Cat.Button.Size.Y.Offset or Cat.UIListLayout.AbsoluteContentSize.Y ) } ):Play( )
			
			Cat.Button.OpenIndicator.Text = not Hide[ a ] and  "Λ" or "V"
			
		end )
		
		Cat.Parent = script.Parent.KeybindFrame.Main
		
		for c = 1, #b do
			
			b[ c ].Parent = Cat
			
		end
		
		Cat.Size = UDim2.new( 1, 0, 0, Hide[ a ] and Cat.Button.Size.Y.Offset or Cat.UIListLayout.AbsoluteContentSize.Y )
		
	end
	
end

local Invalid = true

script.Parent.KeybindFrame.Search:GetPropertyChangedSignal( "Text" ):Connect( function ( )
	
	if script.Parent.KeybindFrame.Visible then
		
		Redraw( )
		
	else
		
		Invalid = true
		
	end
	
end )

KBU.BindAdded:Connect( function ( )
	
	if script.Parent.KeybindFrame.Visible then
		
		Redraw( )
		
	else
		
		Invalid = true
		
	end
	
end )

KBU.BindChanged:Connect( function ( Name )
	
	if not KBU.GetBind( Name ) or not script.Parent.KeybindFrame.Main:FindFirstChild( Name, true ) then
		
		if script.Parent.KeybindFrame.Visible then
			
			Redraw( )
			
		else
			
			Invalid = true
			
		end
		
	end
	
end )

if script.Parent:FindFirstChild( "Toggle" ) then
	
	local function UpdateColor( )
		
		script.Parent.Toggle.BackgroundColor3 = script.Parent.Open.Value and ThemeUtil.GetThemeFor( "Positive_Color3" ) or ThemeUtil.GetThemeFor( "Primary_BackgroundColor" )
		
		local Transparency = ThemeUtil.GetThemeFor( "Primary_BackgroundTransparency" )
		
		script.Parent.Toggle.BackgroundTransparency = Transparency
		
		if Transparency > 0.9 then
			
			script.Parent.Toggle.TextStrokeColor3 = ThemeUtil.GetThemeFor( "Primary_TextColor" )
			
			script.Parent.Toggle.TextColor3 = script.Parent.Open.Value and ThemeUtil.GetThemeFor( "Positive_Color3" ) or ThemeUtil.GetThemeFor( "Primary_BackgroundColor" )
			
			script.Parent.Toggle.TextStrokeTransparency = 0
			
		else
			
			script.Parent.Toggle.TextColor3 = ThemeUtil.GetThemeFor( "Primary_TextColor" )
			
			script.Parent.Toggle.TextStrokeTransparency = 1
			
		end
		
	end
	
	local function ToggleGui( )
		
		if script.Parent.Open.Value and script.Parent.Parent:FindFirstChild( "ThemeGui" ) and script.Parent.Parent.ThemeGui.Open.Value then
			
			script.Parent.Parent.ThemeGui.Open.Value = false
			
		end
		
		if script.Parent.Open.Value then
			
			if Invalid then Redraw( ) Invalid = nil end
			
			script.Parent.KeybindFrame.Visible = true
			
			TweenService:Create( script.Parent.KeybindFrame, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Position = UDim2.new( 0.05, 0, 0.43, 0 ), Size = UDim2.new( 0.3, 0, 0.4, 0 ) } ):Play( )
			
			UpdateColor( )
			
		else
			
			KBU.Rebinding = nil
			
			local Tween = TweenService:Create( script.Parent.KeybindFrame, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Position = script.Parent.Toggle.Position, Size = script.Parent.Toggle.Size } )
			
			Tween.Completed:Connect( function ( State )
				
				if State == Enum.PlaybackState.Completed then
					
					script.Parent.KeybindFrame.Visible = false
					
				end
				
			end )
			
			Tween:Play( )
			
			UpdateColor( )
			
		end
		
	end
	
	ThemeUtil.BindUpdate( script.Parent.Toggle, { BackgroundColor3 = UpdateColor, TextTransparency = "Primary_TextTransparency" } )
	
	script.Parent.Toggle.MouseButton1Click:Connect( function ( )
		
		script.Parent.Open.Value = not script.Parent.Open.Value
		
	end )
	
	script.Parent.Open:GetPropertyChangedSignal( "Value" ):Connect( ToggleGui )
	
	ToggleGui( )
	
else
	
	script.Parent.KeybindFrame.Visible = true
	
	script.Parent.KeybindFrame:GetPropertyChangedSignal( "Visible" ):Connect( function ( )
		
		if script.Parent.KeybindFrame.Visible and Invalid then
			
			Redraw( )
			
		end
		
	end )
	
	Redraw( )
	
end