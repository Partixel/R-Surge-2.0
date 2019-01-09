local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "Core" ) )

local Plr = game:GetService( "Players" ).LocalPlayer

local HealthGui, AmmoGui, Term = script.Parent:WaitForChild( "Container" ):WaitForChild( "HealthGui" ), script.Parent:WaitForChild( "Container" ):WaitForChild( "AmmoGui" ), script.Parent:WaitForChild( "Container" ):WaitForChild( "HealthGui" ):WaitForChild( "Health" ):WaitForChild( "Term" )

local AmmoOpen = false

AmmoGui.Weapon.Info.Size = AmmoOpen and UDim2.new( 1, 0, -5, 0 ) or UDim2.new( 1, 0, 0, 0 )

AmmoGui.Weapon.Info.Visible = AmmoOpen

Plr:WaitForChild( "leaderstats" )

local Assists = Plr:FindFirstChild( "Assists", true )

local function Assist( )
	
	HealthGui.Health.Info.AssistsT.Text = "Assists  |  " .. Assists.Value
	
end

Assists:GetPropertyChangedSignal( "Value" ):Connect( Assist )

Assist( )

local WOs = Plr:FindFirstChild( "WOs", true )

local KOs = Plr:FindFirstChild( "KOs", true )

local function WO( )
	
	HealthGui.Health.Info.Wipeouts.Text = "Wipeouts  |  " .. WOs.Value
	
	HealthGui.Health.Info.KDR.Text = "KDR  |  " .. math.floor( KOs.Value / math.max( 1,WOs.Value ) * 100 ) / 100
	
end

WOs:GetPropertyChangedSignal( "Value" ):Connect( WO )

WO( )

local function KO( )
	
	HealthGui.Health.Info.Knockouts.Text = "Knockouts  |  " .. KOs.Value
	
	HealthGui.Health.Info.KDR.Text = "KDR  |  " .. math.floor( KOs.Value / math.max( 1, WOs.Value ) * 100 ) / 100
	
end

KOs:GetPropertyChangedSignal( "Value" ):Connect( KO )

KO( )

local HealthOpen = false

HealthGui.Health.Info.Size = HealthOpen and UDim2.new( 1, 0, -5, 0 ) or UDim2.new( 1, 0, 0, 0 )

HealthGui.Health.Info.Visible = HealthOpen

local Humanoid

function HealthChanged( )
	
	if not Humanoid or not Humanoid.Parent or not Humanoid.Parent.Parent then
		
		if not Plr.Character then Plr.CharacterAdded:Wait( ) end
		
		Humanoid = Plr.Character:WaitForChild( "Humanoid" )
		
		Humanoid.HealthChanged:Connect( HealthChanged )
		
		Humanoid:GetPropertyChangedSignal( "MaxHealth" ):Connect( HealthChanged )
		
	end
	
	HealthGui.Status.Status.Status.Size = UDim2.new( Humanoid.Health / Humanoid.MaxHealth, 0, 1, 0 )
	
	HealthGui.Status.Status.Status.BackgroundColor3 = Color3.new( 1 - ( Humanoid.Health / Humanoid.MaxHealth ), Humanoid.Health / Humanoid.MaxHealth, 0 )
	
end

if Plr.Character then
	
	HealthChanged( )
	
end

Plr.CharacterAdded:Connect( HealthChanged )

HealthGui.Health.MouseButton1Down:Connect( function ( )
	
	if not HealthOpen then
		
		HealthGui.Health.Info.Visible = true
		
		HealthGui.Health.Info:TweenSize( UDim2.new( 1, 0, -5, 0 ), nil, nil, 0.25, true )
		
		Term:TweenPosition( UDim2.new( 0, -4, -4.62, 0 ), nil, nil, 0.25, true )
		
		HealthOpen = true
		
	else
		
		HealthGui.Health.Info:TweenSize( UDim2.new( 1, 0, 0, 0 ), nil, nil, 0.25, true, function ( ) if not HealthOpen then HealthGui.Health.Info.Visible = false end end )
		
		Term:TweenPosition( UDim2.new( 0, -4, -0.63, 0 ), nil, nil, 0.25, true )
		
		HealthOpen = false
		
	end
	
end )

function WeaponDeselected( StatObj )
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if not Weapon or Weapon.User ~= Plr then return end
	
	AmmoGui.Weapon.Text = "N/A"
	
	AmmoGui.Ammo.Text = "N/A"
	
	AmmoGui.Weapon.Info.Accuracy.Text = "N/A  |  Accurate Range"
	
	AmmoGui.Weapon.Info.Damage.Text = "N/A  |  Damage"
	
	AmmoGui.Weapon.Info.FireRate.Text = "N/A  |  Fire Rate"
	
	AmmoGui.Weapon.Info.Range.Text = "N/A  |  Range"
	
	AmmoGui.Weapon.Info.Automatic.Text = "N/A  |  Automatic"
	
end

function WeaponSelected( StatObj )
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if not Weapon or Weapon.User ~= Plr then return end
	
	local GunStats = Core.GetGunStats( StatObj )
	
	AmmoGui.Weapon.Text = StatObj.Parent.Name
	
	local Ammo, MaxAmmo = Weapon.Clip or "∞", Weapon.StoredAmmo or GunStats.ClipSize
	
	AmmoGui.Ammo.Text = Ammo .. ( MaxAmmo and " | " .. MaxAmmo or "" )
	
	AmmoGui.Weapon.Info.Accuracy.Text = GunStats.AccurateRange .. "  |  Accurate Range"
	
	AmmoGui.Weapon.Info.Damage.Text = GunStats.Damage .. "  |  Damage"
	
	AmmoGui.Weapon.Info.FireRate.Text = GunStats.FireRate .. "  |  Fire Rate"
	
	AmmoGui.Weapon.Info.Range.Text = GunStats.Range .. "  |  Range"
	
	AmmoGui.Weapon.Info.Automatic.Text = ( ( GunStats.Automatic ) and "Yes" or "No" ) .. "  |  Automatic"
	
end

local Weapon = Core.Selected[ Plr ] and next( Core.Selected[ Plr ] )

if Weapon then
	
	WeaponSelected( Weapon.StatObj )
	
else
	
	WeaponDeselected( )
	
end

Core.WeaponSelected.Event:Connect( WeaponSelected )

Core.WeaponDeselected.Event:Connect( WeaponDeselected )

Core.ClipChanged.Event:Connect( function ( StatObj, Ammo )
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if not Weapon or Weapon.User ~= Plr then return end
	
	local GunStats = Core.GetGunStats( StatObj )
	
	local MaxAmmo = Weapon.StoredAmmo or GunStats.ClipSize
	
	AmmoGui.Ammo.Text = ( Ammo or "∞" ) .. ( MaxAmmo and " | " .. MaxAmmo or "" )
	
end )

Core.StoredAmmoChanged.Event:Connect( function ( StatObj, StoredAmmo )
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if not Weapon or Weapon.User ~= Plr then return end
	
	local GunStats = Core.GetGunStats( StatObj )
	
	local Ammo, MaxAmmo = Weapon.Clip or "∞", StoredAmmo or GunStats.ClipSize
	
	AmmoGui.Ammo.Text = Ammo .. ( MaxAmmo and " | " .. MaxAmmo or "" )
	
end )

AmmoGui.Weapon.MouseButton1Down:Connect( function ( )
	
	if not AmmoOpen then
		
		AmmoGui.Weapon.Info.Visible = true
		
		AmmoGui.Weapon.Info:TweenSize( UDim2.new( 1, 0, -5, 0 ), nil, nil, 0.25, true )
		
		AmmoOpen = true
		
	else
		
		AmmoGui.Weapon.Info:TweenSize( UDim2.new( 1, 0, 0, 0 ), nil, nil, 0.25, true, function ( ) if not AmmoOpen then AmmoGui.Weapon.Info.Visible = false end end )
		
		AmmoOpen = false
		
	end
	
end )

-- TERMINAL GUI --

Term.Visible = false

local TermFlag = workspace:WaitForChild( "TermFlag", 5 )

if not TermFlag then return end

local Owner = workspace.TermFlag:WaitForChild( "Flag" )

local WinTimer = workspace.TermFlag:WaitForChild( "BrickTimer" ):GetChildren( )[ 1 ]

Term.BackgroundColor3 = Owner.BrickColor.Color

Term.Bkg.TextLabel.Text = WinTimer.Name

Term.Bkg.Size = UDim2.new( 1, 0, 0, 0 )

Term.Visible = true

Term.Bkg.Visible = false

function FormatTime( Time )
	
	return ( "%.2d:%.2d:%.2d" ):format( Time / ( 60 * 60 ), Time / 60 % 60, Time % 60 )
	
end

function Update( )
	
	Term.BackgroundColor3 = Owner.BrickColor.Color
	
	if WinTimer.Name == "Raiders do not own the main flag" or WinTimer.Name == "No raid in progress" or WinTimer.Name == "Raiders aren't raiding" then
		
		Term.Bkg:TweenSize( UDim2.new( 1, 0, 0, 0 ), nil, nil, 0.5, true, function ( ) Term.Bkg.Visible = false end )
		
		return
		
	end
	
	Term.Bkg.Visible = true
	
	Term.Bkg:TweenSize( UDim2.new( 1, 0, -4, 0 ), nil, nil, 0.5, true )
	
	local YScale = Term.Position.Y.Scale
	
	Term:TweenPosition( UDim2.new( 0.1, -4, YScale, 0 ), nil, nil, 0.1, true, function ( )
		
		Term:TweenPosition( UDim2.new( -0.1, -4, YScale, 0 ), nil, nil, 0.1, true, function ( )
			
			Term:TweenPosition( UDim2.new( 0, -4, YScale, 0 ), nil, nil, 0.1, true )
			
		end )
		
	end )
	
	Term.Bkg.TextLabel.Text = WinTimer.Name
	
end

WinTimer:GetPropertyChangedSignal( "Name" ):Connect( Update )

Update( )

Owner:GetPropertyChangedSignal( "BrickColor" ):Connect( function ( )
	
	Term.BackgroundColor3 = Owner.BrickColor.Color
	
end )

local Event = game.ReplicatedStorage:WaitForChild( "RaidTimerEvent" )

local Start, Limit

Term.Text = ""

Event:FireServer( )

Event.OnClientEvent:Connect( function ( S, L )
	
	while not _G.ServerOffset do wait( ) end
	
	Start, Limit = S, L
	
	if not S then return end
	
	Term.Text = FormatTime( math.ceil( Limit - ( ( tick( ) + _G.ServerOffset ) - S ) ) )
	
	while wait( 1 ) and Start == S do
		
		Term.Text = FormatTime( math.ceil( Limit - ( ( tick( ) + _G.ServerOffset ) - S ) ) )
		
	end
	
	Term.Text = ""
	
end )