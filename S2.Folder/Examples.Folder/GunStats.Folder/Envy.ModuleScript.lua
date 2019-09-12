local Values = { }

Values.FireModes = { "Semi" }

Values.BulletType = { Name = 'Lightning' }

Values.PreventSprint = true

Values.WalkSpeedMod = 1.5625

Values.Damage = 30 -- Damage of the gun

Values.FireRate = 1 -- How many clicks will be handled in a second

Values.ClipSize = 5 -- The max ammo the gun has, -1 is infinite

Values.ReloadDelay = 5 -- The time it takes to reload

Values.Range = 200 -- The distance the bullet travels

Values.AccurateRange = 100 -- The accuracy of the bullet ( Higher = less accurate )

Values.Barrels = function ( StatObj ) return StatObj.Parent:WaitForChild( "Flash" ) end

Values.LeftWeld = CFrame.new( -0.5, 0.5, 0.7 ) * CFrame.Angles( math.rad( 300 ), -0.2, math.rad( -100 ) )

Values.RightWeld = CFrame.new( -1, -0.2, 0.35 ) * CFrame.Angles( math.rad( -90 ), math.rad( -1 ), 0.05 )

Values.FireSound = script.Fire

Values.ReloadSound = script.Reload

Values.BulletColor = BrickColor.new("Bright green").Color

Values.Knockback = 2

Values.KnockAll = true

return Values