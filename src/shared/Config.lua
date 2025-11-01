--!strict
-- Configuration centrale pour tous les param?tres du jeu

return {
	-- Boucle de jeu
	UIRateHz = 10, -- fr?quence des updates HUD
	NightStartIndex = 1,
	NightBase = {
		DurationSec = 210, -- dur?e nuit 1
		ThresholdDb = 70, -- seuil r?veil nuit 1
		DecayPerSecond = 4, -- baisse dB par seconde nuit 1
		MaxConcurrent = 1,
		EventBudget = 3, -- nb d'?v?nements totaux max (s?quentiels/concurrents)
		RewardCoins = 25, -- r?compense base nuit 1
	},
	-- Courbes progressives (nuit n>=1)
	Curves = {
		ThresholdDb = function(n: number): number
			return math.max(48, 70 - (n - 1) * 2)
		end,
		DecayPerSecond = function(n: number): number
			return math.max(1.2, 4 - (n - 1) * 0.18)
		end,
		GrannySpeed = function(n: number): number
			return 9 + (n - 1) * 1.1
		end,
		MaxConcurrent = function(n: number): number
			return math.min(5, 1 + math.floor(n / 2))
		end,
		EventBudget = function(n: number): number
			return 3 + math.floor(n / 1.3)
		end,
		DurationSec = function(n: number): number
			return math.min(360, 210 + (n - 1) * 10)
		end,
		RewardCoins = function(n: number): number
			return 25 + (n - 1) * 5
		end,
	},
	-- Pond?rations g?n?riques d'?v?nements par tiers de difficult?
	EventWeightsByTier = { [1] = 4, [2] = 3, [3] = 2, [4] = 1, [5] = 1 },
	-- Ratelimits remotes (ms)
	Ratelimits = {
		PlayerAction = 120,
		Purchase = 500,
		Interact = 120,
	},
	-- Anti-cheat
	Interaction = {
		MaxDistance = 16,
		RequireLineOfSight = true,
		CooldownMs = 250,
	},
}
