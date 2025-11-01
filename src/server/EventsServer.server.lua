--!strict
-- Serveur de gestion des ?v?nements dynamiques

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local EventRegistry = require(ReplicatedStorage.Shared.EventRegistry)
local DecibelServer = require(ServerScriptService.Server.DecibelServer)
local Prefabs = require(ServerScriptService.Server.Prefabs)
local Leaderstats = require(ServerScriptService.Server.Leaderstats)

local EventSpawn = ReplicatedStorage.Remotes.EventSpawn
local Reward = ReplicatedStorage.Remotes.Reward

local EventsServer = {}

-- ?tat des ?v?nements actifs
local activeEvents: {
	[string]: {
		id: string,
		spec: EventRegistry.EventSpec,
		spawnTime: number,
		prefabInstance: Instance?,
		resolved: boolean,
		currentStep: number,
	},
} = {}

local nextEventId = 1

function EventsServer.init()
	-- Boucle de mise ? jour des ?v?nements
	RunService.Heartbeat:Connect(function(dt)
		updateEvents(dt)
	end)
end

function EventsServer.spawn(spec: EventRegistry.EventSpec): string
	local eventId = "event_" .. tostring(nextEventId)
	nextEventId = nextEventId + 1

	-- Cr?er le prefab
	local prefabInstance = Prefabs.createForEvent(spec)
	if not prefabInstance then
		warn("[EventsServer] ?chec de cr?ation du prefab pour " .. spec.id)
		return ""
	end

	activeEvents[eventId] = {
		id = eventId,
		spec = spec,
		spawnTime = tick(),
		prefabInstance = prefabInstance,
		resolved = false,
		currentStep = 0,
	}

	-- Pulse initial si d?fini
	if spec.dbPulse then
		local position = prefabInstance:IsA("Model") and prefabInstance:GetPivot().Position
			or prefabInstance:IsA("BasePart") and prefabInstance.Position
			or nil

		DecibelServer.add(spec.id, spec.dbPulse, {
			clamp = true,
			position = position,
		})
	end

	-- Notifier clients
	EventSpawn:FireAllClients({
		eventId = eventId,
		eventName = spec.name,
		position = if prefabInstance:IsA("Model")
			then prefabInstance:GetPivot().Position
			elseif prefabInstance:IsA("BasePart") then prefabInstance.Position
			else Vector3.zero,
		resolveTime = spec.resolveTimeSec,
	})

	return eventId
end

function updateEvents(dt: number)
	for eventId, event in pairs(activeEvents) do
		if event.resolved then
			continue
		end

		local elapsed = tick() - event.spawnTime

		-- Appliquer dbTickPerSec
		if event.spec.dbTickPerSec then
			local position = if event.prefabInstance and event.prefabInstance:IsA("Model")
				then event.prefabInstance:GetPivot().Position
				elseif event.prefabInstance and event.prefabInstance:IsA("BasePart") then event.prefabInstance.Position
				else nil

			DecibelServer.add(event.spec.id, event.spec.dbTickPerSec * dt, {
				clamp = true,
				position = position,
			})
		end

		-- V?rifier timeout (?chec)
		if event.spec.resolveTimeSec and elapsed > event.spec.resolveTimeSec then
			EventsServer.fail(eventId)
		end
	end
end

function EventsServer.resolve(eventId: string, player: Player?): boolean
	local event = activeEvents[eventId]
	if not event or event.resolved then
		return false
	end

	-- Incr?menter l'?tape
	event.currentStep = event.currentStep + 1

	-- V?rifier si r?solu compl?tement
	local stepsRequired = event.spec.resolveSteps or 1
	if event.currentStep >= stepsRequired then
		event.resolved = true

		-- Retirer le prefab
		if event.prefabInstance then
			event.prefabInstance:Destroy()
		end

		-- R?compense
		if player then
			Leaderstats.addCoins(player, 5)
			Reward:FireClient(player, {
				type = "event_resolved",
				coins = 5,
				eventName = event.spec.name,
			})
		end

		-- Nettoyer
		task.delay(1, function()
			activeEvents[eventId] = nil
		end)

		return true
	end

	return false
end

function EventsServer.fail(eventId: string): boolean
	local event = activeEvents[eventId]
	if not event or event.resolved then
		return false
	end

	event.resolved = true

	-- Burst de d?cibels
	if event.spec.failDbBurst then
		local position = if event.prefabInstance and event.prefabInstance:IsA("Model")
			then event.prefabInstance:GetPivot().Position
			elseif event.prefabInstance and event.prefabInstance:IsA("BasePart") then event.prefabInstance.Position
			else nil

		DecibelServer.add(event.spec.id .. "_fail", event.spec.failDbBurst, {
			clamp = true,
			position = position,
		})
	end

	-- Retirer le prefab
	if event.prefabInstance then
		event.prefabInstance:Destroy()
	end

	-- Nettoyer
	task.delay(1, function()
		activeEvents[eventId] = nil
	end)

	return true
end

function EventsServer.getActiveCount(): number
	local count = 0
	for _, event in pairs(activeEvents) do
		if not event.resolved then
			count = count + 1
		end
	end
	return count
end

function EventsServer.getActiveEvents(): {
	{
		id: string,
		name: string,
		position: Vector3,
		timeRemaining: number?,
		dbProjection: number,
	}
}
	local result = {}

	for eventId, event in pairs(activeEvents) do
		if not event.resolved then
			local position = if event.prefabInstance and event.prefabInstance:IsA("Model")
				then event.prefabInstance:GetPivot().Position
				elseif event.prefabInstance and event.prefabInstance:IsA("BasePart") then event.prefabInstance.Position
				else Vector3.zero

			local timeRemaining = nil
			if event.spec.resolveTimeSec then
				local elapsed = tick() - event.spawnTime
				timeRemaining = math.max(0, event.spec.resolveTimeSec - elapsed)
			end

			-- Calculer projection dB (estimation sur 20s)
			local dbProjection = 0
			if event.spec.dbTickPerSec then
				dbProjection = event.spec.dbTickPerSec * 20
			elseif event.spec.dbPulse then
				dbProjection = event.spec.dbPulse * 0.5
			end

			table.insert(result, {
				id = eventId,
				name = event.spec.name,
				position = position,
				timeRemaining = timeRemaining,
				dbProjection = dbProjection,
			})
		end
	end

	return result
end

function EventsServer.clearAll(): ()
	for _, event in pairs(activeEvents) do
		if event.prefabInstance then
			event.prefabInstance:Destroy()
		end
	end
	activeEvents = {}
end

function EventsServer.tryResolve(eventId: string, player: Player): boolean
	return EventsServer.resolve(eventId, player)
end

return EventsServer
