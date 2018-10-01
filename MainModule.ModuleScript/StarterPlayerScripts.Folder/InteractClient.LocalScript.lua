local InteractObjs = { }

local Plr, UserInputService = game:GetService( "Players" ).LocalPlayer, game:GetService("UserInputService" )

local KBU, Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) ), require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

local InteractRemote = game:GetService( "ReplicatedStorage" ):WaitForChild( "InteractRemote" )

local IsServer = game:GetService( "RunService" ):IsServer( )

local Interactables = { }

Interactables.LocalDisabled = { }

Interactables.Guis = { }

Interactables.OpenGui = script.OpenGui.Event

Interactables.CloseGui = script.CloseGui.Event

Interactables.MaximiseGui = script.MaximiseGui.Event

Interactables.MinimiseGui = script.MinimiseGui.Event

Interactables.EnableGui = script.EnableGui.Event

Interactables.StartHold = script.StartHold.Event

Interactables.EndHold = script.EndHold.Event

Interactables.UpdateKey = script.UpdateKey.Event

Interactables.UpdateCooldown = script.UpdateCooldown.Event

Interactables.UpdateProgress = script.UpdateProgress.Event

local LastNearest

local HoldStart

function Interactables.DestroyGui( InteractObj )
	
	if Interactables.Guis[ InteractObj ] then
		
		Interactables.Guis[ InteractObj ]:Destroy( )
		
		Interactables.Guis[ InteractObj ] = nil
		
	end
	
	if LastNearest == InteractObj then
		
		LastNearest = nil
		
		HoldStart = nil
		
	end
	
end

_G.Interactables = Interactables

local Mouse = Plr:GetMouse( )

local MD, KD

Mouse.Button1Down:Connect( function ( )
	
	MD = true
	
end )

Mouse.Button1Up:Connect( function ( )
	
	if not MD then return end
	
	MD = nil
	
end )

KBU.AddBind{ Name = "s2_Interact", Callback = function ( Began, Died )
	
	if Died then KD = nil return end
	
	if Began then
		
		KD = true
		
	else
		
		KD = nil
		
	end
	
end, Key = Enum.KeyCode.E, PadKey = Enum.KeyCode.ButtonX, OffOnDeath = true, NoHandled = true }

KBU.ContextChanged:Connect( function ( )
	
	script.UpdateKey:Fire( KBU.GetKeyInContext( "s2_Interact" ) )
	
end )

KBU.BindChanged:Connect( function ( Name )
	
	if not Name or Name == "s2_Interact" then
		
		script.UpdateKey:Fire( KBU.GetKeyInContext( "s2_Interact" ) )
		
	end
	
end )

local function Obscured( Part )
	
	local Obscuring, Obscured = workspace.CurrentCamera:GetPartsObscuringTarget( { Part.Position }, { Part, Plr.Character } )
	
	for a = 1, #Obscuring do
		
		if not Core.IgnoreFunction( Obscuring[ a ] ) then return true end
		
	end
	
end

local Cooldowns = { }

local HBEvent

local function GetSubject( )
	
	local Subject = workspace.CurrentCamera.CameraSubject
	
	if Subject and Subject:IsA( "Humanoid" ) then
		
		Subject = Subject.RootPart
		
	end
	
	return Subject
	
end

function DefaultShouldOpen( InteractObj, Plr )
	
	return Plr.Character and not Plr.Character:FindFirstChildOfClass( "Tool" )
	
end

function StartInteractables( )
	
	HBEvent = game:GetService( "RunService" ).Heartbeat:Connect( function ( )
		
		if next( InteractObjs ) then
			
			local Subject, Humanoid = GetSubject( ), Plr.Character and Plr.Character:FindFirstChildOfClass( "Humanoid" ) 
			
			if Subject and Humanoid and Humanoid:GetState( ) ~= Enum.HumanoidStateType.Dead and Interactables.Visible ~= false then
				
				local Nearest, NearestDist
				
				if HoldStart and not LastNearest:FindFirstChild( "Disabled" ) and not Interactables.LocalDisabled[ LastNearest ] and ( LastNearest.Parent.Position - Subject.Position ).magnitude <= ( LastNearest:FindFirstChild( "Distance" ) and LastNearest.Distance.Value or 16 ) then
					
					Nearest, NearestDist = LastNearest, -1
					
				end
				
				for a, b in pairs( InteractObjs ) do
					
					if a:IsDescendantOf( workspace ) then
						
						if a ~= Nearest then
							
							if not a:FindFirstChild( "CharacterOny" ) or Subject == Humanoid.RootPart then					
								
								local Dist = ( a.Parent.Position - Subject.Position ).magnitude
								
								if Dist <= ( a:FindFirstChild( "Distance" ) and a.Distance.Value or 16 ) and select( 2, workspace.CurrentCamera:WorldToViewportPoint( a.Parent.Position ) ) and not Obscured( a.Parent ) and ( a:FindFirstChild( "CustomFuncs" ) and require( a.CustomFuncs.Value ).ShouldOpen or DefaultShouldOpen )( a, Plr, DefaultShouldOpen ) then
									
									if not a:FindFirstChild( "Disabled" ) and not Interactables.LocalDisabled[ a ] then
										
										if Mouse.Target and ( Mouse.Target == a.Parent or Mouse.Target:IsDescendantOf( a ) ) then
											
											Nearest, NearestDist = a, -1
											
										elseif not NearestDist or Dist < NearestDist then
											
											Nearest, NearestDist = a, Dist
											
										end
										
									end
									
									if Interactables.Guis[ a ] and a.Parent ~= Interactables.Guis[ a ].Adornee then
										
										Interactables.Guis[ a ].Adornee = a.Parent
										
									end
									
									if not Interactables.Guis[ a ] or Interactables.Guis[ a ].Name == "Destroying" then
										
										script.OpenGui:Fire( a, Interactables.Guis[ a ], KBU.GetKeyInContext( "s2_Interact" ) )
										
									elseif a:FindFirstChild( "Disabled" ) then
										
										if Interactables.Guis[ a ].Name ~= "Disabled" then
											
											local CooldownLeft = a.Disabled.Value == 0 and true or math.ceil( math.max( a.Disabled.Value - tick( ) - _G.ServerOffset, 0 ) )
											
											if CooldownLeft ~= true then Cooldowns[ a ] = CooldownLeft end
											
											script.MinimiseGui:Fire( a, Interactables.Guis[ a ], CooldownLeft )
											
											Interactables.Guis[ a ].Name = "Disabled"
											
										elseif a.Disabled.Value ~= 0 then
											
											local CooldownLeft = math.ceil( math.max( a.Disabled.Value - tick( ) - _G.ServerOffset, 0 ) )
											
											if Cooldowns[ a ] ~= CooldownLeft then
												
												Cooldowns[ a ] = CooldownLeft
												
												script.UpdateCooldown:Fire( a, Interactables.Guis[ a ], CooldownLeft )
												
											end
											
										end
										
									elseif not a:FindFirstChild( "Disabled" ) and not Interactables.LocalDisabled[ a ] and Interactables.Guis[ a ].Name == "Disabled" then
										
										Interactables.Guis[ a ].Name = "InteractGui"
										
										Cooldowns[ a ] = nil
										
										script.EnableGui:Fire( a, Interactables.Guis[ a ], KBU.GetKeyInContext( "s2_Interact" ) )
										
									end
									
								elseif Interactables.Guis[ a ] and Interactables.Guis[ a ].Name ~= "Destroying" then
									
									Interactables.Guis[ a ].Name = "Destroying"
									
									Cooldowns[ a ] = nil
									
									script.CloseGui:Fire( a, Interactables.Guis[ a ] )
									
								end
								
							elseif Interactables.Guis[ a ] then
								
								Interactables.Guis[ a ]:Destroy( )
								
								Interactables.Guis[ a ] = nil
								
								if LastNearest == a then LastNearest = nil HoldStart = nil end
								
							end
							
						end
						
					else
						
						InteractObjs[ a ] = nil
						
						Cooldowns[ a ] = nil
						
						if Interactables.Guis[ a ] then
							
							Interactables.Guis[ a ]:Destroy( )
							
							Interactables.Guis[ a ] = nil
							
							if LastNearest == a then LastNearest = nil HoldStart = nil end
							
						end
						
					end
			
				end
				
				if LastNearest ~= Nearest then
					
					HoldStart = nil
					
					if LastNearest and Interactables.Guis[ LastNearest ] and Interactables.Guis[ LastNearest ].Name ~= "Destroying" then
						
						script.MinimiseGui:Fire( LastNearest, Interactables.Guis[ LastNearest ] )
						
					end
					
					if Nearest then
						
						if not Nearest:FindFirstChild( "HoldTime" ) or Nearest.HoldTime.Value <= 0 then
							
							MD, KD = nil, nil
							
						end
						
						script.MaximiseGui:Fire( Nearest, Interactables.Guis[ Nearest ] )
						
					end
					
					LastNearest = Nearest
					
				end
				
				if Nearest then
					
					if HoldStart and not MD and not KD then
						
						if Interactables.Guis[ Nearest ].Name ~= "Destroying" then
							
							script.EndHold:Fire( Nearest, Interactables.Guis[ Nearest ] )
							
						end
						
						HoldStart = nil
						
					end
					
					if not HoldStart and ( KD or ( MD and Mouse.Target and ( Mouse.Target == Nearest.Parent or Mouse.Target:IsDescendantOf( Nearest ) ) ) ) then
						
						HoldStart = tick( )
						
						script.StartHold:Fire( Nearest, Interactables.Guis[ Nearest ] )
						
					end
					
					if HoldStart then
						
						local HoldTime = Nearest:FindFirstChild( "HoldTime" ) and Nearest.HoldTime.Value or 0
						
						if tick( ) - HoldStart > HoldTime then
							
							local Cooldown = Nearest:FindFirstChild( "Cooldown" ) and Nearest:FindFirstChild( "Cooldown" ).Value > 0 and Nearest:FindFirstChild( "Cooldown" ).Value or nil
							
							if not Cooldown then
								
								Interactables.LocalDisabled[ Nearest ] = true
								
								delay( 0.3, function ( )
									
									Interactables.LocalDisabled[ Nearest ] = nil
									
								end )
								
							end
							
							Interactables.Guis[ Nearest ].Name = "Disabled"
							
							script.EndHold:Fire( Nearest, Interactables.Guis[ Nearest ], true, Cooldown )
							
							if not Nearest:FindFirstChild( "ClientOnly" ) then
								
								InteractRemote:FireServer( Nearest, tick( ) + _G.ServerOffset, Subject ~= Humanoid.RootPart and Subject or nil )
								
							elseif Cooldown then
								
								local Disabled = Instance.new( "NumberValue" )
								
								Disabled.Name = "Disabled"
								
								Disabled.Value = tick( ) + _G.ServerOffset + Cooldown
								
								Disabled.Parent = Nearest
								
								delay( Cooldown, function ( )
									
									if Disabled and Disabled.Parent then
										
										Disabled:Destroy( )
										
									end
									
								end )
								
							end
							
							if not IsServer or Nearest:FindFirstChild( "ClientOnly" ) then
								
								Nearest:Fire( Plr )
								
							end
							
							HoldStart = nil
							
							MD, KD = nil, nil
							
						else
							
							local Perc = HoldTime <= 0 and 1 or ( math.min( tick( ) - HoldStart, HoldTime ) / HoldTime )
							
							script.UpdateProgress:Fire( Nearest, Interactables.Guis[ Nearest ], Perc )
							
						end
						
					end
					
				end
				
			else
				
				for a, b in pairs( Interactables.Guis ) do
					
					b.Name = "Destroying"
					
					script.CloseGui:Fire( a, b )
					
				end
				
				Cooldowns = { }
				
				LastNearest, HoldStart = nil, nil
				
			end
			
		else
			
			for a, b in pairs( Interactables.Guis ) do
				
				b.Name = "Destroying"
				
				script.CloseGui:Fire( a, b )
				
			end
			
			Cooldowns = { }
			
			LastNearest, HoldStart = nil, nil
			
			HBEvent:Disconnect( )
			
			HBEvent = nil
			
		end
		
	end )
	
end

workspace.DescendantAdded:Connect( function ( Obj )
	
	if Obj:IsA( "BindableEvent" ) and Obj.Name == "InteractObject" then
		
		InteractObjs[ Obj ] = true
		
		if not HBEvent then
			
			StartInteractables( )
			
		end
		
	end
	
end )

local Objs = workspace:GetDescendants( )

for a = 1, #Objs do
	
	if Objs[ a ]:IsA( "BindableEvent" ) and Objs[ a ].Name == "InteractObject" then
		
		InteractObjs[ Objs[ a ] ] = true
		
		if not HBEvent then
			
			StartInteractables( )
			
		end
		
	end
	
end