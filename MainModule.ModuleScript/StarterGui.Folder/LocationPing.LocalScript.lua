local CollectionService = game:GetService("CollectionService")

local Core = require(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
local KBU = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("S2"):WaitForChild("KeybindUtil"))

local LocationPingEvent = Instance.new("BindableEvent")
LocationPingEvent.Name = "LocationPing"
LocationPingEvent.Parent = script

local Lifetime = 10

-- Compsas point
LocationPingEvent.Event:Connect(function(Pos)
	local Point = Instance.new("Vector3Value")
	Point.Value = Pos
	
	local Col = Instance.new("Color3Value", Point)
	Col.Name = "Color"
	Col.Value = Color3.fromRGB(50, 50, 255)
	
	CollectionService:AddTag(Point, "S2_POI")
	Point.Parent = workspace
	
	wait(Lifetime)
	
	Point:Destroy()
end)

-- Billboard point
LocationPingEvent.Event:Connect(function(Pos)
	local PingBillboard = script.PingBillboard:Clone()
	PingBillboard.Adornee = workspace.Terrain
	PingBillboard.StudsOffsetWorldSpace = Pos
	PingBillboard.Enabled = true
	PingBillboard.Parent = script.Parent
	
	wait(Lifetime)
	
	PingBillboard:Destroy()
end)

local Remote = game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("LocationgPingRemote")
Remote.OnClientEvent:Connect(function(Pos, Type)
	LocationPingEvent:Fire(Pos)
end)

local Active = 0
local function ReduceActive()
	wait(Lifetime)
	
	Active -= 1
end

KBU.AddBind{Name = "Location Ping", Category = "Surge 2.0", Callback = function(Began)
	if Began and Active < 5 then
		Active += 1
		local Pos = Core.GetLPlrsTarget()[2]
		Remote:FireServer(Pos)
		LocationPingEvent:Fire(Pos, "1")
		
		coroutine.wrap(ReduceActive)()
	end
end, Key = Enum.KeyCode.Z, NoHandled = true}