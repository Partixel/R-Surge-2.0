local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local DropHatRemote = Instance.new( "RemoteEvent" )

DropHatRemote.Name = "DropHatRemote"

DropHatRemote.OnServerEvent:Connect( function ( Plr )

	if Core.Config.HatMode == 1 or not Plr.Character then return end

	local Hats = Plr.Character:GetChildren( )

	for a = 1, #Hats do

		if Hats[ a ]:IsA( "Accessory" ) then

			if Core.Config.HatMode == 2 then

				Hats[ a ]:Destroy( )

			else

				Hats[ a ].Parent = workspace

				local Reset

				local Event = Hats[ a ].AncestryChanged:Connect( function ( )

					Reset = true

				end )

				delay( 5, function ( )

					if not Reset then

						Hats[ a ]:Destroy( )

					end

				end )

			end

		end

	end

end )

DropHatRemote.Parent = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )