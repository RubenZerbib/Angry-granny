--!strict
-- Directeur de nuit : calcule les param?tres pour une nuit donn?e

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local NightDirector = {}

export type NightParams = {
	night: number,
	durationSec: number,
	thresholdDb: number,
	decayPerSecond: number,
	grannySpeed: number,
	maxConcurrent: number,
	eventBudget: number,
	rewardCoins: number,
}

function NightDirector.getParams(night: number): NightParams
	local curves = Config.Curves

	return {
		night = night,
		durationSec = curves.DurationSec(night),
		thresholdDb = curves.ThresholdDb(night),
		decayPerSecond = curves.DecayPerSecond(night),
		grannySpeed = curves.GrannySpeed(night),
		maxConcurrent = curves.MaxConcurrent(night),
		eventBudget = curves.EventBudget(night),
		rewardCoins = curves.RewardCoins(night),
	}
end

return NightDirector
