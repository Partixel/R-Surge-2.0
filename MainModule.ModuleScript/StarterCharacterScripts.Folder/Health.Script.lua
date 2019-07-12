-- Gradually regenerates the Humanoid's Health over time.

local REGEN_RATE = 1/100 -- Regenerate this fraction of MaxHealth per second.
local REGEN_STEP = 1 -- Wait this long between each regeneration step.

--------------------------------------------------------------------------------

local Character = script.Parent
local Humanoid = Character:WaitForChild'Humanoid'

--------------------------------------------------------------------------------

while true do
	while true do
		local dt = wait(REGEN_STEP)
		if Humanoid.Health >= Humanoid.MaxHealth or Humanoid:GetState() == Enum.HumanoidStateType.Dead then break end
		Humanoid.Health = math.min(Humanoid.Health + dt*REGEN_RATE*Humanoid.MaxHealth, Humanoid.MaxHealth)
	end
	Humanoid.HealthChanged:Wait()
end