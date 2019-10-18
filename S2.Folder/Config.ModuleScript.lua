return {
	--------[[ Damage Configs ]]--------
	
	SupportLegacyKOs = false, -- Default - false
	
	--[[Teams that cannot team kill each other e.g. { { [ "Bright green" ] = true , White = true } }
	will stop teams Bright green and White from killing each other]]
	AllowTeamKillFor = { 
		
		{ 
			
			[ "Bright green" ] = true,
			
			Black = true,
			
			[ "Bright yellow" ] = true,
			
		},
		
	}, -- Default - { }
	
	--[[If true, anyone without a team ( 'neutral' ) can kill each other]]
	AllowNeutralTeamKill = true, -- Default - true
	
	--[[If true, anyone can kill anyone - Overrides AllowTeamKillFor]]
	AllowTeamKill = false, -- Default - false
	
	AllowSelfDamage = false, -- Default - false
	
	--[[How resistant objects are to each type of damage by default ( 1 = 100% of the normal damage ) ( e.g. { Splash = 1, Fire = 0.5 } )
	Can be overriden per humanoid by putting a Folder name "Resistances" in it and then a NumberValue with the name of the type you want resistance to
	Types = Kinectic, Explosive, Slash, Fire, Electricity]]
	Resistances = { }, -- Default - { }
	
	--[[How much damage is taken as a percentage of normal damage( 1 = 100% of damage )]]
	GlobalDamageMultiplier = 1, -- Default - 1
	
	--[[How much extra damage hitting the head does ( 1 = 100% )]]
	HeadDamageMultiplier = 1.75, -- Default - 1.75
	
	--[[How much extra damage hitting a limb does ( 1 = 100% )]]
	LimbDamageMultiplier = 0.9, -- Default - 0.9
	
	--[[How much distance affects the damage of a bullet]]
	DistanceDamageMultiplier = 0.2, -- Default - 0.2
	
	--------[[ Gameplay Configs ]]--------
	
	--[[How large is the screen recoil ( 1 = 100% of the normal recoil ) ( 0 = No recoil )]]
	ScreenRecoilPercentage = 1, -- Default - 1
	
	--[[How much does movement affect accuracy ( 1 = 100% of the normal reduction in accuracy ) ( 0 = Not at all )]]
	MovementAccuracyPercentage = 1, -- Default - 1
	
	--[[How large the force pushing an object back when shot is ( 1 = 100% of the normal knockback) ( 0 = No knockback )]]
	ShotKnockbackPercentage = 1, -- Default - 1
	
	--[[Automatically handle arm welds]]
	ArmWelds = true, -- Default - true
	
	AllowSprinting = true, -- Default - true
	
	SprintSpeedMultiplier = 1.35, -- Default - 1.35
	
	AllowCrouching = true, -- Default - true
	
	--[[Crouch WalkSpeed (Percentage of normal walkspeed)]]
	CrouchSpeedMultiplier = 0.9, -- Default - 0.9
	
	--[[Crouch JumpPower (Percentage of normal jump power)]]
	CrouchJumpPowerMultiplier = 0.6, -- Default - 0.6
	
	AllowCharacterRotation = true, -- Default - true
	
	AllowSalute = true, -- Default - true
	
	AllowAtEase = true, -- Default - true
	
	AllowSurrender = true, -- Default - true
	
	--[[1 = default roblox, 2 = hats instantly get destroyed, 3 = hats are dropped]]
	HatMode = 3, -- Default - 3
	
	--[["Center", "Left" or "Right"]]
	KillFeedHorizontalAlign = "Center", -- Default - "Center"
	
	--[["Top" or "Bottom"]]
	KillFeedVerticalAlign = "Top", -- Default - "Top"
	
	--[[Adds the number of players on a team after the teams name, will require scripts that access teams to be updated to do:
	game.Teams[ "S2_TEAMNAME" ].Value instead of game.Teams.TEAMNAME]]
	TeamCounts = true, -- Default - false
	
	--------[[ Leaderboard Configs ]]--------
	
	--[[If true, wipeouts will be shown on the leaderboard]]
	ShowWOs = true, -- Default - true
	
	--[[If true, assists will be shown on the leaderboard]]
	ShowAssists = true, -- Default - true
	
	--[[If true, damage done will be shown on the leaderboard]]
	ShowDamaged = false, -- Default - false
	
	--[[If true, healing done will be shown on the leaderboard]]
	ShowHealed = false, -- Default - false
	
	--[[The GroupId used for the rank on the leaderboard ( If nil, no rank stat is created )]]
	RankGroupId = nil, -- Default - nil
	
	--[[If true, credits will be shown on the leaderboard]]
	ShowCredits = false, -- Default - false
	
	--[[The default amount of credits a player will start with]]
	DefaultCredits = 100, -- Default - 100
	
	SaveCredits = false, -- Default - false
	
	--[[The time between each payday]]
	PaydayDelay = 60, -- Default - 60
	
	--[[How many credits a player gets per payday]]
	CreditsPerPayday = 20, -- Default - 20
	
	--[[How many points a player gets for kills]]
	CreditsPerKill = 40, -- Default - 40
	
	CreditsPerAssist = 20, -- Default - 20
	
	CreditsPerDamage = 0, -- Default - 0
	
	CreditsPerHeal = 0, -- Default - 0
	
	SetupVersion = "1.1.0", -- DO NOT CHANGE THIS
}