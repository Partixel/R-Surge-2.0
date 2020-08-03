return {
	{
		"Version",
		"7.*.*",
		[[Uses Major.minor.patch format, if a number is specified instead of * it'll restrict the version to that number]],
	},
	{
		"Disabled",
		{},
		[[If the name of an object S2 loads in (e.g. ["Hud"] = true) is in this table it won't load said object]],
	},
	"Damage Configs",
	{
		"SupportLegacyKOs",
		false,
	},
	{
		"AllowTeamKillFor",
		{ },
		[[Teams that cannot team kill each other e.g. { { [ "Bright green" ] = true , White = true } }
	will stop teams Bright green and White from killing each other]],
	},
	
	"Gameplay Configs",
	{
		"WeaponTypeOverrides",
		{
			All = {
					AllowNeutralTeamKill = true,
					AllowTeamKill = false,
					AllowSelfDamage = false,
					Resistances = {},
					GlobalDamageMultiplier = 1,
					HeadDamageMultiplier = 1.75,
					LimbDamageMultiplier = 0.9,
					DistanceDamageModifier = 0.2,
					ScreenRecoilPercentage = 1,
					MovementAccuracyPercentage = 1,
					ShotKnockbackPercentage = 1,
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
					R6InspectAnimation = 05052440268,
					R15InspectAnimation = nil,
				}
		},
		[[Allows you to override the default weapon stats for all weapons of a specific type, e.g.
	WeaponTypeOverrides = {
		RaycastGun = {Damage = 20, FireRate = 0.5},
	}]],
	},
	{
		"ArmWelds",
		true,
		[[Automatically handle arm welds]],
	},
	{
		"R6SaluteAnimation",
		580605334,
	},
	{
		"R15SaluteAnimation",
		nil,
	},
	{
		"AllowSalute",
		true,
	},
	{
		"R6SurrenderAnimation",
		1173354695,
	},
	{
		"R15SurrenderAnimation",
		nil,
	},
	{
		"AllowSurrender",
		true,
	},
	{
		"HatMode",
		3,
		[[1 = default roblox, 2 = hats instantly get destroyed, 3 = hats are dropped]],
	},
	{
		"KillFeedHorizontalAlign",
		"Center",
		[["Center", "Left" or "Right"]],
	},
	{
		"KillFeedVerticalAlign",
		"Top",
		[["Top" or "Bottom"]],
	},
	{
		"TeamCounts",
		false,
		[[Adds the number of players on a team after the teams name, will require scripts that access teams to be updated to do:
	game.Teams[ "S2_TEAMNAME" ].Value instead of game.Teams.TEAMNAME
	If this is a string it'll be used as a template for the team names (e.g. "%PlayerCount% Player(s) on %TeamName%" will translate to "2 Player(s) on Red Team" assuming the teams name is "Red Team" and it has 2 players on it]],
	},
	
	"Leaderboard Configs",
	{
		"LeaderboardOverrides",
		{},
		[[Lets you override/add stat options for the S2 leaderboard system - You can check what values are available within the Leaderboard script - S2.ServerScriptService.Leaderboard]],
	},
	{
		"LeaderboardCombinedStats",
		{},
		[[Lets create a stat that combines other stats, e.g.
	["K/D/A"] = {
		Format = "{Kills}/{Deaths}/{Assists}",
		Priority = 110,
	},]],
	},
	
	"DO NOT TOUCH",
	
	SetupVersion = "2.0.0",
}