local KBU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ) )

local KeybindGui = script.Parent:WaitForChild( "KeybindFrame" )

ThemeUtil.BindUpdate( KeybindGui, "BackgroundColor3", "SecondaryBackground" )

ThemeUtil.BindUpdate( KeybindGui.Main, "ScrollBarImageColor3", "Background" )

ThemeUtil.ApplyBasicTheming( { KeybindGui.Search, KeybindGui.Bar, KeybindGui.Context.Context.Gamepad, KeybindGui.Context.Context.Keyboard, KeybindGui.Context.Context:FindFirstChild( "Name" ), KeybindGui.Context.Context.Toggle } )

ThemeUtil.BindUpdate( KeybindGui.Search, "PlaceholderColor3", "SecondaryTextColor" )

ThemeUtil.ApplyBasicTheming( KeybindGui.Search )

local function Redraw( )
	
	local Old = KeybindGui.Main:GetChildren( )
	
	for a = 1, #Old do
		
		if Old[ a ]:IsA( "Frame" ) then Old[ a ]:Destroy( ) end
		
	end
	
	local Binds = KBU.GetBinds( )
	
	local Txt = KeybindGui.Search.Text
	
	local Found = 0
	
	for a, b in ipairs( Binds ) do
		
		if b.Name:lower( ):find( Txt ) and not b.NonRebindable then
			
			Found = Found + 1
			
			local Base = KeybindGui.Base:Clone( )
			
			Base.Name = b.Name
			
			Base.Visible = true
			
			ThemeUtil.ApplyBasicTheming( { Base.Gamepad, Base.Keyboard, Base.Main, Base.Toggle } )
			
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
	
	KeybindGui.Main.CanvasSize = UDim2.new( 0, 0, 0, 40 * Found )
	
	KeybindGui.Context.CanvasSize = UDim2.new( 0, 0, 0, 40 * Found )
	
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