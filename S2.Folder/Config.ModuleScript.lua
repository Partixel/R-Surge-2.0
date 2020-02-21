return {
	--[[Uses Major.minor.patch format, if a number is specified instead of * it'll restrict the version to that number]]
	Version = "3.*.*", -- Default - "*.*.*"
	
	--[[If the name of an object S2 loads in (e.g. "Hud") is in this table it won't load said object]]
	Disabled = { }, -- Default - { }
	
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
	
	--------[[ Gameplay Configs ]]--------
	
	--[[Allows you to override the default weapon stats for all weapons of a specific type, e.g.
WeaponTypeOverrides = {
	RaycastGun = {Damage = 20, FireRate = 0.5},
}]]
	WeaponTypeOverrides = { 
		
		All = { 
			
			LimbDamageMultiplier = 0.9,
			
			DistanceDamageModifier = 0.2,
			
			AllowSelfDamage = false,
			
			AllowNeutralTeamKill = true,
			
			AllowTeamKill = false,
			
			GlobalDamageMultiplier = 1,
			
			Resistances = { },
			
			MovementAccuracyPercentage = 1,
			
			HeadDamageMultiplier = 1.75,
			
			ScreenRecoilPercentage = 1,
			
			ShotKnockbackPercentage = 1,
			
		},
		
	}, -- Default - { All = { LimbDamageMultiplier = 0.9, DistanceDamageModifier = 0.2, AllowSelfDamage = false, AllowNeutralTeamKill = true, AllowTeamKill = false, ShotKnockbackPercentage = 1, Resistances = { }, MovementAccuracyPercentage = 1, HeadDamageMultiplier = 1.75, ScreenRecoilPercentage = 1, GlobalDamageMultiplier = 1, }, }
	
	--[[Automatically handle arm welds]]
	ArmWelds = true, -- Default - true
	
	AllowSprinting = true, -- Default - true
	
	SprintSpeedMultiplier = 1.35, -- Default - 1.35
	
	AllowCrouching = true, -- Default - true
	
	--[[Crouch WalkSpeed (Percentage of normal walkspeed)]]
	CrouchSpeedMultiplier = 0.9, -- Default - 0.9
	
	--[[Crouch JumpPower (Percentage of normal jump power)]]
	CrouchJumpPowerMultiplier = 0.6, -- Default - 0.6
	
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
game.Teams[ "S2_TEAMNAME" ].Value instead of game.Teams.TEAMNAME
If this is a string it'll be used as a template for the team names (e.g. "%PlayerCount% Player(s) on %TeamName%" will translate to "2 Player(s) on Red Team" assuming the teams name is "Red Team" and it has 2 players on it]]
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
	
	SetupVersion = "1.4.0", -- DO NOT CHANGE THIS
}