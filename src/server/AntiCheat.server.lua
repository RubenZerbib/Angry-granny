--!strict
-- Syst?me anti-triche pour valider les actions des joueurs

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local EventsServer = require(ServerScriptService.Server.EventsServer)

local PlayerAction = ReplicatedStorage.Remotes.PlayerAction

local AntiCheat = {}

-- Cooldowns par joueur
local cooldowns: { [Player]: { [string]: number } } = {}

function AntiCheat.init()
	-- Intercepter les actions des joueurs
	PlayerAction.OnServerEvent:Connect(function(player, action: string, data: any)
		if not validateAction(player, action, data) then
			warn("[AntiCheat] Action rejet?e pour " .. player.Name .. " : " .. action)
			return
		end

		-- Traiter l'action
		handleAction(player, action, data)
	end)
end

function validateAction(player: Player, action: string, data: any): boolean
	-- V?rifier cooldown global
	if not cooldowns[player] then
		cooldowns[player] = {}
	end

	local now = tick()
	local lastAction = cooldowns[player][action] or 0
	local cooldownMs = Config.Ratelimits[action] or Config.Interaction.CooldownMs

	if (now - lastAction) * 1000 < cooldownMs then
		return false
	end

	-- V?rifier selon le type d'action
	if action == "Interact" then
		return validateInteraction(player, data)
	elseif action == "Purchase" then
		return true -- Valid? dans Purchases.server.lua
	end

	return true
end

function validateInteraction(player: Player, data: any): boolean
	local eventId = data.eventId
	if not eventId then
		return false
	end

	local activeEvents = EventsServer.getActiveEvents()
	local targetEvent = nil

	for _, event in ipairs(activeEvents) do
		if event.id == eventId then
			targetEvent = event
			break
		end
	end

	if not targetEvent then
		return false
	end

	-- V?rifier distance
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return false
	end

	local playerPos = player.Character.HumanoidRootPart.Position
	local distance = Util.distanceTo(playerPos, targetEvent.position)

	if distance > Config.Interaction.MaxDistance then
		return false
	end

	-- V?rifier line of sight si requis
	if Config.Interaction.RequireLineOfSight then
		local hasLOS = Util.lineOfSight(playerPos, targetEvent.position, { player.Character })
		if not hasLOS then
			return false
		end
	end

	return true
end

function handleAction(player: Player, action: string, data: any)
	-- Enregistrer cooldown
	cooldowns[player][action] = tick()

	-- Traiter l'action
	if action == "Interact" then
		EventsServer.tryResolve(data.eventId, player)
	end
end

return AntiCheat
