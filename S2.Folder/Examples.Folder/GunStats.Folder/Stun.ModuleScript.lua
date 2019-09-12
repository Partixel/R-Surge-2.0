return {
	
	PreventSprint = true,
	
	FireModes = { "Auto", "Safety" },
	
	BulletType = { Name = "Stun" },
	
	Damage = 10, -- Damage of the gun
	
	FireRate = 1, -- How many clicks will be handled in a second
	
	ClipSize = 1, -- The max ammo the gun has, -1 is infinite
	
	ReloadDelay = 7, -- The time it takes to reload
	
	Range = 30, -- The distance the bullet travels
	
	BulletLength = 100,
	
	BulletSize = 0.1,
	
	AccurateRange = 10, -- The accuracy of the bullet ( Higher = less accurate )
	
	Barrels = function ( StatObj ) return StatObj.Parent:WaitForChild( "Handle" ) end, -- A function returning a table of the Barrels
	
	FireSound = script.Fire,
	
	ReloadSound = script.Reload
	
}