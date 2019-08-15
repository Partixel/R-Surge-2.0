local Plr = game:GetService( "Players" ).LocalPlayer

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ):WaitForChild( "ThemeUtil" ) )

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

local VIPFunc = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "VIPFunc" )

local VIPEvent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "VIPEvent" )

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

ThemeUtil.BindUpdate( script.Parent.Sparkles, { BackgroundColor3 = not OwnSparkles and "Negative_Color3" or SparklesEnabled and "Selection_Color3" or "Primary_BackgroundColor", TextTransparency = "Primary_TextTransparency", TextStrokeColor3 = "Primary_TextColor", Primary_BackgroundTransparency = HandleTransparency } )

script.Parent.Sparkles.MouseButton1Click:Connect( function ( )
	
	if SparklesUse then return end
	
	SparklesUse = true
	
	if not OwnSparkles then
		
		OwnSparkles = VIPFunc:InvokeServer( "BuySparkles" )
		
	else
		
		SparklesEnabled = not SparklesEnabled
		
		VIPEvent:FireServer( "SetSparkles", SparklesEnabled or nil )
		
		ThemeUtil.BindUpdate( script.Parent.Sparkles, { BackgroundColor3 = SparklesEnabled and "Selection_Color3" or "Primary_BackgroundColor" } )
		
	end
	
	SparklesUse = false
	
end )

local NeonUse = false

ThemeUtil.BindUpdate( script.Parent.Neon, { BackgroundColor3 = not OwnNeon and "Negative_Color3" or NeonEnabled and "Selection_Color3" or "Primary_BackgroundColor", TextTransparency = "Primary_TextTransparency", TextStrokeColor3 = "Primary_TextColor", Primary_BackgroundTransparency = HandleTransparency } )

script.Parent.Neon.MouseButton1Click:Connect( function ( )
	
	if NeonUse then return end
	
	NeonUse = true
	
	if not OwnNeon then
		
		OwnNeon = VIPFunc:InvokeServer( "BuyNeon" )
		
	else
		
		NeonEnabled = not NeonEnabled
		
		VIPEvent:FireServer( "SetNeon", NeonEnabled or nil )
		
		ThemeUtil.BindUpdate( script.Parent.Neon, { BackgroundColor3 = NeonEnabled and "Selection_Color3" or "Primary_BackgroundColor" } )
		
	end
	
	NeonUse = false
	
end )

local ColUse = false

local ColShow = false

if OwnCol then
	
	UpdateColGui( )
	
end

ThemeUtil.BindUpdate( script.Parent.Color, { BackgroundColor3 = not OwnCol and "Negative_Color3" or ColShow and "Selection_Color3" or "Primary_BackgroundColor", TextTransparency = "Primary_TextTransparency", TextStrokeColor3 = "Primary_TextColor", Primary_BackgroundTransparency = HandleTransparency } )

script.Parent.Color.MouseButton1Click:Connect( function ( )
	
	if ColUse then return end
	
	ColUse = true
	
	if not OwnCol then
		
		OwnCol = VIPFunc:InvokeServer( "BuyCol" )
		
	else
		
		ColShow = not ColShow
		
		ThemeUtil.BindUpdate( script.Parent.Color, { BackgroundColor3 = ColShow and "Selection_Color3" or "Primary_BackgroundColor" } )
		
		script.Parent.ColorFrame.Visible = ColShow
		
		if ColShow then
			
			UpdateColGui( )
			
		end
		
	end
	
	ColUse = false
	
end )