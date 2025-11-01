--!strict
-- Server-side event spawning and management with interactive prefabs

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local EventRegistry = require(ReplicatedStorage.Shared.EventRegistry)
local NightDirector = require(ReplicatedStorage.Shared.NightDirector)
local Prefabs = require(ServerScriptService.Server.Prefabs)

local EventSpawnRemote = ReplicatedStorage.Remotes.EventSpawn
local PlayerActionRemote = ReplicatedStorage.Remotes.PlayerAction
local RewardRemote = ReplicatedStorage.Remotes.Reward

local EventsServer = {}

local currentNight = 1
local activeEvents: {[string]: {spec: EventRegistry.EventSpec, instance: Instance?, startTime: number}} = {}
local playerEventProgress: {[Player]: {[string]: boolean}} = {}

function EventsServer.init()
	-- Listen to player interactions
	PlayerActionRemote.OnServerEvent:Connect(handlePlayerAction)
	print("[EventsServer] Initialized with", #EventRegistry.getAllEvents(), "event types")
end

function EventsServer.startNight(nightNumber: number)
	currentNight = nightNumber
	local params = NightDirector.getParamsForNight(nightNumber)
	
	print(string.format("[EventsServer] Starting night %d - Budget: %d, MaxConcurrent: %d", 
		nightNumber, params.eventBudget, params.maxConcurrentEvents))
	
	-- Clear previous events
	clearAllEvents()
	
	-- Spawn initial events based on budget
	spawnEvents(params)
end

function spawnEvents(params)
	local spawnedCount = 0
	local attempts = 0
	local maxAttempts = params.eventBudget * 3
	
	while spawnedCount < math.min(params.eventBudget, params.maxConcurrentEvents) and attempts < maxAttempts do
		attempts += 1
		
		-- Pick random event appropriate for this night
		local event = EventRegistry.getRandomEventForNight(currentNight)
		
		if event and not activeEvents[event.id] then
			local success = spawnEvent(event)
			if success then
				spawnedCount += 1
				print(string.format("[EventsServer] Spawned event: %s (%d/%d)", 
					event.name, spawnedCount, params.maxConcurrentEvents))
			end
		end
	end
	
	print(string.format("[EventsServer] Spawned %d events", spawnedCount))
end

function spawnEvent(spec: EventRegistry.EventSpec): boolean
	-- Create the interactive prefab
	local prefabInstance = Prefabs.createForEvent(spec)
	
	if not prefabInstance then
		warn("[EventsServer] Failed to create prefab for", spec.id)
		return false
	end
	
	-- Track active event
	activeEvents[spec.id] = {
		spec = spec,
		instance = prefabInstance,
		startTime = tick()
	}
	
	-- Notify clients
	EventSpawnRemote:FireAllClients({
		eventId = spec.id,
		eventName = spec.name,
		position = prefabInstance:GetPivot().Position,
		dbPerSecond = spec.dbPulse
	})
	
	-- Schedule timeout/auto-fail
	task.delay(spec.resolveTimeSec, function()
		if activeEvents[spec.id] and not activeEvents[spec.id].completed then
			failEvent(spec.id)
		end
	end)
	
	return true
end

function handlePlayerAction(player: Player, data: {action: string, eventId: string?, eventType: string?, position: Vector3?})
	if data.action ~= "interact" then return end
	
	local eventId = data.eventId or data.eventType
	if not eventId then return end
	
	local eventData = activeEvents[eventId]
	if not eventData then
		warn("[EventsServer] Event not found:", eventId)
		return
	end
	
	-- Validate distance (anti-cheat)
	if data.position and eventData.instance then
		local distance = (data.position - eventData.instance:GetPivot().Position).Magnitude
		if distance > 20 then
			warn("[EventsServer] Player too far from event:", player.Name, distance)
			return
		end
	end
	
	-- Mark as completed
	resolveEvent(eventId, player)
end

function resolveEvent(eventId: string, player: Player)
	local eventData = activeEvents[eventId]
	if not eventData then return end
	
	eventData.completed = true
	
	-- Mark object as completed
	if eventData.instance then
		eventData.instance:SetAttribute("Completed", true)
		
		-- Disable proximity prompt
		local prompt = eventData.instance:FindFirstChildOfClass("ProximityPrompt", true)
		if prompt then
			prompt.Enabled = false
		end
		
		-- Visual feedback
		if eventData.instance:IsA("Model") then
			for _, part in ipairs(eventData.instance:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Color = Color3.fromRGB(100, 255, 100)
				end
			end
		end
		
		-- Remove after delay
		task.delay(3, function()
			if eventData.instance and eventData.instance.Parent then
				eventData.instance:Destroy()
			end
		end)
	end
	
	-- Award coins
	local coinsEarned = 5
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins and coins:IsA("IntValue") then
			coins.Value += coinsEarned
		end
	end
	
	-- Notify player
	RewardRemote:FireClient(player, {
		type = "event_resolved",
		eventName = eventData.spec.name,
		coins = coinsEarned
	})
	
	print(string.format("[EventsServer] Player %s resolved: %s (+%d coins)", 
		player.Name, eventData.spec.name, coinsEarned))
	
	-- Remove from active events
	activeEvents[eventId] = nil
	
	-- Spawn new event to maintain budget
	local params = NightDirector.getParamsForNight(currentNight)
	if countActiveEvents() < params.maxConcurrentEvents then
		local newEvent = EventRegistry.getRandomEventForNight(currentNight)
		if newEvent and not activeEvents[newEvent.id] then
			task.delay(2, function()
				spawnEvent(newEvent)
			end)
		end
	end
end

function failEvent(eventId: string)
	local eventData = activeEvents[eventId]
	if not eventData then return end
	
	print("[EventsServer] Event timed out:", eventData.spec.name)
	
	-- Clean up
	if eventData.instance and eventData.instance.Parent then
		eventData.instance:Destroy()
	end
	
	activeEvents[eventId] = nil
	
	-- Could trigger consequences here (e.g., wake Granny)
end

function clearAllEvents()
	for eventId, eventData in pairs(activeEvents) do
		if eventData.instance and eventData.instance.Parent then
			eventData.instance:Destroy()
		end
	end
	activeEvents = {}
end

function countActiveEvents(): number
	local count = 0
	for _ in pairs(activeEvents) do
		count += 1
	end
	return count
end

function EventsServer.getActiveEvents()
	return activeEvents
end

function EventsServer.cleanup()
	clearAllEvents()
end

return EventsServer
