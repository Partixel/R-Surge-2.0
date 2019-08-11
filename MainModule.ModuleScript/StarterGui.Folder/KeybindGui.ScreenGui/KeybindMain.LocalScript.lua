local KBU = require( game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "KeybindUtil" ) )

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ):WaitForChild( "ThemeUtil" ) )

local TweenService = game:GetService( "TweenService" )

ThemeUtil.BindUpdate( script.Parent.KeybindFrame, { BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency" } )

ThemeUtil.BindUpdate( script.Parent.KeybindFrame.Main, { ScrollBarImageColor3 = "Secondary_BackgroundColor", ScrollBarImageTransparency = "Secondary_BackgroundTransparency" } )

ThemeUtil.BindUpdate( { script.Parent.KeybindFrame.Search, script.Parent.KeybindFrame.Context.Gamepad, script.Parent.KeybindFrame.Context.Keyboard, script.Parent.KeybindFrame.Context:FindFirstChild( "Name" ), script.Parent.KeybindFrame.Context.Toggle }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency" } )

ThemeUtil.BindUpdate( { script.Parent.KeybindFrame.Search, script.Parent.KeybindFrame.Context.Gamepad, script.Parent.KeybindFrame.Context.Keyboard, script.Parent.KeybindFrame.Context:FindFirstChild( "Name" ), script.Parent.KeybindFrame.Context.Toggle }, { TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )

ThemeUtil.BindUpdate( script.Parent.KeybindFrame.Search, { PlaceholderColor3 = "Secondary_TextColor" } )

script.Parent.KeybindFrame.Main.UIListLayout:GetPropertyChangedSignal( "AbsoluteContentSize" ):Connect( function ( )
	
	script.Parent.KeybindFrame.Main.CanvasSize = UDim2.new( 0, 0, 0, script.Parent.KeybindFrame.Main.UIListLayout.AbsoluteContentSize.Y )
	
	if script.Parent.KeybindFrame.Main.UIListLayout.AbsoluteContentSize.Y > script.Parent.KeybindFrame.Main.AbsoluteSize.Y then
		
		script.Parent.KeybindFrame.Context.Size = UDim2.new( 1, -5, 0, 25 )
		
	else
		
		script.Parent.KeybindFrame.Context.Size = UDim2.new( 1, 0, 0, 25 )
		
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
	
	for _, Obj in ipairs( script.Parent.KeybindFrame.Main:GetChildren( ) ) do
		
		if Obj:IsA( "Frame" ) or Obj:IsA( "TextButton" ) then Obj:Destroy( ) end
		
	end
	
	local Binds = KBU.GetBinds( )
	
	local Txt = script.Parent.KeybindFrame.Search.Text:lower( ):gsub( ".", EscapePatterns )
	
	local Categories = { }
	
	for _, Bind in ipairs( Binds ) do
		
		if Bind.Name:lower( ):find( Txt ) and not Bind.NonRebindable then
			
			local Category = Bind.Category or "Uncategorised"
			
			Categories[ Category ] = Categories[ Category ] or { }
			
			local Base = script.Base:Clone( )
			
			Base.Name = Bind.Name
			
			Categories[ Category ][ #Categories[ Category ] + 1 ] = Base
			
			ThemeUtil.BindUpdate( { Base.Gamepad, Base.Keyboard, Base.Main, Base.Toggle }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
			
			Base.Main.Text = Bind.Name
			
			Base.Main.MouseButton1Click:Connect( function ( )
				
				KBU.Defaults( Bind.Name )
				
				KBU.WriteToObj( Base.Keyboard, Bind.Key )
				
				KBU.WriteToObj( Base.Gamepad, Bind.PadKey )
				
				KBU.WriteToObj( Base.Toggle, Bind.ToggleState or false )
				
			end )
			
			KBU.WriteToObj( Base.Keyboard, Bind.Key )
			
			Base.Keyboard.MouseButton1Click:Connect( function ( )
				
				KBU.Rebind( Bind.Name, Enum.UserInputType.Keyboard, Base.Keyboard )
				
				KBU.WriteToObj( Base.Keyboard, Bind.Key )
				
			end )
			
			KBU.WriteToObj( Base.Gamepad, Bind.PadKey )
			
			Base.Gamepad.MouseButton1Click:Connect( function ( )
				
				KBU.Rebind( Bind.Name, Enum.UserInputType.Gamepad1, Base.Gamepad )
				
				KBU.WriteToObj( Base.Gamepad, Bind.PadKey )
				
			end )
			
			if Bind.CanToggle then
				
				KBU.WriteToObj( Base.Toggle, Bind.ToggleState or false )
				
				Base.Toggle.MouseButton1Click:Connect( function ( )
					
					KBU.Rebind( Bind.Name, "Toggle", Base.Toggle )
					
					KBU.WriteToObj( Base.Toggle, Bind.ToggleState or false )
					
				end )
				
			else
				
				Base.Toggle.Visible = false
				
			end
			
		end
		
	end
	
	for a, b in pairs( Categories ) do
		
		local Cat = script.Category:Clone( )
		
		ThemeUtil.BindUpdate( { Cat.Button.BarL, Cat.Button.BarR, Cat.Button.BarR2 }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency" } )
		
		ThemeUtil.BindUpdate( { Cat.Button.OpenIndicator, Cat.Button.TitleText }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
		
		Cat.Name = a
		
		Cat.Button.OpenIndicator.Text = not Hide[ a ] and  "Λ" or "V"
		
		Cat.Button.TitleText.Text = a
		
		Cat.Button.MouseButton1Click:Connect( function ( )
			
			Hide[ a ] = not Hide[ a ]
			
			TweenService:Create( Cat, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Size = UDim2.new( 1, 0, 0, Hide[ a ] and Cat.Button.Size.Y.Offset or Cat.UIListLayout.AbsoluteContentSize.Y ) } ):Play( )
			
			Cat.Button.OpenIndicator.Text = not Hide[ a ] and  "Λ" or "V"
			
		end )
		
		Cat.Parent = script.Parent.KeybindFrame.Main
		
		for _, Obj in ipairs( b ) do
			
			Obj.Parent = Cat
			
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
			
			if Invalid then Redraw( ) Invalid = nil end
			
			script.Parent.KeybindFrame.Visible = true
			
			TweenService:Create( script.Parent.KeybindFrame, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Position = UDim2.new( 0.05, 0, 0.43, 0 ), Size = UDim2.new( 0.3, 0, 0.4, 0 ) } ):Play( )
			
			ThemeUtil.BindUpdate( script.Parent.Toggle, { BackgroundColor3 = script.Parent.Open.Value and "Selection_Color3" or "Primary_BackgroundColor" } )
			
		else
			
			_G.OpenPxlGui = nil
			
			KBU.Rebinding = nil
			
			local Tween = TweenService:Create( script.Parent.KeybindFrame, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Position = script.Parent.Toggle.Position, Size = script.Parent.Toggle.Size } )
			
			Tween.Completed:Connect( function ( State )
				
				if State == Enum.PlaybackState.Completed then
					
					script.Parent.KeybindFrame.Visible = false
					
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
	
	script.Parent.KeybindFrame.Visible = true
	
	script.Parent.KeybindFrame:GetPropertyChangedSignal( "Visible" ):Connect( function ( )
		
		if script.Parent.KeybindFrame.Visible and Invalid then
			
			Redraw( )
			
		end
		
	end )
	
	Redraw( )
	
end