--!strict
-- Remote pour mettre ? jour les clients sur l'?tat des d?cibels

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = Instance.new("RemoteEvent")
remote.Name = "DecibelUpdate"
remote.Parent = script.Parent

return remote
