--!strict
-- Serveur de gestion des d?cibels

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Decibel = require(ReplicatedStorage.Shared.Decibel)
local Config = require(ReplicatedStorage.Shared.Config)

local DecibelUpdate = ReplicatedStorage.Remotes.DecibelUpdate

local DecibelServer = {}

-- ?tat global
local state: Decibel.DecibelState = Decibel.new()
local currentThreshold = Config.NightBase.ThresholdDb
local currentDecay = Config.NightBase.DecayPerSecond
local wakeCallback: ((number) -> ())?

local lastUpdateTime = tick()
local updateInterval = 1 / Config.UIRateHz

function DecibelServer.init()
	-- Boucle de mise ? jour
	RunService.Heartbeat:Connect(function(dt)
		Decibel.tick(state, dt, currentDecay)

		local now = tick()
		if now - lastUpdateTime >= updateInterval then
			-- Notifier tous les clients
			DecibelUpdate:FireAllClients(state.currentDb, currentThreshold, state.trend)
			lastUpdateTime = now

			-- V?rifier r?veil de Granny
			if state.currentDb >= currentThreshold and wakeCallback then
				wakeCallback(state.currentDb)
			end
		end
	end)
end

function DecibelServer.add(source: string, amount: number, opts: { clamp: boolean?, position: Vector3? }?): ()
	Decibel.add(state, source, amount, opts)
end

function DecibelServer.setThreshold(threshold: number): ()
	currentThreshold = threshold
end

function DecibelServer.setDecay(decay: number): ()
	currentDecay = decay
end

function DecibelServer.reset(): ()
	state = Decibel.new()
end

function DecibelServer.getCurrent(): number
	return state.currentDb
end

function DecibelServer.getTopHotspots(count: number): { Decibel.Hotspot }
	return Decibel.getTopHotspots(state, count)
end

function DecibelServer.onWakeRequested(callback: (number) -> ()): ()
	wakeCallback = callback
end

return DecibelServer
