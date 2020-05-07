Module = { }

local ContextChanged = Instance.new( "BindableEvent" )

Module.ContextChanged = ContextChanged.Event

Module.BindAdded = Instance.new( "BindableEvent" )

Module.BindChanged = Instance.new( "BindableEvent" )

local Binds = { }

local Holding = { }

local UIS = game:GetService( "UserInputService" )

function Module.FireBind( Bind, Began, Handled, Died )
	if not Module.Rebinding then
		if type( Bind ) == "string" then
			Bind = Binds[ Bind ]
		end
		
		if not Bind.NoHandled or not Handled then
			if Bind.HoldFor then
				Holding[Bind] = nil
				
				if Bind.NoHandled then
					Bind.Callback(Began, Died)
				else
					Bind.Callback(Began, Handled, Died)
				end
			elseif Bind.State ~= Began then
				Bind.State = Began
				
				local State
				if Bind.NoHandled then
					State = Bind.Callback(Began, Died)
				else
					State = Bind.Callback(Began, Handled, Died)
				end
				
				if State ~= nil then
					if Bind.ToggleState then
						Bind.Toggle = State
					end
					Bind.State = State
				end
			end
		end
	end
end

UIS.WindowFocusReleased:Connect( function ( )
	
	for a, b in pairs( Binds ) do
		
		if b.HoldFor then
			
			if Holding[b] then
				
				Module.FireBind( b, false, false )
				
			end
			
		elseif not b.ToggleState then
			
			Module.FireBind( b, false, false )
			
		end
		
	end
	
end )

game:GetService( "Players" ).LocalPlayer.CharacterAdded:Connect( function ( )
	
	for a, b in pairs( Binds ) do
		
		if b.OffOnDeath then
			
			if b.HoldFor then
				
				if Holding[b] then
					
					Module.FireBind( b, false, false )
					
				end
				
			else
				
				if b.ToggleState then
					
					b.Toggle = false
					
				end
				
				Module.FireBind( b, false, false, true )
				
			end
			
		end
		
	end
	
end )

local Context = 0

local function UpdateContext( Type )
	
	local new = 0
	
	if Type.Name:lower( ):find( "gamepad" ) then new = 1 end
	
	if Context ~= new then Context = new ContextChanged:Fire( ) end
	
end

local Heartbeat = game:GetService("RunService").Heartbeat
local function HeartbeatWait(num)
	local t=0
	while t<num do
		t = t + Heartbeat:Wait()
	end
	return t
end

UIS.InputBegan:Connect( function ( Input, Handled )
	
	UpdateContext( Input.UserInputType )
	
	for a, b in pairs( Binds ) do
		
		if b.Key == Input.KeyCode or b.PadKey == Input.KeyCode or b.Key == Input.UserInputType or ( b.Key == Enum.UserInputType.MouseButton1 and Input.UserInputType == Enum.UserInputType.Touch ) then
			
			if b.HoldFor then
				if not b.NoHandled or not Handled then
					local Tick = tick()
					Holding[b] = Tick
					
					HeartbeatWait(b.HoldFor)
					
					if Holding[b] == Tick then
						Module.FireBind(b, true, Handled)
					end
				end
			else
				
				if b.ToggleState then
					
					b.Toggle = not b.Toggle
					
					Module.FireBind( b, b.Toggle, Handled )
					
				else
					
					Module.FireBind( b, true, Handled )
					
				end
				
			end
			
		end
		
	end
	
end )

UIS.InputEnded:Connect( function ( Input, Handled )
	
	UpdateContext( Input.UserInputType )
	
	for a, b in pairs( Binds ) do
		
		if b.Key == Input.KeyCode or b.PadKey == Input.KeyCode or b.Key == Input.UserInputType or ( b.Key == Enum.UserInputType.MouseButton1 and Input.UserInputType == Enum.UserInputType.Touch ) then
			
			if b.HoldFor then
				if Holding[b] then
					Module.FireBind(b, false, Handled)
				end
			elseif not b.ToggleState then
				
				Module.FireBind( b, false, Handled )
				
			end
			
		end
		
	end
	
end )

function Module.GetBinds( )
	
	local Tmp = { }
	
	for a, b in pairs( Binds ) do
		
		Tmp[ #Tmp + 1 ] = b
		
	end
	
	return Tmp
	
end

-- Name, Category, Callback, Key, PadKey, PadNum, ToggleState, CanToggle, OffOnDeath, NonRebindable, NoHandled
function Module.AddBind( Bind )
	
	Bind.PadNum = Bind.PadNum or Enum.UserInputType.Gamepad1
	
	Bind.Defaults = { Key = Bind.Key, PadKey = Bind.PadKey, PadNum = Bind.PadNum, ToggleState = Bind.ToggleState }
	
	Bind.Toggle = false
	
	Bind.State = false
	
	if Module.SavedBinds and Module.SavedBinds[ Bind.Name ] then
		
		if Module.SavedBinds[ Bind.Name ][ "Key" ] ~= nil then Bind.Key = Module.SavedBinds[ Bind.Name ][ "Key" ] end
		
		if Module.SavedBinds[ Bind.Name ][ "PadKey" ] ~= nil then Bind.PadKey = Module.SavedBinds[ Bind.Name ][ "PadKey" ] end
		
		if Module.SavedBinds[ Bind.Name ][ "PadNum" ] ~= nil then Bind.PadNum = Module.SavedBinds[ Bind.Name ][ "PadNum" ] end
		
		if Module.SavedBinds[ Bind.Name ][ "ToggleState" ] ~= nil then Bind.ToggleState = Module.SavedBinds[ Bind.Name ][ "ToggleState" ] end
		
	end
	
	Binds[ Bind.Name ] = Bind
	
	Module.BindAdded:Fire( Bind.Name, Bind )
	
end

function Module.GetBind( Name )
	
	return Binds[ Name ]
	
end

function Module.RemoveBind( Name )
	
	if not Binds[ Name ] then return end
	
	coroutine.wrap( Binds[ Name ].Callback )( false, false )
	
	Binds[ Name ] = nil
	
	Module.BindChanged:Fire( Name )
	
end

function Module.SetToggleState( Name, Val )
	
	if not Binds[ Name ] then return end
	
	coroutine.wrap( Binds[ Name ].Callback )( false, false )
	
	if Val then
		
		Binds[ Name ].Toggle = false
		
	end
	
	Binds[ Name ].ToggleState = Val
	
	Module.BindChanged:Fire( Name )
	
end

function Module.SetToggle( Name, Val )
	
	if not Binds[ Name ] then return end
	
	Binds[ Name ].State = Val
	
	Binds[ Name ].Toggle = Val
	
	coroutine.wrap( Binds[ Name ].Callback )( Val, false )
	
end

local function NameOfKey(Key)
	if type( Key ) == "string" then
		return Key
	else
		local Name = Key.EnumType == Enum.KeyCode and UIS:GetStringForKeyCode(Key)
		return Name and Name ~= "" and Name  or Key.Name:gsub("Button", "")
	end
end

function Module.GetKeyInContext( Name )
	
	if not Binds[ Name ] then return end
	
	if Context == 0 then
		
		return NameOfKey( Binds[ Name ].Key or Binds[ Name ].PadKey )
		
	else
		
		return NameOfKey( Binds[ Name ].PadKey or Binds[ Name ].Key )
		
	end
	
end

function Module.WriteToObj( TextObj, Key )
	
	if type( Key ) == "boolean" then
		
		TextObj.Text = tostring( Key )
		
		return
		
	elseif type( Key ) == "string" then
		
		TextObj.Text = "..."
		
		return
		
	end
	
	local Text = "none"
	
	if Key then
		
		Text = NameOfKey( Key )
		
	elseif Key == false then
		
		Text = "..."
		
	end
	
	TextObj.Text = Text
	
end

local function KeyDown( Type )
	
	local Input = nil
	
	while true do
		
		Input = UIS.InputBegan:wait( )
		
		if not Module.Rebinding then return end
		
		if Input.UserInputType == Enum.UserInputType.Touch then
			
			return Enum.UserInputType.MouseButton1
			
		end
		
		if Input.KeyCode == Enum.KeyCode.Escape then return end
		
		if Type == Enum.UserInputType.Keyboard and ( Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 or Input.UserInputType == Enum.UserInputType.MouseButton3 ) then
			
			return Input.UserInputType
			
		end
		
		if Input.UserInputType ~= Type then Input = nil end
		
		if Input and Input.KeyCode ~= Enum.KeyCode.Unknown then
			
			return Input.KeyCode
			
		end
		
	end
	
end

function Module.Defaults( Name )
	
	if Module.Rebinding or not Binds[ Name ] then return end
	
	local Bind = Binds[ Name ]
	
	Bind.Key = Bind.Defaults.Key
	
	Bind.PadKey = Bind.Defaults.PadKey
	
	Bind.PadNum = Bind.Defaults.PadNum
	
	Bind.ToggleState = Bind.Defaults.ToggleState
	
	Module.BindChanged:Fire( Name, "Default" )
	
end

function Module.Rebind( Name, Type, TextObj )
	
	if Module.Rebinding or not Binds[ Name ] then return end
	
	if Type == "Toggle" then
		
		if not Binds[ Name ].CanToggle then return end
		
	elseif Type == Enum.UserInputType.Keyboard then
		
		if not UIS.KeyboardEnabled and not UIS.TouchEnabled then return end
		
	elseif not UIS:GetGamepadConnected( Type ) then
		
		return
		
	end
	
	coroutine.wrap( Binds[ Name ].Callback )( false, false )
		
	if Type == "Toggle" then
		
		Module.SetToggleState( Name, not Binds[ Name ].ToggleState )
		
		Module.WriteToObj( TextObj, Binds[ Name ].ToggleState )
		
		Module.BindChanged:Fire( Name, "ToggleState", Binds[ Name ].ToggleState )
		
		return
		
	end
	
	Module.WriteToObj( TextObj, "" )
	
	Module.Rebinding = true
	
	local Key = KeyDown( Type )
	
	if not Key then Module.WriteToObj( TextObj, Key ) Module.Rebinding = nil return end
	
	if Key == Enum.KeyCode.Backspace or Key == Enum.KeyCode.ButtonSelect then
		
		Key = nil
		
	end
	
	Module.WriteToObj( TextObj, Key )
	
	wait( )
	
	Binds[ Name ][ Type == Enum.UserInputType.Keyboard and "Key" or "PadKey" ] = Key
	
	Module.BindChanged:Fire( Name, Type == Enum.UserInputType.Keyboard and "Key" or "PadKey", Key )
	
	Module.Rebinding = nil
	
	return Key
	
end

return Module