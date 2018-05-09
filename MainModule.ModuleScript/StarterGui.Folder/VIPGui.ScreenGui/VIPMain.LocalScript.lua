local Plr = game:GetService( "Players" ).LocalPlayer

local KBU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )

local CloseColsCache = { }

function CloseCols( Col )
	
	if CloseColsCache[ tostring( Col ) ] then return CloseColsCache[ tostring( Col ) ] end
	
	local Cols = { [ tostring( Col ) ] = true }
	
	local h, s, v = Color3.toHSV( Col.Color )
	
	h, s, v = h * 100, s * 100, v * 100
	
	for a = math.max( s - 30, 0 ), math.min( s + 30, 100 ) do
		
		local New = BrickColor.new( Color3.fromHSV( h / 100, a / 100, v / 100 ) )
		
		if not Cols[ tostring( New ) ] then
			
			Cols[ tostring( New ) ] = true
			
		end
		
	end
	
	local tmp = { Col }
	
	Cols[ tostring( Col ) ] = nil
	
	for a, b in pairs( Cols ) do
		
		if #tmp > 6 then break end
		
		tmp[ #tmp + 1 ] = BrickColor.new( a )
		
	end
	
	CloseColsCache[ tostring( Col ) ] = tmp
	
	return tmp
	
end

local VIPFunc = game:GetService( "ReplicatedStorage" ):WaitForChild( "VIPFunc" )

local VIPEvent = game:GetService( "ReplicatedStorage" ):WaitForChild( "VIPEvent" )

local ChosenCol = { }

local VIPGui = script.Parent

local Buttons = VIPGui:WaitForChild( "Buttons" )

local KeybindGui = VIPGui:WaitForChild( "KeybindFrame" )

local ColGui = VIPGui:WaitForChild( "Color" )

local SparklesEnabled = false

local NeonEnabled = false

local function UpdateColGui( )
	
	local Cols = CloseCols( Plr.TeamColor )
	
	for a = 1, 6 do
		
		local Col = ColGui:FindFirstChild( a )
		
		if Col then
			
			if Cols[ a ] then
				
				Col.Visible = true
				
				if a == ( ChosenCol[ Plr.TeamColor.Name ] or 1 ) then
					
					Col.BorderSizePixel = 3
					
				else
					
					Col.BorderSizePixel = 0
					
				end
				
				Col.BackgroundColor = Cols[ a ]
				
			else
				
				Col.Visible = false
				
			end
			
		end
		
	end
	
end

Plr:GetPropertyChangedSignal( "TeamColor" ):Connect( function ( )
	
	VIPEvent:FireServer( "ChosenCol", CloseCols( Plr.TeamColor )[ ChosenCol[ Plr.TeamColor.Name ] or 1 ] )
	
	UpdateColGui( )
	
end )

local OwnNeon, OwnCol, OwnSparkles = VIPFunc:InvokeServer( )

local function ChangeCol( Num )
	
	local Cols = CloseCols( Plr.TeamColor )
	
	ChosenCol[ Plr.TeamColor.Name ] = Num
	
	UpdateColGui( )
	
	VIPEvent:FireServer( "ChosenCol", Cols[ Num ] )
	
end

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

for a = 1, 6 do
	
	ColGui:WaitForChild( a ).MouseButton1Click:Connect( function ( )
		
		ChangeCol( a )
		
	end )
	
end

-------------- STUPID WORKAROUND UNTIL PLACEHOLDER IS OFFICIALlY RELEASED, PLS
KeybindGui.Search.PlaceholderText = "Search all keybinds"
KeybindGui.Search.PlaceholderColor3 = Color3.fromRGB( 27, 42, 53 )

KeybindGui.Search:GetPropertyChangedSignal( "Text" ):Connect( function ( )
	
	Redraw( KeybindGui )
	
end )

KBU.BindAdded:Connect( function ( ) Redraw( ) end )

KBU.BindChanged:Connect( function ( Name )
	
	if not KBU.GetBind( Name ) or not KeybindGui.Main:FindFirstChild( Name ) then Redraw( ) end
	
end )

Redraw( )

local KeybindOpen = false

Buttons:WaitForChild( "Keybinds" ).MouseButton1Click:Connect( function ( )
	
	KeybindOpen = not KeybindOpen
	
	if KeybindOpen then
		
		script.Parent.KeybindFrame:TweenPosition( UDim2.new( 0.05, 0, 0.43, 0 ), nil, Enum.EasingStyle.Sine, 0.5, true )
		
		Buttons.Keybinds.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
		
	else
		
		KBU.Rebinding = nil
		
		script.Parent.KeybindFrame:TweenPosition( UDim2.new( 0.05, 0, 1, 0 ), nil, Enum.EasingStyle.Sine, 0.5, true )
		
		Buttons.Keybinds.TextColor3 = Color3.new( 1, 1, 1 )
		
	end
	
end )

local SparklesUse = false

Buttons:WaitForChild( "Sparkles" ).MouseButton1Click:Connect( function ( )
	
	if SparklesUse then return end
	
	SparklesUse = true
	
	if not OwnSparkles then
		
		OwnSparkles = VIPFunc:InvokeServer( "BuySparkles" )
		
		if OwnSparkles then
			
			Buttons.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
			
		end
		
	else
		
		SparklesEnabled = not SparklesEnabled
		
		VIPEvent:FireServer( "SetSparkles", SparklesEnabled )
		
		if SparklesEnabled then
			
			Buttons.Sparkles.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
			
		else
			
			Buttons.Sparkles.TextColor3 = Color3.new( 1, 1, 1 )
			
		end
		
	end
	
	SparklesUse = false
	
end )

local NeonUse = false

Buttons:WaitForChild( "Neon" ).MouseButton1Click:Connect( function ( )
	
	if NeonUse then return end
	
	NeonUse = true
	
	if not OwnNeon then
		
		OwnNeon = VIPFunc:InvokeServer( "BuyNeon" )
		
		if OwnNeon then
			
			Buttons.Neon.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
			
		end
		
	else
		
		NeonEnabled = not NeonEnabled
		
		VIPEvent:FireServer( "SetNeon", NeonEnabled and "Neon" or "" )
		
		if NeonEnabled then
			
			Buttons.Neon.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
			
		else
			
			Buttons.Neon.TextColor3 = Color3.new( 1, 1, 1 )
			
		end
		
	end
	
	NeonUse = false
	
end )

local ColUse = false

local ColShow = false

Buttons:WaitForChild( "Color" ).MouseButton1Click:Connect( function ( )
	
	if ColUse then return end
	
	ColUse = true
	
	if not OwnCol then
		
		OwnCol = VIPFunc:InvokeServer( "BuyCol" )
		
		if OwnCol then
			
			Buttons.Color.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
			
		end
		
	else
		
		ColShow = not ColShow
		
		if ColShow then
			
			Buttons.Color.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
			
			UpdateColGui( )
			
			Buttons.Parent.Color.Visible = true
			
		else
			
			Buttons.Color.TextColor3 = Color3.new( 1, 1, 1 )
			
			Buttons.Parent.Color.Visible = false
			
		end
		
	end
	
	ColUse = false
	
end )

if OwnNeon then
	
	Buttons.Neon.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
	
	if NeonEnabled then
		
		Buttons.Neon.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
		
	else
		
		Buttons.Neon.TextColor3 = Color3.new( 1, 1, 1 )
		
	end
	
end

if OwnCol then
	
	Buttons.Color.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
	
	UpdateColGui( )
	
end

if OwnSparkles then
	
	Buttons.Sparkles.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
	
	if SparklesEnabled then
		
		Buttons.Sparkles.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
		
	else
		
		Buttons.Sparkles.TextColor3 = Color3.new( 1, 1, 1 )
		
	end
	
end