--!strict
-- Remote pour les achats d'items

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = Instance.new("RemoteEvent")
remote.Name = "Purchase"
remote.Parent = script.Parent

return remote
