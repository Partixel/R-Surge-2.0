local Plr = game:GetService( "Players" ).LocalPlayer

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
	
end

local SparklesUse = false

script.Parent:WaitForChild( "Sparkles" ).MouseButton1Click:Connect( function ( )
	
	if SparklesUse then return end
	
	SparklesUse = true
	
	if not OwnSparkles then
		
		OwnSparkles = VIPFunc:InvokeServer( "BuySparkles" )
		
		if OwnSparkles then
			
			script.Parent.Sparkles.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
			
		end
		
	else
		
		SparklesEnabled = not SparklesEnabled
		
		VIPEvent:FireServer( "SetSparkles", SparklesEnabled )
		
		if SparklesEnabled then
			
			script.Parent.Sparkles.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
			
		else
			
			script.Parent.Sparkles.TextColor3 = Color3.new( 1, 1, 1 )
			
		end
		
	end
	
	SparklesUse = false
	
end )

local NeonUse = false

script.Parent:WaitForChild( "Neon" ).MouseButton1Click:Connect( function ( )
	
	if NeonUse then return end
	
	NeonUse = true
	
	if not OwnNeon then
		
		OwnNeon = VIPFunc:InvokeServer( "BuyNeon" )
		
		if OwnNeon then
			
			script.Parent.Neon.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
			
		end
		
	else
		
		NeonEnabled = not NeonEnabled
		
		VIPEvent:FireServer( "SetNeon", NeonEnabled and "Neon" or "" )
		
		if NeonEnabled then
			
			script.Parent.Neon.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
			
		else
			
			script.Parent.Neon.TextColor3 = Color3.new( 1, 1, 1 )
			
		end
		
	end
	
	NeonUse = false
	
end )

local ColUse = false

local ColShow = false

script.Parent:WaitForChild( "Color" ).MouseButton1Click:Connect( function ( )
	
	if ColUse then return end
	
	ColUse = true
	
	if not OwnCol then
		
		OwnCol = VIPFunc:InvokeServer( "BuyCol" )
		
		if OwnCol then
			
			script.Parent.Color.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
			
		end
		
	else
		
		ColShow = not ColShow
		
		if ColShow then
			
			script.Parent.Color.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
			
			UpdateColGui( )
			
			script.Parent.ColorFrame.Visible = true
			
		else
			
			script.Parent.Color.TextColor3 = Color3.new( 1, 1, 1 )
			
			script.Parent.ColorFrame.Visible = false
			
		end
		
	end
	
	ColUse = false
	
end )

if OwnNeon then
	
	script.Parent.Neon.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
	
	if NeonEnabled then
		
		script.Parent.Neon.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
		
	else
		
		script.Parent.Neon.TextColor3 = Color3.new( 1, 1, 1 )
		
	end
	
end

if OwnCol then
	
	script.Parent.Color.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
	
	UpdateColGui( )
	
end

if OwnSparkles then
	
	script.Parent.Sparkles.BackgroundColor3 = Color3.new( 77 / 255, 77 / 255, 77 / 255 )
	
	if SparklesEnabled then
		
		script.Parent.Sparkles.TextColor3 = Color3.new( 1, 100 / 255, 100 / 255 )
		
	else
		
		script.Parent.Sparkles.TextColor3 = Color3.new( 1, 1, 1 )
		
	end
	
end