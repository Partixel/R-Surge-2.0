return {
	--[[Uses Major.minor.patch format, if a number is specified instead of * it'll restrict the version to that number]]
	Version = "7.*.*", -- Default - "5.*.*"
	
	--[[If the name of an object S2 loads in (e.g. ["Hud"] = true) is in this table it won't load said object]]
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
			
			ShotKnockbackPercentage = 0,
			
			GlobalDamageMultiplier = 1,
			
			MovementAccuracyPercentage = 0,
			
			HeadDamageMultiplier = 1.75,
			
			ScreenRecoilPercentage = 0,
			
			Resistances = { },
			
			AllowSprint = true,
			
			SprintSpeedMultiplier = 1.35,
			
			R6SprintAnimation = nil,
			
			R15SprintAnimation = nil,
			
			AllowCrouch = true,
			
			CrouchSpeedMultiplier = 0.9,
			
			CrouchJumpPowerMultiplier = 0.6,
			
			AllowAtEase = true,
			
			R6AtEaseAnimation = 955877742,
			
			R15AtEaseAnimation = nil,
			
			AllowInspect = true,
			
			R6InspectAnimation = 5455927431, --05052440268,
			
			R15InspectAnimation = nil,
			
		},
		RaycastGun = {
		
			R6AtEaseAnimation = 04994572482,
			
			R6SprintAnimation = 4994779369,
			
		}
	}, -- Default - { All = { LimbDamageMultiplier = 0.9, DistanceDamageModifier = 0.2, AllowSelfDamage = false, AllowNeutralTeamKill = true, AllowTeamKill = false, ShotKnockbackPercentage = 1, Resistances = { }, MovementAccuracyPercentage = 1, HeadDamageMultiplier = 1.75, ScreenRecoilPercentage = 1, GlobalDamageMultiplier = 1, }, }
	
	--[[Automatically handle arm welds]]
	ArmWelds = true, -- Default - true
	
	R6SaluteAnimation = 580605334,
	
	R15SaluteAnimation = nil,
	
	AllowSalute = true, -- Default - true
	
	R6SurrenderAnimation = 1173354695,
	
	R15SurrenderAnimation = nil,
	
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
	
	--[[Lets you override/add stat options for the S2 leaderboard system - You can check what values are available within the Leaderboard script - S2.ServerScriptService.Leaderboard]]
	LeaderboardOverrides = { }, -- Default - { }
	
	--[[Lets create a stat that combines other stats, e.g.
	["K/D/A"] = {
		Format = "{Kills}/{Deaths}/{Assists}",
		Priority = 110,
	},]]
	LeaderboardCombinedStats = { }, -- Default - { }
	
	--------[[ DO NOT TOUCH ]]--------
	
	SetupVersion = "2.0.0", -- DO NOT CHANGE THIS
}