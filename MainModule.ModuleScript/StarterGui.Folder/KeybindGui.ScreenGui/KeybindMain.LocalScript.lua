local KBU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ) )

local KeybindGui = script.Parent:WaitForChild( "KeybindFrame" )

ThemeUtil.BindUpdate( KeybindGui, "BackgroundColor3", "Background" )

ThemeUtil.BindUpdate( KeybindGui.Main, "ScrollBarImageColor3", "SecondaryBackground" )

ThemeUtil.BindUpdate( { KeybindGui.Search, KeybindGui.Bar, KeybindGui.Context.Context.Gamepad, KeybindGui.Context.Context.Keyboard, KeybindGui.Context.Context:FindFirstChild( "Name" ), KeybindGui.Context.Context.Toggle }, "BackgroundColor3", "SecondaryBackground" )

ThemeUtil.BindUpdate( { KeybindGui.Search, KeybindGui.Context.Context.Gamepad, KeybindGui.Context.Context.Keyboard, KeybindGui.Context.Context:FindFirstChild( "Name" ), KeybindGui.Context.Context.Toggle }, "TextColor3", "TextColor" )

ThemeUtil.BindUpdate( KeybindGui.Search, "PlaceholderColor3", "SecondaryTextColor" )

local Hide = { }

function Redraw( )
	
	local Old = KeybindGui.Main:GetChildren( )
	
	for a = 1, #Old do
		
		if Old[ a ]:IsA( "Frame" ) or Old[ a ]:IsA( "TextButton" ) then Old[ a ]:Destroy( ) end
		
	end
	
	local Binds = KBU.GetBinds( )
	
	local Txt = KeybindGui.Search.Text
	
	local Categories = { }
	
	for a, b in ipairs( Binds ) do
		
		if b.Name:lower( ):find( Txt ) and not b.NonRebindable then
			
			local Category = b.Category or "Uncategorised"
			
			Categories[ Category ] = Categories[ Category ] or { }
			
			if not Hide[ b.Category or "Uncategorised" ] then
				
				local Base = KeybindGui.Base:Clone( )
				
				Categories[ Category ][ #Categories[ Category ] + 1 ] = Base
				
				Base.Name = b.Name
				
				Base.Visible = true
				
				ThemeUtil.BindUpdate( { Base.Gamepad, Base.Keyboard, Base.Main, Base.Toggle }, "BackgroundColor3", "SecondaryBackground" )
				
				ThemeUtil.BindUpdate( { Base.Gamepad, Base.Keyboard, Base.Main, Base.Toggle }, "TextColor3", "TextColor" )
				
				Base.Main.Text = b.Name
				
				Base.Main.MouseButton1Click:Connect( function ( )
					
					KBU.Defaults( b.Name )
					
					KBU.WriteToObj( Base.Keyboard, b.Key )
					
					KBU.WriteToObj( Base.Gamepad, b.PadKey )
					
					KBU.WriteToObj( Base.Toggle, b.ToggleState or false )
					
				end )
				
				KBU.WriteToObj( Base.Keyboard, b.Key )
				
				Base.Keyboard.MouseButton1Click:Connect( function ( )
					
					KBU.Rebind( b.Name, Enum.UserInputType.Keyboard, Base.Keyboard )
					
					KBU.WriteToObj( Base.Keyboard, b.Key )
					
				end )
				
				KBU.WriteToObj( Base.Gamepad, b.PadKey )
				
				Base.Gamepad.MouseButton1Click:Connect( function ( )
					
					KBU.Rebind( b.Name, Enum.UserInputType.Gamepad1, Base.Gamepad )
					
					KBU.WriteToObj( Base.Gamepad, b.PadKey )
					
				end )
				
				if b.CanToggle then
					
					KBU.WriteToObj( Base.Toggle, b.ToggleState or false )
					
					Base.Toggle.MouseButton1Click:Connect( function ( )
						
						KBU.Rebind( b.Name, "Toggle", Base.Toggle )
						
						KBU.WriteToObj( Base.Toggle, b.ToggleState or false )
						
					end )
					
				else
					
					Base.Toggle.Visible = false
					
				end
				
				Base.Parent = KeybindGui.Main
				
			end
			
		end
		
	end
	
	local CategoryOrdered = { }
	
	for a, b in pairs( Categories ) do
		
		CategoryOrdered[ #CategoryOrdered + 1 ] = a
		
	end
	
	table.sort( CategoryOrdered )
	
	for a = 1, #CategoryOrdered do
		
		local Cat = KeybindGui.Category:Clone( )
		
		ThemeUtil.BindUpdate( { Cat, Cat.Bar, Cat.OpenIndicator, Cat.TitleText }, "BackgroundColor3", "SecondaryBackground" )
		
		ThemeUtil.BindUpdate( { Cat, Cat.OpenIndicator, Cat.TitleText }, "TextColor3", "TextColor" )
		
		Cat.Visible = true
		
		Cat.LayoutOrder = a * 2 - 1
		
		Cat.OpenIndicator.Text = not Hide[ CategoryOrdered[ a ] ] and  "Λ" or "V"
		
		local Binds = Categories[ CategoryOrdered[ a ] ]
		
		Cat.TitleText.Text = CategoryOrdered[ a ]
		
		Cat.MouseButton1Click:Connect( function ( )
			
			Hide[ CategoryOrdered[ a ] ] = not Hide[ CategoryOrdered[ a ] ]
			
			Redraw( )
			
		end )
		
		Cat.Parent = KeybindGui.Main
		
		if not Hide[ CategoryOrdered[ a ] ] then
			
			for b = 1, #Binds do
				
				Binds[ b ].LayoutOrder = a * 2
				
			end
			
		end
		
	end
	
	KeybindGui.Main.CanvasSize = UDim2.new( 0, 0, 0, KeybindGui.Main.UIListLayout.AbsoluteContentSize.Y )
	
	KeybindGui.Context.CanvasSize = UDim2.new( 0, 0, 0, KeybindGui.Main.UIListLayout.AbsoluteContentSize.Y )
	
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
			
			script.Parent.KeybindFrame:TweenPosition( UDim2.new( 0.05, 0, 0.43, 0 ), nil, Enum.EasingStyle.Sine, 0.5, true )
			
			UpdateColor( )
			
		else
			
			KBU.Rebinding = nil
			
			script.Parent.KeybindFrame:TweenPosition( UDim2.new( 0.05, 0, 1, 0 ), nil, Enum.EasingStyle.Sine, 0.5, true, function ( )
				
				script.Parent.KeybindFrame.Visible = false
				
			end )
			
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