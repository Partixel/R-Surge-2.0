return {
	
	ReloadWhileUnequipped = true,
	
	PreventSprint = true,
	
	WeaponModes = { "Auto", "Safety" },
	
	Damage = 30, -- Damage of the gun
	
	FireRate = 80, -- How many clicks will be handled in a second
	
	ClipSize = 200, -- The max ammo the gun has, -1 is infinite
	
	ReloadDelay = 4, -- The time it takes to reload
	
	Range = 1000, -- The distance the bullet travels
	
	AccurateRange = 25, -- The accuracy of the bullet ( Higher = less accurate )
	
	WindupTime = 3,
	
	Barrels = function ( StatObj ) return StatObj.Parent:WaitForChild( "Handle" ) end, -- A function returning a table of the Barrels
	
	BulletSize = .5,
	
	BulletTransparency = 0,
	
	FireSound = script.Fire,
	
	ReloadSound = script.Reload,
	
	WindupSound = script.Windup
	
}