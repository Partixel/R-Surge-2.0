return {
	
	WeaponModes = { "Semi", "Safety" },
	
	Damage = 19,
	
	FireRate = 0.9,
	
	ShotsPerClick = 5,
	
	OneAmmoPerClick = true,
	
	ClipSize = 12,
	
	ReloadDelay = 2,
	
	ReloadFromEmpty = false,
	
	Range = 160,
	
	AccurateRange = 10,
	
	DistanceDamageMultiplier = 0.8,
	
	Barrels = function ( StatObj ) return StatObj.Parent:WaitForChild( "Barrel" ) end,
	
	LeftWeld = CFrame.new( 0.8, 0.5, 0.4 ) * CFrame.Angles( math.rad( 280 ), math.rad( 43 ), 0 ),
	
	RightWeld = CFrame.new( -1.2, 0.1, 0.4 ) * CFrame.Angles( math.rad( 270 ), math.rad( -10 ), 0 ),
	
	FireSound = script.Fire,
	
	ReloadSound = script.Reload
	
}