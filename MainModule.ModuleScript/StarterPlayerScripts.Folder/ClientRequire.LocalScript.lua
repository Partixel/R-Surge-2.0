local LuaRequire = function(...) return require(...) end
coroutine.wrap(LuaRequire)(game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
coroutine.wrap(LuaRequire)(script.Parent:WaitForChild("PoseUtil"))
coroutine.wrap(LuaRequire)(script.Parent:WaitForChild("KeybindUtil"))