--!strict
-- Remote pour l'?tat de Granny

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = Instance.new("RemoteEvent")
remote.Name = "GrannyState"
remote.Parent = script.Parent

return remote
