local TweenService, ThemeUtil = game:GetService( "TweenService" ), require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ):WaitForChild( "ThemeUtil" ) )

local KBU = require( game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "KeybindUtil" ) )

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

return {
	
	RequiresRemote = true,
	
	GetCustomGui = function ( )
		
		return game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerGui" ):WaitForChild( "S2" ):WaitForChild( "KeybindGui" )
		
	end,
	
	CustomMenuFunc = function ( Remote, Gui )
		
		Remote.OnClientEvent:Connect( function ( Binds )
			
			KBU.SavedBinds = Binds
			
			KBU.BindChanged:Fire( )
			
		end )
		
		KBU.BindChanged.Event:Connect( function ( Name, Type, Value )
			
			if Type then
				
				Remote:FireServer( Name, Type ~= "Default" and Type or nil, Value )
				
			end
			
		end )
		
		ThemeUtil.BindUpdate( Gui.Frame, { BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency" } )
		
		ThemeUtil.BindUpdate( Gui.Frame.Main, { ScrollBarImageColor3 = "Secondary_BackgroundColor", ScrollBarImageTransparency = "Secondary_BackgroundTransparency" } )
		
		ThemeUtil.BindUpdate( { Gui.Frame.Search, Gui.Frame.Context.Gamepad, Gui.Frame.Context.Keyboard, Gui.Frame.Context:FindFirstChild( "Name" ), Gui.Frame.Context.Toggle }, { BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency" } )
		
		ThemeUtil.BindUpdate( { Gui.Frame.Search, Gui.Frame.Context.Gamepad, Gui.Frame.Context.Keyboard, Gui.Frame.Context:FindFirstChild( "Name" ), Gui.Frame.Context.Toggle }, { TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency" } )
		
		ThemeUtil.BindUpdate( Gui.Frame.Search, { PlaceholderColor3 = "Secondary_TextColor" } )
		
		Gui.Frame.Main.UIListLayout:GetPropertyChangedSignal( "AbsoluteContentSize" ):Connect( function ( )
			
			Gui.Frame.Main.CanvasSize = UDim2.new( 0, 0, 0, Gui.Frame.Main.UIListLayout.AbsoluteContentSize.Y )
			
			if Gui.Frame.Main.UIListLayout.AbsoluteContentSize.Y > Gui.Frame.Main.AbsoluteSize.Y then
				
				Gui.Frame.Context.Size = UDim2.new( 1, -5, 0, 25 )
				
			else
				
				Gui.Frame.Context.Size = UDim2.new( 1, 0, 0, 25 )
				
			end
			
		end )
		
		local Hide = { }
		
		function Redraw( )
			
			for _, Obj in ipairs( Gui.Frame.Main:GetChildren( ) ) do
				
				if Obj:IsA( "Frame" ) or Obj:IsA( "TextButton" ) then Obj:Destroy( ) end
				
			end
			
			local Binds = KBU.GetBinds( )
			
			local Txt = Gui.Frame.Search.Text:lower( ):gsub( ".", EscapePatterns )
			
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
				
				Cat.Parent = Gui.Frame.Main
				
				for _, Obj in ipairs( b ) do
					
					Obj.Parent = Cat
					
				end
				
				Cat.Size = UDim2.new( 1, 0, 0, Hide[ a ] and Cat.Button.Size.Y.Offset or Cat.UIListLayout.AbsoluteContentSize.Y )
				
			end
			
		end
		
		local Invalid = true
		
		Gui.Frame.Search:GetPropertyChangedSignal( "Text" ):Connect( function ( )
			
			if Gui.Frame.Visible then
				
				Redraw( )
				
			else
				
				Invalid = true
				
			end
			
		end )
		
		KBU.BindAdded.Event:Connect( function ( )
			
			if Gui.Frame.Visible then
				
				Redraw( )
				
			else
				
				Invalid = true
				
			end
			
		end )
		
		KBU.BindChanged.Event:Connect( function ( Name )
			
			if not KBU.GetBind( Name ) or not Gui.Frame.Main:FindFirstChild( Name, true ) then
				
				if Gui.Frame.Visible then
					
					Redraw( )
					
				else
					
					Invalid = true
					
				end
				
			end
			
		end )
		
		if Gui:FindFirstChild( "Toggle" ) then
			
			local function HandleTransparency( Obj, Transparency )
				
				Obj.BackgroundTransparency = Transparency
				
				if Transparency > 0.9 then
					
					ThemeUtil.BindUpdate( Obj, { TextColor3 = Gui.Open.Value and "Selection_Color3" or "Primary_BackgroundColor" } )
					
					Obj.TextStrokeTransparency = 0
					
				else
					
					ThemeUtil.BindUpdate( Obj, { TextColor3 = "Primary_TextColor" } )
					
					Obj.TextStrokeTransparency = 1
					
				end
				
			end
			
			ThemeUtil.BindUpdate( Gui.Toggle, { TextTransparency = "Primary_TextTransparency", TextStrokeColor3 = "Primary_TextColor", Primary_BackgroundTransparency = HandleTransparency } )
			
			local function ToggleGui( )
				
				if Gui.Open.Value and _G.OpenPxlGui then
					
					_G.OpenPxlGui.Value = false
					
				end
				
				if Gui.Open.Value then
					
					_G.OpenPxlGui = Gui.Open
					
					if Invalid then Redraw( ) Invalid = nil end
					
					Gui.Frame.Visible = true
					
					TweenService:Create( Gui.Frame, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Position = UDim2.new( 0.05, 0, 0.43, 0 ), Size = UDim2.new( 0.3, 0, 0.4, 0 ) } ):Play( )
					
					ThemeUtil.BindUpdate( Gui.Toggle, { BackgroundColor3 = Gui.Open.Value and "Selection_Color3" or "Primary_BackgroundColor" } )
					
				else
					
					_G.OpenPxlGui = nil
					
					KBU.Rebinding = nil
					
					local Tween = TweenService:Create( Gui.Frame, TweenInfo.new( 0.5, Enum.EasingStyle.Sine ), { Position = Gui.Toggle.Position, Size = Gui.Toggle.Size } )
					
					Tween.Completed:Connect( function ( State )
						
						if State == Enum.PlaybackState.Completed then
							
							Gui.Frame.Visible = false
							
						end
						
					end )
					
					Tween:Play( )
					
					ThemeUtil.BindUpdate( Gui.Toggle, { BackgroundColor3 = Gui.Open.Value and "Selection_Color3" or "Primary_BackgroundColor" } )
					
				end
				
			end
			
			Gui.Toggle.MouseButton1Click:Connect( function ( )
				
				Gui.Open.Value = not Gui.Open.Value
				
			end )
			
			Gui.Open:GetPropertyChangedSignal( "Value" ):Connect( ToggleGui )
			
			ToggleGui( )
			
		else
			
			Gui.Frame:GetPropertyChangedSignal( "Visible" ):Connect( function ( )
				
				if Gui.Frame.Visible and Invalid then
					
					Redraw( )
					
				end
				
			end )
			
			if Gui.Frame.Visible then
				
				Redraw( )
				
			end
			
		end
		
	end
	
}