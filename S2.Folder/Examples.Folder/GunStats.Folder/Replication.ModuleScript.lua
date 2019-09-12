return {
	
	FireModes = { "Auto", "Burst", "Semi", "Safety" },
	
	Damage = 13,
	
	FireRate = 7,
	
	ClipSize = 22,
	
	MaxStoredAmmo = 100,
	
	ReloadDelay = 4,
	
	InitialReloadDelay = 1,
	
	FinalReloadDelay = 1,
	
	InvertTeamKill = true,
	
	--ReloadAmount = 22,
	
	Range = 450,
	
	AccurateRange = 100,
	
	DistanceDamageMultiplier = 0.8,
	
	LongReloadSound = true,
	
	Scope = { Min = 10, Max = 30 },
	
	Barrels = function ( StatObj ) return StatObj.Parent:WaitForChild( "Barrel" ) end,
	
	LeftWeld = CFrame.new( 0.8, 0.5, 0.4 ) * CFrame.Angles( math.rad( 280 ), math.rad( 43 ), 0 ),
	
	RightWeld = CFrame.new( -1.2, 0.1, 0.4 ) * CFrame.Angles( math.rad( 270 ), math.rad( -10 ), 0 ),
	
	FireSound = script.Fire,
	
	ReloadSound = script.Reload
	
}