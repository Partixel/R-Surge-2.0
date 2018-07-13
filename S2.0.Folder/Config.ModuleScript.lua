_G.S20Config = { }

-- Teams that cannot team kill each other e.g. { { [ "Bright green" ] = true , White = true } }
-- will stop teams Bright green and White from killing each other ( Default { } )
_G.S20Config.AllowTeamKillFor = { { Black = true, [ "Bright green" ] = true, [ "Bright yellow" ] = true } }

-- The distance a bullet will drop at a distance of 999 studs ( Default - 10 )
_G.S20Config.BulletDrop = 10

-- How much damage is taken as a percentage of normal damage( 1 = 100% of damage )
_G.S20Config.GlobalDamageMultiplier = 1

-- How much extra damage hitting the head does ( 1 = 100% ) ( Default - 1.75 ( 125% damage ) )
_G.S20Config.HeadDamageMultiplier = 1.75

-- How much extra damage hitting a limb does ( 1 = 100% ) ( Default - 0.9 ( 90% damage ) )
_G.S20Config.LimbDamageMultiplier = 0.9

-- How much extra damage hitting a limb does ( 1 = 100% ) ( Default - 0.2 ( 20% damage ) )
_G.S20Config.AppendageDamageMultiplier = 0.2

-- How large is the screen recoil ( 1 = 100% of the normal recoil ) ( 0 = No recoil ) ( Default - 1 )
_G.S20Config.ScreenRecoilPercentage = 1

-- How much distance affects the damage of a bullet ( Default - 0.2 )
_G.S20Config.DistanceDamageMultiplier = 0.2

-- How much does movement affect accuracy ( 1 = 100% of the normal reduction in accuracy ) ( 0 = Not at all ) ( Default - 1 )
_G.S20Config.MovementAccuracyPercentage = 1

-- How large the force pushing an object back when shot is ( 1 = 100% of the normal knockback) ( 0 = No knockback ) ( Default - 1 )
_G.S20Config.ShotKnockbackPercentage = 1

-- How resistant objects are to each type of damage by default ( 1 = 100% of the normal damage ) ( e.g. { Splash = 1, Fire = 0.5 } ) ( Default = { } )
-- Can be overriden per humanoid by putting a Folder name "Resistances" in it and then a NumberValue with the name of the type you want resistance to
-- Types = Kinectic, Explosive, Slash, Fire, Electricity
_G.S20Config.Resistances = { }

-- If true, anyone without a team ( 'neutral' ) can kill each other ( Default - true)
_G.S20Config.AllowNeutralTeamKill = true

-- If true, anyone can kill anyone - Overrides AllowTeamKillFor ( Default - false )
_G.S20Config.AllowTeamKill = false

-- Automatically handle arm welds( Default - true )
_G.S20Config.ArmWelds = true

-- Use the S2.0 gun cursor ( Default - true )
_G.S20Config.GunCursor = true

_G.S20Config.AllowSprinting = true

_G.S20Config.AllowCrouching = true

-- Self damage
_G.S20Config.SelfDamage = false

-- Crouch Walkspeed reduction (Percentage)
_G.S20Config.CrouchSpeedMultiplier = 0.9

-- Crouch JumpPower (Percentage)
_G.S20Config.CrouchJumpPowerMultiplier = 0.5

---- LEADBOARD CONFIGS ----

-- The GroupId used for the rank on the leaderboard ( Default - nil ) ( If nil, no rank stat is created )
_G.S20Config.RankGroupId = nil

-- If true, wipeouts will be shown on the leaderboard ( Default - true )
_G.S20Config.ShowWOs = true

-- If true, assists will be shown on the leaderboard ( Default - true )
_G.S20Config.ShowAssists = true

-- If true, credits will be shown on the leaderboard ( Default - false )
_G.S20Config.ShowCredits = false

-- The amount of player points a player will be given for a KO ( Default - 2 )
_G.S20Config.PlayerPointsPerKO = 2

_G.S20Config.PlayerPointsPerAssist = 1

-- The default amount of credits a player will start with ( Default - 100 )
_G.S20Config.DefaultCredits = 100

-- If this is 0 credits do not save, 1 saves to DataStore and 2 saves to PointsService ( Default - 0 )
_G.S20Config.SaveCredits = 0 

-- How many credits a player gets per payday ( Default - 20 )
_G.S20Config.CreditsPerPayday = 20

-- The time between each payday ( Default - 60 )
_G.S20Config.PaydayDelay = 1

-- How many points a player gets for kills ( They get half of this for assists ) ( Default - 40 )
_G.S20Config.CreditsPerKill = 40

_G.S20Config.CreditsPerAssist = 20

_G.S20Config.CreditsPerDamage = 0

_G.S20Config.CreditsPerHeal = 0

return nil