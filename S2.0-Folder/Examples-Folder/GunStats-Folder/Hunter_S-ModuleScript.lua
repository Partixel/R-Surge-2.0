return {
	FireModes = {"Semi"},
	Damage = 60,
	FireRate = 0.3,
	MaxAmmo = 7,
	ReloadDelay = 2.3,
	Range = 1000,
	AccurateRange = 800,
	Scope = {Max = 10, Min = 40},
	FireSound = script.Fire,
	ReloadSound = script.Reload,
	LeftWeld = CFrame.new(0.8, 0.5, 0.4 ) * CFrame.Angles(math.rad(280), math.rad(43), 0),
	RightWeld = CFrame.new(-1.2, 0.1, 0.4 ) * CFrame.Angles(math.rad(270), math.rad(-10), 0),
	Barrels = function(StatObj) return StatObj.Parent:WaitForChild("Barrel") end
}