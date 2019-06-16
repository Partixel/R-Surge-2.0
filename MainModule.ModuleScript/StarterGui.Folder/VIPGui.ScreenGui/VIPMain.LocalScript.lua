local Plr = game:GetService( "Players" ).LocalPlayer

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ) )

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

local SparklesEnabled = false

local NeonEnabled = false

local function UpdateColGui( )
	
	local Cols = CloseCols( Plr.TeamColor )
	
	for a = 1, 6 do
		
		local Col = script.Parent.ColorFrame:FindFirstChild( a )
		
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

for a = 1, 6 do
	
	script.Parent.ColorFrame:WaitForChild( a ).MouseButton1Click:Connect( function ( )
		
		ChangeCol( a )
		
	end )
	
	ThemeUtil.BindUpdate( script.Parent.ColorFrame[ a ], { BorderColor3 = "Selection_Color3" } )
	
end

local SparklesUse = false

function UpdateSparklesColor( )
	
	script.Parent.Sparkles.BackgroundColor3 = not OwnSparkles and ThemeUtil.GetThemeFor( "Negative_Color3" ) or SparklesEnabled and ThemeUtil.GetThemeFor( "Positive_Color3" ) or ThemeUtil.GetThemeFor( "Primary_BackgroundColor" )
	
	local Transparency = ThemeUtil.GetThemeFor( "Primary_BackgroundTransparency" )
	
	script.Parent.Sparkles.BackgroundTransparency = Transparency
	
	if Transparency > 0.9 then
		
		script.Parent.Sparkles.TextStrokeColor3 = ThemeUtil.GetThemeFor( "Primary_TextColor" )
		
		script.Parent.Sparkles.TextColor3 = not OwnSparkles and ThemeUtil.GetThemeFor( "Negative_Color3" ) or SparklesEnabled and ThemeUtil.GetThemeFor( "Positive_Color3" ) or ThemeUtil.GetThemeFor( "Primary_BackgroundColor" )
		
		script.Parent.Sparkles.TextStrokeTransparency = 0
		
	else
		
		script.Parent.Sparkles.TextColor3 = ThemeUtil.GetThemeFor( "Primary_TextColor" )
		
		script.Parent.Sparkles.TextStrokeTransparency = 1
		
	end
	
end

ThemeUtil.BindUpdate( script.Parent.Sparkles, { BackgroundColor3 = UpdateSparklesColor, TextTransparency = "Primary_TextTransparency" } )

script.Parent:WaitForChild( "Sparkles" ).MouseButton1Click:Connect( function ( )
	
	if SparklesUse then return end
	
	SparklesUse = true
	
	if not OwnSparkles then
		
		OwnSparkles = VIPFunc:InvokeServer( "BuySparkles" )
		
		UpdateSparklesColor( )
		
	else
		
		SparklesEnabled = not SparklesEnabled
		
		VIPEvent:FireServer( "SetSparkles", SparklesEnabled )
		
		UpdateSparklesColor( )
		
	end
	
	SparklesUse = false
	
end )

local NeonUse = false

function UpdateNeonColor( )
	
	script.Parent.Neon.BackgroundColor3 = not OwnNeon and ThemeUtil.GetThemeFor( "Negative_Color3" ) or NeonEnabled and ThemeUtil.GetThemeFor( "Positive_Color3" ) or ThemeUtil.GetThemeFor( "Primary_BackgroundColor" )
	
	local Transparency = ThemeUtil.GetThemeFor( "Primary_BackgroundTransparency" )
	
	script.Parent.Neon.BackgroundTransparency = Transparency
	
	if Transparency > 0.9 then
		
		script.Parent.Neon.TextStrokeColor3 = ThemeUtil.GetThemeFor( "Primary_TextColor" )
		
		script.Parent.Neon.TextColor3 = not OwnNeon and ThemeUtil.GetThemeFor( "Negative_Color3" ) or NeonEnabled and ThemeUtil.GetThemeFor( "Positive_Color3" ) or ThemeUtil.GetThemeFor( "Primary_BackgroundColor" )
		
		script.Parent.Neon.TextStrokeTransparency = 0
		
	else
		
		script.Parent.Neon.TextColor3 = ThemeUtil.GetThemeFor( "Primary_TextColor" )
		
		script.Parent.Neon.TextStrokeTransparency = 1
		
	end
	
end

ThemeUtil.BindUpdate( script.Parent.Neon, { BackgroundColor3 = UpdateNeonColor, TextTransparency = "Primary_TextTransparency" } )

script.Parent:WaitForChild( "Neon" ).MouseButton1Click:Connect( function ( )
	
	if NeonUse then return end
	
	NeonUse = true
	
	if not OwnNeon then
		
		OwnNeon = VIPFunc:InvokeServer( "BuyNeon" )
		
		UpdateNeonColor( )
		
	else
		
		NeonEnabled = not NeonEnabled
		
		VIPEvent:FireServer( "SetNeon", NeonEnabled and "Neon" or "" )
		
		UpdateNeonColor( )
		
	end
	
	NeonUse = false
	
end )

local ColUse = false

local ColShow = false

if OwnCol then
	
	UpdateColGui( )
	
end

function UpdateColor( )
	
	script.Parent.Color.BackgroundColor3 = not OwnCol and ThemeUtil.GetThemeFor( "Negative_Color3" ) or ColShow and ThemeUtil.GetThemeFor( "Positive_Color3" ) or ThemeUtil.GetThemeFor( "Primary_BackgroundColor" )
	
	local Transparency = ThemeUtil.GetThemeFor( "Primary_BackgroundTransparency" )
	
	script.Parent.Color.BackgroundTransparency = Transparency
	
	if Transparency > 0.9 then
		
		script.Parent.Color.TextStrokeColor3 = ThemeUtil.GetThemeFor( "Primary_TextColor" )
		
		script.Parent.Color.TextColor3 = not OwnCol and ThemeUtil.GetThemeFor( "Negative_Color3" ) or ColShow and ThemeUtil.GetThemeFor( "Positive_Color3" ) or ThemeUtil.GetThemeFor( "Primary_BackgroundColor" )
		
		script.Parent.Color.TextStrokeTransparency = 0
		
	else
		
		script.Parent.Color.TextColor3 = ThemeUtil.GetThemeFor( "Primary_TextColor" )
		
		script.Parent.Color.TextStrokeTransparency = 1
		
	end
	
end

ThemeUtil.BindUpdate( script.Parent.Color, { BackgroundColor3 = UpdateColor, TextTransparency = "Primary_TextTransparency" } )

script.Parent:WaitForChild( "Color" ).MouseButton1Click:Connect( function ( )
	
	if ColUse then return end
	
	ColUse = true
	
	if not OwnCol then
		
		OwnCol = VIPFunc:InvokeServer( "BuyCol" )
		
		UpdateColor( )
		
	else
		
		ColShow = not ColShow
		
		UpdateColor( )
		
		script.Parent.ColorFrame.Visible = ColShow
		
		if ColShow then
			
			UpdateColGui( )
			
		end
		
	end
	
	ColUse = false
	
end )