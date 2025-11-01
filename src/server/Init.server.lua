-- Init.server.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- === Debug Switch ===
local dbg = require(script.Parent:FindFirstChild("ServerDebug") or Instance.new("ModuleScript"))
if not script.Parent:FindFirstChild("ServerDebug") then
	local m = Instance.new("ModuleScript")
	m.Name = "ServerDebug"
	m.Source = [[
		local M = { ENABLED = true, TAGS = {NIGHT=true,GRANNY=true,EVENTS=true,DB=true,IAP=false} }
		function M.log(tag, ...) if M.ENABLED and (M.TAGS[tag] ~= false) then print(("[%-6s] "):format(tag), ...) end end
		return M
	]]
	m.Parent = script.Parent
end
local LOG = require(script.Parent.ServerDebug)

-- === Remotes bootstrap ===
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage
local remoteNames = { "DecibelUpdate","NightUpdate","EventSpawn","PlayerAction","GrannyState","Purchase","Reward" }
for _, n in ipairs(remoteNames) do
	if not remotesFolder:FindFirstChild(n) then
		local ev = Instance.new("RemoteEvent"); ev.Name = n; ev.Parent = remotesFolder
		LOG.log("DB","Created RemoteEvent", n)
	end
end

-- === Load core systems ===
local ok, NightServer = pcall(function() return require(script.Parent.NightServer) end)
local ok2, GrannyAI    = pcall(function() return require(script.Parent.GrannyAI) end)
local ok3, EventsServer= pcall(function() return require(script.Parent.EventsServer) end)
local ok4, DecibelSrv  = pcall(function() return require(script.Parent.DecibelServer) end)
if not ok then warn("NightServer require failed") end
if not ok2 then warn("GrannyAI require failed") end
if not ok3 then warn("EventsServer require failed") end
if not ok4 then warn("DecibelServer require failed") end

task.spawn(function()
	if NightServer and NightServer.StartNightLoop then
		LOG.log("NIGHT","Starting night loop?")
		NightServer.StartNightLoop()
	end
end)

task.spawn(function()
	if GrannyAI and GrannyAI.Init then
		LOG.log("GRANNY","Initializing Granny AI?")
		GrannyAI.Init() -- Spawns granny at bed in Sleeping state
	end
end)

Players.PlayerAdded:Connect(function(plr)
	LOG.log("NIGHT","Player joined:", plr.Name)
end)

print("[SERVER] ? Init complete (Remotes, NightLoop, Granny).")
