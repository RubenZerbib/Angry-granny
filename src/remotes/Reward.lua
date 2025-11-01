--!strict
-- Remote pour les r?compenses (coins, notifications)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = Instance.new("RemoteEvent")
remote.Name = "Reward"
remote.Parent = script.Parent

return remote
