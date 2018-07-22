repeat wait( ) until _G.Interactables

--[[ Options ( All of the following are optional )
	
	Name = StringValue = The name that shows above the GUI

	HoldTime = NumberValue = How long this has to be held for
	
	Distance = NumberValue = How close you have to be to see/interact
	
	Cooldown = NumberValue = How long before you can interact with this again
	
	Disabled = NumberValue = Prevents the GUI from being selected. If value is 0 then GUI will show infinity symbol, else GUI will assume value is the time until it is next enabled, e.g. tick( )+ 5 + _G.ServerOffset will count down from 5. This is used by the Cooldown option.
	
	MinXSize = IntValue = The size in pixels of the GUI when it's not selected
	
	MaxXSize = IntValue = The size in pixels of the GUI when it's selected
	
	ExtraYSize = IntValue = The extra space in pixels for use by devs that want to add custom information ( e.g. gun stats, descriptions, images, etc )
	
	Font = StringValue = The name of the font that you want the text to use ( The name + key ) ( Should be the end of the enum, e.g. Fantasy for Enum.Font.Fantasy )
	
	ProgressColor = Color3Value = The color of the Progress outline
	
	SpriteSheet = StringValue = Assetid:// of your custom sprite sheet ( sprites must be 83 pixels tall and wide, with a 1 pixel gap around it and must be 1024x1024 in total
	
	SpriteRotation = IntValue = Rotation of the SpriteSheet
	
	ClientOnly = Folder = Prevents the interactable sending it's interaction to the server ( use this if the interactable is only used on the client to save networking )
	
	CustomFuncs = ObjectValue = It's value should be a ModuleScript that returns a table with the following functions you want to override:
		{ ShouldOpen = function ( InteractObj, Plr, DefaultShouldOpen ) end -- return true if the InteractGui should open }
	
	CustomGui = Folder = If your interactable has a custom gui, use this to hide the default GUI
	
	CustomFrame = ObjectValue = The value of this is cloned into the extra space in the GUI when it's first opened ( can include scripts if you want it dynamic! )
								The frame must be Size ( 1, 0, 1, 0 ) Position ( 0, 0, 0, 0 ) and you must use ExtraYSize to set the size in pixels of your custom frame.
	
--]]

local Plr = game:GetService( "Players" ).LocalPlayer

local Interactables = _G.Interactables

local TweenService = game:GetService("TweenService" )

local Sprites = { "rbxassetid://1648362548" } --, "rbxassetid://1673809362", "rbxassetid://1673772742", "rbxassetid://1673763277", "rbxassetid://1673087472", "rbxassetid://1672808384", "rbxassetid://1672748980" }

-- rbxassetid://1673824521 - TRAngle

-- rbxassetid://1673800273 -- Trifatty

local floor = math.floor

local SpriteConfig = { Diamater = 83, Padding = 1, Count = 144 }

local Rows = math.sqrt( SpriteConfig.Count ) ;

function GetOffset( Num )
	
	Num = floor( Num ) % SpriteConfig.Count
	
	return ( ( SpriteConfig.Diamater + SpriteConfig.Padding * 2 ) * ( floor( Num % Rows ) ) ) + SpriteConfig.Padding, ( ( SpriteConfig.Diamater + SpriteConfig.Padding * 2 ) * floor( Num / Rows ) ) + SpriteConfig.Padding
	
end

local Vector2new = Vector2.new

local ZeroOffset = Vector2new( GetOffset( 0 ) )

local function NotMyGui( InteractObj )
	
	return InteractObj:FindFirstChild( "CustomGui" )
	
end

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ) )

Interactables.OpenGui:Connect( function ( InteractObj, Gui, Key )
	
	if NotMyGui( InteractObj ) then return end
	
	if not Gui then
		
		Gui = script.InteractGui:Clone( )
		
		if InteractObj:FindFirstChild( "ProgressColor" ) then
			
			Gui.Progress.ImageColor3 = InteractObj.ProgressColor.Value
			
		else
			
			ThemeUtil.BindUpdate( Gui.Progress, "ImageColor3", "PositiveColor" )
			
		end
		
		ThemeUtil.BindUpdate( Gui.KeyBack, "ImageColor3", function ( Obj )
			
			Obj.ImageColor3 = ( Obj:FindFirstChild( "Disabled" ) or Interactables.LocalDisabled[ Obj ] ) and ThemeUtil.GetThemeFor( "PositiveColor" ) or ThemeUtil.GetThemeFor( "Background" )
			
		end )
		
		ThemeUtil.ApplyBasicTheming( Gui.KeyBack.KeyText )
		
		ThemeUtil.BindUpdate( Gui.Back, "ImageColor3", { "SecondaryBackground", "InvertedBackground" } )
		
		ThemeUtil.BindUpdate( Gui.NameBack.AddonFrame, "BackgroundColor3", { "SecondaryBackground", "InvertedBackground" } )
		
		ThemeUtil.BindUpdate( Gui.NameBack, "BackgroundColor3", { "SecondaryBackground", "InvertedBackground" } )
		
		ThemeUtil.BindUpdate( Gui.NameBack.NameText, "TextColor3", { "TextColor", "InvertedBackground" } )
		
		local Rotate = InteractObj:FindFirstChild( "SpriteRotation" ) and InteractObj.SpriteRotation or 0
		
		Gui.Back.Rotation = 90 * Rotate
		
		Gui.KeyBack.Rotation = 90 * Rotate
		
		Gui.KeyBack.KeyText.Rotation = -90 * Rotate
		
		Gui.Progress.Rotation = 90 * Rotate
		
		local Chosen = InteractObj:FindFirstChild( "SpriteSheet" ) and InteractObj.SpriteSheet or Sprites[ 1 ]
		
		Gui.Back.Image = Chosen
		
		Gui.KeyBack.Image = Chosen
		
		Gui.Progress.Image = Chosen
		
		Gui.Enabled = true
		
		if InteractObj:FindFirstChild( "Font" ) then
			
			Gui.NameBack.NameText.Font = Enum.Font[ InteractObj.Font.Value ]
			
			Gui.KeyBack.KeyText.Font = Enum.Font[ InteractObj.Font.Value ]
			
		end
		
		Interactables.Guis[ InteractObj ] = Gui
		
		
		
	end
	
	Gui.Adornee = InteractObj.Parent
	
	Gui.Progress.ImageRectOffset = ZeroOffset
	
	Gui.KeyBack.KeyText.Text = Key
	
	Gui.KeyBack.ImageColor3 = ( InteractObj:FindFirstChild( "Disabled" ) or Interactables.LocalDisabled[ InteractObj ] ) and ThemeUtil.GetThemeFor( "PositiveColor" ) or ThemeUtil.GetThemeFor( "Background" )
	
	if InteractObj:FindFirstChild( "Disabled" )  then
		
		Gui.KeyBack.KeyText.Text = InteractObj.Disabled.Value == 0 and "∞" or math.ceil( math.max( InteractObj.Disabled.Value - tick( ) - _G.ServerOffset, 0 ) )
		
	elseif Interactables.LocalDisabled[ InteractObj ] then
		
		Gui.KeyBack.KeyText.Text = "1"
		
	end
	
	local MaxXSize = InteractObj:FindFirstChild( "MaxXSize" ) and InteractObj.MaxXSize.Value or 75
	
	local MinXSize = InteractObj:FindFirstChild( "MinXSize" ) and InteractObj.MinXSize.Value or 50
	
	local NameSize = ( InteractObj:FindFirstChild( "Name" ) and 25 or 0 )

	local ExtraYSize = NameSize + ( InteractObj:FindFirstChild( "ExtraYSize" ) and InteractObj.ExtraYSize.Value or 0 )
	
	local Ratio = MaxXSize / ( MaxXSize + ExtraYSize * 2 )
	
	Gui.Back.Size = UDim2.new( 1, 0, Ratio, 0 )
	
	Gui.Progress.Size = UDim2.new( 1, 0, Ratio, 0 )
	
	Gui.KeyBack.Size = UDim2.new( 1, 0, Ratio, 0 )
	
	Gui.NameBack.NameText.Size = UDim2.new( 1, -10, NameSize / ( MaxXSize / Ratio * 0.5 ), 0 )
	
	Gui.NameBack.AddonFrame.Position = UDim2.new( 0.5, 0, NameSize / ( MaxXSize / Ratio * 0.5 ), 0 )
	
	Gui.NameBack.AddonFrame.Size = UDim2.new( 1, 0, ( ExtraYSize - NameSize ) / ( MaxXSize / Ratio * 0.5 ), 0 )
	
	if InteractObj:FindFirstChild( "CustomFrame" ) then
		
		InteractObj.CustomFrame.Value:Clone( ).Parent = Gui.NameBack.AddonFrame
		
	end
	
	Gui.Name = "InteractGui"
	
	Gui.Parent = Plr:WaitForChild( "PlayerGui" )
	
	TweenService:Create( Gui, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 0, MinXSize, 0, MinXSize / Ratio ) } ):Play( )
	
end )

Interactables.CloseGui:Connect( function ( InteractObj, Gui )
	
	if NotMyGui( InteractObj ) then return end
			
	local Tween = TweenService:Create( Gui, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 0, 0, 0, 0 ) } )
	
	Tween.Completed:Connect( function ( State )
		
		if State == Enum.PlaybackState.Completed then
			
			Interactables.DestroyGui( InteractObj )
			
		end
		
	end )
	
	Tween:Play( )
	
end )

Interactables.EnableGui:Connect( function ( InteractObj, Gui, Key )
	
	if NotMyGui( InteractObj ) then return end
	
	TweenService:Create( Gui.KeyBack, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { ImageColor3 = ThemeUtil.GetThemeFor( "Background" ) } ):Play( )
	
	Gui.KeyBack.KeyText.Text = Key
	
end )

Interactables.MaximiseGui:Connect( function ( InteractObj, Gui )
	
	if NotMyGui( InteractObj ) then return end
	
	Gui.Progress.ImageRectOffset = ZeroOffset
	
	Gui.Back.Visible = true
	
	Gui.Progress.Visible = true
	
	if InteractObj:FindFirstChild( "Name" ) then
		
		Gui.NameBack.NameText.Text = InteractObj:FindFirstChild( "Name" ).Value
		
	end
	
	local MaxXSize = InteractObj:FindFirstChild( "MaxXSize" ) and InteractObj.MaxXSize.Value or 75

	local ExtraYSize = ( InteractObj:FindFirstChild( "Name" ) and 25 or 0 ) + ( InteractObj:FindFirstChild( "ExtraYSize" ) and InteractObj.ExtraYSize.Value or 0 )
	
	local Ratio = MaxXSize / ( MaxXSize + ExtraYSize * 2 )
	
	if Ratio ~= 1 then
		
		Gui.NameBack.Visible = true
		
		TweenService:Create( Gui.NameBack, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 1, 0, 0.5, 0 ) } ):Play( )
		
	end
	
	TweenService:Create( Gui.KeyBack, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 0.85, 0, Ratio * 0.85, 0 ) } ):Play( )
	
	TweenService:Create( Gui, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 0, MaxXSize, 0, MaxXSize / Ratio ) } ):Play( )
	
end )

Interactables.MinimiseGui:Connect( function ( InteractObj, Gui, CooldownLeft )
	
	if NotMyGui( InteractObj ) then return end
	
	if CooldownLeft then
		
		TweenService:Create( Gui.KeyBack, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { ImageColor3 = ThemeUtil.GetThemeFor( "PositiveColor" ) } ):Play( )
		
		Gui.KeyBack.KeyText.Text = CooldownLeft == true and "∞" or CooldownLeft
		
	end
	
	local MaxXSize = InteractObj:FindFirstChild( "MaxXSize" ) and InteractObj.MaxXSize.Value or 75

	local ExtraYSize = ( InteractObj:FindFirstChild( "Name" ) and 25 or 0 ) + ( InteractObj:FindFirstChild( "ExtraYSize" ) and InteractObj.ExtraYSize.Value or 0 )
	
	local Ratio = MaxXSize / ( MaxXSize + ExtraYSize * 2 )
	
	if Ratio ~= 1 then
		
		TweenService:Create( Gui.NameBack, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 1, 0, 0, 0 ) } ):Play( )
		
	end
	
	local Tween = TweenService:Create( Gui.KeyBack, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 1, 0, Ratio, 0 ) } )
	
	Tween.Completed:Connect( function ( State )
		
		if State == Enum.PlaybackState.Completed and Gui and Gui.Name ~= "Destroying" then
			
			Gui.Back.Visible = false
			
			Gui.Progress.Visible = false
			
			Gui.NameBack.Visible = false
			
			Gui.Progress.ImageRectOffset = ZeroOffset
			
		end
		
	end )
	
	Tween:Play( )
	
	local MinXSize = InteractObj:FindFirstChild( "MinXSize" ) and InteractObj.MinXSize.Value or 50
	
	TweenService:Create( Gui, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 0, MinXSize, 0, MinXSize / Ratio ) } ):Play( )
	
end )

Interactables.StartHold:Connect( function ( InteractObj, Gui )
	
	if NotMyGui( InteractObj ) then return end
	
	TweenService:Create( Gui.Progress, TweenInfo.new( 0 ), { ImageTransparency = 0 } ):Play( )
	
end )

Interactables.EndHold:Connect( function ( InteractObj, Gui, Completed, Cooldown )
	
	if NotMyGui( InteractObj ) then return end
	
	if Completed then
		
		Gui.Progress.ImageRectOffset = Vector2new( GetOffset( SpriteConfig.Count - 1 ) )
		
		Gui.KeyBack.KeyText.Text = Cooldown and math.ceil( Cooldown ) or "1" 
		
		TweenService:Create( Gui.KeyBack, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { ImageColor3 = ThemeUtil.GetThemeFor( "PositiveColor" ) } ):Play( )
		
	else
		
		TweenService:Create( Gui.Progress, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { ImageTransparency = 1 } ):Play( )
		
	end
	
end )

Interactables.UpdateProgress:Connect( function ( InteractObj, Gui, Perc )
	
	if NotMyGui( InteractObj ) then return end
	
	Gui.Progress.ImageRectOffset = Vector2new( GetOffset( math.min( Perc * SpriteConfig.Count, SpriteConfig.Count - 1 ) ) )
	
end )

Interactables.UpdateCooldown:Connect( function ( InteractObj, Gui, CooldownLeft )
	
	if NotMyGui( InteractObj ) then return end
	
	Gui.KeyBack.KeyText.Text = CooldownLeft
	
end )

Interactables.UpdateKey:Connect( function ( Key )
	
	for a, b in pairs( Interactables.Guis ) do
		
		if not NotMyGui( a ) and not tonumber( b.KeyBack.KeyText.Text ) and b.KeyBack.KeyText.Text ~= "∞" then
			
			b.KeyBack.KeyText.Text = Key
			
		end 
		
	end
	
end )
