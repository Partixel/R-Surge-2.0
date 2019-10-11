local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local Plr = game:GetService( "Players" ).LocalPlayer

local StarterGui = game:GetService( "StarterGui" )

local KBU = require( Plr:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "KeybindUtil" ) )

local PU = require( Plr:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "PoseUtil" ) )

local Animations = { [ Enum.HumanoidRigType.R6 ] = { "rbxassetid://580605334", "rbxassetid://955877742", "rbxassetid://1173354695" }, [ Enum.HumanoidRigType.R15 ] = { "rbxassetid://2225371665", "rbxassetid://2225372526", "rbxassetid://2225382014" } }

local Salute, AtEase, Surrender

function Spawned( Char )
	
	Char.ChildAdded:Connect( function ( Obj )
		
		if Obj:IsA( "BackpackItem" ) then
			
			if Salute then KBU.SetToggle( "Salute", false ) end
			
			if AtEase then KBU.SetToggle( "At_ease", false ) end
			
			if AtEase then KBU.SetToggle( "Surrender", false ) end
			
		end
		
	end )
	
	local Hum = Char:WaitForChild( "Humanoid" )
	
	while not Hum.Parent do Hum.AncestryChanged:Wait( ) end
	
	local SaluteAnim = Instance.new( "Animation" )
	
	SaluteAnim.AnimationId = Animations[ Hum.RigType ][ 1 ]
	
	Salute = Hum:LoadAnimation( SaluteAnim )
	
	local AtEaseAnim = Instance.new( "Animation" )
	
	AtEaseAnim.AnimationId = Animations[ Hum.RigType ][ 2 ]
	
	AtEase = Hum:LoadAnimation( AtEaseAnim )
	
	local SurrenderAnim = Instance.new( "Animation" )
	
	SurrenderAnim.AnimationId = Animations[ Hum.RigType ][ 3 ]
	
	Surrender = Hum:LoadAnimation( SurrenderAnim )
	
end

Spawned( Plr.Character or Plr.CharacterAdded:Wait( ) )

Plr.CharacterAdded:Connect( Spawned )

local Surrendered

local SDebounce, SLast

KBU.AddBind{ Name = "Salute", Category = "Surge 2.0", Callback = function ( Began, Died )
	
	if Died then return end
	
	if not Salute then return false end
	
	if SDebounce then return SLast end
	
	if Began then
		
		if Plr.Character and Plr.Character:FindFirstChildWhichIsA( "BackpackItem" ) or Core.Config.AllowSalute == false or SDebounce or Surrendered ~= nil then return false end
		
		KBU.SetToggle( "At_ease", false )
		
		KBU.SetToggle( "Surrender", false )
		
		Salute:Play( )
		
		SDebounce = true
		
		wait( )
		
		SDebounce = false
		
	else
		
		Salute:Stop( )
		
		SDebounce = true
		
		wait( )
		
		SDebounce = false
		
	end
	
end, Key = Enum.KeyCode.T, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true }

local ADebounce, ALast

KBU.AddBind{ Name = "At_ease", Category = "Surge 2.0", Callback = function ( Began, Died )
	
	if Died then return end
	
	if not AtEase then return false end
	
	if ADebounce then return ALast end
	
	if Began then
		
		if Plr.Character and Plr.Character:FindFirstChildWhichIsA( "BackpackItem" ) or Core.Config.AllowAtEase == false or ADebounce or Surrendered ~= nil then return false end
		
		KBU.SetToggle( "Salute", false )
		
		KBU.SetToggle( "Surrender", false )
		
		AtEase:Play( )
		
		ADebounce = true
		
		wait( )
		
		ADebounce = false
		
	else
		
		AtEase:Stop( )
		
		ADebounce = true
		
		wait( )
		
		ADebounce = false
		
	end
	
end, Key = Enum.KeyCode.Y, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true }

KBU.AddBind{ Name = "Surrender", Category = "Surge 2.0", Callback = function ( Began, Died )
	
	if Died then
		
		Core.PreventSprint[ "Surrender" ] = nil
		
		Core.PreventCrouch[ "Surrender" ] = nil
		
		StarterGui:SetCoreGuiEnabled( Enum.CoreGuiType.Backpack, Surrendered )
		
		Surrendered = nil
		
		return
		
	end
	
	if not Surrender then
		
		Core.PreventSprint[ "Surrender" ] = nil
		
		Core.PreventCrouch[ "Surrender" ] = nil
		
		return false
		
	end
	
	if Surrendered ~= nil then return true end
	
	if Began then
		
		if Plr.Character and Plr.Character:FindFirstChildWhichIsA( "BackpackItem" ) or Core.Config.AllowSurrender == false then return false end
		
		Surrendered = StarterGui:GetCoreGuiEnabled( Enum.CoreGuiType.Backpack )
		
		StarterGui:SetCoreGuiEnabled( Enum.CoreGuiType.Backpack, false )
		
		KBU.SetToggle( "Salute", false )
		
		KBU.SetToggle( "At_ease", false )
		
		KBU.SetToggle( "Crouch", false )
		
		PU.SetPose( "Crouching", true )
		
		Core.PreventSprint[ "Surrender" ] = true
		
		Core.PreventCrouch[ "Surrender" ] = true
		
		Surrender:Play( )
		
	end
	
end, Key = Enum.KeyCode.U, ToggleState = true, OffOnDeath = true, NoHandled = true }

Core.WeaponSelected.Event:Connect( function ( StatObj, User )
	
	if not StatObj then return end
	
	KBU.SetToggle( "Salute", false )
	
	KBU.SetToggle( "At_ease", false )
	
end )