return {
	
	PreventSprint = true,
	
	FireModes = { "Semi", "Safety" },
	
	BulletType = { Name = "Explosive", Type = "Stun", BlastRadius = 6, BlastPressure = 10000, ExplosionType = Enum.ExplosionType.CratersAndDebris },
	
	Damage = 10,
	
	FireRate = 0.5,
	
	MaxAmmo = 1,
	
	ReloadDelay = 5,
	
	Range = 350,
	
	AccurateRange = 25,
	
	Barrels = function ( StatObj ) return StatObj.Parent:WaitForChild( "Flash" ) end,
	
	LeftWeld = CFrame.new( 0.8, 0.5, 0.4 ) * CFrame.Angles( math.rad( 280 ), math.rad( 43 ), 0 ),
	
	RightWeld = CFrame.new( -1.2, 0.1, 0.4 ) * CFrame.Angles( math.rad( 270 ), math.rad( -10 ), 0 ),
	
	FireSound = script.Fire,
	
	ReloadSound = script.Reload
	
}