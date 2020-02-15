local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local Plr = game:GetService( "Players" ).LocalPlayer

local HealthGui, AmmoGui, Term = script.Parent:WaitForChild( "Container" ):WaitForChild( "HealthGui" ), script.Parent:WaitForChild( "Container" ):WaitForChild( "AmmoGui" ), script.Parent:WaitForChild( "Container" ):WaitForChild( "HealthGui" ):WaitForChild( "Health" ):WaitForChild( "Term" )

local AmmoOpen = false

AmmoGui.Weapon.Info.Size = AmmoOpen and UDim2.new( 1, 0, -5, 0 ) or UDim2.new( 1, 0, 0, 0 )

AmmoGui.Weapon.Info.Visible = AmmoOpen

Plr:WaitForChild( "leaderstats" )

local Assists
while not Assists do
	Assists = Plr:FindFirstChild( "Assists", true )
end

local function Assist( )
	
	HealthGui.Health.Info.AssistsT.Text = "Assists  |  " .. Assists.Value
	
end

Assists:GetPropertyChangedSignal( "Value" ):Connect( Assist )

Assist( )

local WOs
while not WOs do
	WOs = Plr:FindFirstChild( "WOs", true )
end

local KOs
while not KOs do
	KOs = Plr:FindFirstChild( "KOs", true )
end

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
	
	if StatObj and Core.GetWeapon( StatObj ).User ~= Plr then return end
	
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
	
	if Weapon.User ~= Plr or Weapon.WeaponType ~= Core.WeaponTypes.RaycastGun then return end
	
	local WeaponStats = Core.GetWeaponStats( StatObj )
	
	AmmoGui.Weapon.Text = StatObj.Parent.Name
	
	local Ammo, MaxAmmo = Weapon.Clip or "∞", Weapon.WeaponType.GetStoredAmmo(Weapon) or WeaponStats.ClipSize
	
	AmmoGui.Ammo.Text = Ammo .. ( MaxAmmo and " | " .. MaxAmmo or "" )
	
	AmmoGui.Weapon.Info.Accuracy.Text = WeaponStats.AccurateRange .. "  |  Accurate Range"
	
	AmmoGui.Weapon.Info.Damage.Text = WeaponStats.Damage .. "  |  Damage"
	
	AmmoGui.Weapon.Info.FireRate.Text = WeaponStats.FireRate .. "  |  Fire Rate"
	
	AmmoGui.Weapon.Info.Range.Text = WeaponStats.Range .. "  |  Range"
	
	AmmoGui.Weapon.Info.Automatic.Text = ( ( WeaponStats.Automatic ) and "Yes" or "No" ) .. "  |  Automatic"
	
end

local Weapon = Core.Selected[ Plr ] and next( Core.Selected[ Plr ] )

if Weapon then
	
	WeaponSelected( Weapon.StatObj )
	
else
	
	WeaponDeselected( )
	
end

Core.WeaponSelected.Event:Connect( WeaponSelected )

Core.WeaponDeselected.Event:Connect( WeaponDeselected )

Core.WeaponTypes.RaycastGun.ClipChanged.Event:Connect( function ( StatObj, Ammo )
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if Weapon.User ~= Plr or not Core.Selected[ Weapon.User ] or not Core.Selected[ Weapon.User ][ Weapon ] then return end
	
	local WeaponStats = Core.GetWeaponStats( StatObj )
	
	local MaxAmmo = Weapon.WeaponType.GetStoredAmmo(Weapon) or WeaponStats.ClipSize
	
	AmmoGui.Ammo.Text = ( Ammo or "∞" ) .. ( MaxAmmo and " | " .. MaxAmmo or "" )
	
end )

Core.WeaponTypes.RaycastGun.StoredAmmoChanged.Event:Connect( function ( StatObj, StoredAmmo )
	
	local Weapon = Core.GetWeapon( StatObj )
	
	if Weapon.User ~= Plr or not Core.Selected[ Weapon.User ] or not Core.Selected[ Weapon.User ][ Weapon ] then return end
	
	local WeaponStats = Core.GetWeaponStats( StatObj )
	
	local Ammo, MaxAmmo = Weapon.Clip or "∞", StoredAmmo or WeaponStats.ClipSize
	
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

if not game.ReplicatedStorage:WaitForChild("RaidLib", 5) then return end

local TimeSync = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("TimeSync"))

if game.ReplicatedStorage.RaidLib:FindFirstChild( "HomeWinAmount" ) then
	
	local HomeWinAmount = game.ReplicatedStorage.RaidLib:WaitForChild( "HomeWinAmount" )
	
	local AwayWinAmount = game.ReplicatedStorage.RaidLib:WaitForChild( "AwayWinAmount" )
	
	local WinPoints = 0
	
	function Changed( )
		
		Term.Bkg.TextLabel.Text = "TRA - " .. math.floor( HomeWinAmount.Value ) .. "/" .. WinPoints .. "\nRaiders - " .. math.floor( AwayWinAmount.Value ) .. "/" .. WinPoints
		
		if HomeWinAmount.Value > AwayWinAmount.Value then
			
			Term.BackgroundColor3 = BrickColor.Green( ).Color
			
		elseif AwayWinAmount.Value > HomeWinAmount.Value then
			
			Term.BackgroundColor3 = BrickColor.Red( ).Color
			
		else
			
			Term.BackgroundColor3 = BrickColor.Gray( ).Color
			
		end
		
	end
	
	HomeWinAmount:GetPropertyChangedSignal( "Value" ):Connect( Changed )
	
	AwayWinAmount:GetPropertyChangedSignal( "Value" ):Connect( Changed )
	
	Changed( )
	
	function Toggle( )
		
		
	end
	
	Term.Visible = true
	
	local OfficialRaid = game.ReplicatedStorage:WaitForChild("RaidLib"):WaitForChild( "OfficialRaid" )
	
	if not OfficialRaid.Value then
		
		Term.Bkg.Size = UDim2.new( 1, 0, 0, 0 )
		
		Term.Bkg.Visible = false
		
	end
	
	OfficialRaid:GetPropertyChangedSignal( "Value" ):Connect( function ( )
		
		if OfficialRaid.Value then
			
			Term.Bkg.Visible = true
			
			Term.Bkg:TweenSize( UDim2.new( 1, 0, -4, 0 ), nil, nil, 0.5, true )
			
		else
			
			Term.Bkg:TweenSize( UDim2.new( 1, 0, 0, 0 ), nil, nil, 0.5, true, function ( ) Term.Bkg.Visible = false end )
			
		end
		
	end )
	
	function FormatTime( Time )
		
		return ( "%.2d:%.2d:%.2d" ):format( Time / ( 60 * 60 ), Time / 60 % 60, Time % 60 )
		
	end
	
	local Event = game.ReplicatedStorage:WaitForChild("RaidLib"):WaitForChild( "RaidTimerEvent" )
	
	local Start, Limit
	
	Term.Text = ""
	
	Event.OnClientEvent:Connect( function ( S, L, W )
		
		if W then WinPoints = W Changed( ) end
		
		Start, Limit = S, L
		
		if not S then return end
		
		Term.Text = FormatTime( math.ceil( Limit - ( ( TimeSync.GetServerTime() ) - S ) ) )
		
		while wait( 1 ) and Start == S and Limit == L do
			
			Term.Text = FormatTime( math.ceil( Limit - ( ( TimeSync.GetServerTime() ) - S ) ) )
			
		end
		
		Term.Text = ""
		
	end )
	
	Event:FireServer( )
	
else
	
	local TermFlag = workspace:WaitForChild( "TermFlag", 5 )
	
	if not TermFlag then return end
	
	local Owner = workspace.TermFlag:WaitForChild( "Flag" )
	
	local WinTimer = workspace.TermFlag:WaitForChild( "BrickTimer" ):GetChildren( )[ 1 ]
	
	Term.BackgroundColor3 = Owner.BrickColor.Color
	
	Term.Bkg.TextLabel.Text = WinTimer.Name
	
	Term.Visible = true
	
	Term.Bkg.Size = UDim2.new( 1, 0, 0, 0 )
	
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
	
	local Event = game.ReplicatedStorage:WaitForChild("RaidLib"):WaitForChild( "RaidTimerEvent" )
	
	local Start, Limit
	
	Term.Text = ""
	
	Event.OnClientEvent:Connect( function ( S, L )
		
		Start, Limit = S, L
		
		if not S then return end
		
		Term.Text = FormatTime( math.ceil( Limit - ( ( TimeSync.GetServerTime() ) - S ) ) )
		
		while wait( 1 ) and Start == S and Limit == L do
			
			Term.Text = FormatTime( math.ceil( Limit - ( ( TimeSync.GetServerTime() ) - S ) ) )
			
		end
		
		Term.Text = ""
		
	end )
	
	Event:FireServer( )
	
end