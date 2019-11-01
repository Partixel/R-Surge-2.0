return {
	
	WeaponModes = { "Auto", "Burst", "Semi", "Safety" },
	
	Damage = -5,
	
	FireRate = 30,
	
	ClipSize = 100,
	
	MaxStoredAmmo = 300,
	
	ReloadAmount = 100,
	
	AllowManualReload = false,
	
	ClipReloadPerSecond = 30,
	
	ReloadDelay = 4,
	
	Barrels = function ( StatObj ) return StatObj.Parent.Handle end,
	
	Range = 500,
	
	AccurateRange = 100,
	
	WindupTime = 0,
	
	WindupSound = script.Windup,
	
	ReloadSound = script.Reload
	
}