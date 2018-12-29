local KBU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ) )

local TweenService = game:GetService( "TweenService" )

local KeybindGui = script.Parent:WaitForChild( "KeybindFrame" )

ThemeUtil.BindUpdate( KeybindGui, "BackgroundColor3", "Background" )

ThemeUtil.BindUpdate( KeybindGui.Main, "ScrollBarImageColor3", "SecondaryBackground" )

ThemeUtil.BindUpdate( { KeybindGui.Search, KeybindGui.Bar, KeybindGui.Context.Context.Gamepad, KeybindGui.Context.Context.Keyboard, KeybindGui.Context.Context:FindFirstChild( "Name" ), KeybindGui.Context.Context.Toggle }, "BackgroundColor3", "SecondaryBackground" )

ThemeUtil.BindUpdate( { KeybindGui.Search, KeybindGui.Context.Context.Gamepad, KeybindGui.Context.Context.Keyboard, KeybindGui.Context.Context:FindFirstChild( "Name" ), KeybindGui.Context.Context.Toggle }, "TextColor3", "TextColor" )

ThemeUtil.BindUpdate( KeybindGui.Search, "PlaceholderColor3", "SecondaryTextColor" )

KeybindGui.Main.UIListLayout:GetPropertyChangedSignal( "AbsoluteContentSize" ):Connect( function ( )
	
	KeybindGui.Main.CanvasSize = UDim2.new( 0, 0, 0, KeybindGui.Main.UIListLayout.AbsoluteContentSize.Y )
	
	KeybindGui.Context.CanvasSize = UDim2.new( 0, 0, 0, KeybindGui.Main.UIListLayout.AbsoluteContentSize.Y )
	
end )

local Hide = { }

function Redraw( )
	
	local Old = KeybindGui.Main:GetChildren( )
	
	for a = 1, #Old do
		
		if Old[ a ]:IsA( "Frame" ) or Old[ a ]:IsA( "TextButton" ) then Old[ a ]:Destroy( ) end
		
	end
	
	local Binds = KBU.GetBinds( )
	
	local Txt = KeybindGui.Search.Text
	
	local Categories = { }
	
	for a = 1, #Binds do
		
		if Binds[ a ].Name:lower( ):find( Txt ) and not Binds[ a ].NonRebindable then
			
			local Category = Binds[ a ].Category or "Uncategorised"
			
			Categories[ Category ] = Categories[ Category ] or { }
			
			local Base = KeybindGui.Base:Clone( )
			
			Base.Name = Binds[ a ].Name
			
			Categories[ Category ][ #Categories[ Category ] + 1 ] = Base
			
			Base.Visible = true
			
			ThemeUtil.BindUpdate( { Base.Gamepad, Base.Keyboard, Base.Main, Base.Toggle }, "BackgroundColor3", "SecondaryBackground" )
			
			ThemeUtil.BindUpdate( { Base.Gamepad, Base.Keyboard, Base.Main, Base.Toggle }, "TextColor3", "TextColor" )
			
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
		
		local Cat = KeybindGui.Category:Clone( )
		
		ThemeUtil.BindUpdate( { Cat.Button.Bar, Cat.Button.OpenIndicator, Cat.Button.TitleText }, "BackgroundColor3", "SecondaryBackground" )
		
		ThemeUtil.BindUpdate( { Cat.Button.OpenIndicator, Cat.Button.TitleText }, "TextColor3", "TextColor" )
		
		Cat.Visible = true
		
		Cat.Name = a
		
		Cat.Button.OpenIndicator.Text = not Hide[ a ] and  "Λ" or "V"
		
		Cat.Button.TitleText.Text = a
		
		Cat.Button.MouseButton1Click:Connect( function ( )
			
			Hide[ a ] = not Hide[ a ]
			
			TweenService:Create( Cat, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Size = UDim2.new( 1, 0, 0, Hide[ a ] and Cat.Button.Size.Y.Offset or Cat.UIListLayout.AbsoluteContentSize.Y ) } ):Play( )
			
			Cat.Button.OpenIndicator.Text = not Hide[ a ] and  "Λ" or "V"
			
		end )
		
		Cat.Parent = KeybindGui.Main
		
		for c = 1, #b do
			
			b[ c ].Parent = Cat
			
		end
		
		Cat.Size = UDim2.new( 1, 0, 0, Hide[ a ] and Cat.Button.Size.Y.Offset or Cat.UIListLayout.AbsoluteContentSize.Y )
		
	end
	
end

local Invalid = true

KeybindGui.Search:GetPropertyChangedSignal( "Text" ):Connect( function ( )
	
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
	
	if not KBU.GetBind( Name ) or not KeybindGui.Main:FindFirstChild( Name ) then
		
		if script.Parent.KeybindFrame.Visible then
			
			Redraw( )
			
		else
			
			Invalid = true
			
		end
		
	end
	
end )

if script.Parent:FindFirstChild( "Keybinds" ) then
	
	local KeybindOpen
	
	function UpdateColor( )
		
		script.Parent.Keybinds.BackgroundColor3 = KeybindOpen and ThemeUtil.GetThemeFor( "PositiveColor" ) or ThemeUtil.GetThemeFor( "Background" )
		
		script.Parent.Keybinds.TextColor3 = ThemeUtil.GetThemeFor( "TextColor" )
		
	end
	
	ThemeUtil.BindUpdate( script.Parent.Keybinds, "BackgroundColor3", UpdateColor )
	
	script.Parent.Keybinds.MouseButton1Click:Connect( function ( )
		
		KeybindOpen = not KeybindOpen
		
		if KeybindOpen then
			
			if Invalid then Redraw( ) Invalid = nil end
			
			script.Parent.KeybindFrame.Visible = true
			
			TweenService:Create( KeybindGui, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Position = UDim2.new( 0.05, 0, 0.43, 0 ), Size = UDim2.new( 0.3, 0, 0.4, 0 ) } ):Play( )
			
			UpdateColor( )
			
		else
			
			KBU.Rebinding = nil
			
			local Tween = TweenService:Create( KeybindGui, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Position = script.Parent.Keybinds.Position, Size = script.Parent.Keybinds.Size } )
			
			Tween.Completed:Connect( function ( State )
				
				if State == Enum.PlaybackState.Completed then
					
					KeybindGui.Visible = false
					
				end
				
			end )
			
			Tween:Play( )
			
			UpdateColor( )
			
		end
		
	end )
	
else
	
	KeybindOpen = true
	
	script.Parent.KeybindFrame.Visible = true
	
	script.Parent.KeybindFrame:GetPropertyChangedSignal( "Visible" ):Connect( function ( )
		
		if script.Parent.KeybindFrame.Visible and Invalid then
			
			Redraw( )
			
		end
		
	end )
	
	Redraw( )
	
end