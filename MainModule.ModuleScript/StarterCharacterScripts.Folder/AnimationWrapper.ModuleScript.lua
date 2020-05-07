local AnimationWrapper = {Humanoid = script.Parent.Parent:WaitForChild("Humanoid")}

local RunningAnimations = {}
for _, Priority in ipairs(Enum.AnimationPriority:GetEnumItems()) do
	RunningAnimations[Priority] = {}
end

local function Add(Animation, FadeTime)
	Animation.RanPriority = Animation.AnimationTrack.Priority
	local PriorityTable = RunningAnimations[Animation.AnimationTrack.Priority]
	if PriorityTable then
		if #PriorityTable == 0 then
			PriorityTable[1] = Animation
		elseif PriorityTable[#PriorityTable].Priority <= Animation.Priority then
			PriorityTable[#PriorityTable].AnimationTrack:AdjustWeight(0.0001, FadeTime)
			PriorityTable[#PriorityTable + 1] = Animation
		else
			Animation.AnimationTrack:AdjustWeight(0.0001, 0)
			for i, Track in ipairs(PriorityTable) do
				if Track.Priority > Animation.Priority then
					table.insert(PriorityTable, i, Animation)
					break
				end
			end
		end
	end
end

local function Remove(Animation, FadeTime)
	local PriorityTable = RunningAnimations[Animation.RanPriority]
	if PriorityTable[#PriorityTable] == Animation then
		PriorityTable[#PriorityTable] = nil
		if #PriorityTable ~= 0 then
			PriorityTable[#PriorityTable].AnimationTrack:AdjustWeight(PriorityTable[#PriorityTable].OriginalWeight, FadeTime)
		end
	else
		table.remove(PriorityTable, table.find(PriorityTable, Animation))
	end
end

local AnimationObject = {
	Play = function(self, FadeTime, Weight, ...)
		if self.AnimationTrack.IsPlaying then
			Remove(self, FadeTime)
		end
		
		self.OriginalWeight = Weight
		self.AnimationTrack:Play(FadeTime, Weight, ...)
		Add(self, FadeTime)
	end,
	Stop = function(self, FadeTime)
		if self.AnimationTrack.Looped then
			Remove(self, FadeTime)
			self.OriginalWeight = nil
			self.RanPriority = nil
		end
		
		self.AnimationTrack:Stop(FadeTime)
	end,
	SetPriority = function(self, Priority)
		if self.IsPlaying then
			Remove(self)
		end
		
		self.Priority = Priority
		
		if self.IsPlaying then
			Add(self)
		end
	end,
}

local Index = {
	__index = AnimationObject
}

local Animations = {}
function AnimationWrapper.GetAnimation(Name, AnimProps, Priority)
	local Key = Name .. ":" .. tostring(AnimProps)
	if not Animations[Key] then
		local Animation = Instance.new("Animation")
		Animation.AnimationId = "rbxassetid://" .. AnimProps.Id
		Animation.Name = Name
		Animation = setmetatable({Name = Name, Priority = Priority, AnimationTrack = AnimationWrapper.Humanoid:LoadAnimation(Animation), Cache = {}}, Index)
		if not Animation.AnimationTrack.Looped then
			Animation.AnimationTrack.Stopped:Connect(function()
				Remove(Animation)
				Animation.OriginalWeight = nil
				Animation.RanPriority = nil
			end)
		end
		Animations[Key] = Animation
	end
	
	return Animations[Key]
end

return AnimationWrapper