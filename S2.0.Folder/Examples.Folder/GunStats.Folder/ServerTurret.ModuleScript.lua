return {
	
	PreventSprint = true,
	
	FireModes = { "Auto", "Safety" },
	
	Damage = 10, -- Damage of the gun
	
	FireRate = 80, -- How many clicks will be handled in a second
	
	MaxAmmo = 20, -- The max ammo the gun has, -1 is infinite
	
	ReloadDelay = 5, -- The time it takes to reload
	
	Range = 1000, -- The distance the bullet travels
	
	AccurateRange = 25, -- The accuracy of the bullet ( Higher = less accurate )

	WindupTime = 2,
	
	Barrels = function ( StatObj ) return StatObj.Parent:WaitForChild( "Handle" ) end, -- A function returning a table of the Barrels
	
	BulletSize = .5,
	
	BulletTransparency = 0,
	
	FireSound = script.Fire,
	
	ReloadSound = script.Reload,
	
	User = { Name = "Model", TeamColor = BrickColor.Random( ) },
	
	Target = function ( StatObj ) return nil, ( StatObj.Parent.Handle.CFrame + StatObj.Parent.Handle.CFrame.lookVector * 999 ).p end
	
}