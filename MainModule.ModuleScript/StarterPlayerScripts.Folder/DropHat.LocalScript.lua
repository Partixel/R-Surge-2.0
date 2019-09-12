local KBU = require( game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "KeybindUtil" ) )

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local DropHatRemote = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "DropHatRemote" )

local Players = game:GetService( "Players" )

KBU.AddBind{ Name = "Drop_hat", Category = "Surge 2.0", Callback = function ( Began )

	if Core.Config.HatMode == 1 then return end

	if Players.LocalPlayer.Character then

		local Found

		local Hats = Players.LocalPlayer.Character:GetChildren( )

		for a = 1, #Hats do

			if Hats[ a ]:IsA( "Accessory" ) then

				Found = true

			end

		end

		if Found then

			DropHatRemote:FireServer( )

		end

	end

end, Key = Enum.KeyCode.Equals, NoHandled = true }