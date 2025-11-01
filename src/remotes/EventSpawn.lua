--!strict
-- Remote pour notifier les clients d'un nouvel ?v?nement

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = Instance.new("RemoteEvent")
remote.Name = "EventSpawn"
remote.Parent = script.Parent

return remote
