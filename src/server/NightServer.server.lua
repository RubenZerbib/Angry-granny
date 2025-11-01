--!strict
-- Serveur de gestion des nuits

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NightDirector = require(ReplicatedStorage.Shared.NightDirector)
local EventRegistry = require(ReplicatedStorage.Shared.EventRegistry)
local Config = require(ReplicatedStorage.Shared.Config)

local DecibelServer = require(ServerScriptService.Server.DecibelServer)
local EventsServer = require(ServerScriptService.Server.EventsServer)
local GrannyAI = require(ServerScriptService.Server.GrannyAI)
local Leaderstats = require(ServerScriptService.Server.Leaderstats)

local NightUpdate = ReplicatedStorage.Remotes.NightUpdate

local NightServer = {}

-- ?tat
local currentNight = Config.NightStartIndex
local nightActive = false
local nightStartTime = 0
local nightParams: NightDirector.NightParams? = nil
local eventScheduleTimer: thread?

function NightServer.init()
	-- Configurer callback de r?veil
	DecibelServer.onWakeRequested(function(db)
		if nightActive and GrannyAI.getState() == "Sleeping" then
			GrannyAI.wake()
		end
	end)
end

function NightServer.startNight(night: number): ()
	currentNight = night
	nightParams = NightDirector.getParams(night)

	-- R?initialiser syst?mes
	DecibelServer.reset()
	DecibelServer.setThreshold(nightParams.thresholdDb)
	DecibelServer.setDecay(nightParams.decayPerSecond)
	GrannyAI.reset(nightParams.grannySpeed)
	EventsServer.clearAll()

	nightActive = true
	nightStartTime = tick()

	-- Notifier clients
	NightUpdate:FireAllClients({
		night = night,
		phase = "start",
		duration = nightParams.durationSec,
		threshold = nightParams.thresholdDb,
	})

	-- D?marrer le scheduler d'?v?nements
	task.spawn(function()
		scheduleEvents(nightParams)
	end)

	-- Timer de fin de nuit
	task.delay(nightParams.durationSec, function()
		if nightActive then
			NightServer.endNight(true)
		end
	end)
end

function NightServer.endNight(victory: boolean): ()
	if not nightActive then
		return
	end

	nightActive = false
	EventsServer.clearAll()

	if victory and nightParams then
		-- Distribuer r?compenses
		for _, player in ipairs(game.Players:GetPlayers()) do
			Leaderstats.addCoins(player, nightParams.rewardCoins)
		end

		NightUpdate:FireAllClients({
			night = currentNight,
			phase = "victory",
			reward = nightParams.rewardCoins,
		})

		-- Pr?parer la nuit suivante
		task.wait(5)
		NightServer.startNight(currentNight + 1)
	else
		NightUpdate:FireAllClients({
			night = currentNight,
			phase = "defeat",
		})

		-- Recommencer la m?me nuit
		task.wait(5)
		NightServer.startNight(currentNight)
	end
end

function scheduleEvents(params: NightDirector.NightParams): ()
	local eligible = EventRegistry.getForNight(params.night, Config.EventWeightsByTier)
	local selected = EventRegistry.selectWeighted(eligible, params.eventBudget, Config.EventWeightsByTier)

	local eventDelay = params.durationSec / (#selected + 1)

	for i, eventSpec in ipairs(selected) do
		task.wait(eventDelay)

		if nightActive then
			-- V?rifier nombre d'?v?nements concurrents
			local activeCount = EventsServer.getActiveCount()
			if activeCount < params.maxConcurrent then
				EventsServer.spawn(eventSpec)
			end
		end
	end
end

function NightServer.onWakeRequested(): ()
	-- Appel? par DecibelServer quand seuil d?pass?
	if nightActive and GrannyAI.getState() == "Sleeping" then
		GrannyAI.wake()
	end
end

function NightServer.getCurrentNight(): number
	return currentNight
end

function NightServer.isNightActive(): boolean
	return nightActive
end

return NightServer
