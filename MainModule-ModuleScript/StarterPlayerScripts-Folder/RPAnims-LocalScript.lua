local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

local KBU = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "KeybindUtil" ) )

local Plr = game:GetService( "Players" ).LocalPlayer

local Animations = { { "rbxassetid://580605334", "rbxassetid://955877742", "rbxassetid://1173354695" }, { } }

local Salute, AtEase, Surrender

local R6SaluteAnim = Instance.new( "Animation" )

R6SaluteAnim.AnimationId = Animations[ 1 ][ 1 ]

local R6AtEaseAnim = Instance.new( "Animation" )

R6AtEaseAnim.AnimationId = Animations[ 1 ][ 2 ]

local R6SurrenderAnim = Instance.new( "Animation" )

R6SurrenderAnim.AnimationId = Animations[ 1 ][ 3 ]

function Spawned( Char )
	
	Char.ChildAdded:Connect( function ( Obj )
		
		if Obj:IsA( "BackpackItem" ) then
			
			if Salute then KBU.SetToggle( "s2_Salute", false ) end
			
			if AtEase then KBU.SetToggle( "s2_AtEase", false ) end
			
			if AtEase then KBU.SetToggle( "s2_Surrender", false ) end
			
		end
		
	end )
	
	local Hum = Char:WaitForChild( "Humanoid" )
	
	repeat wait( ) until Hum.Parent
	
	if Hum.RigType == Enum.HumanoidRigType.R6 then
		
		Salute = Hum:LoadAnimation( R6SaluteAnim )
		
		AtEase = Hum:LoadAnimation( R6AtEaseAnim )
		
		Surrender = Hum:LoadAnimation( R6SurrenderAnim )
		
	end
	
end

repeat wait( ) until Plr.Character

Spawned( Plr.Character )

Plr.CharacterAdded:Connect( Spawned )

KBU.AddBind{ Name = "s2_Salute", Callback = function ( Began, Died )
	
	if Died then return end
	
	if not Salute then return false end
	
	if Began then
		
		if Plr.Character and Plr.Character:FindFirstChildWhichIsA( "BackpackItem" ) or _G.S20Config.AllowSalute == false then return false end
		
		KBU.SetToggle( "s2_AtEase", false )
		
		KBU.SetToggle( "s2_Surrender", false )
		
		Salute:Play( )
		
	else
		
		Salute:Stop( )
		
	end
	
end, Key = Enum.KeyCode.T, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true }

KBU.AddBind{ Name = "s2_AtEase", Callback = function ( Began, Died )
	
	if Died then return end
	
	if not AtEase then return false end
	
	if Began then
		
		if Plr.Character and Plr.Character:FindFirstChildWhichIsA( "BackpackItem" ) or _G.S20Config.AllowAtEase == false then return false end
		
		KBU.SetToggle( "s2_Salute", false )
		
		KBU.SetToggle( "s2_Surrender", false )
		
		AtEase:Play( )
		
	else
		
		AtEase:Stop( )
		
	end
	
end, Key = Enum.KeyCode.Y, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true }

KBU.AddBind{ Name = "s2_Surrender", Callback = function ( Began, Died )
	
	if Died then
		
		Core.PreventSprint[ "Surrender" ] = nil
		
		Core.PreventCrouch[ "Surrender" ] = nil
		
		return
		
	end
	
	if not Surrender then
		
		Core.PreventSprint[ "Surrender" ] = nil
		
		Core.PreventCrouch[ "Surrender" ] = nil
		
		return false
		
	end
	
	if Began then
		
		if Plr.Character and Plr.Character:FindFirstChildWhichIsA( "BackpackItem" ) or _G.S20Config.AllowSurrender == false then return false end
		
		KBU.SetToggle( "s2_Salute", false )
		
		KBU.SetToggle( "s2_AtEase", false )
		
		KBU.SetToggle( "s2_Crouch", true )
		
		Core.PreventSprint[ "Surrender" ] = true
		
		Core.PreventCrouch[ "Surrender" ] = true
		
		Surrender:Play( )
		
	else
		
		Core.PreventSprint[ "Surrender" ] = nil
		
		Core.PreventCrouch[ "Surrender" ] = nil
		
		KBU.SetToggle( "s2_Crouch", false )
		
		Surrender:Stop( )
		
	end
	
end, Key = Enum.KeyCode.U, ToggleState = true, CanToggle = true, OffOnDeath = true, NoHandled = true }

Core.WeaponSelected.Event:Connect( function ( StatObj, User )
	
	if not StatObj then return end
	
	KBU.SetToggle( "s2_Salute", false )
	
	KBU.SetToggle( "s2_AtEase", false )
	
	KBU.SetToggle( "s2_Surrender", false )
	
end )