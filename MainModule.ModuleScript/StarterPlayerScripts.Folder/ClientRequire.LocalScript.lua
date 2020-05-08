local CoroutineErrorHandling = require(game:GetService("ReplicatedStorage"):FindFirstChild("CoroutineErrorHandling"))

CoroutineErrorHandling.CoroutineWithStack(require, game:GetService("ReplicatedStorage"):WaitForChild("S2"):WaitForChild("Core"))
CoroutineErrorHandling.CoroutineWithStack(require, script.Parent:WaitForChild("PoseUtil"))
CoroutineErrorHandling.CoroutineWithStack(require, script.Parent:WaitForChild("KeybindUtil"))