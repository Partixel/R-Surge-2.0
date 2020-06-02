local CollectionService = game:GetService("CollectionService")

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))

local Menu = require(game:GetService("ReplicatedStorage"):WaitForChild("MenuLib"):WaitForChild("S2"))

local SoundId
Menu:AddSetting{Name = "DamageIndicatorSoundId", Text = "Damage Indicator SoundId", Default = 161164363, Update = function(Options, Val)
	SoundId = Val
end}

local Volume
Menu:AddSetting{Name = "DamageIndicatorVolume", Text = "Damage Indicator Volume", Default = 0.2, Min = 0, Max = 1, Update = function(Options, Val)
	Volume = Val
end}

local PlaybackSpeed
Menu:AddSetting{Name = "DamageIndicatorPlaybackSpeed", Text = "Damage Indicator Playback Speed", Default = 1, Min = 0, Max = 5, Update = function(Options, Val)
	PlaybackSpeed = Val
end}

local TimePosition
Menu:AddSetting{Name = "DamageIndicatorTimePosition", Text = "Damage Indicator Sound Start Time", Default = 0, Update = function(Options, Val)
	TimePosition = Val
end}

local PlayTime
Menu:AddSetting{Name = "DamageIndicatorPlayTime", Text = "Damage Indicator Sound Play Time (0 = Full sound)", Default = 0, Update = function(Options, Val)
	PlayTime = Val
end}

local HeadshotSoundId
Menu:AddSetting{Name = "DamageIndicatorHeadshotSoundId", Text = "Damage Indicator Headshot SoundId", Default = 0, Update = function(Options, Val)
	HeadshotSoundId = Val
end}

local HeadshotVolume
Menu:AddSetting{Name = "DamageIndicatorHeadshotVolume", Text = "Damage Indicator Headshot Volume", Default = 0.2, Min = 0, Max = 1, Update = function(Options, Val)
	HeadshotVolume = Val
end}

local HeadshotPlaybackSpeed
Menu:AddSetting{Name = "DamageIndicatorHeadshotPlaybackSpeed", Text = "Damage Indicator Headshot Playback Speed", Default = 1.25, Min = 0, Max = 5, Update = function(Options, Val)
	HeadshotPlaybackSpeed = Val
end}

local HeadshotTimePosition
Menu:AddSetting{Name = "DamageIndicatorHeadshotTimePosition", Text = "Damage Indicator Headshot Sound Start Time", Default = 0, Update = function(Options, Val)
	HeadshotTimePosition = Val
end}

local HeadshotPlayTime
Menu:AddSetting{Name = "DamageIndicatorHeadshotPlayTime", Text = "Damage Indicator Headshot Sound Play Time (0 = Full sound)", Default = 0, Update = function(Options, Val)
	HeadshotPlayTime = Val
end}

local Heartbeat = game:GetService("RunService").Heartbeat
function HeartbeatWait(num)
	local t=0
	while t<num do
		t = t + Heartbeat:Wait()
	end
	return t
end

Core.Events.DamageMarkerSound = Core.ClientDamage.OnClientEvent:Connect(function(DamageSplits, ExtraInformation)
	if type(ExtraInformation) ~= "string" then
		local Headshot, Noise = ExtraInformation.HitName:lower( ):find( "head" ), nil
		for _, DamageSplit in ipairs(DamageSplits) do
			if DamageSplit[1].Parent and not CollectionService:HasTag(DamageSplit[1], "s2_silent") then
				Noise = true
				break
			end
		end
		
		if Noise then
			local HitSound = Instance.new("Sound")
			HitSound.Volume = Headshot and HeadshotVolume or Volume
			HitSound.SoundId = "rbxassetid://" .. (Headshot and HeadshotSoundId ~= 0 and HeadshotSoundId or SoundId)
			HitSound.PlaybackSpeed = Headshot and HeadshotPlaybackSpeed or PlaybackSpeed
			HitSound.TimePosition = Headshot and HeadshotTimePosition or TimePosition
			if (Headshot and HeadshotPlayTime == 0) or (not Headshot and PlayTime == 0) then
				HitSound.Ended:Connect( function () wait() HitSound:Destroy() end)
			end
			HitSound.Parent = workspace.CurrentCamera
			HitSound:Play()
			if (Headshot and HeadshotPlayTime ~= 0) or (not Headshot and PlayTime ~= 0) then
				HeartbeatWait(Headshot and HeadshotPlayTime or PlayTime)
				HitSound:Destroy()
			end
		end
	end
end)