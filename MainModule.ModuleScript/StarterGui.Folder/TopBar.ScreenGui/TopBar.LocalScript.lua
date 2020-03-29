local ThemeUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))
if script.Parent then
	ThemeUtil.BindUpdate(script.Parent.Frame, {BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
	game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(1)
	
	--[[local PlayerGui = game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerGui" )
	
	script.Parent.Frame.BackgroundTransparency = PlayerGui:GetTopbarTransparency( )
	
	PlayerGui:SetTopbarTransparency( 1 )
	
	local Changed
	
	PlayerGui.TopbarTransparencyChangedSignal:Connect( function ( Transparency )
		
		if Changed then Changed = nil return end
		
		script.Parent.Frame.BackgroundTransparency = Transparency
		
		PlayerGui:SetTopbarTransparency( 1 )
		
	end )]]
end