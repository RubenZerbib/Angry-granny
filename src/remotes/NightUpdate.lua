--!strict
-- Remote pour mettre ? jour les clients sur l'?tat de la nuit

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = Instance.new("RemoteEvent")
remote.Name = "NightUpdate"
remote.Parent = script.Parent

return remote
