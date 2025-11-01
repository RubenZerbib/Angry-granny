--!strict
-- Point d'entr?e serveur : initialise tous les syst?mes

local ServerScriptService = game:GetService("ServerScriptService")

local DecibelServer = require(ServerScriptService.Server.DecibelServer)
local NightServer = require(ServerScriptService.Server.NightServer)
local GrannyAI = require(ServerScriptService.Server.GrannyAI)
local EventsServer = require(ServerScriptService.Server.EventsServer)
local Economy = require(ServerScriptService.Server.Economy)
local Purchases = require(ServerScriptService.Server.Purchases)
local Leaderstats = require(ServerScriptService.Server.Leaderstats)
local Prefabs = require(ServerScriptService.Server.Prefabs)
local AntiCheat = require(ServerScriptService.Server.AntiCheat)

print("[Server] Initialisation des syst?mes...")

-- Initialiser les syst?mes dans l'ordre
Prefabs.init()
DecibelServer.init()
Leaderstats.init()
Economy.init()
Purchases.init()
EventsServer.init()
GrannyAI.init()
NightServer.init()
AntiCheat.init()

print("[Server] Tous les syst?mes initialis?s")

-- D?marrer la premi?re nuit apr?s un d?lai
task.wait(3)
NightServer.startNight(1)
print("[Server] Nuit 1 d?marr?e")
