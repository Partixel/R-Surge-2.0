return {
	
	PreventSprint = true,
	
	WeaponModes = { "Auto", "Safety" },
	
	BulletType = { Name = "Lightning", Radius = 4 },
	
	Damage = 10, -- Damage of the gun
	
	FireRate = 7, -- How many clicks will be handled in a second
	
	ClipSize = 22, -- The max ammo the gun has, -1 is infinite
	
	ReloadAmount = 11, -- The amount that will be reloaded at a time ( Will reload from a multiple of this, e.g. 22 ClipSize, 11 ReloadAmount, 20 ammo when reloading will result in ammo being set to 11 and then after half the ReloadDelay will be filled )
	
	ReloadFromEmpty = false, -- The gun will not empty the ammo when reloading
	
	ReloadDelay = 2, -- The time it takes to reload
	
	Range = 150, -- The distance the bullet travels
	
	AccurateRange = 80, -- The accuracy of the bullet ( Higher = less accurate )
	
	Barrels = function ( StatObj ) return StatObj.Parent:WaitForChild( "Handle" ) end, -- A function returning a table of the Barrels
	
	FireSound = script.Fire,
	
	ReloadSound = script.Reload
	
}