local Players, TweenService, TextService = game:GetService( "Players" ), game:GetService("TweenService" ), game:GetService( "TextService" )

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local ThemeUtil = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "ThemeUtil" ):WaitForChild( "ThemeUtil" ) )

local function Scale( Feed )
	
	Feed.Killer.Size = UDim2.new( 10, 0, 1, 0 )
	
	Feed.Killer.Size = UDim2.new( ( ( Feed.Killer.KillerName.TextBounds.X ~= 0 and Feed.Killer.KillerName.TextBounds.X + 10 or 0 ) + ( Feed.Killer:FindFirstChild( "KillerPct" ) and Feed.Killer.KillerPct.TextBounds.X + 5 or 0 ) ) / Feed.AbsoluteSize.X, 0, 1, 0 )
	
	if Feed.Killer:FindFirstChild( "Assister" ) then
		
		Feed.Killer.Assister.Size = UDim2.new( 10, 0, 0.5, 0 )
		
		Feed.Killer.Assister.Size = UDim2.new( ( ( Feed.Killer.Assister.AssisterName.TextBounds.X ~= 0 and Feed.Killer.Assister.AssisterName.TextBounds.X + 10 or 0 ) + ( Feed.Killer.Assister.AssisterPct.TextBounds.X ~= 0 and Feed.Killer.Assister.AssisterPct.TextBounds.X + 5 or 0 ) ) / Feed.Killer.AbsoluteSize.X, 0, 0.5, 0 )
		
		if Feed.Killer.AbsoluteSize.X < Feed.Killer.Assister.AbsoluteSize.X then
		
			Feed.Killer.Assister.Frame.Size = UDim2.new( Feed.Killer.AbsoluteSize.X / Feed.Killer.Assister.AbsoluteSize.X, 0, 1.5, 0 )
			
		else
			
			Feed.Killer.Assister.Frame.Size = UDim2.new( 1, 0, 1.5, 0 )
			
		end
		
	end
	
	local Max = 0
	
	local Kids = Feed:GetChildren( )
	
	for _, Obj in ipairs( Kids ) do
		
		if Obj.Name:sub( 1, 6 ) == "Victim" then
	
			Obj.Size = UDim2.new( 10, 0, 1, 0 )
			
			Max = math.max( Max, ( Obj.VictimName.TextBounds.X ~= 0 and Obj.VictimName.TextBounds.X + 10 or 0 ) + ( Obj:FindFirstChild( "VictimType" ) and Obj.VictimType.AbsoluteSize.X + 5 or 0 ) )
			
		end
		
	end
	
	for _, Obj in ipairs( Kids ) do
		
		if Obj.Name:sub( 1, 6 ) == "Victim" then
			
			Obj.Size = UDim2.new( Max / Feed.AbsoluteSize.X, 0, 1, 0 )
			
		end
		
	end
	
	if Core.Config.KillFeedHorizontalAlign then
		
		Feed.AnchorPoint = Vector2.new( Core.Config.KillFeedHorizontalAlign == "Left" and 0 or Core.Config.KillFeedHorizontalAlign == "Right" and 1 or 0.5, 0.5 )
		
		local HorizontalScale, HorizontalOffset = 0.5, 0
		
		if Core.Config.KillFeedHorizontalAlign == "Left" then
			
			HorizontalScale = 0
			
			HorizontalOffset = Feed.Killer.AbsoluteSize.X + 2
			
		elseif Core.Config.KillFeedHorizontalAlign == "Right" then
			
			HorizontalScale = 1
			
			HorizontalOffset = -Feed.Victim1.AbsoluteSize.X - 2
			
		end
		
		if Core.Config.KillFeedVerticalAlign == "Bottom" then
			
			local Pos = UDim2.new( HorizontalScale, HorizontalOffset, 0.175 - Feed.ActualPos.Value, 0  )
			
			Feed.Position = Pos
			
			TweenService:Create( Feed, TweenInfo.new( 0 ), { Position = Pos } ):Play( )
			
		else
			
			local Pos = UDim2.new( HorizontalScale, HorizontalOffset, Feed.ActualPos.Value, 0  )
			
			Feed.Position = Pos
			
			TweenService:Create( Feed, TweenInfo.new( 0 ), { Position = Pos } ):Play( )
			
		end
		
	end
	
end

workspace.CurrentCamera:GetPropertyChangedSignal( "ViewportSize" ):Connect( function ( )
	
	wait( )
	
	for _, Feed in ipairs( script.Parent.Container:GetChildren( )) do
		
		if Feed:IsA( "Frame" ) then
			
			Scale( Feed )
			
		end
		
	end
	
end )

local function PctStr( Num, Decimals )
	-- Needs percentage as a value between 0 - 100 ( multiply the decimal by 100 )
	Decimals = Decimals or 0
	local Min = 0.1 ^ Decimals
	return string.format( "%." .. Decimals .. "f", Num > 0 and Num < Min and Min or Num > 100 - Min and Num < 100 and 100 - Min or Num )
end

local VictimTypes = { Head = "rbxassetid://1693819171", NewHead = "rbxassetid://1693819171" }
-- Need suicide dmgtype
--local DmgTypes = { Kinetic = "rbxassetid://2625025813", Explosive = "rbxassetid://2625029682", Slash = "rbxassetid://2625006640" }
local DmgTypes = { Kinetic = "rbxassetid://1693831893", Explosive = "rbxassetid://1693825708" }

local Zero = UDim2.new( 0, 0, 0, 0 )

local function UpdateContrastTextStroke( Obj )
	
	if Obj.Parent.BackgroundTransparency > 0.9 then
		
		Obj.TextStrokeColor3 = ThemeUtil.GetThemeFor( "Inverted_TextColor" )
		
	else
		
		ThemeUtil.ContrastTextStroke( Obj, Obj.Parent.ImageColor3 )
		
	end
	
end

game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "RemoteKilled" ).OnClientEvent:Connect( function ( DeathInfo )
	
	local NewFeed = script.Feed:Clone( )
	
	local NumVictims = 0
	
	for _, Info in ipairs( DeathInfo.VictimInfos ) do
		
		if not Info.NoFeed then
			
			NumVictims = NumVictims + 1
			
			local Victim = script.Victim:Clone( )
			
			ThemeUtil.BindUpdate( Victim, { ImageColor3 = "Primary_BackgroundColor", ImageTransparency = "Primary_BackgroundTransparency" } )
			
			Victim.VictimName.Text = Info.User.Name
			
			Victim.VictimName.TextColor3 = Info.User.TeamColor and Info.User.TeamColor.Color or ThemeUtil.GetThemeFor( "Primary_TextColor" )
			
			ThemeUtil.BindUpdate( Victim.VictimName, { Primary_BackgroundTransparency = UpdateContrastTextStroke } )
			
			Victim.Name = "Victim" .. NumVictims
			
			local Type = VictimTypes[ Info.Hit ]
			
			if Type then
				
				local VictimType = script.VictimType:Clone( )
				
				VictimType.Image = Type
				
				VictimType.Parent = Victim
				
			end
			
			Victim.Position = UDim2.new( 1, 0, ( Core.Config.KillFeedVerticalAlign == "Bottom" and -1 or 1 ) * ( NumVictims - 1 ), 0 )
			
			if NumVictims > 1 then
				
				local VictimFrame = script.VictimFrame:Clone( )
				
				if Core.Config.KillFeedVerticalAlign == "Bottom" then
					
					VictimFrame.Position = UDim2.new( 0, 0, 1, 0 )
					
				end
				
				ThemeUtil.BindUpdate( VictimFrame, { BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency" } )
				
				VictimFrame.Parent = Victim
				
			end
			
			Victim.Parent = NewFeed
			
		end
		
	end
	
	if NumVictims == 0 then return end
	
	NewFeed.Type.Image = DmgTypes[ DeathInfo.Type ] or DmgTypes[ "Kinetic" ]
	
	ThemeUtil.BindUpdate( NewFeed.Type, { ImageColor3 = "Primary_TextColor", ImageTransparency = "Primary_TextTransparency" } )
	
	ThemeUtil.BindUpdate( NewFeed.Killer, { ImageColor3 = "Primary_BackgroundColor", ImageTransparency = "Primary_BackgroundTransparency" } )
	
	ThemeUtil.BindUpdate( NewFeed.Frame, { BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency" } )
	
	NewFeed.Killer.KillerName.Text = DeathInfo.Killer and DeathInfo.Killer.Name or NewFeed[ "Victim1" ].VictimName.Text
	
	NewFeed.Killer.KillerName.TextColor3 = DeathInfo.Killer and DeathInfo.Killer.TeamColor and DeathInfo.Killer.TeamColor.Color or NewFeed[ "Victim1" ].VictimName.TextColor3
	
	ThemeUtil.BindUpdate( NewFeed.Killer.KillerName, { Primary_BackgroundTransparency = UpdateContrastTextStroke } )
	
	if DeathInfo.Assister then
		
		local Assister = script.Assister:Clone( )
		
		ThemeUtil.BindUpdate( Assister, { ImageColor3 = "Primary_BackgroundColor", ImageTransparency = "Primary_BackgroundTransparency" } )
		
		ThemeUtil.BindUpdate( Assister.Frame, { BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency" } )
		
		Assister.AssisterName.Text = DeathInfo.Assister.Name
		
		Assister.AssisterName.TextColor3 = DeathInfo.Assister.TeamColor and DeathInfo.Assister.TeamColor.Color or ThemeUtil.GetThemeFor( "Primary_TextColor" )
		
		ThemeUtil.BindUpdate( Assister.AssisterName, { Primary_BackgroundTransparency = UpdateContrastTextStroke } )
		
		Assister.AssisterPct.Text = PctStr( DeathInfo.AssisterDamage / DeathInfo.TotalDamage * 100, 0 ) .. "%"
		
		if Core.Config.KillFeedVerticalAlign == "Bottom" then
			
			Assister.Frame.Position = UDim2.new( 1, 0, 0.25, 0 )
			
			Assister.Position = UDim2.new( 1, 0, 0, 0 )
			
		end
		
		Assister.Parent = NewFeed.Killer
		
		local KillPct = script.KillerPct:Clone( )
		
		KillPct.Text = PctStr( DeathInfo.KillerDamage / DeathInfo.TotalDamage * 100, 0 ) .. "%"
		
		KillPct.Parent = NewFeed.Killer
		
	end
	
	for _, Feed in ipairs( script.Parent.Container:GetChildren( ) ) do
		
		if Feed:IsA( "Frame" ) then
			
			Feed.ActualPos.Value = Feed.ActualPos.Value + 0.035 + math.max( 0.035 * ( NumVictims - 1 ), DeathInfo.Assister and 0.015 or 0 )
			
			if Core.Config.KillFeedVerticalAlign == "Bottom" then
				
				TweenService:Create( Feed, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Position = UDim2.new( Feed.Position.X.Scale, Feed.Position.X.Offset, 0.175 - Feed.ActualPos.Value, 0  ) } ):Play( )
				
			else
				
				TweenService:Create( Feed, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Position = UDim2.new( Feed.Position.X.Scale, Feed.Position.X.Offset, Feed.ActualPos.Value, 0  ) } ):Play( )
				
			end
			
			if Feed.ActualPos.Value > 0.175 and Feed.Name ~= "Destroying" then
				
				local Feed = Feed
				
				Feed.Name = "Destroying"
				
				local Tween = TweenService:Create( Feed, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = Zero } )
				
				Tween.Completed:Connect( function ( State )
					
					Feed:Destroy( )
					
				end )
				
				Tween:Play( )
				
			end
			
		end
		
	end
	
	for _, Feed in ipairs( NewFeed:GetDescendants( ) ) do
		
		if Feed:IsA( "TextLabel" ) then
			
			local Obj = Feed
			
			Obj:GetPropertyChangedSignal( "AbsoluteSize" ):Connect( function ( )
				
				if Obj.AbsoluteSize.X < 1 then
					
					Obj.Visible = false
					
				else
					
					Obj.Visible = true
					
				end
				
			end )
			
		end
		
	end
	
	NewFeed.Parent = script.Parent.Container
	
	Scale( NewFeed )
	
	NewFeed.Size = Zero
	
	TweenService:Create( NewFeed, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 0.03, 0, 0.03, 0 ) } ):Play( )
	
	wait( 0.25 )
	
	if NewFeed:FindFirstChild( "Type" ) then
		
		TweenService:Create( NewFeed.Type, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 1, 0, 1, 0 ), ImageTransparency = 0 } ):Play( )
		
	end
	
	wait( 5 )
	
	if NewFeed.Parent and NewFeed.Name ~= "Destroying" then
		
		NewFeed.Name = "Destroying"
		
		local Tween = TweenService:Create( NewFeed, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = Zero } )
		
		Tween.Completed:Connect( function ( State )
			
			NewFeed:Destroy( )
			
		end )
		
		Tween:Play( )
		
	end
	
end )