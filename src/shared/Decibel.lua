--!strict
-- Syst?me de gestion des d?cibels c?t? partag? (logique commune)

local Decibel = {}
Decibel.__index = Decibel

export type Hotspot = {
	source: string,
	position: Vector3?,
	weight: number,
	timestamp: number,
}

export type DecibelState = {
	currentDb: number,
	trend: number,
	hotspots: { Hotspot },
	lastUpdateTime: number,
}

function Decibel.new(): DecibelState
	return {
		currentDb = 0,
		trend = 0,
		hotspots = {},
		lastUpdateTime = tick(),
	}
end

function Decibel.add(
	state: DecibelState,
	source: string,
	amount: number,
	opts: { clamp: boolean?, position: Vector3? }?
): ()
	opts = opts or {}
	local clamp = if opts.clamp ~= nil then opts.clamp else true

	state.currentDb = state.currentDb + amount

	if clamp then
		state.currentDb = math.clamp(state.currentDb, 0, 100)
	end

	-- Ajouter hotspot si position fournie
	if opts.position then
		table.insert(state.hotspots, {
			source = source,
			position = opts.position,
			weight = amount,
			timestamp = tick(),
		})
	end
end

function Decibel.tick(state: DecibelState, dt: number, decayPerSecond: number): ()
	local oldDb = state.currentDb
	state.currentDb = math.max(0, state.currentDb - decayPerSecond * dt)
	state.currentDb = math.clamp(state.currentDb, 0, 100)

	-- Calculer tendance
	state.trend = state.currentDb - oldDb

	-- Nettoyer les hotspots anciens (> 5s)
	local now = tick()
	local filtered = {}
	for _, hotspot in ipairs(state.hotspots) do
		if now - hotspot.timestamp < 5 then
			table.insert(filtered, hotspot)
		end
	end
	state.hotspots = filtered

	state.lastUpdateTime = now
end

function Decibel.getTopHotspots(state: DecibelState, count: number): { Hotspot }
	local sorted = table.clone(state.hotspots)
	table.sort(sorted, function(a, b)
		return a.weight > b.weight
	end)

	local result = {}
	for i = 1, math.min(count, #sorted) do
		table.insert(result, sorted[i])
	end
	return result
end

return Decibel
