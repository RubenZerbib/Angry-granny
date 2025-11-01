--!strict
-- Gestion des effets des items et de l'?conomie

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ItemCatalog = require(ReplicatedStorage.Shared.ItemCatalog)
local DecibelServer = require(ServerScriptService.Server.DecibelServer)

local Economy = {}

-- Effets actifs par joueur
local activeEffects: {
	[Player]: {
		[string]: {
			expiresAt: number,
			params: any,
		},
	},
} = {}

function Economy.init()
	Players.PlayerAdded:Connect(function(player)
		activeEffects[player] = {}
	end)

	Players.PlayerRemoving:Connect(function(player)
		activeEffects[player] = nil
	end)

	-- Boucle de mise ? jour des effets
	RunService.Heartbeat:Connect(function()
		updateEffects()
	end)
end

function updateEffects()
	local now = tick()

	for player, effects in pairs(activeEffects) do
		for effectId, data in pairs(effects) do
			if now >= data.expiresAt then
				-- Expirer l'effet
				effects[effectId] = nil
			else
				-- Appliquer les effets continus
				applyEffect(player, effectId, data.params)
			end
		end
	end
end

function Economy.activateItem(player: Player, itemId: string): boolean
	local item = ItemCatalog.getById(itemId)
	if not item then
		return false
	end

	if not activeEffects[player] then
		activeEffects[player] = {}
	end

	-- Calculer expiration
	local expiresAt = tick() + (item.durationSec or 0)

	activeEffects[player][item.effectId] = {
		expiresAt = expiresAt,
		params = {
			itemId = itemId,
			effectId = item.effectId,
		},
	}

	return true
end

function applyEffect(player: Player, effectId: string, params: any)
	-- Impl?mentation des 30 effets
	if effectId == "step_noise_reduce" or effectId == "step_noise_boost" or effectId == "step_training" then
		-- Modifier le multiplicateur de bruit de pas
		applyStepNoiseMultiplier(player, effectId)
	elseif effectId == "granny_sensitivity_reduce" or effectId == "granny_slowdown" then
		-- Modifier la sensibilit? ou la vitesse de Granny
		applyGrannyModifier(effectId)
	elseif effectId == "db_tick_negative" or effectId == "db_mask" or effectId == "db_burst_negative" then
		-- R?duction des d?cibels
		applyDecibelReduction(effectId)
	elseif
		effectId == "door_noise_reduce"
		or effectId == "wall_noise_reduce"
		or effectId == "window_noise_reduce"
		or effectId == "furniture_noise_reduce"
		or effectId == "door_seal"
		or effectId == "area_silence"
		or effectId == "entrance_silence"
		or effectId == "object_stabilize"
		or effectId == "door_silent_permanent"
		or effectId == "furniture_pads"
		or effectId == "wire_stabilize"
		or effectId == "step_dampening"
	then
		-- R?ductions structurelles (passives)
		-- Impl?ment?es via tags sur les structures
	elseif
		effectId == "event_resolve_clock"
		or effectId == "event_resolve_baby"
		or effectId == "event_resolve_neighbor"
		or effectId == "event_resolve_cat"
		or effectId == "event_resolve_rat"
		or effectId == "event_resolve_grandfather_clock"
		or effectId == "clock_immunity"
	then
		-- R?solution automatique d'?v?nements
		-- G?r? par EventsServer lors de la v?rification des ?v?nements
	elseif effectId == "player_audio_filter" or effectId == "vision_enhance" then
		-- Effets client-side (sons/visuel)
	elseif effectId == "repair_speed" then
		-- Acc?l?ration de r?solution
	end
end

function applyStepNoiseMultiplier(player: Player, effectId: string)
	if not player.Character then
		return
	end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	-- ?couter les mouvements
	local lastPosition = if player.Character:FindFirstChild("HumanoidRootPart")
		then player.Character.HumanoidRootPart.Position
		else nil

	if lastPosition then
		local currentPosition = player.Character.HumanoidRootPart.Position
		local distance = (currentPosition - lastPosition).Magnitude

		if distance > 0.1 then
			-- Calculer le bruit
			local baseNoise = 0.5 * distance
			local multiplier = 1.0

			if effectId == "step_noise_reduce" then
				multiplier = 0.5
			elseif effectId == "step_noise_boost" then
				multiplier = 0.3
			elseif effectId == "step_training" then
				multiplier = 0.6
			end

			local noise = baseNoise * multiplier
			DecibelServer.add("player_step", noise, {
				clamp = true,
				position = currentPosition,
			})
		end
	end
end

function applyGrannyModifier(effectId: string)
	-- Modifie les param?tres de Granny (? impl?menter dans GrannyAI)
	-- Pour l'instant, placeholder
end

function applyDecibelReduction(effectId: string)
	if effectId == "db_tick_negative" then
		DecibelServer.add("radio_lullaby", -1, { clamp = true })
	elseif effectId == "db_mask" then
		DecibelServer.add("white_noise", -0.8, { clamp = true })
	elseif effectId == "db_burst_negative" then
		DecibelServer.add("panic_button", -20, { clamp = true })
	end
end

function Economy.getActiveEffects(player: Player): { string }
	if not activeEffects[player] then
		return {}
	end

	local result = {}
	for effectId, data in pairs(activeEffects[player]) do
		table.insert(result, effectId)
	end
	return result
end

function Economy.getEffectTimeRemaining(player: Player, effectId: string): number?
	if not activeEffects[player] or not activeEffects[player][effectId] then
		return nil
	end

	local remaining = activeEffects[player][effectId].expiresAt - tick()
	return math.max(0, remaining)
end

return Economy
