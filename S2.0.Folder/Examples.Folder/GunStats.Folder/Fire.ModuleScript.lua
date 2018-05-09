return {
	
	PreventSprint = true,
	
	FireModes = { "Auto", "Safety" },
	
	BulletType = { Name = "Fire" },
	
	Damage = 2, -- Damage of the gun
	
	FireRate = 15, -- How many clicks will be handled in a second
	
	MaxAmmo = 100, -- The max ammo the gun has, -1 is infinite
	
	ReloadDelay = 2, -- The time it takes to reload
	
	Range = 30, -- The distance the bullet travels
	
	AccurateRange = 5, -- The accuracy of the bullet ( Higher = less accurate )
	
	Barrels = function ( StatObj ) return StatObj.Parent:WaitForChild( "Handle" ) end, -- A function returning a table of the Barrels
	
	FireSound = script.Fire,
	
	ReloadSound = script.Reload
	
}