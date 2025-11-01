--!strict
-- Remote pour les actions du joueur (interactions avec ?v?nements)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = Instance.new("RemoteEvent")
remote.Name = "PlayerAction"
remote.Parent = script.Parent

return remote
