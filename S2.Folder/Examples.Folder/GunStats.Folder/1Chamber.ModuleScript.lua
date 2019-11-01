return {
	
	WeaponModes = { "Semi", "Safety" },
	
	Damage = 150,
	
	FireRate = 1,
	
	StartingClip = 1,
	
	ReloadDelay = 2,
	
	Range = 450,
	
	AccurateRange = 100,
	
	Barrels = function ( StatObj ) return StatObj.Parent:WaitForChild( "Barrel" ) end,
	
	FireSound = script.Fire,
	
	ReloadSound = script.Reload
	
}