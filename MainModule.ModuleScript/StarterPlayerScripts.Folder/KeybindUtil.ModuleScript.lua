Module = { }

local SaveBind = game:GetService( "ReplicatedStorage" ):WaitForChild( "SaveBind" )

local ContextChanged = Instance.new( "BindableEvent" )

Module.ContextChanged = ContextChanged.Event

local BindAdded = Instance.new( "BindableEvent" )

Module.BindAdded = BindAdded.Event

local BindChanged = Instance.new( "BindableEvent" )

Module.BindChanged = BindChanged.Event

local Binds = { }

local UIS = game:GetService( "UserInputService" )

function Module.FireBind( Bind, Began, Handled, Died )
	
	if Module.Rebinding then return end
	
	if type( Bind ) == "string" then
		
		if not Binds[ Bind ] then return end
		
		Bind = Binds[ Bind ]
		
	end
	
	if Bind.NoHandled and Handled then return end
	
	if Bind.State ~= Began then
		
		Bind.State = Began
		
		local Ran, Error
		
		if Bind.NoHandled then
			
			Ran, Error = pcall( function ( ) return coroutine.wrap( Bind.Callback )( Began, Died ) end )
			
		else
			
			Ran, Error = pcall( function ( ) return coroutine.wrap( Bind.Callback )( Began, Handled, Died ) end )
			
		end
		
		if not Ran then warn( Bind.Name .. " bind errored\n" .. Error .. "\n" .. debug.traceback( ) ) end
		
		if Error ~= nil then
			
			if Bind.ToggleState then
				
				Bind.Toggle = Error
				
			end
			
			Bind.State = Error
			
		end
		
	end
	
end

UIS.WindowFocusReleased:Connect( function ( )
	
	for a, b in pairs( Binds ) do
		
		if not b.ToggleState then
			
			Module.FireBind( b, false, false )
			
		end
		
	end
	
end )

game:GetService( "Players" ).LocalPlayer.CharacterAdded:Connect( function ( )
	
	for a, b in pairs( Binds ) do
		
		if b.OffOnDeath then
			
			if b.ToggleState then
				
				b.Toggle = false
				
			end
			
			Module.FireBind( b, false, false, true )
			
		end
		
	end
	
end )

local Context = 0

local function UpdateContext( Type )
	
	local new = 0
	
	if Type.Name:lower( ):find( "gamepad" ) then new = 1 end
	
	if Context ~= new then Context = new ContextChanged:Fire( ) end
	
end

UIS.InputBegan:Connect( function ( Input, Handled )
	
	UpdateContext( Input.UserInputType )
	
	for a, b in pairs( Binds ) do
		
		if b.Key == Input.KeyCode or b.PadKey == Input.KeyCode or b.Key == Input.UserInputType or ( b.Key == Enum.UserInputType.MouseButton1 and Input.UserInputType == Enum.UserInputType.Touch ) then
			
			if b.ToggleState then
				
				b.Toggle = not b.Toggle
				
				Module.FireBind( b, b.Toggle, Handled )
				
			else
				
				Module.FireBind( b, true, Handled )
				
			end
			
		end
		
	end
	
end )

UIS.InputEnded:Connect( function ( Input, Handled )
	
	UpdateContext( Input.UserInputType )
	
	for a, b in pairs( Binds ) do
		
		if b.Key == Input.KeyCode or b.PadKey == Input.KeyCode or b.Key == Input.UserInputType or ( b.Key == Enum.UserInputType.MouseButton1 and Input.UserInputType == Enum.UserInputType.Touch ) then
			
			if not b.ToggleState then
				
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

local SavedBinds = game:GetService( "ReplicatedStorage" ):WaitForChild( "GetSavedBinds" ):InvokeServer( )

BindChanged:Fire( )

-- Name, Category, Callback, Key, PadKey, PadNum, ToggleState, CanToggle, OffOnDeath, NonRebindable, NoHandled
function Module.AddBind( Bind )
	
	Bind.PadNum = Bind.PadNum or Enum.UserInputType.Gamepad1
	
	Bind.Defaults = { Key = Bind.Key, PadKey = Bind.PadKey, PadNum = Bind.PadNum, ToggleState = Bind.ToggleState }
	
	Bind.Toggle = false
	
	Bind.State = false
	
	if SavedBinds[ Bind.Name ] then
		
		if SavedBinds[ Bind.Name ][ "Key" ] ~= nil then Bind.Key = SavedBinds[ Bind.Name ][ "Key" ] end
		
		if SavedBinds[ Bind.Name ][ "PadKey" ] ~= nil then Bind.PadKey = SavedBinds[ Bind.Name ][ "PadKey" ] end
		
		if SavedBinds[ Bind.Name ][ "PadNum" ] ~= nil then Bind.PadNum = SavedBinds[ Bind.Name ][ "PadNum" ] end
		
		if SavedBinds[ Bind.Name ][ "ToggleState" ] ~= nil then Bind.ToggleState = SavedBinds[ Bind.Name ][ "ToggleState" ] end
		
	end
	
	Binds[ Bind.Name ] = Bind
	
	BindAdded:Fire( Bind.Name, Bind )
	
end

function Module.GetBind( Name )
	
	return Binds[ Name ]
	
end

function Module.RemoveBind( Name )
	
	if not Binds[ Name ] then return end
	
	coroutine.wrap( Binds[ Name ].Callback )( false, false )
	
	Binds[ Name ] = nil
	
	BindChanged:Fire( Name )
	
end

function Module.SetToggleState( Name, Val )
	
	if not Binds[ Name ] then return end
	
	coroutine.wrap( Binds[ Name ].Callback )( false, false )
	
	if Val then
		
		Binds[ Name ].Toggle = false
		
	end
	
	Binds[ Name ].ToggleState = Val
	
	BindChanged:Fire( Name )
	
end

function Module.SetToggle( Name, Val )
	
	if not Binds[ Name ] then return end
	
	Binds[ Name ].State = Val
	
	Binds[ Name ].Toggle = Val
	
	coroutine.wrap( Binds[ Name ].Callback )( Val, false )
	
end

local function NameOfKey( Key )
	
	if type( Key ) == "string" then return Key end
	
	return Key.Name:gsub( "Button", "" )
	
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
	
	SaveBind:FireServer( Name )
	
	BindChanged:Fire( Name )
	
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
		
		SaveBind:FireServer( Name, "ToggleState", Binds[ Name ].ToggleState )
		
		Module.WriteToObj( TextObj, Binds[ Name ].ToggleState )
		
		BindChanged:Fire( Name )
		
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
	
	SaveBind:FireServer( Name, Type == Enum.UserInputType.Keyboard and "Key" or "PadKey", Key )
	
	BindChanged:Fire( Name )
	
	Module.Rebinding = nil
	
	return Key
	
end

return Module