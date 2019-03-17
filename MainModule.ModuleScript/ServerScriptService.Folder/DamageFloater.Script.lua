local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

Core.ObjDamaged.Event:Connect( function ( User, Damageable, Amount, PrevHealth )
	
	local Gui = script.DamageFloater:Clone( )
	
	Gui.TextLabel.Text = math.abs( Amount )
	
	
	
end )
