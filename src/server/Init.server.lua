-- Init.server.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

-- === Debug Switch ===
if not script.Parent:FindFirstChild("ServerDebug") then
	local m = Instance.new("ModuleScript")
	m.Name = "ServerDebug"
	m.Source = [[
		local M = { ENABLED = true, TAGS = {NIGHT=true,GRANNY=true,EVENTS=true,DB=true,IAP=false,MANOR=true} }
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

print("[SERVER] ?? Initializing Angry Granny Manor...")

-- === Load core systems ===
local Prefabs = require(script.Parent.Prefabs)
local DecibelServer = require(script.Parent.DecibelServer)
local Leaderstats = require(script.Parent.Leaderstats)
local GrannyAI = require(script.Parent.GrannyAI)
local NightServer = require(script.Parent.NightServer)
local EventsServer = require(script.Parent.EventsServer)
local Economy = require(script.Parent.Economy)
local Purchases = require(script.Parent.Purchases)
local AntiCheat = require(script.Parent.AntiCheat)

-- === Initialize in order ===
LOG.log("MANOR", "Generating manor...")
Prefabs.init() -- Generates the manor

LOG.log("DB", "Initializing decibel system...")
DecibelServer.init()

LOG.log("EVENTS", "Initializing events system...")
EventsServer.init()

LOG.log("DB", "Initializing leaderstats...")
Leaderstats.init()

LOG.log("IAP", "Initializing economy...")
Economy.init()

LOG.log("IAP", "Initializing purchases...")
Purchases.init()

LOG.log("DB", "Initializing anti-cheat...")
AntiCheat.init()

-- === Setup atmosphere ===
LOG.log("MANOR", "Setting up atmosphere...")
Lighting.Ambient = Color3.fromRGB(10, 10, 20)
Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 20)
Lighting.Brightness = 0.3
Lighting.ClockTime = 0 -- Midnight
Lighting.FogEnd = 100
Lighting.FogColor = Color3.fromRGB(20, 20, 30)

-- Add atmosphere
local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.4
atmosphere.Offset = 0.5
atmosphere.Color = Color3.fromRGB(150, 150, 180)
atmosphere.Decay = Color3.fromRGB(100, 100, 120)
atmosphere.Glare = 0.2
atmosphere.Haze = 1
atmosphere.Parent = Lighting

-- === Initialize Granny ===
LOG.log("GRANNY", "Spawning Granny...")
GrannyAI.init()

-- === Start night system ===
task.delay(3, function()
	LOG.log("NIGHT", "Starting Night 1...")
	NightServer.init()
	NightServer.startNight(1)
end)

-- === Player setup ===
Players.PlayerAdded:Connect(function(plr)
	LOG.log("NIGHT", "Player joined:", plr.Name)
	
	-- Give player a flashlight
	plr.CharacterAdded:Connect(function(character)
		task.wait(1) -- Wait for character to load
		
		-- Add flashlight tool
		local flashlight = Instance.new("Tool")
		flashlight.Name = "Flashlight"
		flashlight.RequiresHandle = true
		
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(0.5, 1, 2)
		handle.Material = Enum.Material.Plastic
		handle.Color = Color3.fromRGB(50, 50, 50)
		handle.Parent = flashlight
		
		local light = Instance.new("SpotLight")
		light.Brightness = 5
		light.Range = 40
		light.Angle = 45
		light.Face = Enum.NormalId.Front
		light.Shadows = true
		light.Color = Color3.fromRGB(255, 240, 200)
		light.Parent = handle
		
		flashlight.Parent = plr:WaitForChild("Backpack")
	end)
end)

print("[SERVER] ? Init complete! Manor generated, Granny sleeping, ready to play!")
print("[SERVER] ???  Explore the manor, complete tasks, survive the night!")
